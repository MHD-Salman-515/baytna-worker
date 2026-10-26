part of 'worker_bloc.dart';

sealed class WorkerEvent extends Equatable {
  const WorkerEvent();

  @override
  List<Object?> get props => [];
}

/// Load from scratch (shows the splash). Also the retry after a failure.
final class WorkerLoadRequested extends WorkerEvent {
  const WorkerLoadRequested();
}

/// Reload in the background (pull-to-refresh, app resumed) — e.g. to notice
/// that an admin approved her.
final class WorkerRefreshRequested extends WorkerEvent {
  const WorkerRefreshRequested();
}

/// A screen got a newer profile from the server (apply, save, submit).
final class WorkerProfileChanged extends WorkerEvent {
  const WorkerProfileChanged(this.profile);

  final WorkerProfile profile;

  @override
  List<Object?> get props => [profile];
}

final class WorkerSignedOut extends WorkerEvent {
  const WorkerSignedOut();
}
