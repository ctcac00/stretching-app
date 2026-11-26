'use strict';

const $ = (s, el = document) => el.querySelector(s);
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);
const uid = () => Date.now().toString(36) + Math.random().toString(36).slice(2, 7);
const today = () => new Date().toLocaleDateString('sv');
const KEY = 'limbloop-proto-v1';
const MAX_PENDING = 64;
const SWITCH_SECONDS = 5;
const DEFAULT_SECONDS = 60;

let library = [];
let state;
let tab = 'today';
const filters = { q: '', muscle: '', equipment: '' };
let sideBySide = false;
const selected = new Set();

function defaults() {
  const pick = (name, seconds, sides) => {
    const e = library.find((x) => x.name.toLowerCase().includes(name));
    return e && { id: uid(), exerciseId: e.id, mode: 'time', value: seconds, sides };
  };
  const routine = [
    pick('hamstring', DEFAULT_SECONDS, 'lr'),
    pick('calf', DEFAULT_SECONDS, 'lr'),
    pick('shoulder', DEFAULT_SECONDS, 'lr'),
    pick('child', DEFAULT_SECONDS, 'single'),
  ].filter(Boolean);
  return {
    routine,
    custom: [],
    reminders: [{ id: uid(), type: 'interval', every: 120, from: '09:00', to: '18:00', times: [], items: null, enabled: true }],
    sessions: [],
    settings: { sound: true, haptics: true, theme: 'auto' },
    permission: null,
  };
}

function save() {
  try {
    localStorage.setItem(KEY, JSON.stringify(state));
  } catch {
    alert('Could not save. Browser storage is full or blocked.');
  }
}

const exercise = (id) => state.custom.find((e) => e.id === id) || library.find((e) => e.id === id);
const images = (e) => (e.custom ? (e.photo ? [e.photo] : []) : e.images.map((p) => `data/images/${p}`));
const thumb = (e) => (images(e)[0] ? `<img loading="lazy" src="${esc(images(e)[0])}" alt="">` : '<span class="thumb">✎</span>');
const describe = (r) => `${r.value}${r.mode === 'time' ? ' s' : ' reps'}${r.sides === 'lr' ? ' · left + right' : ''}`;

/* ---------- reminders logic ---------- */

const toMinutes = (t) => Number(t.slice(0, 2)) * 60 + Number(t.slice(3));
const toTime = (m) => `${String(Math.floor(m / 60)).padStart(2, '0')}:${String(m % 60).padStart(2, '0')}`;

function timesOf(r) {
  if (r.type === 'times') return [...r.times].sort();
  const out = [];
  for (let m = toMinutes(r.from); m <= toMinutes(r.to); m += r.every) out.push(toTime(m));
  return out;
}

const pendingCount = (reminders) => new Set(reminders.filter((r) => r.enabled).flatMap(timesOf)).size;

function nextReminder() {
  const now = new Date().toTimeString().slice(0, 5);
  const all = state.reminders.filter((r) => r.enabled)
    .flatMap((r) => timesOf(r).map((time) => ({ time, r })))
    .sort((a, b) => a.time.localeCompare(b.time));
  return all.find((x) => x.time > now) || all[0];
}

const doneToday = () => new Set(state.sessions.filter((s) => s.date === today()).flatMap((s) => s.done));

// next undone exercises; "auto" spreads what is left over this session and the reminders still to come today
function nextUp() {
  const done = doneToday();
  const left = state.routine.filter((i) => !done.has(i.id));
  const now = new Date().toTimeString().slice(0, 5);
  const later = new Set(state.reminders.filter((r) => r.enabled).flatMap(timesOf).filter((t) => t > now)).size;
  return left.slice(0, state.settings.perSession || Math.ceil(left.length / (later + 1)));
}

