import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/availability/domain/entities/availability.dart';
import 'package:baytna_worker/features/availability/domain/repositories/availability_repository.dart';
import 'package:baytna_worker/features/countries/domain/repositories/country_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'availability_event.dart';
part 'availability_state.dart';

/// Her weekly schedule and date exceptions. Edits stay local until she saves
/// (PUT replaces everything). Her country's timezone is loaded with it, so
/// the screen can say which clock these times are on.
@injectable
class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  AvailabilityBloc(this._repository, this._countries, @factoryParam String countryId)
    : _countryId = countryId,
      super(const AvailabilityState()) {
    on<AvailabilityStarted>(_onStarted);
    on<AvailabilityDayToggled>(_onDayToggled);
    on<AvailabilityRangeAdded>(_onRangeAdded);
    on<AvailabilityRangeRemoved>(_onRangeRemoved);
    on<AvailabilityRangeChanged>(_onRangeChanged);
    on<AvailabilityOverrideAdded>(_onOverrideAdded);
    on<AvailabilityOverrideRemoved>(_onOverrideRemoved);
    on<AvailabilitySaved>(_onSaved);
  }

  final AvailabilityRepository _repository;
  final CountryRepository _countries;
  final String _countryId;

  static const _defaultRange = TimeRange(start: '09:00', end: '17:00');

  Future<void> _onStarted(AvailabilityStarted event, Emitter<AvailabilityState> emit) async {
    emit(state.copyWith(status: const ScheduleLoading()));
    final (schedule, country) = await (_repository.load(), _countries.getById(_countryId)).wait;
    switch ((schedule, country)) {
      case (Ok(value: final s), Ok(value: final c)):
        emit(state.copyWith(saved: s, draft: s, timezone: c.timezone, status: const ScheduleEditing()));
      case (Err(:final failure), _) || (_, Err(:final failure)):
        emit(state.copyWith(status: ScheduleLoadFailed(failure)));
    }
  }

  void _editDays(Emitter<AvailabilityState> emit, void Function(Map<int, List<TimeRange>> days) edit) {
    final days = {for (final e in state.draft.days.entries) e.key: [...e.value]};
    edit(days);
    days.removeWhere((_, ranges) => ranges.isEmpty);
    emit(
      state.copyWith(
        draft: AvailabilitySchedule(days: days, overrides: state.draft.overrides),
        status: const ScheduleEditing(),
      ),
    );
  }

  void _onDayToggled(AvailabilityDayToggled event, Emitter<AvailabilityState> emit) => _editDays(emit, (days) {
    if (event.enabled) {
      days[event.day] = [_defaultRange];
    } else {
      days.remove(event.day);
    }
  });

  void _onRangeAdded(AvailabilityRangeAdded event, Emitter<AvailabilityState> emit) => _editDays(emit, (days) {
    final ranges = days[event.day] ??= [];
    ranges.add(ranges.isEmpty ? _defaultRange : TimeRange(start: ranges.last.end, end: ranges.last.end));
  });

  void _onRangeRemoved(AvailabilityRangeRemoved event, Emitter<AvailabilityState> emit) =>
      _editDays(emit, (days) => days[event.day]?.removeAt(event.index));

  void _onRangeChanged(AvailabilityRangeChanged event, Emitter<AvailabilityState> emit) =>
      _editDays(emit, (days) => days[event.day]?[event.index] = event.range);

  void _onOverrideAdded(AvailabilityOverrideAdded event, Emitter<AvailabilityState> emit) {
    final kept = state.draft.overrides.where((o) => o.date != event.exception.date);
    emit(
      state.copyWith(
        draft: AvailabilitySchedule(
          days: state.draft.days,
          overrides: [...kept, event.exception]..sort((a, b) => a.date.compareTo(b.date)),
        ),
        status: const ScheduleEditing(),
      ),
    );
  }

  void _onOverrideRemoved(AvailabilityOverrideRemoved event, Emitter<AvailabilityState> emit) {
    emit(
      state.copyWith(
        draft: AvailabilitySchedule(
          days: state.draft.days,
          overrides: state.draft.overrides.where((o) => o != event.exception).toList(),
        ),
        status: const ScheduleEditing(),
      ),
    );
  }

  Future<void> _onSaved(AvailabilitySaved event, Emitter<AvailabilityState> emit) async {
    if (state.status is ScheduleSaving) return;
    if (!ScheduleValidator.isValid(state.draft)) {
      return emit(state.copyWith(status: const ScheduleInvalid()));
    }
    emit(state.copyWith(status: const ScheduleSaving()));
    emit(switch (await _repository.save(state.draft)) {
      Ok(:final value) => state.copyWith(saved: value, draft: value, status: const ScheduleSavedOk()),
      Err(:final failure) => state.copyWith(status: ScheduleSaveFailed(failure)),
    });
  }
}
