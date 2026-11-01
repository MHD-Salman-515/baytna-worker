part of 'offering_form_bloc.dart';

sealed class OfferingFormEvent extends Equatable {
  const OfferingFormEvent();

  @override
  List<Object?> get props => [];
}

final class OfferingFormStarted extends OfferingFormEvent {
  const OfferingFormStarted();
}

final class OfferingServiceSelected extends OfferingFormEvent {
  const OfferingServiceSelected(this.serviceId);

  final String serviceId;

  @override
  List<Object?> get props => [serviceId];
}

final class OfferingPricingTypeSelected extends OfferingFormEvent {
  const OfferingPricingTypeSelected(this.type);

  final PricingType type;

  @override
  List<Object?> get props => [type];
}

/// The hourly rate or the fixed price, whichever applies.
final class OfferingAmountChanged extends OfferingFormEvent {
  const OfferingAmountChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class OfferingMinHoursChanged extends OfferingFormEvent {
  const OfferingMinHoursChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class OfferingTierAdded extends OfferingFormEvent {
  const OfferingTierAdded();
}

final class OfferingTierRemoved extends OfferingFormEvent {
  const OfferingTierRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class OfferingTierChanged extends OfferingFormEvent {
  const OfferingTierChanged(this.index, {this.maxRooms, this.price});

  final int index;
  final String? maxRooms;
  final String? price;

  @override
  List<Object?> get props => [index, maxRooms, price];
}

final class OfferingActiveToggled extends OfferingFormEvent {
  const OfferingActiveToggled({required this.isActive});

  final bool isActive;

  @override
  List<Object?> get props => [isActive];
}

final class OfferingFormSubmitted extends OfferingFormEvent {
  const OfferingFormSubmitted();
}

final class OfferingDeleteRequested extends OfferingFormEvent {
  const OfferingDeleteRequested();
}
