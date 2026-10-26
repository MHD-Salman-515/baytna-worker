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

final class StatusSubmitRequested extends StatusEvent {
  const StatusSubmitRequested();
}
