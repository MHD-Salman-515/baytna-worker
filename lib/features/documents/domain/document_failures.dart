import 'package:baytna_worker/core/error/failure.dart';

sealed class DocumentFailure extends FeatureFailure {
  const DocumentFailure([super.debugMessage]);
}

/// Over 5 MB — caught locally, or 413 from the server.
final class DocumentTooLarge extends DocumentFailure {
  const DocumentTooLarge([super.debugMessage]);
}

/// Not a real JPEG/PNG/PDF — caught locally by magic bytes, or 400 "File
/// type not recognized" from the server.
final class DocumentTypeNotAllowed extends DocumentFailure {
  const DocumentTypeNotAllowed([super.debugMessage]);
}

/// CRIMINAL_RECORD without a (future) expiry date.
final class DocumentExpiryRequired extends DocumentFailure {
  const DocumentExpiryRequired([super.debugMessage]);
}

/// 400 "Documents can only be deleted while the profile is DRAFT or REJECTED".
final class DocumentDeletionLocked extends DocumentFailure {
  const DocumentDeletionLocked([super.debugMessage]);
}
