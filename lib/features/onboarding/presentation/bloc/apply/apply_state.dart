part of 'apply_bloc.dart';

sealed class ApplyState extends Equatable {
  const ApplyState();

  @override
  List<Object?> get props => [];
}

final class ApplyIdle extends ApplyState {
  const ApplyIdle();
}

final class ApplyInProgress extends ApplyState {
  const ApplyInProgress();
}

/// Applied AND the token now carries WORKER. The screen hands [profile] to
/// the WorkerBloc, and the router moves on.
final class ApplySucceeded extends ApplyState {
  const ApplySucceeded(this.profile);

  final WorkerProfile profile;

  @override
  List<Object?> get props => [profile];
}

/// Safe to retry: applying is idempotent.
final class ApplyFailed extends ApplyState {
  const ApplyFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
