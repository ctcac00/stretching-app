import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/tabs.dart';
import '../../core/providers.dart';
import '../../core/ui/exercise_image.dart';
import 'routine_hooks.dart';

/// The routine builder: reorder by the drag handle, tap to edit.
class RoutineScreen extends ConsumerStatefulWidget {
  const RoutineScreen({super.key});

  @override
  ConsumerState<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends ConsumerState<RoutineScreen> {
  /// The order just dropped, shown until the database catches up.
  List<RoutineItem>? _dropped;

  void _reorder(List<RoutineItem> items, int from, int to) {
    final order = [...items];
    order.insert(to, order.removeAt(from));
    setState(() => _dropped = order);
    ref.read(routineRepositoryProvider).reorder([for (final i in order) i.id]);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(routineProvider, (_, _) => _dropped = null);
    final routine = ref.watch(routineProvider);
    final exercises = ref.watch(exerciseMapProvider);
    final items = _dropped ?? routine.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Routine')),
      body: items == null
          ? Center(
              child: routine.hasError
                  ? const Text('Could not load the routine.')
                  : const CircularProgressIndicator(),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              buildDefaultDragHandles: false,
              header: const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Drag the handle to reorder. Tap to edit.'),
              ),
              footer: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Routine empty. Add stretches from the library.',
                      ),
                    ),
                  OutlinedButton(
                    onPressed: () => ref
                        .read(selectedTabProvider.notifier)
                        .select(AppTab.library),
                    child: const Text('+ Add from library'),
                  ),
                ],
              ),
              itemCount: items.length,
              onReorderItem: (from, to) => _reorder(items, from, to),
              itemBuilder: (context, index) {
                final item = items[index];
                final exercise = exercises[item.exerciseId];
                return Card(
                  key: ValueKey(item.id),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: Semantics(
                          label: 'Drag to reorder',
                          child: const ColoredBox(
                            color: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 24,
                              ),
                              child: Icon(Icons.drag_indicator),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(right: 12),
                          minVerticalPadding: 10,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ExerciseImage(
                              exercise,
                              width: 56,
                              height: 56,
                            ),
                          ),
                          title: Text(exercise?.name ?? ''),
                          subtitle: Text(_describe(item)),
                          onTap: () => openRoutineItemEditor(context, item.id),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

String _describe(RoutineItem item) =>
    '${item.value}${item.mode == ExerciseMode.time ? ' s' : ' reps'}'
    '${item.sides == Sides.leftRight ? ' · left + right' : ''}';
