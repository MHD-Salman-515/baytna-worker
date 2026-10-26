part of 'documents_bloc.dart';

final class DocumentsState extends Equatable {
  const DocumentsState({
    this.documents = const [],
    this.drafts = const {},
    this.load = const DocumentsLoading(),
    this.notice,
  });

  /// From the server, newest first.
  final List<WorkerDocument> documents;

  /// Picked-but-not-yet-uploaded files, per type. In memory only.
  final Map<DocumentType, DocumentDraft> drafts;
  final DocumentsLoadStatus load;

  /// One-shot message for a snackbar.
  final DocumentsNotice? notice;

  WorkerDocument? current(DocumentType type) => DocumentRequirements.current(documents, type);

  bool get isUploading => drafts.values.any((d) => d.status is DraftUploading);

  DocumentsState copyWith({
    List<WorkerDocument>? documents,
    Map<DocumentType, DocumentDraft>? drafts,
    DocumentsLoadStatus? load,
    DocumentsNotice? notice,
  }) => DocumentsState(
    documents: documents ?? this.documents,
    drafts: drafts ?? this.drafts,
    load: load ?? this.load,
    notice: notice ?? this.notice,
  );

  DocumentsState withDraft(DocumentType type, DocumentDraft draft) =>
      copyWith(drafts: {...drafts, type: draft});

  DocumentsState withoutDraft(DocumentType type) =>
      copyWith(drafts: {...drafts}..remove(type));

  @override
  List<Object?> get props => [documents, drafts, load, notice];
}

final class DocumentDraft extends Equatable {
  const DocumentDraft({this.file, this.expiresAt, this.status = const DraftReady(), this.attempt});

  /// Null when what she picked was rejected locally (see [status]).
  final DocumentFile? file;
  final DateTime? expiresAt;
  final DraftStatus status;

  /// Set once an upload has been attempted; later taps retry THIS attempt.
  final DocumentUpload? attempt;

  DocumentDraft copyWith({DraftStatus? status, DocumentUpload? Function()? attempt}) => DocumentDraft(
    file: file,
    expiresAt: expiresAt,
    status: status ?? this.status,
    attempt: attempt != null ? attempt() : this.attempt,
  );

  @override
  List<Object?> get props => [file, expiresAt, status, attempt];
}

sealed class DraftStatus extends Equatable {
  const DraftStatus();

  @override
  List<Object?> get props => [];
}

final class DraftReady extends DraftStatus {
  const DraftReady();
}

final class DraftUploading extends DraftStatus {
  const DraftUploading([this.progress]);

  /// 0..1, or null before the first progress report.
  final double? progress;

  @override
  List<Object?> get props => [progress];
}

/// The pick was rejected (size/type), the expiry is missing, or the upload
/// failed. With a file present, the action becomes "retry".
final class DraftError extends DraftStatus {
  const DraftError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

sealed class DocumentsLoadStatus extends Equatable {
  const DocumentsLoadStatus();

  @override
  List<Object?> get props => [];
}

final class DocumentsLoading extends DocumentsLoadStatus {
  const DocumentsLoading();
}

final class DocumentsLoaded extends DocumentsLoadStatus {
  const DocumentsLoaded();
}

final class DocumentsLoadFailed extends DocumentsLoadStatus {
  const DocumentsLoadFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

sealed class DocumentsNotice extends Equatable {
  const DocumentsNotice();
}

final class DocumentUploadedNotice extends DocumentsNotice {
  const DocumentUploadedNotice(this.document);

  final WorkerDocument document;

  @override
  List<Object?> get props => [document];
}
