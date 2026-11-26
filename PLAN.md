# Limbloop: implementation plan

Written 2026-11-26. Handover for an agent with no earlier context.

## 0. Start here

- **Status:** steps 1 to 8 implemented on 2026-11-26. Checked with tests and an Android 33 emulator; iOS unbuilt and unverified. Committed on `main`. Shared models and repositories live in `lib/core/`, not in the feature folders shown in section 3.
- **Gate:** passed. The owner approved the mockup on 2026-11-26.
- **Behaviour reference:** `prototype/www/app.js` shows the agreed flows. Where it and this plan disagree, ask. It is throwaway code: copy behaviour, not structure.
- **Decided:** section 7, option B (2026-11-26). It overrides the "repeating" wording in 2.4.
- Propose changes before making them if anything is unclear. Do not commit or push unless asked.

## 1. Product

An iOS app built in Flutter. The user sets up a daily routine of stretching and mobility exercises and gets reminders through the day to do them, a few at a time.

| | |
|---|---|
| Name | Limbloop |
| Bundle / application ID | `com.lusoquantum.limbloop` |
| Platforms | iOS first. Avoid iOS-only code where easy |
| Backend, accounts | None. Fully offline |

The name was checked on 2026-11-26: no title containing it appeared in App Store (US, PT) or Google Play (US) search, and a web search found nothing. This does not reserve it. No trademark search was done. Creating the App Store Connect record is the real check.

## 2. Requirements

