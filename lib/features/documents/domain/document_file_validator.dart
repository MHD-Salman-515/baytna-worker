import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/documents/domain/document_failures.dart';
import 'package:baytna_worker/features/documents/domain/entities/document_file.dart';

/// Mirrors the backend's upload rules so she gets a clear error immediately
/// instead of after uploading megabytes over a slow connection.
abstract final class DocumentFileValidator {
  /// 5 MB, the backend's limit (413 above it).
  static const int maxBytes = 5 * 1024 * 1024;

  static Result<DocumentFile> validate(PickedBytes picked) {
    if (picked.bytes.isEmpty) return const Err<DocumentFile>(DocumentTypeNotAllowed('Empty file'));
    if (picked.bytes.length > maxBytes) {
      return Err(DocumentTooLarge('${picked.bytes.length} B > $maxBytes B'));
    }
    final mime = DocumentMime.sniff(picked.bytes);
    if (mime == null) return Err(DocumentTypeNotAllowed('Unrecognized content: ${picked.name}'));
    return Ok(DocumentFile(bytes: picked.bytes, mime: mime, name: picked.name));
  }

  /// The day after [today] at the earliest: an expiry of today or before is
  /// already expired by the time a reviewer sees it.
  static Failure? validateExpiry(DateTime? expiresAt, DateTime today) {
    if (expiresAt == null) return const DocumentExpiryRequired();
    final startOfTomorrow = DateTime(today.year, today.month, today.day + 1);
    return expiresAt.isBefore(startOfTomorrow) ? const DocumentExpiryRequired('In the past') : null;
  }
}
