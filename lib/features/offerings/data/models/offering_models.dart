import 'package:baytna_worker/core/format/money.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/network/json.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';

/// Payload shapes verified against staging. These are hand-decoded rather
/// than json_serializable: the price is a union across three nullable blocks.
abstract final class OfferingMapper {
  /// Element of GET /services.
  static Service service(Json json) => Service(
    id: json['id'] as String,
    key: json['key'] as String,
    name: LocalizedText.fromJson(json['name']),
    allowedPricingTypes: [
      for (final t in json['allowedPricingTypes'] as List<dynamic>? ?? const <dynamic>[]) PricingType.fromApi(t),
    ],
  );

  /// Element of GET /service-pricing-rules:
  /// `{ serviceId, countryId, pricingType, minPrice, maxPrice, unit, isActive, id }`.
  static PricingRule rule(Json json) => PricingRule(
    serviceId: json['serviceId'] as String,
    pricingType: PricingType.fromApi(json['pricingType']),
    minPrice: moneyFromJson(json['minPrice']),
    maxPrice: moneyFromJson(json['maxPrice']),
  );

  /// Element of GET /workers/me/services:
  /// `{ id, serviceId, pricingType, hourly: {rate, minHours} | null,
  ///    bySize: {tiers: [{maxRooms, price}]} | null, fixed: {price} | null,
  ///    currency, isActive }`.
  static Offering offering(Json json) => Offering(
    id: json['id'] as String,
    serviceId: json['serviceId'] as String,
    price: _price(json),
    currency: json['currency'] as String,
    isActive: json['isActive'] as bool? ?? true,
  );

  static OfferingPrice _price(Json json) {
    final type = PricingType.fromApi(json['pricingType']);
    return switch (type) {
      PricingType.hourly => HourlyPrice(
        rate: moneyFromJson(asJson(json['hourly'])['rate']),
        minHours: (asJson(json['hourly'])['minHours'] as num).toInt(),
      ),
      PricingType.bySize => BySizePrice([
        for (final t in asJsonList(asJson(json['bySize'])['tiers']))
          SizeTier(maxRooms: (t['maxRooms'] as num).toInt(), price: moneyFromJson(t['price'])),
      ]),
      PricingType.fixed => FixedPrice(moneyFromJson(asJson(json['fixed'])['price'])),
      PricingType.unknown => throw FormatException('Unknown pricingType ${json['pricingType']}'),
    };
  }

  /// The `pricingType` + matching block, as POST and PATCH expect them.
  static Json priceBody(OfferingPrice price) => {
    'pricingType': price.type.apiValue,
    ...switch (price) {
      HourlyPrice(:final rate, :final minHours) => {
        'hourly': {'rate': rate, 'minHours': minHours},
      },
      BySizePrice(:final tiers) => {
        'bySize': {
          'tiers': [
            for (final t in tiers) {'maxRooms': t.maxRooms, 'price': t.price},
          ],
        },
      },
      FixedPrice(price: final amount) => {
        'fixed': {'price': amount},
      },
    },
  };
}
