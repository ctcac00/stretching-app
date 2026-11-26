import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers.dart';

/// What the editor was closed with: save [item], or remove it.
typedef RoutineEdit = ({RoutineItem item, bool remove});

/// Bottom sheet editing a draft of one routine item. Pops a [RoutineEdit].
class RoutineItemEditor extends ConsumerStatefulWidget {
  const RoutineItemEditor(this.item, {super.key});

  final RoutineItem item;

  @override
  ConsumerState<RoutineItemEditor> createState() => _RoutineItemEditorState();
}

class _RoutineItemEditorState extends ConsumerState<RoutineItemEditor> {
  late RoutineItem _draft = widget.item;

  void _edit(RoutineItem draft) => setState(() => _draft = draft);

  void _step(int direction) {
    final step = _draft.mode == ExerciseMode.time ? secondsStep : repsStep;
    final value = clampValue(_draft.mode, _draft.value + direction * step);
    _edit(_draft.copyWith(value: value));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = ref.watch(exerciseMapProvider)[_draft.exerciseId]?.name ?? '';
    final unit = _draft.mode == ExerciseMode.time ? 'Seconds' : 'Reps';
    final perSide = _draft.sides == Sides.leftRight ? ' per side' : '';

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text, style: theme.textTheme.titleSmall),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(name, style: theme.textTheme.titleLarge),
          heading('Measure'),
          SegmentedButton<ExerciseMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ExerciseMode.time, label: Text('Duration')),
              ButtonSegment(value: ExerciseMode.reps, label: Text('Reps')),
            ],
            selected: {_draft.mode},
            onSelectionChanged: (selection) => _edit(
              _draft.copyWith(
                mode: selection.single,
                value: defaultValue(selection.single),
              ),
            ),
          ),
          heading('$unit$perSide'),
          Row(
            children: [
              IconButton.outlined(
                tooltip: 'Decrease',
                iconSize: 32,
                onPressed: () => _step(-1),
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  '${_draft.value}',
                  key: const Key('routine-value'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge,
                ),
              ),
              IconButton.outlined(
                tooltip: 'Increase',
                iconSize: 32,
                onPressed: () => _step(1),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          heading('Sides'),
          SegmentedButton<Sides>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: Sides.single, label: Text('Single')),
              ButtonSegment(
                value: Sides.leftRight,
                label: Text('Left / right'),
              ),
            ],
            selected: {_draft.sides},
            onSelectionChanged: (selection) =>
                _edit(_draft.copyWith(sides: selection.single)),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, (item: _draft, remove: false)),
            child: const Text('Save'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: () =>
                Navigator.pop(context, (item: _draft, remove: true)),
            child: const Text('Remove from routine'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
