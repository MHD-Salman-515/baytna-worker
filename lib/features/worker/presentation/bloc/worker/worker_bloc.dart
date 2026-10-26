import 'dart:async';

import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/auth/domain/entities/user.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/domain/repositories/worker_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'worker_event.dart';
part 'worker_state.dart';

/// THE SPINE OF THE APP: her worker profile, and therefore her
/// verificationStatus. App-wide; the router redirects on its state, so a
/// worker who isn't APPROVED can't reach anything that implies she can work.
///
/// Follows the session: signing in loads the profile, signing out forgets it.
@lazySingleton
class WorkerBloc extends Bloc<WorkerEvent, WorkerState> {
  WorkerBloc(this._repository, AuthBloc auth) : super(const WorkerUnknown()) {
    on<WorkerLoadRequested>(_onLoadRequested);
    on<WorkerRefreshRequested>(_onRefreshRequested);
    on<WorkerProfileChanged>((e, emit) => emit(WorkerLoaded(e.profile)));
    on<WorkerSignedOut>((e, emit) => emit(const WorkerUnknown()));
    _onAuth(auth.state);
    _authSub = auth.stream.listen(_onAuth);
  }

  final WorkerRepository _repository;
  late final StreamSubscription<AuthState> _authSub;
  User? _user;

  void _onAuth(AuthState auth) {
    switch (auth) {
      case AuthAuthenticated(:final user):
        // AuthBloc re-emits the same user on e.g. a locale sync; only a
        // different account warrants a reload.
        if (user.id == _user?.id) return;
        _user = user;
        add(const WorkerLoadRequested());
      case AuthUnauthenticated() || AuthUnknown():
        if (_user == null) return;
        _user = null;
        add(const WorkerSignedOut());
    }
  }

  Future<void> _onLoadRequested(WorkerLoadRequested event, Emitter<WorkerState> emit) async {
    final user = _user;
    if (user == null) return;
    emit(const WorkerUnknown());
    emit(_toState(await _repository.fetchProfile(accountRoles: user.roles)));
  }

  /// Silent: keeps showing what she has while it reloads, and a failed
  /// refresh (offline, server asleep) never throws her out of the screen.
  Future<void> _onRefreshRequested(WorkerRefreshRequested event, Emitter<WorkerState> emit) async {
    final user = _user;
    if (user == null) return;
    if (state is! WorkerLoaded) return add(const WorkerLoadRequested());
    final result = await _repository.fetchProfile(accountRoles: user.roles);
    if (result case Ok()) emit(_toState(result));
  }

  static WorkerState _toState(Result<WorkerProfile?> result) => switch (result) {
    Ok(value: final WorkerProfile profile) => WorkerLoaded(profile),
    Ok(value: null) => const WorkerNotApplied(),
    Err(:final failure) => WorkerLoadFailed(failure),
  };

  @override
  Future<void> close() async {
    await _authSub.cancel();
    await super.close();
  }
}
