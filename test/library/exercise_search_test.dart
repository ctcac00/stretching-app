import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/core/models/exercise.dart';
import 'package:limbloop/features/library/exercise_search.dart';

void main() {
  group('parsing', () {
    test('reads the source schema, including nulls', () {
      final e = Exercise.fromJson({
        'id': 'Calf_Stretch',
        'name': 'Calf Stretch',
        'force': null,
        'level': 'beginner',
        'mechanic': null,
        'equipment': null,
        'primaryMuscles': ['calves'],
        'secondaryMuscles': <dynamic>[],
        'instructions': ['Stand.', 'Lean.'],
        'category': 'stretching',
        'images': ['Calf_Stretch/0.jpg', 'Calf_Stretch/1.jpg'],
      });

      expect(e.force, isNull);
      expect(e.mechanic, isNull);
      expect(e.equipmentLabel, 'none');
      expect(e.primaryMuscles, ['calves']);
      expect(e.instructions, ['Stand.', 'Lean.']);
      expect(e.isCustom, isFalse);
      expect(e.imageCount, 2);
      expect(e.assetImages.first, 'assets/images/Calf_Stretch_0.jpg');
    });

    test('reads a custom entry without the library fields', () {
      final e = Exercise.fromJson({
        'id': 'custom-1',
        'name': 'Mine',
        'isCustom': true,
        'notes': 'slowly',
        'photoPath': 'custom_photos/custom-1.jpg',
      });

      expect(e.notes, 'slowly');
      expect(e.primaryMuscles, isEmpty);
      expect(e.instructions, isEmpty);
      expect(e.imageCount, 1);
    });
  });

  group('search and filters', () {
    const exercises = [
      Exercise(id: 'c', name: 'My Calf Thing', isCustom: true),
      Exercise(id: 'a', name: 'Calf Stretch', primaryMuscles: ['calves']),
      Exercise(
        id: 'b',
        name: 'Hamstring Roll',
        equipment: 'foam roll',
        primaryMuscles: ['hamstrings'],
      ),
    ];

    List<String> ids({String query = '', String? muscle, String? equipment}) =>
        [
          for (final e in searchExercises(
            exercises,
            query: query,
            muscle: muscle,
            equipment: equipment,
          ))
            e.id,
        ];

    test('searches names, ignoring case and outer spaces', () {
      expect(ids(), ['c', 'a', 'b']);
      expect(ids(query: '  cALf '), ['c', 'a']);
      expect(ids(query: 'zzz'), isEmpty);
    });

    test('filters by primary muscle and equipment, dropping custom', () {
      expect(ids(muscle: 'calves'), ['a']);
      expect(ids(equipment: 'none'), ['a']);
      expect(ids(equipment: 'foam roll'), ['b']);
      expect(ids(query: 'calf', muscle: 'hamstrings'), isEmpty);
    });

    test('offers sorted options from library exercises', () {
      expect(muscleOptions(exercises), ['calves', 'hamstrings']);
      expect(equipmentOptions(exercises), ['foam roll', 'none']);
    });
  });
}
