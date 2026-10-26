import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A file to send as multipart/form-data, held in memory only. Features hand
/// this to `ApiClient.upload`, so they never touch Dio's MultipartFile.
class UploadFile extends Equatable {
  const UploadFile({
    required this.bytes,
    required this.filename,
    required this.contentType,
  });

  final Uint8List bytes;
  final String filename;

  /// e.g. `image/jpeg`. Sent as the part's Content-Type.
  final String contentType;

  @override
  List<Object?> get props => [bytes, filename, contentType];

  /// Never dump file bytes into logs.
  @override
  String toString() => 'UploadFile($filename, $contentType, ${bytes.length} B)';
}

/// (bytes sent, total bytes). Total is -1 when unknown.
typedef UploadProgress = void Function(int sent, int total);
