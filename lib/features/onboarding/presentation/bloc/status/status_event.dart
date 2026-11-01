part of 'status_bloc.dart';

sealed class StatusEvent extends Equatable {
  const StatusEvent();

  @override
  List<Object?> get props => [];
}

/// Load or (silently) reload her documents.
final class StatusDocumentsRequested extends StatusEvent {
  const StatusDocumentsRequested();
}

/// Only once she can have been approved, so never during onboarding.
final class StatusJobsRequested extends StatusEvent {
  const StatusJobsRequested();
}

final class StatusSubmitRequested extends StatusEvent {
  const StatusSubmitRequested();
}