### 2.1 Exercise library
- Source: [free-exercise-db](https://github.com/yuhonas/free-exercise-db), public domain (Unlicense), no attribution needed.
- Take `dist/exercises.json`, keep `category == "stretching"`, bundle as `assets/exercises.json`.
- Schema: `id, name, force, level, mechanic, equipment, primaryMuscles[], secondaryMuscles[], instructions[], category, images[]`.
- Image URL: `https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/` + image path.
- **Bundle the images** (decided). No `cached_network_image`.
- Measured: 876 exercises, 123 stretches, 246 JPGs, 8.4 MiB. Every stretch has 2 images and instructions.
- `equipment`: 62 null, 23 body only, 23 other, 11 foam roll, 4 exercise ball. Show null as "none". `force` and `mechanic` can also be null.
- Browse, search by name, filter by primary muscle and equipment.
- Detail screen: both images (alternating, with a side-by-side toggle) and instructions.
- Custom exercises: name (required), notes, optional photo from the photo library. Copy the photo into app documents and store a relative path. Custom exercises have no muscle or equipment, so they drop out when those filters are set. Deleting one removes it from the routine.

### 2.2 Routine
- One daily routine.
- Per item: duration (seconds) or reps; single or left/right. The same exercise may be added twice.
- **Default hold is 60 s**, configurable per item: steps of 5 s, range 5 to 600. Applies to new items and when switching from reps to duration. Duration is per side.
- Reps: default 10, step 1.
- Reorder by dragging.

### 2.3 Doing a few at a time
The owner wants to do **all routine exercises every day, but not all at once**, typically one or two at a time.

- **Next up** (default scope for reminders and the main Today button): the first N routine items not yet done today, in routine order, chosen **when the session starts**, not when the notification is scheduled.
- **Stretches per session** setting: Auto (default), 1, 2, 3.
- Auto: `N = ceil(left / (later + 1))`, where `left` = routine items not done today and `later` = distinct enabled reminder times (all scopes) strictly after now.
- Skipped items stay undone and come round again.
- When nothing is left, the Today button reads "All done for today" and is disabled. Opening a next-up reminder starts no session.
- Today also offers: pick any items and **Start N selected**, **Start whole routine**, **Mark routine done**.

### 2.4 Reminders
- Several per day. Each is either a list of set times, or an interval (30, 60, 90, 120, 180, 240 min) between a start and end time. The end is included if a step lands on it: every 2 h from 09:00 to 18:00 gives 09, 11, 13, 15, 17. No overnight windows (start after end cannot be saved).
- Scope per reminder: **Next up** (default), **All**, or **Choose** a subset.
- Each can be enabled or disabled.
- A reminder with no times or an empty subset cannot be saved. If removing routine items empties a subset, disable that reminder.
- Use `flutter_local_notifications` with scheduled one-off local notifications, several days ahead (section 7, option B).
- **iOS allows 64 pending.** Schedule the next 64 occurrences, soonest first, one per distinct time per day across enabled reminders. Block saving or enabling beyond 64 distinct times. Show the count.
- Once every routine item is done today, schedule nothing more for today.
- Reminders sharing a time become one notification. When scopes differ: All wins; otherwise take the union of chosen subsets and next-up items.
- Reschedule everything on app open, on resume (covers time zone changes), after any edit and whenever today's completion changes.
- Ask for notification permission when the user first saves a reminder. If denied, show a notice pointing to iOS Settings.
- Notification text must stay correct on any day, so keep it generic (for example "Time to stretch"). Next-up items are not known at scheduling time.
- Tapping a notification opens the session player, both from a running app and from a cold start (`getNotificationAppLaunchDetails`). Decide foreground presentation explicitly.

### 2.5 Session player
- 5 s "get ready" before each exercise and before the second side.
- Countdown per timed exercise; reps wait for **Done**.
- Left/right items prompt the switch.
- Controls: Skip (not counted), Pause, Done / Start now, close.
- An exercise counts only when all its sides are completed. Closing early records what was completed.
- Compute time from the wall clock so it stays correct after backgrounding. Keep the screen awake during a session. No cues while backgrounded.
- Sound and haptic cues, each switchable.

### 2.6 Progress
- Today's completion = distinct current routine items done today / routine size.
- List today's sessions. Days use the local date.
- **No streak** (removed by the owner).

### 2.7 Look
Calm and simple, large tap targets, light and dark. The mockup also has an auto / light / dark override. Tabs: Today, Library, Routine, Reminders.

## 3. Technical choices

- Flutter 3.50.1 (latest stable on 2026-11-26), Dart 3.14.
- `flutter_riverpod` without code generation.
- `drift` for storage. `isar` was rejected: last release April 2023.
- Plain `Navigator` with a global navigator key (needed for notification taps).
- Hand-written `fromJson`.

Latest versions seen on pub.dev on 2026-11-26: `flutter_riverpod` 3.5.0, `drift` 2.35.4, `flutter_local_notifications` 23.0.4, `timezone` 0.11.2, `flutter_timezone` 5.1.1, `image_picker` 1.2.4, `wakelock_plus` 1.8.2, `audioplayers` 6.8.1. Check current API docs before using them.

```
lib/
  app/            theme, root, navigation
  core/db/        Drift tables and database
  features/
    library/      models, repository, list, detail, custom exercise
    routine/      builder
    reminders/    schedule and next-up logic (pure Dart), notification service, UI
    session/      player controller, UI
    progress/     today screen
tool/fetch_exercises.dart
assets/exercises.json, assets/images/
test/
```

Suggested tables: custom exercises; routine items (position, exercise ID, mode, value, sides); reminders (type, interval, start, end, times, scope, enabled); reminder-to-routine-item subset; sessions (local date, time); completed items per session; settings.

Keep scheduling and next-up logic free of Flutter imports and inject the clock, so both are unit-testable.

## 4. Build steps

Each step ends with `flutter analyze` clean and `flutter test` passing.

| # | Step | Done when |
|---|---|---|
| 1 | `flutter create` with the ID above, `git init`, add dependencies | Empty app analyses and tests |
| 2 | `tool/fetch_exercises.dart`: download, filter, save JSON and images, register assets. Reject image paths that escape the target folder (see `prototype/fetch.py`) | 123 entries, 246 files |
| 3 | Library, detail, custom exercises | Model parsing and search/filter tests |
| 4 | Routine builder and database | Add, edit, reorder, delete tests, including subset cleanup |
| 5 | Reminders and notification service | Tests: interval expansion, dedupe, 64 cap, merged scopes |
| 6 | Next-up logic and session player | Tests: auto count, skip, all done, new day, countdown, side switch, notification tap from cold start |
| 7 | Today screen and progress | Completion tests including midnight boundary |
| 8 | Light/dark, tap targets, permission-denied path | Manual pass on Android emulator |

## 5. This machine

- Debian Linux. **No Xcode: iOS cannot be built or run here.** The owner checks iOS on a Mac. Report iOS behaviour as unverified.
- Flutter is at `~/flutter` (upgraded to 3.50.1), not on `PATH`: use `~/flutter/bin/flutter`.
- Android SDK at `~/Android/Sdk` with an Android 33 system image and KVM. An AVD `verdant_test` already exists, probably for another project: create a separate one. `flutter doctor` reports some Android licences not accepted.
- Android needs its own notification setup (permission, receivers, desugaring); follow the plugin README.
- About 24 GB disk free. `sudo` needs a password.

## 6. Mockup

- Files: `prototype/www/` (plain HTML, CSS, JS). `prototype/fetch.py` fills `prototype/www/data/`; run `python3 -I prototype/fetch.py`.
- Served by the user systemd unit `limbloop-proto` at `http://192.168.1.3:8765` (LAN only, plain HTTP; the phone reaches it over the home WireGuard VPN). It is transient and does not survive a reboot.

```sh
systemctl --user stop limbloop-proto
systemd-run --user --unit=limbloop-proto /usr/bin/python3 -I -m http.server 8765 \
  --bind 192.168.1.3 --directory "$PWD/prototype/www"   # run from the project root
```

- Notifications and the permission prompt are simulated; data lives in browser `localStorage`.
- Tested with headless Chromium at iPhone size (test scripts were temporary and are not in the project). Not tested on real Safari.
- When Flutter work begins, add `prototype/www/data/` to `.gitignore`.

## 7. Decision: pings after everything is done

**Decided 2026-11-26: option B.** Verified in plugin 23.0.4: the iOS daily trigger keeps only hour, minute, second and time zone.

Next up means the routine can be finished before the last reminder. The owner was told the app would cancel the rest of that day's notifications. **That does not fit daily-repeating notifications:** cancelling one removes it for all future days, and an iOS trigger that matches only hour and minute cannot be told to skip today. Verify against the current plugin, then ask the owner to choose:

| Option | Effect | Cost |
|---|---|---|
| A. Keep daily repeating (suggested default) | Reminders never stop | Pings continue after all is done |
| B. One-off notifications for several days ahead, within 64 | Today's remaining ones can be cancelled | Reminders run out if the app is not opened (about 12 days at 5 per day) |

Option B departs from the brief's "repeating notifications".