// reminder.items: null = next up, 'all' = whole routine, array = chosen exercises
function itemsFor(r) {
  if (Array.isArray(r.items)) return state.routine.filter((i) => r.items.includes(i.id));
  return r.items === 'all' ? state.routine : nextUp();
}
const hasNothing = (r) => !state.routine.length || (Array.isArray(r.items) && !r.items.length);
const scopeLabel = (r) => (Array.isArray(r.items) ? `${itemsFor(r).length} chosen exercises` : r.items === 'all' ? 'Whole routine' : 'Next up');

/* ---------- screens ---------- */

const screens = {
  today() {
    const done = doneToday();
    const upNext = nextUp();
    const count = state.routine.filter((i) => done.has(i.id)).length;
    const total = state.routine.length;
    const pct = total ? Math.round((count / total) * 100) : 0;
    const next = nextReminder();
    const sessions = state.sessions.filter((s) => s.date === today());
    const picked = state.routine.filter((i) => selected.has(i.id)).length;
    return `<h1>Today</h1>
      <div class="ring" style="--p:${pct}"><div><strong>${pct}%</strong><span class="muted">${count} of ${total} done</span></div></div>
      <button class="primary wide" data-act="start" ${picked || upNext.length ? '' : 'disabled'}>${picked ? `Start ${picked} selected` : upNext.length ? `Start next ${upNext.length}` : total ? 'All done for today' : 'Routine is empty'}</button>
      ${upNext.length && !picked ? `<p class="muted" style="text-align:center">${upNext.map((i) => esc(exercise(i.exerciseId).name)).join(' · ')}</p>` : ''}
      <h3>STRETCHES PER SESSION</h3>
      <div class="row">${[0, 1, 2, 3].map((n) => `<button class="grow ${(state.settings.perSession || 0) === n ? 'on' : ''}" data-act="per" data-id="${n}">${n || 'Auto'}</button>`).join('')}</div>
      <p class="muted">Auto spreads what is left over today’s remaining reminders.</p>
      <h3>OR TAP TO PICK ONE OR MORE</h3>
      ${state.routine.map((r) => {
        const e = exercise(r.exerciseId);
        const on = selected.has(r.id);
        return `<button class="item ${on ? 'on' : ''}" data-act="select" data-id="${r.id}" aria-pressed="${on}">${thumb(e)}<span class="grow"><b>${esc(e.name)}</b><span class="muted">${describe(r)}${done.has(r.id) ? ' · ✓ done today' : ''}</span></span><span class="mark">${on ? '●' : '○'}</span></button>`;
      }).join('')}
      <button class="wide" data-act="start-all" ${total ? '' : 'disabled'}>Start whole routine</button>
      <button class="wide" data-act="mark-all" ${total && count < total ? '' : 'disabled'}>Mark routine done</button>
      <h3>NEXT REMINDER</h3>
      <div class="card">${next ? `<b>${next.time}</b> · ${scopeLabel(next.r)}
        <button class="wide" data-act="notify" data-id="${next.r.id}">Preview notification</button>` : 'None set.'}</div>
      <h3>SESSIONS TODAY</h3>
      ${sessions.length ? sessions.map((s) => `<div class="card">✓ ${esc(s.time)} · ${s.done.length} exercises</div>`).join('') : '<p class="muted">Nothing yet.</p>'}
      <h3>SETTINGS</h3>
      <div class="card">
        <label class="row"><span class="grow">Sound cue</span><input type="checkbox" data-setting="sound" ${state.settings.sound ? 'checked' : ''}></label>
        <label class="row" style="margin-top:14px"><span class="grow">Haptic cue <span class="muted">(not on iPhone browser)</span></span><input type="checkbox" data-setting="haptics" ${state.settings.haptics ? 'checked' : ''}></label>
        <h3>THEME</h3>
        <div class="row">${['auto', 'light', 'dark'].map((t) => `<button class="grow ${state.settings.theme === t ? 'on' : ''}" data-act="theme" data-id="${t}">${t}</button>`).join('')}</div>
        <button class="wide danger" data-act="reset">Reset demo data</button>
      </div>`;
  },

  library() {
    const all = [...state.custom, ...library];
    const options = (values, current, label) => `<option value="">${label}</option>` +
      values.map((v) => `<option ${v === current ? 'selected' : ''}>${esc(v)}</option>`).join('');
    const muscles = [...new Set(library.flatMap((e) => e.primaryMuscles))].sort();
    const equipment = [...new Set(library.map((e) => e.equipment || 'none'))].sort();
    return `<h1>Library</h1>
      <input type="search" id="q" placeholder="Search ${all.length} stretches" value="${esc(filters.q)}">
      <div class="row" style="margin:10px 0">
        <select data-filter="muscle">${options(muscles, filters.muscle, 'All muscles')}</select>
        <select data-filter="equipment">${options(equipment, filters.equipment, 'All equipment')}</select>
      </div>
      <button class="wide" data-act="new-custom" style="margin:0 0 12px">+ Custom exercise</button>
      <div id="results">${results()}</div>`;
  },

  routine() {
    return `<h1>Routine</h1>
      <p class="muted">Drag ⠿ to reorder. Tap to edit.</p>
      <div id="list">${state.routine.map((r) => {
        const e = exercise(r.exerciseId);
        return `<div class="card row" data-row="${r.id}" style="padding:8px">
          <span class="handle" aria-label="Drag to reorder">⠿</span>
          <button class="item grow" style="margin:0;border:0;padding:0" data-act="edit" data-id="${r.id}">${thumb(e)}<span><b>${esc(e.name)}</b><span class="muted">${describe(r)}</span></span></button>
        </div>`;
      }).join('') || '<p>Routine empty. Add stretches from the library.</p>'}</div>
      <button class="wide" data-act="tab" data-id="library">+ Add from library</button>`;
  },

  reminders() {
    const n = pendingCount(state.reminders);
    return `<h1>Reminders</h1>
      ${state.permission === false ? '<div class="card">Notifications are off. In the real app, enable them in iOS Settings.<button class="wide" data-act="allow">Allow (demo)</button></div>' : ''}
      <p class="muted">${n} of ${MAX_PENDING} iOS notification slots used</p>
      ${state.reminders.map((r) => `<div class="card">
        <div class="row"><button class="grow" style="border:0;text-align:left;padding:0" data-act="edit-reminder" data-id="${r.id}">
          <b>${r.type === 'interval' ? `Every ${r.every / 60} h, ${r.from}–${r.to}` : timesOf(r).join(', ')}</b><br>
          <span class="muted">${scopeLabel(r)}</span></button>
          <input type="checkbox" data-toggle="${r.id}" ${r.enabled ? 'checked' : ''} aria-label="Enabled"></div>
        <button class="wide" data-act="notify" data-id="${r.id}">Preview notification</button>
      </div>`).join('') || '<p>No reminders.</p>'}
      <button class="primary wide" data-act="new-reminder">+ Add reminder</button>`;
  },
};

