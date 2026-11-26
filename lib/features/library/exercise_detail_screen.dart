import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers.dart';
import '../../core/ui/exercise_image.dart';
import '../routine/routine_hooks.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  /// Remembered while the app runs.
  static bool _sideBySide = false;

  bool _adding = false;

  Future<void> _addToRoutine() async {
    if (_adding) return;
    _adding = true;
    try {
      final item = await ref
          .read(routineRepositoryProvider)
          .add(widget.exerciseId);
      if (mounted) await openRoutineItemEditor(context, item.id);
    } finally {
      _adding = false;
    }
  }

  Future<void> _delete() async {
    final navigator = Navigator.of(context);
    final repository = ref.read(customExerciseRepositoryProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this exercise?'),
        content: const Text('It is also removed from your routine.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    // Leave first, so the screen never shows the exercise as missing.
    navigator.pop();
    await repository.delete(widget.exerciseId);
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesProvider);
    final exercise = ref.watch(exerciseMapProvider)[widget.exerciseId];
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise')),
      body: exercise != null
          ? _body(exercise)
          : Center(
              child: exercises.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Exercise not found.'),
            ),
    );
  }

  Widget _body(Exercise e) {
    final theme = Theme.of(context);
    final inRoutine =
        ref
            .watch(routineProvider)
            .value
            ?.any((item) => item.exerciseId == e.id) ??
        false;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(e.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        if (e.imageCount > 1) ...[
          if (_sideBySide)
            Row(
              spacing: 4,
              children: [
                for (var i = 0; i < e.imageCount; i++)
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 3 / 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ExerciseImage(e, index: i),
                      ),
                    ),
                  ),
              ],
            )
          else
            AlternatingExerciseImage(e, key: ValueKey(e.id)),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => setState(() => _sideBySide = !_sideBySide),
            child: Text(_sideBySide ? 'Alternate images' : 'Show side by side'),
          ),
        ] else if (e.imageCount == 1)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ExerciseImage(
              e,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
        const SizedBox(height: 12),
        if (e.isCustom)
          Text(e.notes.isEmpty ? 'No notes.' : e.notes)
        else ...[
          Text(
            [?e.level, e.equipmentLabel, ...e.primaryMuscles].join(' · '),
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          for (final (i, step) in e.instructions.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 28, child: Text('${i + 1}.')),
                  Expanded(child: Text(step)),
                ],
              ),
            ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _addToRoutine,
          child: Text(inRoutine ? 'Add again to routine' : 'Add to routine'),
        ),
        if (e.isCustom) ...[
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: _delete,
            child: const Text('Delete exercise'),
          ),
        ],
      ],
    );
  }
}
