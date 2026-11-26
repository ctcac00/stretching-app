// Cross-feature entry points to the library. Keep these signatures.
import 'package:material_ui/material_ui.dart';

import 'exercise_detail_screen.dart';
import 'exercise_picker_screen.dart';

Future<void> openExerciseDetail(BuildContext context, String exerciseId) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExerciseDetailScreen(exerciseId: exerciseId),
      ),
    );

/// Lets the user choose an exercise. Returns its id, or null if cancelled.
Future<String?> pickExercise(BuildContext context) =>
    Navigator.of(context).push(
      MaterialPageRoute<String>(
        fullscreenDialog: true,
        builder: (_) => const ExercisePickerScreen(),
      ),
    );