function results() {
  const q = filters.q.trim().toLowerCase();
  const found = [...state.custom, ...library].filter((e) =>
    e.name.toLowerCase().includes(q) &&
    (!filters.muscle || e.primaryMuscles?.includes(filters.muscle)) &&
    (!filters.equipment || (!e.custom && (e.equipment || 'none') === filters.equipment)));
  return found.map((e) => `<button class="item" data-act="detail" data-id="${esc(e.id)}">${thumb(e)}
    <span><b>${esc(e.name)}</b><span class="muted">${e.custom ? 'custom' : esc([...e.primaryMuscles, e.equipment].filter(Boolean).join(' · '))}</span></span></button>`).join('') ||
    '<p class="muted">No matches.</p>';
}

function render() {
  $('#view').innerHTML = screens[tab]();
  document.querySelectorAll('#tabs button').forEach((b) => b.classList.toggle('on', b.dataset.tab === tab));
  if (state.settings.theme === 'auto') delete document.documentElement.dataset.theme;
  else document.documentElement.dataset.theme = state.settings.theme;
}

/* ---------- sheets ---------- */

function openSheet(html) {
  const scroll = $('#sheet > div')?.scrollTop || 0;
  $('#sheet').innerHTML = `<div>${html}<button class="wide" data-act="close">Close</button></div>`;
  $('#sheet').hidden = false;
  $('#sheet > div').scrollTop = scroll;
}
const closeSheet = () => { $('#sheet').hidden = true; $('#sheet').innerHTML = ''; };

