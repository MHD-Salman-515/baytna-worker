import 'package:baytna_worker/features/documents/domain/entities/worker_document.dart';

/// Where one required document stands, as the app shows it.
enum RequirementState {
  missing,
  pending,
  approved,
  rejected,

  /// Uploaded but `expiresAt` has passed — the backend treats it as missing.
  expired,
}

/// The backend keeps EVERY upload (it doesn't replace or dedupe), so a type
/// can have several documents. The newest one is the one that counts.
abstract final class DocumentRequirements {
  static WorkerDocument? current(List<WorkerDocument> documents, DocumentType type) {
    WorkerDocument? newest;
    for (final d in documents) {
      if (d.type == type && (newest == null || d.createdAt.isAfter(newest.createdAt))) newest = d;
    }
    return newest;
  }

  static RequirementState stateOf(WorkerDocument? doc, DateTime now) {
    if (doc == null) return RequirementState.missing;
    if (doc.isExpiredAt(now)) return RequirementState.expired;
    return switch (doc.status) {
      DocumentStatus.pending || DocumentStatus.unknown => RequirementState.pending,
      DocumentStatus.approved => RequirementState.approved,
      DocumentStatus.rejected => RequirementState.rejected,
    };
  }

  /// Required types that would block submission.
  static List<DocumentType> outstanding(List<WorkerDocument> documents, DateTime now) => [
    for (final type in DocumentType.required)
      if (switch (stateOf(current(documents, type), now)) {
        RequirementState.missing || RequirementState.rejected || RequirementState.expired => true,
        RequirementState.pending || RequirementState.approved => false,
      })
        type,
  ];

  /// Older uploads of the same type as [keep] — deleted after a replacement
  /// lands, so a stale rejected copy can't linger next to the new one.
  static List<WorkerDocument> superseded(List<WorkerDocument> documents, WorkerDocument keep) => [
    for (final d in documents)
      if (d.type == keep.type && d.id != keep.id) d,
  ];
}
