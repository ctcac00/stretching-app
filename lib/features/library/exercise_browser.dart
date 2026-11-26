import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers.dart';
import '../../core/ui/exercise_image.dart';
import 'exercise_search.dart';

/// Searchable, filterable exercise list, shared by the library and the picker.
class ExerciseBrowser extends ConsumerStatefulWidget {
  const ExerciseBrowser({super.key, required this.onSelected, this.action});

  final ValueChanged<Exercise> onSelected;

  /// Shown between the filters and the results.
  final Widget? action;

  @override
  ConsumerState<ExerciseBrowser> createState() => _ExerciseBrowserState();
}

class _ExerciseBrowserState extends ConsumerState<ExerciseBrowser> {
  final _query = TextEditingController();
  String? _muscle;
  String? _equipment;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(exercisesProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              const Center(child: Text('Could not load exercises.')),
          data: _list,
        );
  }

  Widget _list(List<Exercise> all) {
    final found = searchExercises(
      all,
      query: _query.text,
      muscle: _muscle,
      equipment: _equipment,
    );
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        TextField(
          controller: _query,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search ${all.length} stretches',
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (_) => setState(() {}),
        ),
        Row(
          spacing: 10,
          children: [
            _filter(
              'All muscles',
              muscleOptions(all),
              _muscle,
              (v) => _muscle = v,
            ),
            _filter(
              'All equipment',
              equipmentOptions(all),
              _equipment,
              (v) => _equipment = v,
            ),
          ],
        ),
        ?widget.action,
        if (found.isEmpty) const Text('No matches.'),
        const SizedBox.shrink(),
      ],
    );
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: found.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) return header;
        final e = found[i - 1];
        return Card(
          key: ValueKey(e.id),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ExerciseImage(e, width: 56, height: 56),
            ),
            title: Text(e.name),
            subtitle: Text(
              e.isCustom
                  ? 'custom'
                  : [...e.primaryMuscles, e.equipmentLabel].join(' · '),
            ),
            onTap: () => widget.onSelected(e),
          ),
        );
      },
    );
  }

  Widget _filter(
    String all,
    List<String> options,
    String? selected,
    ValueChanged<String?> select,
  ) => Expanded(
    child: DropdownButtonFormField<String?>(
      initialValue: selected,
      isExpanded: true,
      items: [
        DropdownMenuItem(child: Text(all, overflow: TextOverflow.ellipsis)),
        for (final option in options)
          DropdownMenuItem(
            value: option,
            child: Text(option, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (v) => setState(() => select(v)),
    ),
  );
}
