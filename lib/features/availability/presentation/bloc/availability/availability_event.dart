part of 'availability_bloc.dart';

sealed class AvailabilityEvent extends Equatable {
  const AvailabilityEvent();

  @override
  List<Object?> get props => [];
}

final class AvailabilityStarted extends AvailabilityEvent {
  const AvailabilityStarted();
}

final class AvailabilityDayToggled extends AvailabilityEvent {
  const AvailabilityDayToggled(this.day, {required this.enabled});

  final int day;
  final bool enabled;

  @override
  List<Object?> get props => [day, enabled];
}

final class AvailabilityRangeAdded extends AvailabilityEvent {
  const AvailabilityRangeAdded(this.day);

  final int day;

  @override
  List<Object?> get props => [day];
}

final class AvailabilityRangeRemoved extends AvailabilityEvent {
  const AvailabilityRangeRemoved(this.day, this.index);

  final int day;
  final int index;

  @override
  List<Object?> get props => [day, index];
}

final class AvailabilityRangeChanged extends AvailabilityEvent {
  const AvailabilityRangeChanged(this.day, this.index, this.range);

  final int day;
  final int index;
  final TimeRange range;

  @override
  List<Object?> get props => [day, index, range];
}

final class AvailabilityOverrideAdded extends AvailabilityEvent {
  const AvailabilityOverrideAdded(this.exception);

  final DateOverride exception;

  @override
  List<Object?> get props => [exception];
}

final class AvailabilityOverrideRemoved extends AvailabilityEvent {
  const AvailabilityOverrideRemoved(this.exception);

  final DateOverride exception;

  @override
  List<Object?> get props => [exception];
}

final class AvailabilitySaved extends AvailabilityEvent {
  const AvailabilitySaved();
}
