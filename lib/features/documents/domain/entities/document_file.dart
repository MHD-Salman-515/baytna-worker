import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// The formats the backend accepts. It checks the real type from the file's
/// MAGIC BYTES (a renamed text file is refused), so the app does the same
/// before uploading rather than trusting the extension.
enum DocumentMime {
  jpeg('image/jpeg', 'jpg'),
  png('image/png', 'png'),
  pdf('application/pdf', 'pdf');

  DocumentMime(this.contentType, this.extension);

  final String contentType;
  final String extension;

  bool get isImage => this != pdf;

  static DocumentMime? sniff(Uint8List bytes) {
    bool startsWith(List<int> magic) {
      if (bytes.length < magic.length) return false;
      for (var i = 0; i < magic.length; i++) {
        if (bytes[i] != magic[i]) return false;
      }
      return true;
    }

    if (startsWith(const [0xFF, 0xD8, 0xFF])) return jpeg;
    if (startsWith(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) return png;
    if (startsWith(const [0x25, 0x50, 0x44, 0x46, 0x2D])) return pdf; // %PDF-
    return null;
  }
}

/// A file she picked, held IN MEMORY ONLY: it is never written to app
/// storage, and dies with the documents screen.
class DocumentFile extends Equatable {
  const DocumentFile({required this.bytes, required this.mime, required this.name});

  final Uint8List bytes;
  final DocumentMime mime;

  /// Display name only. The upload uses a neutral name (see uploadName).
  final String name;

  int get sizeBytes => bytes.length;

  /// Never send her original filename (it may contain her name or ID number).
  String uploadName(String typeApiValue) => '${typeApiValue.toLowerCase()}.${mime.extension}';

  /// Bytes are compared by identity: two picks are different files.
  @override
  List<Object?> get props => [identityHashCode(bytes), mime, name];

  @override
  String toString() => 'DocumentFile($name, ${mime.contentType}, $sizeBytes B)';
}

/// What the platform picker hands back, before validation.
class PickedBytes {
  const PickedBytes({required this.bytes, required this.name});

  final Uint8List bytes;
  final String name;
}
