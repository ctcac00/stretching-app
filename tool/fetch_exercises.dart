// Downloads free-exercise-db stretches and their images into assets/.
// Run from the project root: dart run tool/fetch_exercises.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

const _base =
    'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/';
const _parallel = 16;

final _client = HttpClient()..connectionTimeout = const Duration(seconds: 30);

Future<Uint8List> _get(String path) async {
  final uri = Uri.parse(_base)
      .resolve(path.split('/').map(Uri.encodeComponent).join('/'));
  final response = await (await _client.getUrl(uri)).close();
  if (response.statusCode != 200) {
    throw HttpException('HTTP ${response.statusCode}', uri: uri);
  }
  final bytes = BytesBuilder(copy: false);
  await response.timeout(const Duration(seconds: 60)).forEach(bytes.add);
  return bytes.takeBytes();
}

/// Images are stored flat (`<id>_<n>.jpg`) so pubspec.yaml can list one folder.
/// Must match `Exercise.assetImages`.
Future<void> _saveImage(String path) async {
  final root = p.canonicalize('assets/images');
  final nested = p.canonicalize(p.join(root, path));
  if (!p.isWithin(root, nested) ||
      path.contains(r'\') ||
      path.split('/').contains('..') ||
      p.extension(nested).toLowerCase() != '.jpg') {
    throw FormatException('unexpected image path: $path');
  }
  final target = File(p.join(root, path.replaceAll('/', '_')));
  if (target.existsSync()) return;
  final data = await _get('exercises/$path');
  final partial = File('${target.path}.part');
  await partial.writeAsBytes(data);
  await partial.rename(target.path);
}

Future<void> main() async {
  final all =
      jsonDecode(utf8.decode(await _get('dist/exercises.json'))) as List;
  final stretches = [
    for (final e in all.cast<Map<String, dynamic>>())
      if (e['category'] == 'stretching') e,
  ];
  final paths = [
    for (final e in stretches) ...(e['images'] as List).cast<String>(),
  ];
  await Directory('assets/images').create(recursive: true);
  for (var i = 0; i < paths.length; i += _parallel) {
    await Future.wait(paths.skip(i).take(_parallel).map(_saveImage));
  }
  await File('assets/exercises.json').writeAsString(jsonEncode(stretches));
  stdout.writeln('${stretches.length} exercises, ${paths.length} images');
  _client.close();
}
