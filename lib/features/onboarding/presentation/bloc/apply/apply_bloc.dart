import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/domain/repositories/worker_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'apply_event.dart';
part 'apply_state.dart';

/// "Become a worker": POST /workers/me/apply plus the token refresh that
/// makes the new WORKER role usable (both inside the repository).
@injectable
class ApplyBloc extends Bloc<ApplyEvent, ApplyState> {
  ApplyBloc(this._repository) : super(const ApplyIdle()) {
    on<ApplySubmitted>(_onSubmitted);
  }

  final WorkerRepository _repository;

  Future<void> _onSubmitted(ApplySubmitted event, Emitter<ApplyState> emit) async {
    if (state is ApplyInProgress || state is ApplySucceeded) return;
    emit(const ApplyInProgress());
    emit(switch (await _repository.apply()) {
      Ok(:final value) => ApplySucceeded(value),
      Err(:final failure) => ApplyFailed(failure),
    });
  }
}
