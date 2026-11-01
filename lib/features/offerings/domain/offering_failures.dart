import 'package:baytna_worker/core/error/failure.dart';

sealed class OfferingFailure extends FeatureFailure {
  const OfferingFailure([super.debugMessage]);
}

/// 400 "price must be between 10000 and 50000 (inclusive)". The app checks
/// first; this covers an admin changing the range while she was typing.
final class PriceOutOfRange extends OfferingFailure {
  const PriceOutOfRange(this.min, this.max, [super.debugMessage]);

  final int min;
  final int max;

  @override
  List<Object?> get props => [min, max];
}

/// 400 "BY_SIZE is not an allowed pricing type for COOKING (allowed: …)".
final class PricingTypeNotAllowed extends OfferingFailure {
  const PricingTypeNotAllowed([super.debugMessage]);
}

/// 409 "You already offer this service".
final class OfferingAlreadyExists extends OfferingFailure {
  const OfferingAlreadyExists([super.debugMessage]);
}
