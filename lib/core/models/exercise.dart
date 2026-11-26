/// A bundled stretch or a user-created exercise.
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    this.force,
    this.level,
    this.mechanic,
    this.equipment,
    this.primaryMuscles = const [],
    this.secondaryMuscles = const [],
    this.instructions = const [],
    this.category,
    this.images = const [],
    this.isCustom = false,
    this.notes = '',
    this.photoPath,
  });

  /// Bundled entries follow the free-exercise-db schema. Custom entries have
  /// `id`, `name`, `isCustom: true`, `notes` and optionally `photoPath`.
  factory Exercise.fromJson(Map<String, dynamic> json) {
    List<String> strings(String key) =>
        (json[key] as List?)?.cast<String>() ?? const [];
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      force: json['force'] as String?,
      level: json['level'] as String?,
      mechanic: json['mechanic'] as String?,
      equipment: json['equipment'] as String?,
      primaryMuscles: strings('primaryMuscles'),
      secondaryMuscles: strings('secondaryMuscles'),
      instructions: strings('instructions'),
      category: json['category'] as String?,
      images: strings('images'),
      isCustom: json['isCustom'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
      photoPath: json['photoPath'] as String?,
    );
  }

  final String id;
  final String name;
  final String? force;
  final String? level;
  final String? mechanic;
  final String? equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final String? category;

  /// Image paths as in the source data, e.g. `Some_Stretch/0.jpg`.
  final List<String> images;

  final bool isCustom;
  final String notes;

  /// Custom exercises only: photo path relative to the app documents folder.
  final String? photoPath;

  /// Equipment for display and filtering; null shows as "none".
  /// Not meaningful for custom exercises.
  String get equipmentLabel => equipment ?? 'none';

  /// Asset keys of the bundled images (stored flat by the fetch tool).
  List<String> get assetImages => [
    for (final path in images) 'assets/images/${path.replaceAll('/', '_')}',
  ];

  /// Number of pictures to show: bundled images, or the custom photo.
  int get imageCount => isCustom ? (photoPath == null ? 0 : 1) : images.length;
}
