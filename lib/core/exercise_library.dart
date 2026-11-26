import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/exercise.dart';

/// Loads the bundled stretches.
Future<List<Exercise>> loadBundledExercises(AssetBundle bundle) async {
  final json = jsonDecode(await bundle.loadString('assets/exercises.json'));
  return [
    for (final e in json as List) Exercise.fromJson(e as Map<String, dynamic>),
  ];
}
