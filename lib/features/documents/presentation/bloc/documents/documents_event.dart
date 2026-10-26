part of 'documents_bloc.dart';

sealed class DocumentsEvent extends Equatable {
  const DocumentsEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) her documents.
final class DocumentsStarted extends DocumentsEvent {
  const DocumentsStarted();
}

final class DocumentPickRequested extends DocumentsEvent {
  const DocumentPickRequested(this.type, this.source);

  final DocumentType type;
  final DocumentSource source;

  @override
  List<Object?> get props => [type, source];
}

final class DocumentExpiryChanged extends DocumentsEvent {
  const DocumentExpiryChanged(this.type, this.expiresAt);

  final DocumentType type;
  final DateTime expiresAt;

  @override
  List<Object?> get props => [type, expiresAt];
}

final class DocumentDraftDiscarded extends DocumentsEvent {
  const DocumentDraftDiscarded(this.type);

  final DocumentType type;

  @override
  List<Object?> get props => [type];
}

/// Upload the draft, or retry its failed upload.
final class DocumentUploadRequested extends DocumentsEvent {
  const DocumentUploadRequested(this.type);

  final DocumentType type;

  @override
  List<Object?> get props => [type];
}

final class _DocumentUploadProgressed extends DocumentsEvent {
  const _DocumentUploadProgressed(this.type, this.sent, this.total);

  final DocumentType type;
  final int sent;
  final int total;

  @override
  List<Object?> get props => [type, sent, total];
}
