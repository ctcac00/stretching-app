import 'package:material_ui/material_ui.dart';

import 'exercise_browser.dart';

/// Pops with the chosen exercise id.
class ExercisePickerScreen extends StatelessWidget {
  const ExercisePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose exercise')),
      body: ExerciseBrowser(onSelected: (e) => Navigator.of(context).pop(e.id)),
    );
  }
}
