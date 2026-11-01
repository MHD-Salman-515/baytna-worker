import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';

abstract interface class OfferingRepository {
  Future<Result<List<Service>>> getServices();

  /// Active ranges for her country.
  Future<Result<List<PricingRule>>> getPricingRules(String countryId);

  Future<Result<List<Offering>>> getOfferings();

  /// Currency is left out, so the backend applies her country's.
  Future<Result<Offering>> create({required String serviceId, required OfferingPrice price});

  Future<Result<Offering>> update(String id, {OfferingPrice? price, bool? isActive});

  Future<Result<void>> delete(String id);
}
