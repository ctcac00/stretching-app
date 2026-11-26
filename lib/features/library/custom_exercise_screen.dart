import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers.dart';

/// Overridden in tests.
final imagePickerProvider = Provider((ref) => ImagePicker());

/// Form for a new custom exercise: name, notes and an optional photo.
class CustomExerciseScreen extends ConsumerStatefulWidget {
  const CustomExerciseScreen({super.key});

  @override
  ConsumerState<CustomExerciseScreen> createState() =>
      _CustomExerciseScreenState();
}

class _CustomExerciseScreenState extends ConsumerState<CustomExerciseScreen> {
  final _name = TextEditingController();
  final _notes = TextEditingController();
  String? _photo;
  String? _nameError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android) _recoverPhoto();
  }

  /// Android may kill the app while the picker is open; the photo then arrives
  /// here the next time this form is opened.
  Future<void> _recoverPhoto() async {
    try {
      final lost = await ref.read(imagePickerProvider).retrieveLostData();
      final path = lost.file?.path;
      if (path != null && mounted) setState(() => _photo ??= path);
    } catch (error) {
      debugPrint('No lost photo recovered: $error');
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await ref
          .read(imagePickerProvider)
          .pickImage(
            source: ImageSource.gallery,
            maxWidth: 800,
            maxHeight: 800,
            imageQuality: 80,
            // Avoids the iOS photo library permission prompt.
            requestFullMetadata: false,
          );
      if (file != null && mounted) setState(() => _photo = file.path);
    } catch (_) {
      _showError('Could not open the photo library.');
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = 'Enter a name');
      return;
    }
    _saving = true;
    try {
      await ref
          .read(customExerciseRepositoryProvider)
          .add(name: _name.text, notes: _notes.text, photoSource: _photo);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      _saving = false;
      _showError('Could not save the exercise.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photo;
    return Scaffold(
      appBar: AppBar(title: const Text('Custom exercise')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Name',
              errorText: _nameError,
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notes,
            minLines: 4,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Notes',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 10),
          if (photo != null) ...[
            Image.file(
              File(photo),
              height: 200,
              errorBuilder: (_, _, _) => const Text('Could not read photo.'),
            ),
            const SizedBox(height: 10),
          ],
          OutlinedButton.icon(
            icon: const Icon(Icons.photo_library),
            label: Text(
              photo == null ? 'Add photo (optional)' : 'Change photo',
            ),
            onPressed: _pickPhoto,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
