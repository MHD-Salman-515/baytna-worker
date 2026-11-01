import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:equatable/equatable.dart';

/// Mirrors the backend enum; an unknown value is kept rather than crashing.
enum PricingType {
  hourly('HOURLY'),
  bySize('BY_SIZE'),
  fixed('FIXED'),
  unknown('');

  PricingType(this.apiValue);

  final String apiValue;

  static PricingType fromApi(Object? value) =>
      values.firstWhere((t) => t.apiValue == value && t != unknown, orElse: () => unknown);
}

/// A service Baytna offers (GET /services).
class Service extends Equatable {
  const Service({required this.id, required this.key, required this.name, required this.allowedPricingTypes});

  final String id;

  /// Stable machine key, e.g. "CLEANING". The UI picks its glyph from this
  /// (`icon` is null on every staging service).
  final String key;
  final LocalizedText name;

  /// Differs per service: cooking can't be BY_SIZE, for example.
  final List<PricingType> allowedPricingTypes;

  @override
  List<Object?> get props => [id, key, name, allowedPricingTypes];
}

/// The admin's allowed range for one service + country + pricing type
/// (GET /service-pricing-rules). Shown BEFORE she types.
class PricingRule extends Equatable {
  const PricingRule({
    required this.serviceId,
    required this.pricingType,
    required this.minPrice,
    required this.maxPrice,
  });

  final String serviceId;
  final PricingType pricingType;
  final int minPrice;
  final int maxPrice;

  bool allows(int price) => price >= minPrice && price <= maxPrice;

  @override
  List<Object?> get props => [serviceId, pricingType, minPrice, maxPrice];
}

/// One BY_SIZE tier: homes up to [maxRooms] rooms cost [price].
class SizeTier extends Equatable {
  const SizeTier({required this.maxRooms, required this.price});

  final int maxRooms;
  final int price;

  @override
  List<Object?> get props => [maxRooms, price];
}

/// What she charges. One subtype per model, so nothing can hold a rate and a
/// tier list at once, and `switch` is exhaustive.
sealed class OfferingPrice extends Equatable {
  const OfferingPrice();

  PricingType get type;
}

final class HourlyPrice extends OfferingPrice {
  const HourlyPrice({required this.rate, required this.minHours});

  final int rate;
  final int minHours;

  @override
  PricingType get type => PricingType.hourly;

  @override
  List<Object?> get props => [rate, minHours];
}

final class BySizePrice extends OfferingPrice {
  const BySizePrice(this.tiers);

  final List<SizeTier> tiers;

  @override
  PricingType get type => PricingType.bySize;

  @override
  List<Object?> get props => [tiers];
}

final class FixedPrice extends OfferingPrice {
  const FixedPrice(this.price);

  final int price;

  @override
  PricingType get type => PricingType.fixed;

  @override
  List<Object?> get props => [price];
}

/// A service she offers (a WorkerService). [currency] is fixed at creation:
/// the backend refuses to change it, so it is never editable.
class Offering extends Equatable {
  const Offering({
    required this.id,
    required this.serviceId,
    required this.price,
    required this.currency,
    required this.isActive,
  });

  final String id;
  final String serviceId;
  final OfferingPrice price;
  final String currency;
  final bool isActive;

  @override
  List<Object?> get props => [id, serviceId, price, currency, isActive];
}
