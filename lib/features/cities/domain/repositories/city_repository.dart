import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/cities/domain/entities/city.dart';

abstract interface class CityRepository {
  /// Every active city of [countryId] (all pages), cached per country.
  Future<Result<List<City>>> getCities(String countryId, {bool forceRefresh = false});
}
