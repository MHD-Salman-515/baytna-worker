part of 'availability_bloc.dart';

final class AvailabilityState extends Equatable {
  const AvailabilityState({
    this.saved = const AvailabilitySchedule(),
    this.draft = const AvailabilitySchedule(),
    this.timezone = 'UTC',
    this.status = const ScheduleLoading(),
  });

  final AvailabilitySchedule saved;
  final AvailabilitySchedule draft;

  /// IANA zone of her country.
  final String timezone;
  final ScheduleStatus status;

  bool get hasChanges => saved != draft;

  AvailabilityState copyWith({
    AvailabilitySchedule? saved,
    AvailabilitySchedule? draft,
    String? timezone,
    ScheduleStatus? status,
  }) => AvailabilityState(
    saved: saved ?? this.saved,
    draft: draft ?? this.draft,
    timezone: timezone ?? this.timezone,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [saved, draft, timezone, status];
}

sealed class ScheduleStatus extends Equatable {
  const ScheduleStatus();

  @override
  List<Object?> get props => [];
}

final class ScheduleLoading extends ScheduleStatus {
  const ScheduleLoading();
}

final class ScheduleLoadFailed extends ScheduleStatus {
  const ScheduleLoadFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class ScheduleEditing extends ScheduleStatus {
  const ScheduleEditing();
}

final class ScheduleInvalid extends ScheduleStatus {
  const ScheduleInvalid();
}

final class ScheduleSaving extends ScheduleStatus {
  const ScheduleSaving();
}

final class ScheduleSavedOk extends ScheduleStatus {
  const ScheduleSavedOk();
}

final class ScheduleSaveFailed extends ScheduleStatus {
  const ScheduleSaveFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
