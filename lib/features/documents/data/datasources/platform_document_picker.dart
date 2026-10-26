import 'dart:io';

import 'package:baytna_worker/features/documents/domain/entities/document_file.dart';
import 'package:baytna_worker/features/documents/domain/repositories/document_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Camera / gallery (image_picker) and PDF/image files (file_picker).
///
/// These are photos of her national ID and criminal record, so nothing may
/// outlive the screen: the bytes are read into memory and every temporary
/// copy the plugins wrote into the app cache is deleted straight away (see
/// [purgeTemporaryFiles]). Nothing is ever written to the device gallery.
@LazySingleton(as: DocumentPicker)
class PlatformDocumentPicker implements DocumentPicker {
  PlatformDocumentPicker() : _images = ImagePicker();

  final ImagePicker _images;

  /// Downscaled on-device to stay well under the 5 MB limit while keeping ID
  /// text legible. Only applies to camera/gallery images, never to PDFs.
  static const _maxDimension = 2400.0;
  static const _jpegQuality = 85;

  @override
  Future<PickedBytes?> pick(DocumentSource source) async {
    try {
      return switch (source) {
        DocumentSource.camera => await _pickImage(ImageSource.camera),
        DocumentSource.gallery => await _pickImage(ImageSource.gallery),
        DocumentSource.file => await _pickFile(),
      };
    } finally {
      await purgeTemporaryFiles();
    }
  }

  Future<PickedBytes?> _pickImage(ImageSource source) async {
    final file = await _images.pickImage(
      source: source,
      maxWidth: _maxDimension,
      maxHeight: _maxDimension,
      imageQuality: _jpegQuality,
      requestFullMetadata: false, // no location/EXIF permission prompt
    );
    if (file == null) return null;
    return PickedBytes(bytes: await file.readAsBytes(), name: file.name);
  }

  Future<PickedBytes?> _pickFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (file == null) return null;
    return PickedBytes(bytes: await file.readAsBytes(), name: file.name);
  }

  /// Deletes what the pickers leave in the app cache (their own docs suggest
  /// clearing it on startup — we also do it after every pick):
  ///  * file_picker: `<cache>/file_picker/…`
  ///  * image_picker: `<cache>/<uuid>/<name>` (gallery copies), `scaled_*`
  ///    (resized output) and `<uuid><n>.jpg` (camera capture).
  static Future<void> purgeTemporaryFiles() async {
    if (kIsWeb) return;
    try {
      await FilePicker.clearTemporaryFiles();
    } on Object catch (e) {
      debugPrint('[documents] file_picker cleanup failed: $e');
    }
    try {
      final cache = await getTemporaryDirectory();
      if (!cache.existsSync()) return;
      for (final entity in cache.listSync(followLinks: false)) {
        final name = p.basename(entity.path);
        final isPickerArtifact = switch (entity) {
          Directory() => _uuid.hasMatch(name) || name == 'file_picker',
          File() => name.startsWith('scaled_') || _cameraTemp.hasMatch(name),
          _ => false,
        };
        if (isPickerArtifact) await entity.delete(recursive: true);
      }
    } on Object catch (e) {
      debugPrint('[documents] image_picker cleanup failed: $e');
    }
  }

  static final _uuid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');
  static final _cameraTemp = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\d*\.(jpg|jpeg|png)$',
  );
}
