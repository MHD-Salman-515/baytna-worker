import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';

enum OfferingError {
  /// Empty or not a whole number.
  priceMissing,
  priceOutOfRange,

  /// HOURLY: at least 1 (the backend's minimum).
  minHoursInvalid,
  tiersEmpty,

  /// Each tier must cover more rooms than the one before.
  tiersNotAscending,
}

/// The client-side mirror of the backend's checks. `rule` may be null when no
/// range exists for this combination; the server then has the last word.
abstract final class OfferingValidator {
  static Set<OfferingError> validate(OfferingPrice price, PricingRule? rule) => switch (price) {
    HourlyPrice(:final rate, :final minHours) => {
      if (minHours < 1) OfferingError.minHoursInvalid,
      if (rule != null && !rule.allows(rate)) OfferingError.priceOutOfRange,
    },
    FixedPrice(price: final amount) => {
      if (rule != null && !rule.allows(amount)) OfferingError.priceOutOfRange,
    },
    BySizePrice(:final tiers) => {
      if (tiers.isEmpty) OfferingError.tiersEmpty,
      if (rule != null && tiers.any((t) => !rule.allows(t.price))) OfferingError.priceOutOfRange,
      if (!_ascending(tiers)) OfferingError.tiersNotAscending,
    },
  };

  static bool _ascending(List<SizeTier> tiers) {
    for (var i = 0; i < tiers.length; i++) {
      if (tiers[i].maxRooms < 1) return false;
      if (i > 0 && tiers[i].maxRooms <= tiers[i - 1].maxRooms) return false;
    }
    return true;
  }
}