function detail(id) {
  const e = exercise(id);
  const pics = images(e);
  const inRoutine = state.routine.filter((r) => r.exerciseId === id).length;
  openSheet(`<h2>${esc(e.name)}</h2>
    ${pics.length ? `<div class="pics ${pics.length > 1 ? (sideBySide ? 'side' : 'alt') : ''}">${pics.map((p) => `<img src="${esc(p)}" alt="">`).join('')}</div>` : ''}
    ${pics.length > 1 ? `<button class="wide" data-act="layout" data-id="${esc(id)}">${sideBySide ? 'Alternate images' : 'Show side by side'}</button>` : ''}
    ${e.custom ? `<p>${esc(e.notes) || '<span class="muted">No notes.</span>'}</p>` : `<p class="muted">${esc([e.level, e.equipment || 'no equipment', ...e.primaryMuscles].join(' · '))}</p><ol>${e.instructions.map((i) => `<li>${esc(i)}</li>`).join('')}</ol>`}
    <button class="primary wide" data-act="add" data-id="${esc(id)}">${inRoutine ? 'Add again to routine' : 'Add to routine'}</button>
    ${e.custom ? `<button class="wide danger" data-act="delete-custom" data-id="${esc(id)}">Delete exercise</button>` : ''}`);
}

let draft;

function editItem() {
  openSheet(`<h2>${esc(exercise(draft.exerciseId).name)}</h2>
    <h3>MEASURE</h3>
    <div class="row">${[['time', 'Duration'], ['reps', 'Reps']].map(([v, l]) => `<button class="grow ${draft.mode === v ? 'on' : ''}" data-act="mode" data-id="${v}">${l}</button>`).join('')}</div>
    <h3>${draft.mode === 'time' ? 'SECONDS' : 'REPS'}${draft.sides === 'lr' ? ' PER SIDE' : ''}</h3>
    <div class="row"><button data-act="step" data-id="-1">−</button><strong class="grow" style="text-align:center;font-size:32px">${draft.value}</strong><button data-act="step" data-id="1">+</button></div>
    <h3>SIDES</h3>
    <div class="row">${[['single', 'Single'], ['lr', 'Left / right']].map(([v, l]) => `<button class="grow ${draft.sides === v ? 'on' : ''}" data-act="sides" data-id="${v}">${l}</button>`).join('')}</div>
    <button class="primary wide" data-act="save-item">Save</button>
    <button class="wide danger" data-act="remove-item">Remove from routine</button>`);
}

