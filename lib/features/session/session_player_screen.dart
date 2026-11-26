import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/tabs.dart';
import '../../core/providers.dart';
import '../../core/ui/exercise_image.dart';
import 'session_controller.dart';
import 'session_device.dart';

_SessionPlayerState? _running;

/// Stops the running player, if any, and records what it completed. Null if
/// there is no player; otherwise completes once the record is saved.
Future<void>? closeRunningSession() => _running?._end();

class SessionPlayerScreen extends ConsumerStatefulWidget {
  const SessionPlayerScreen({super.key, required this.itemIds});

  /// Routine item ids, in play order.
  final List<int> itemIds;

  @override
  ConsumerState<SessionPlayerScreen> createState() => _SessionPlayerState();
}

class _SessionPlayerState extends ConsumerState<SessionPlayerScreen> {
  // Captured here because `ref` cannot be used in dispose.
  late final SessionRepository _sessions;
  late final SessionDevice _device;
  late final AppLifecycleListener _lifecycle;
  late final Timer _timer;

  /// The requested items that still exist; null while loading.
  List<RoutineItem>? _items;
  SessionController? _controller;
  bool _background = false;
  bool _awake = true;
  bool _ended = false;

  @override
  void initState() {
    super.initState();
    _running = this;
    _sessions = ref.read(sessionRepositoryProvider);
    _device = ref.read(sessionDeviceProvider)..keepAwake(true);
    final state = WidgetsBinding.instance.lifecycleState;
    _background =
        state == AppLifecycleState.hidden || state == AppLifecycleState.paused;
    // No ticking, and so no cues, while backgrounded.
    _lifecycle = AppLifecycleListener(
      onHide: () => _background = true,
      onResume: () {
        setState(() => _background = false);
        _tick();
      },
    );
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
    _load();
  }

  Future<void> _load() async {
    final routine = await ref.read(routineRepositoryProvider).getAll();
    if (!mounted) return;
    final byId = {for (final item in routine) item.id: item};
    setState(() => _items = [for (final id in widget.itemIds) ?byId[id]]);
  }

  void _tick() {
    final controller = _controller;
    if (_background || _ended || controller == null) return;
    if (controller.phase == SessionPhase.finished) return;
    _act(controller.tick);
  }

  void _act(VoidCallback action) => setState(() {
    action();
    if (_controller?.phase == SessionPhase.finished) _release();
  });

  void _cue() {
    final settings = ref.read(settingsProvider).value;
    if (_background || settings == null) return;
    if (settings.sound) _device.sound();
    if (settings.haptics) _device.haptic();
  }

  Future<void> _record(List<int> ids) async {
    try {
      await _sessions.record(ids);
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stack, library: 'session'),
      );
    }
  }

  void _release() {
    if (!_awake) return;
    _awake = false;
    _device.keepAwake(false);
  }

  Future<void> _end() {
    _ended = true;
    _release();
    return _controller?.close() ?? Future.value();
  }

  void _close() {
    _end();
    ref.read(selectedTabProvider.notifier).select(AppTab.today);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer.cancel();
    _lifecycle.dispose();
    _end();
    if (identical(_running, this)) _running = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesProvider);
    final byId = ref.watch(exerciseMapProvider);
    ref.watch(settingsProvider); // Kept current for the cues.
    final items = _items;

    // The first "get ready" starts once there is something to show.
    if (items != null &&
        items.isNotEmpty &&
        exercises.hasValue &&
        !_background &&
        !_ended) {
      _controller ??= SessionController(
        items: items,
        clock: ref.read(clockProvider),
        onCue: _cue,
        record: _record,
      );
    }

    final controller = _controller;
    if (controller == null) {
      return _message(
        items != null && items.isEmpty
            ? 'These exercises are no longer in your routine.'
            : exercises.hasError
            ? 'Could not load the exercises.'
            : null,
      );
    }
    if (controller.phase == SessionPhase.finished) {
      return _finished(controller);
    }
    return _playing(controller, byId[controller.item.exerciseId]);
  }

  /// A spinner, or [text].
  Widget _message(String? text) => Scaffold(
    appBar: AppBar(leading: CloseButton(onPressed: _close)),
    body: Center(
      child: text == null
          ? const CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Text(text, textAlign: TextAlign.center),
            ),
    ),
  );

  Widget _finished(SessionController c) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Done',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '${c.completed.length} of ${c.items.length} exercises '
                'completed.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _close,
                child: const Text('Back to today'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _playing(SessionController c, Exercise? exercise) {
    final theme = Theme.of(context);
    final ready = c.phase == SessionPhase.ready;
    final twoSided = c.item.sides == Sides.leftRight;
    final side = twoSided ? ['Left side', 'Right side'][c.side] : '';
    final label = !ready
        ? side
        : c.side == 1
        ? 'Switch to right side'
        : twoSided
        ? 'Get ready: ${side.toLowerCase()}'
        : 'Get ready';
    final length = c.phaseSeconds;

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: _close),
        title: Text('${c.index + 1} of ${c.items.length}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text(
                    exercise?.name ?? 'Unknown exercise',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (exercise != null && exercise.imageCount > 0)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: AlternatingExerciseImage(
                          exercise,
                          key: ValueKey(exercise.id),
                        ),
                      ),
                    )
                  else
                    Text(exercise?.notes ?? '', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox.square(
                      dimension: 180,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 12,
                            backgroundColor: theme.colorScheme.outlineVariant,
                            value: length == null
                                ? 0
                                : 1 -
                                      (c.remaining.inMilliseconds /
                                              (length * 1000))
                                          .clamp(0, 1),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${length == null ? c.item.value : c.secondsLeft}',
                                style: theme.textTheme.displayMedium,
                              ),
                              Text(length == null ? 'reps' : 'seconds'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                spacing: 10,
                children: [
                  _control(
                    OutlinedButton(
                      onPressed: () => _act(c.skip),
                      child: const Text('Skip'),
                    ),
                  ),
                  if (length != null)
                    _control(
                      OutlinedButton(
                        onPressed: () => _act(c.togglePause),
                        child: Text(c.isPaused ? 'Resume' : 'Pause'),
                      ),
                    ),
                  _control(
                    FilledButton(
                      onPressed: () => _act(c.next),
                      child: Text(ready ? 'Start now' : 'Done'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _control(Widget button) =>
      Expanded(child: SizedBox(height: 64, child: button));
}
