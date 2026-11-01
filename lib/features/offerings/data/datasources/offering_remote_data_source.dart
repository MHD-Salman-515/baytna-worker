import 'package:baytna_worker/core/network/api_client.dart';
import 'package:baytna_worker/core/network/json.dart';
import 'package:baytna_worker/features/offerings/data/models/offering_models.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class OfferingRemoteDataSource {
  OfferingRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<Service>> services() => _api.get(
    '/services',
    decode: (data) => asJsonList(data).map(OfferingMapper.service).toList(),
    authenticated: false,
  );

  Future<List<PricingRule>> pricingRules(String countryId) => _api.get(
    '/service-pricing-rules',
    query: {'countryId': countryId},
    decode: (data) => [
      for (final json in asJsonList(data))
        if (json['isActive'] != false) OfferingMapper.rule(json),
    ],
    authenticated: false,
  );

  Future<List<Offering>> offerings() => _api.get(
    '/workers/me/services',
    decode: (data) => asJsonList(data).map(OfferingMapper.offering).toList(),
  );

  Future<Offering> create(String serviceId, OfferingPrice price) => _api.post(
    '/workers/me/services',
    body: {'serviceId': serviceId, ...OfferingMapper.priceBody(price)},
    decode: (data) => OfferingMapper.offering(asJson(data)),
  );

  Future<Offering> update(String id, {OfferingPrice? price, bool? isActive}) => _api.patch(
    '/workers/me/services/$id',
    body: {
      if (price != null) ...OfferingMapper.priceBody(price),
      'isActive': ?isActive,
    },
    decode: (data) => OfferingMapper.offering(asJson(data)),
  );

  /// Answers 204 with no body.
  Future<void> delete(String id) => _api.delete('/workers/me/services/$id', decode: ApiClient.ignore);
}
