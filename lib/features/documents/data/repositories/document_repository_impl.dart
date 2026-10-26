import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/network/upload_file.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/documents/data/datasources/document_remote_data_source.dart';
import 'package:baytna_worker/features/documents/domain/document_failures.dart';
import 'package:baytna_worker/features/documents/domain/entities/worker_document.dart';
import 'package:baytna_worker/features/documents/domain/repositories/document_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: DocumentRepository)
class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._remote);

  final DocumentRemoteDataSource _remote;

  @override
  Future<Result<List<WorkerDocument>>> listDocuments() =>
      guard(() async => (await _remote.list()).map((m) => m.toEntity()).toList(growable: false));

  @override
  Future<Result<WorkerDocument>> upload(DocumentUpload upload, {UploadProgress? onProgress}) async {
    // A previous attempt may have reached the server even though we never saw
    // the response. Never send again without checking.
    if (upload.isRetry) {
      switch (await _findLanded(upload)) {
        case Ok(value: final WorkerDocument landed):
          debugPrint('[documents] retry: earlier ${upload.type.apiValue} upload had landed');
          return Ok(landed);
        case Ok(value: null):
          break;
        case Err(:final failure):
          // Can't tell whether it landed: refuse to risk a duplicate.
          return Err(failure);
      }
    }

    final result = await guard(() async {
      final model = await _remote.upload(
        type: upload.type.apiValue,
        file: UploadFile(
          bytes: upload.file.bytes,
          filename: upload.file.uploadName(upload.type.apiValue),
          contentType: upload.file.mime.contentType,
        ),
        expiresAt: upload.expiresAt == null ? null : _isoDate(upload.expiresAt!),
        onProgress: onProgress,
      );
      return model.toEntity();
    });

    switch (result) {
      case Ok():
        return result;
      case Err(:final failure) when _isAmbiguous(failure):
        // The response was lost, not necessarily the upload.
        if (await _findLanded(upload) case Ok(value: final WorkerDocument landed)) return Ok(landed);
        return result;
      case Err(:final failure):
        return Err(_uploadFailure(failure));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    final result = await guard(() => _remote.delete(id));
    return switch (result) {
      Err(failure: final ValidationFailure f)
          when f.messages.join(' ').toLowerCase().contains('can only be deleted') =>
        Err(DocumentDeletionLocked(f.debugMessage)),
      _ => result,
    };
  }

  /// A document of this type that didn't exist before the first attempt.
  Future<Result<WorkerDocument?>> _findLanded(DocumentUpload upload) async {
    final listed = await listDocuments();
    return switch (listed) {
      Ok(:final value) => Ok(
        value
            .where((d) => d.type == upload.type && !upload.knownIdsBefore.contains(d.id))
            .firstOrNull,
      ),
      Err(:final failure) => Err(failure),
    };
  }

  /// The request may or may not have been processed.
  static bool _isAmbiguous(Failure f) => switch (f) {
    NetworkFailure() || TimeoutFailure() => true,
    ServerFailure(:final statusCode) => statusCode == null || statusCode >= 500,
    _ => false,
  };

  /// Observed: 413 "File too large"; 400 "File type not recognized. Allowed:
  /// JPEG, PNG, PDF."; 400 "expiresAt is required for CRIMINAL_RECORD documents".
  static Failure _uploadFailure(Failure f) {
    if (f case ServerFailure(statusCode: 413)) return DocumentTooLarge(f.debugMessage);
    if (f case ValidationFailure(:final messages)) {
      final message = messages.join(' ').toLowerCase();
      if (message.contains('file type')) return DocumentTypeNotAllowed(f.debugMessage);
      if (message.contains('expiresat')) return DocumentExpiryRequired(f.debugMessage);
      if (message.contains('too large')) return DocumentTooLarge(f.debugMessage);
    }
    return f;
  }

  /// `expiresAt` as a calendar date (the backend parses ISO dates).
  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
