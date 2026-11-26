import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:limbloop/core/providers.dart';
import 'package:limbloop/features/library/custom_exercise_screen.dart';
import 'package:limbloop/features/library/library_hooks.dart';
import 'package:limbloop/features/library/library_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../support/test_support.dart';

const _bundled = [
  Exercise(
    id: 'calf',
    name: 'Calf Stretch',
    level: 'beginner',
    primaryMuscles: ['calves'],
    instructions: ['Lean forward.'],
    images: ['calf/0.jpg', 'calf/1.jpg'],
  ),
  Exercise(
    id: 'ham',
    name: 'Hamstring Roll',
    equipment: 'foam roll',
    primaryMuscles: ['hamstrings'],
  ),
];

class _FakePicker implements ImagePicker {
  _FakePicker(this.path);

  final String path;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async => XFile(path);

  @override
  Future<LostDataResponse> retrieveLostData() async => LostDataResponse.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late Directory documents;

  setUp(() {
    db = testDatabase();
    documents = Directory.systemTemp.createTempSync('limbloop_library');
  });
  tearDown(() => documents.deleteSync(recursive: true));

  Future<void> pump(
    WidgetTester tester,
    Widget home, [
    String photo = 'unused',
  ]) async {
    // Tall enough that lazy lists build everything.
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          documentsDirectoryProvider.overrideWithValue(documents),
          bundledExercisesProvider.overrideWith((ref) async => _bundled),
          imagePickerProvider.overrideWithValue(_FakePicker(photo)),
        ],
        child: MaterialApp(home: home),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await db.close();
  }

  testWidgets('library searches and filters', (tester) async {
    await pump(tester, const LibraryScreen());
    expect(find.text('Search 2 stretches'), findsOne);

    await tester.enterText(find.byType(TextField), 'ham');
    await tester.pump();
    expect(find.text('Calf Stretch'), findsNothing);
    expect(find.text('Hamstring Roll'), findsOne);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    await tester.tap(find.text('All muscles'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('calves').last);
    await tester.pumpAndSettle();
    expect(find.text('Calf Stretch'), findsOne);
    expect(find.text('Hamstring Roll'), findsNothing);

    await tester.tap(find.text('All equipment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('foam roll').last);
    await tester.pumpAndSettle();
    expect(find.text('No matches.'), findsOne);
    await finish(tester);
  });

  testWidgets('creates a custom exercise with a photo, then deletes it', (
    tester,
  ) async {
    final source = File('${documents.path}/picked.jpg')
      ..writeAsBytesSync([1, 2, 3]);
    await pump(tester, const LibraryScreen(), source.path);
    await tester.tap(find.text('Custom exercise'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter a name'), findsOne);

    await tester.enterText(find.byType(TextField).first, 'Wall lean');
    await tester.enterText(find.byType(TextField).last, 'Gently');
    await tester.tap(find.text('Add photo (optional)'));
    await tester.pump();
    // The photo is copied with real file IO.
    await tester.runAsync(() async {
      await tester.tap(find.text('Save'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    final saved = (await CustomExerciseRepository(
      db,
      documents,
      DateTime.now,
    ).getAll()).single;
    expect(saved.notes, 'Gently');
    final copy = File('${documents.path}/${saved.photoPath}');
    expect(copy.existsSync(), isTrue);
    expect(find.text('Wall lean'), findsOne);

    await RoutineRepository(db).add(saved.id);
    await tester.tap(find.text('Wall lean'));
    await tester.pumpAndSettle();
    expect(find.text('Gently'), findsOne);
    expect(find.text('Add again to routine'), findsOne);

    await tester.tap(find.text('Delete exercise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    // The delete mixes database work (fake time) and file IO (real time).
    for (var i = 0; i < 10; i++) {
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
    }
    await tester.pumpAndSettle();

    expect(find.text('Wall lean'), findsNothing);
    expect(find.text('Library'), findsOne);
    expect(await RoutineRepository(db).getAll(), isEmpty);
    expect(copy.existsSync(), isFalse);
    await finish(tester);
  });

  testWidgets('detail toggles images and adds to the routine', (tester) async {
    await pump(tester, const LibraryScreen());
    await tester.tap(find.text('Calf Stretch'));
    // The alternating image never settles.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('beginner · none · calves'), findsOne);
    expect(find.text('Lean forward.'), findsOne);
    await tester.tap(find.text('Show side by side'));
    await tester.pumpAndSettle();
    expect(find.text('Alternate images'), findsOne);

    await tester.tap(find.text('Add to routine'));
    await tester.pumpAndSettle();
    final item = (await RoutineRepository(db).getAll()).single;
    expect(item.exerciseId, 'calf');
    await finish(tester);
  });

  testWidgets('picker returns the chosen id', (tester) async {
    Future<String?>? result;
    await pump(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => result = pickExercise(context),
          child: const Text('Pick'),
        ),
      ),
    );
    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hamstring Roll'));
    await tester.pumpAndSettle();

    expect(await result, 'ham');
    await finish(tester);
  });
}
