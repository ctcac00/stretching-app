import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import '../providers.dart';

/// One picture of an exercise (bundled asset or custom photo), with a
/// placeholder when it has none.
class ExerciseImage extends ConsumerWidget {
  const ExerciseImage(
    this.exercise, {
    super.key,
    this.index = 0,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final Exercise? exercise;
  final int index;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholder = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: const Icon(Icons.self_improvement),
    );
    final e = exercise;
    if (e == null || index >= e.imageCount) return placeholder;
    final ImageProvider image = e.isCustom
        ? FileImage(
            File(
              p.join(ref.watch(documentsDirectoryProvider).path, e.photoPath),
            ),
          )
        : AssetImage(e.assetImages[index]);
    return Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

/// Alternates between an exercise's pictures. Sizes itself to a 3:2 box unless
/// the parent dictates otherwise.
class AlternatingExerciseImage extends StatefulWidget {
  /// Give it a new key when the exercise changes.
  const AlternatingExerciseImage(this.exercise, {super.key});

  final Exercise exercise;

  @override
  State<AlternatingExerciseImage> createState() =>
      _AlternatingExerciseImageState();
}

class _AlternatingExerciseImageState extends State<AlternatingExerciseImage> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (widget.exercise.imageCount > 1) {
      _timer = Timer.periodic(
        const Duration(milliseconds: 1200),
        (_) => setState(() => _index++),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.exercise.imageCount;
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExerciseImage(
          widget.exercise,
          index: count > 1 ? _index % count : 0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
