import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/domain/repositories/worker_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// One switch with one call, hence a Cubit. The result is handed to the
/// WorkerBloc by the screen, which owns the profile.
@injectable
class AvailabilityToggleCubit extends Cubit<AvailabilityToggleState> {
  AvailabilityToggleCubit(this._repository) : super(const AvailabilityToggleState());

  final WorkerRepository _repository;

  Future<void> set({required bool isAvailable}) async {
    if (state.saving) return;
    emit(const AvailabilityToggleState(saving: true));
    emit(switch (await _repository.setAvailability(isAvailable: isAvailable)) {
      Ok(:final value) => AvailabilityToggleState(updated: value),
      Err(:final failure) => AvailabilityToggleState(failure: failure),
    });
  }
}

final class AvailabilityToggleState extends Equatable {
  const AvailabilityToggleState({this.saving = false, this.updated, this.failure});

  final bool saving;
  final WorkerProfile? updated;
  final Failure? failure;

  @override
  List<Object?> get props => [saving, updated, failure];
}
