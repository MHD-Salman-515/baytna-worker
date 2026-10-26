part of 'worker_bloc.dart';

sealed class WorkerState extends Equatable {
  const WorkerState();

  @override
  List<Object?> get props => [];
}

/// Signed out, or loading — the splash is shown while signed in.
final class WorkerUnknown extends WorkerState {
  const WorkerUnknown();
}

/// Signed in but never applied: only the "become a worker" screen.
final class WorkerNotApplied extends WorkerState {
  const WorkerNotApplied();
}

final class WorkerLoaded extends WorkerState {
  const WorkerLoaded(this.profile);

  final WorkerProfile profile;

  @override
  List<Object?> get props => [profile];
}

/// Couldn't load (offline / server asleep). Nothing is assumed about her
/// status — in particular she is NOT treated as approved.
final class WorkerLoadFailed extends WorkerState {
  const WorkerLoadFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
