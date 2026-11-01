part of 'offerings_bloc.dart';

sealed class OfferingsState extends Equatable {
  const OfferingsState();

  @override
  List<Object?> get props => [];
}

final class OfferingsLoading extends OfferingsState {
  const OfferingsLoading();
}

final class OfferingsLoaded extends OfferingsState {
  const OfferingsLoaded({required this.services, required this.offerings});

  final List<Service> services;
  final List<Offering> offerings;

  Service? service(String id) => services.where((s) => s.id == id).firstOrNull;

  /// Each service can be offered once (409 otherwise).
  bool get canAddMore => services.any((s) => offerings.every((o) => o.serviceId != s.id));

  @override
  List<Object?> get props => [services, offerings];
}

final class OfferingsFailed extends OfferingsState {
  const OfferingsFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