function editReminder() {
  const r = draft;
  const count = pendingCount([...state.reminders.filter((x) => x.id !== r.id), { ...r, enabled: true }]);
  const empty = !timesOf(r).length || (Array.isArray(r.items) && !r.items.length);
  openSheet(`<h2>Reminder</h2>
    <div class="row">${[['interval', 'Interval'], ['times', 'Set times']].map(([v, l]) => `<button class="grow ${r.type === v ? 'on' : ''}" data-act="rtype" data-id="${v}">${l}</button>`).join('')}</div>
    ${r.type === 'interval' ? `<h3>EVERY</h3><select data-field="every">${[30, 60, 90, 120, 180, 240].map((m) => `<option value="${m}" ${m === r.every ? 'selected' : ''}>${m / 60} hours</option>`).join('')}</select>
      <div class="row"><label class="grow"><h3>FROM</h3><input type="time" data-field="from" value="${r.from}"></label><label class="grow"><h3>TO</h3><input type="time" data-field="to" value="${r.to}"></label></div>`
    : `<h3>TIMES</h3><div class="row wrap">${timesOf(r).map((t) => `<button data-act="remove-time" data-id="${t}">${t} ✕</button>`).join('') || '<span class="muted">Add at least one.</span>'}</div>
      <div class="row" style="margin-top:10px"><input type="time" id="newtime" value="12:00"><button data-act="add-time">Add</button></div>`}
    <p class="muted">Fires at: ${timesOf(r).join(', ') || '—'}</p>
    <h3>EXERCISES</h3>
    <div class="row">${[['next', 'Next up', !r.items], ['all', 'All', r.items === 'all'], ['some', 'Choose', Array.isArray(r.items)]].map(([v, l, on]) => `<button class="grow ${on ? 'on' : ''}" data-act="scope" data-id="${v}">${l}</button>`).join('')}</div>
    ${r.items ? '' : '<p class="muted">Gives the next stretches not yet done today.</p>'}
    ${Array.isArray(r.items) ? state.routine.map((i) => `<label class="row card" style="margin:8px 0 0"><input type="checkbox" data-pick="${i.id}" ${r.items.includes(i.id) ? 'checked' : ''}><span class="grow">${esc(exercise(i.exerciseId).name)}</span></label>`).join('') : ''}
    ${count > MAX_PENDING ? `<p style="color:var(--danger)">${count} notification slots needed, iOS allows ${MAX_PENDING}.</p>` : ''}
    <button class="primary wide" data-act="save-reminder" ${empty || count > MAX_PENDING ? 'disabled' : ''}>Save</button>
    ${state.reminders.some((x) => x.id === r.id) ? '<button class="wide danger" data-act="delete-reminder">Delete</button>' : ''}`);
}

function askPermission() {
  openSheet(`<h2>Allow notifications?</h2>
    <p>Limbloop needs permission to remind you at the times you picked.</p>
    <p class="muted">Demo of the iOS prompt. Your phone is not asked.</p>
    <button class="primary wide" data-act="allow">Allow</button>
    <button class="wide" data-act="deny">Don’t allow</button>`);
}

function newCustom() {
  draft = { photo: null };
  openSheet(`<h2>Custom exercise</h2>
    <input id="cname" placeholder="Name" maxlength="80">
    <textarea id="cnotes" rows="4" placeholder="Notes" style="margin-top:10px"></textarea>
    <h3>PHOTO (OPTIONAL)</h3><input type="file" accept="image/*" id="cphoto">
    <button class="primary wide" data-act="save-custom">Save</button>`);
}

function readPhoto(file) {
  const img = new Image();
  img.onload = () => {
    const scale = Math.min(1, 800 / Math.max(img.width, img.height));
    const canvas = document.createElement('canvas');
    canvas.width = img.width * scale;
    canvas.height = img.height * scale;
    canvas.getContext('2d').drawImage(img, 0, 0, canvas.width, canvas.height);
    draft.photo = canvas.toDataURL('image/jpeg', 0.8);
    URL.revokeObjectURL(img.src);
  };
  img.onerror = () => alert('Could not read that image.');
  img.src = URL.createObjectURL(file);
}

/* ---------- session player ---------- */

let session;
let audio;

function cue() {
  if (state.settings.haptics) navigator.vibrate?.(150);
  if (!state.settings.sound || !audio) return;
  const osc = audio.createOscillator();
  const gain = audio.createGain();
  osc.frequency.value = 660;
  gain.gain.setValueAtTime(0.2, audio.currentTime);
  gain.gain.exponentialRampToValueAtTime(0.001, audio.currentTime + 0.4);
  osc.connect(gain).connect(audio.destination);
  osc.start();
  osc.stop(audio.currentTime + 0.4);
}

function startSession(items) {
  if (!items.length) return;
  closeSheet();
  // AudioContext must be created from a tap
  const Ctx = window.AudioContext || window.webkitAudioContext;
  if (Ctx) audio ||= new Ctx();
  audio?.resume();
  session = { items, index: 0, side: 0, done: [], paused: null };
  session.timer = setInterval(tick, 200);
  $('#player').hidden = false;
  getReady();
}

function getReady() {
  session.phase = 'ready';
  session.end = Date.now() + SWITCH_SECONDS * 1000;
  session.paused = null;
  drawPlayer();
}

