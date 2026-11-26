import '../../core/models/exercise.dart';

/// Exercises whose name contains [query], narrowed by primary muscle and
/// equipment. Custom exercises have neither, so a set filter drops them.
List<Exercise> searchExercises(
  List<Exercise> exercises, {
  String query = '',
  String? muscle,
  String? equipment,
}) {
  final text = query.trim().toLowerCase();
  return [
    for (final e in exercises)
      if (e.name.toLowerCase().contains(text) &&
          (muscle == null || e.primaryMuscles.contains(muscle)) &&
          (equipment == null || (!e.isCustom && e.equipmentLabel == equipment)))
        e,
  ];
}

/// Sorted values for the muscle filter.
List<String> muscleOptions(List<Exercise> exercises) =>
    {for (final e in exercises) ...e.primaryMuscles}.toList()..sort();

/// Sorted values for the equipment filter.
List<String> equipmentOptions(List<Exercise> exercises) => {
  for (final e in exercises)
    if (!e.isCustom) e.equipmentLabel,
}.toList()..sort();
