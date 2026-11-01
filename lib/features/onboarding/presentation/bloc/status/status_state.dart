part of 'status_bloc.dart';

final class StatusState extends Equatable {
  const StatusState({
    this.documents = const StatusDocumentsLoading(),
    this.submit = const StatusSubmitIdle(),
    this.jobsInHand = const [],
  });

  final StatusDocuments documents;
  final StatusSubmit submit;

  /// Jobs accepted before her status changed.
  final List<Booking> jobsInHand;

  List<WorkerDocument> get documentList => switch (documents) {
    StatusDocumentsLoaded(:final documents) => documents,
    StatusDocumentsLoading() || StatusDocumentsFailed() => const [],
  };

  StatusState copyWith({StatusDocuments? documents, StatusSubmit? submit, List<Booking>? jobsInHand}) => StatusState(
    documents: documents ?? this.documents,
    submit: submit ?? this.submit,
    jobsInHand: jobsInHand ?? this.jobsInHand,
  );

  @override
  List<Object?> get props => [documents, submit, jobsInHand];
}

sealed class StatusDocuments extends Equatable {
  const StatusDocuments();

  @override
  List<Object?> get props => [];
}

final class StatusDocumentsLoading extends StatusDocuments {
  const StatusDocumentsLoading();
}

final class StatusDocumentsLoaded extends StatusDocuments {
  const StatusDocumentsLoaded(this.documents);

  final List<WorkerDocument> documents;

  @override
  List<Object?> get props => [documents];
}

final class StatusDocumentsFailed extends StatusDocuments {
  const StatusDocumentsFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

sealed class StatusSubmit extends Equatable {
  const StatusSubmit();

  @override
  List<Object?> get props => [];
}

final class StatusSubmitIdle extends StatusSubmit {
  const StatusSubmitIdle();
}

final class StatusSubmitting extends StatusSubmit {
  const StatusSubmitting();
}

/// The screen forwards [profile] (now PENDING_REVIEW) to the WorkerBloc.
final class StatusSubmitSucceeded extends StatusSubmit {
  const StatusSubmitSucceeded(this.profile);

  final WorkerProfile profile;

  @override
  List<Object?> get props => [profile];
}

/// The server's status moved on without us; the screen reloads the profile.
final class StatusSubmitConflict extends StatusSubmit {
  const StatusSubmitConflict();
}

final class StatusSubmitFailed extends StatusSubmit {
  const StatusSubmitFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