function work() {
  const item = session.items[session.index];
  session.phase = 'work';
  session.end = item.mode === 'time' ? Date.now() + item.value * 1000 : null;
  session.paused = null;
  cue();
  drawPlayer();
}

const remaining = () => Math.max(0, Math.ceil((session.paused ?? session.end - Date.now()) / 1000));

function tick() {
  if (!session || session.phase === 'finished' || session.paused !== null || session.end === null) return;
  if (Date.now() < session.end) {
    const el = $('#count');
    if (el) {
      el.textContent = remaining();
      const length = session.phase === 'ready' ? SWITCH_SECONDS : session.items[session.index].value;
      $('#player .ring').style.setProperty('--p', 100 - (remaining() / length) * 100);
    }
  } else if (session.phase === 'ready') work();
  else completeSide();
}

function completeSide() {
  const item = session.items[session.index];
  if (item.sides === 'lr' && session.side === 0) {
    session.side = 1;
    cue();
    getReady();
  } else {
    session.done.push(item.id);
    advance();
  }
}

function advance() {
  session.index += 1;
  session.side = 0;
  if (session.index < session.items.length) {
    cue();
    getReady();
  } else finish();
}

function record() {
  if (session.done.length && !session.recorded) {
    session.recorded = true;
    state.sessions.push({ date: today(), time: new Date().toTimeString().slice(0, 5), done: session.done });
    save();
  }
}

function finish() {
  record();
  cue();
  session.phase = 'finished';
  clearInterval(session.timer);
  $('#player').innerHTML = `<div><h1 style="margin-top:30vh">Done</h1><p>${session.done.length} of ${session.items.length} exercises completed.</p>
    <div class="controls"><button class="primary" data-act="exit">Back to today</button></div></div>`;
}

function exitSession() {
  record();
  clearInterval(session.timer);
  session = null;
  $('#player').hidden = true;
  tab = 'today';
  render();
}

function drawPlayer() {
  const item = session.items[session.index];
  const e = exercise(item.exerciseId);
  const ready = session.phase === 'ready';
  const side = item.sides === 'lr' ? ['Left side', 'Right side'][session.side] : '';
  const timed = ready || item.mode === 'time';
  const pics = images(e);
  $('#player').innerHTML = `<div>
    <div class="row"><button data-act="exit">✕</button><span class="grow muted">${session.index + 1} of ${session.items.length}</span><span style="width:48px"></span></div>
    <h2 style="margin-top:12px">${esc(e.name)}</h2>
    ${pics.length ? `<div class="pics ${pics.length > 1 ? 'alt' : ''}">${pics.map((p) => `<img src="${esc(p)}" alt="">`).join('')}</div>` : `<p>${esc(e.notes)}</p>`}
    <div class="side-label">${ready ? (session.side ? 'Switch to right side' : `Get ready${side ? `: ${side.toLowerCase()}` : ''}`) : side}</div>
    <div class="ring" style="--p:0"><div><strong id="count">${timed ? remaining() : item.value}</strong><span class="muted">${timed ? 'seconds' : 'reps'}</span></div></div>
    <div class="controls">
      <button data-act="skip">Skip</button>
      ${timed ? `<button data-act="pause">${session.paused === null ? 'Pause' : 'Resume'}</button>` : ''}
      <button class="primary" data-act="next">${ready ? 'Start now' : 'Done'}</button>
    </div></div>`;
}

/* ---------- events ---------- */

function showBanner(id) {
  const r = state.reminders.find((x) => x.id === id);
  if (hasNothing(r)) return alert('This reminder has no exercises.');
  const count = itemsFor(r).length;
  $('#banner').innerHTML = `<button data-act="open-banner" data-id="${id}"><b>Limbloop</b> <span class="muted">now</span><br>${count ? `Time to stretch: ${count} exercise${count > 1 ? 's' : ''}. Tap to start.` : 'All stretches done for today.'}</button>`;
  $('#banner').hidden = false;
  clearTimeout(showBanner.timer);
  showBanner.timer = setTimeout(() => { $('#banner').hidden = true; }, 8000);
}

