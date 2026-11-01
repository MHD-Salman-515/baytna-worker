part of 'offerings_bloc.dart';

sealed class OfferingsEvent extends Equatable {
  const OfferingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load, or silently reload after returning from the form.
final class OfferingsRequested extends OfferingsEvent {
  const OfferingsRequested();
}
