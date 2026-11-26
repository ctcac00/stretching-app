import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/core/exercise_library.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled library has 123 stretches, each image present', () async {
    final exercises = await loadBundledExercises(rootBundle);

    expect(exercises, hasLength(123));
    for (final e in exercises) {
      expect(e.isCustom, isFalse);
      expect(e.instructions, isNotEmpty);
      expect(e.assetImages, hasLength(2));
      for (final asset in e.assetImages) {
        expect(File(asset).existsSync(), isTrue, reason: asset);
      }
    }
    await rootBundle.load(exercises.first.assetImages.first);
    await rootBundle.load('assets/cue.wav');
    expect(exercises.any((e) => e.equipmentLabel == 'none'), isTrue);
  });
}