const actions = {
  tab: (id) => { tab = id; render(); scrollTo(0, 0); },
  close: closeSheet,
  theme: (id) => { state.settings.theme = id; save(); render(); },
  reset: () => { if (confirm('Reset all demo data?')) { state = defaults(); save(); render(); } },
  select: (id) => { if (!selected.delete(id)) selected.add(id); render(); },
  per: (n) => { state.settings.perSession = Number(n); save(); render(); },
  start: () => {
    const picked = state.routine.filter((i) => selected.has(i.id));
    selected.clear();
    startSession(picked.length ? picked : nextUp());
  },
  'start-all': () => { selected.clear(); startSession(state.routine); },
  'mark-all': () => {
    state.sessions.push({ date: today(), time: new Date().toTimeString().slice(0, 5), done: state.routine.map((i) => i.id) });
    save(); render();
  },
  notify: showBanner,
  'open-banner': (id) => {
    $('#banner').hidden = true;
    if (session) exitSession();
    startSession(itemsFor(state.reminders.find((r) => r.id === id)));
  },
  detail,
  layout: (id) => { sideBySide = !sideBySide; detail(id); },
  add: (id) => {
    state.routine.push({ id: uid(), exerciseId: id, mode: 'time', value: DEFAULT_SECONDS, sides: 'single' });
    save();
    draft = { ...state.routine.at(-1) };
    render();
    editItem();
  },
  'new-custom': newCustom,
  'save-custom': () => {
    const name = $('#cname').value.trim();
    if (!name) return $('#cname').focus();
    state.custom.unshift({ id: `custom-${uid()}`, custom: true, name, notes: $('#cnotes').value.trim(), photo: draft.photo });
    save(); closeSheet(); render();
  },
  'delete-custom': (id) => {
    if (!confirm('Delete this exercise? It is also removed from your routine.')) return;
    state.routine.filter((r) => r.exerciseId === id).forEach((r) => removeItem(r.id));
    state.custom = state.custom.filter((e) => e.id !== id);
    save(); closeSheet(); render();
  },
  edit: (id) => { draft = { ...state.routine.find((r) => r.id === id) }; editItem(); },
  mode: (v) => { if (draft.mode !== v) { draft.mode = v; draft.value = v === 'time' ? DEFAULT_SECONDS : 10; } editItem(); },
  step: (d) => { const s = draft.mode === 'time' ? 5 : 1; draft.value = Math.min(600, Math.max(s, draft.value + d * s)); editItem(); },
  sides: (v) => { draft.sides = v; editItem(); },
  'save-item': () => { state.routine = state.routine.map((r) => (r.id === draft.id ? draft : r)); save(); closeSheet(); render(); },
  'remove-item': () => { removeItem(draft.id); save(); closeSheet(); render(); },
  'new-reminder': () => { draft = { id: uid(), type: 'times', every: 120, from: '09:00', to: '18:00', times: ['09:00'], items: null, enabled: true }; editReminder(); },
  'edit-reminder': (id) => { draft = clone(state.reminders.find((r) => r.id === id)); editReminder(); },
  rtype: (v) => { draft.type = v; editReminder(); },
  'add-time': () => { const t = $('#newtime').value; if (t && !draft.times.includes(t)) draft.times.push(t); editReminder(); },
  'remove-time': (t) => { draft.times = draft.times.filter((x) => x !== t); editReminder(); },
  scope: (v) => {
    draft.items = v === 'next' ? null : v === 'all' ? 'all' : Array.isArray(draft.items) ? draft.items : [];
    editReminder();
  },
  'save-reminder': () => {
    const i = state.reminders.findIndex((r) => r.id === draft.id);
    if (i < 0) state.reminders.push(draft); else state.reminders[i] = draft;
    save(); render();
    if (state.permission === null) askPermission(); else closeSheet();
  },
  'delete-reminder': () => { state.reminders = state.reminders.filter((r) => r.id !== draft.id); save(); closeSheet(); render(); },
  allow: () => { state.permission = true; save(); closeSheet(); render(); },
  deny: () => { state.permission = false; save(); closeSheet(); render(); },
  exit: exitSession,
  skip: advance,
  next: () => (session.phase === 'ready' ? work() : completeSide()),
  pause: () => {
    if (session.paused === null) session.paused = session.end - Date.now();
    else { session.end = Date.now() + session.paused; session.paused = null; }
    drawPlayer();
  },
};

