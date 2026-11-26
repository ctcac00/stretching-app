import 'package:material_ui/material_ui.dart';

import 'custom_exercise_screen.dart';
import 'exercise_browser.dart';
import 'library_hooks.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ExerciseBrowser(
        onSelected: (e) => openExerciseDetail(context, e.id),
        action: OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Custom exercise'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              fullscreenDialog: true,
              builder: (_) => const CustomExerciseScreen(),
            ),
          ),
        ),
      ),
    );
  }
}
