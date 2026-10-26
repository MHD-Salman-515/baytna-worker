import 'package:baytna_worker/core/network/upload_file.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/documents/domain/entities/document_file.dart';
import 'package:baytna_worker/features/documents/domain/entities/worker_document.dart';
import 'package:equatable/equatable.dart';

/// One upload, possibly attempted several times.
class DocumentUpload extends Equatable {
  const DocumentUpload({
    required this.type,
    required this.file,
    required this.knownIdsBefore,
    this.expiresAt,
    this.isRetry = false,
  });

  final DocumentType type;
  final DocumentFile file;
  final DateTime? expiresAt;

  /// Ids of every document that existed BEFORE the first attempt. A document
  /// of [type] outside this set can only be this upload having landed.
  final Set<String> knownIdsBefore;

  /// Check whether an earlier attempt already landed before sending again.
  final bool isRetry;

  DocumentUpload asRetry() => DocumentUpload(
    type: type,
    file: file,
    expiresAt: expiresAt,
    knownIdsBefore: knownIdsBefore,
    isRetry: true,
  );

  @override
  List<Object?> get props => [type, file, expiresAt, knownIdsBefore, isRetry];
}

abstract interface class DocumentRepository {
  /// Newest first (as the backend returns them).
  Future<Result<List<WorkerDocument>>> listDocuments();

  /// Uploads without ever creating a duplicate: when an attempt fails in a
  /// way that leaves the outcome unknown (timeout, dropped connection, 5xx)
  /// — or before a retry — it lists her documents and adopts the upload if it
  /// landed. Fails with `DocumentTooLarge`, `DocumentTypeNotAllowed`,
  /// `DocumentExpiryRequired` among the generic failures.
  Future<Result<WorkerDocument>> upload(DocumentUpload upload, {UploadProgress? onProgress});

  /// Only while DRAFT or REJECTED; otherwise `DocumentDeletionLocked`.
  Future<Result<void>> delete(String id);
}

/// The camera / gallery / file picker. An interface so tests (and the E2E
/// run, which can't drive the system picker) can substitute it.
abstract interface class DocumentPicker {
  /// Null if she cancelled. Implementations must not leave copies on disk.
  Future<PickedBytes?> pick(DocumentSource source);
}

enum DocumentSource { camera, gallery, file }