const clone = (v) => JSON.parse(JSON.stringify(v));

function removeItem(id) {
  state.routine = state.routine.filter((r) => r.id !== id);
  state.reminders.forEach((r) => {
    if (!Array.isArray(r.items)) return;
    r.items = r.items.filter((x) => x !== id);
    if (!r.items.length) r.enabled = false;
  });
}

document.addEventListener('click', (ev) => {
  const nav = ev.target.closest('#tabs button');
  if (nav) return actions.tab(nav.dataset.tab);
  const el = ev.target.closest('[data-act]');
  if (el) return actions[el.dataset.act](el.dataset.id);
  if (ev.target.id === 'sheet') closeSheet();
});

document.addEventListener('input', (ev) => {
  if (ev.target.id === 'q') { filters.q = ev.target.value; $('#results').innerHTML = results(); }
});

document.addEventListener('change', (ev) => {
  const t = ev.target;
  const d = t.dataset;
  if (d.filter) { filters[d.filter] = t.value; $('#results').innerHTML = results(); }
  else if (d.setting) { state.settings[d.setting] = t.checked; save(); }
  else if (d.toggle) {
    const r = state.reminders.find((x) => x.id === d.toggle);
    r.enabled = t.checked;
    if (t.checked && (pendingCount(state.reminders) > MAX_PENDING || hasNothing(r))) {
      r.enabled = false;
      alert(hasNothing(r) ? 'This reminder has no exercises.' : `That exceeds ${MAX_PENDING} notification slots.`);
    }
    save(); render();
  } else if (d.field && t.value) { draft[d.field] = d.field === 'every' ? Number(t.value) : t.value; editReminder(); }
  else if (d.pick) { draft.items = t.checked ? [...draft.items, d.pick] : draft.items.filter((x) => x !== d.pick); editReminder(); }
  else if (t.id === 'cphoto' && t.files[0]) readPhoto(t.files[0]);
});

// drag to reorder, works with touch and mouse
document.addEventListener('pointerdown', (ev) => {
  const handle = ev.target.closest('.handle');
  if (!handle) return;
  ev.preventDefault();
  const row = handle.closest('[data-row]');
  row.classList.add('dragging');
  const move = (e) => {
    const others = [...$('#list').children].filter((c) => c !== row);
    const at = others.findIndex((c) => e.clientY < c.getBoundingClientRect().top + c.offsetHeight / 2);
    const split = at < 0 ? others.length : at;
    // move the neighbours around the dragged row, keeping the row itself in the DOM
    row.before(...others.slice(0, split));
    row.after(...others.slice(split));
    if (e.clientY > innerHeight - 120) scrollBy(0, 12);
    if (e.clientY < 80) scrollBy(0, -12);
  };
  const up = () => {
    removeEventListener('pointermove', move);
    removeEventListener('pointerup', up);
    removeEventListener('pointercancel', up);
    const order = [...$('#list').children].map((c) => c.dataset.row);
    state.routine.sort((a, b) => order.indexOf(a.id) - order.indexOf(b.id));
    save(); render();
  };
  addEventListener('pointermove', move);
  addEventListener('pointerup', up);
  addEventListener('pointercancel', up);
});

fetch('data/exercises.json')
  .then((r) => { if (!r.ok) throw new Error(r.status); return r.json(); })
  .then((data) => {
    library = data;
    try { state = JSON.parse(localStorage.getItem(KEY)); } catch { state = null; }
    state ||= defaults();
    render();
  })
  .catch((err) => { $('#view').textContent = `Could not load exercises: ${err.message}`; });
