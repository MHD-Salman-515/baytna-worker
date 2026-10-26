import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/countries/domain/entities/country.dart';

abstract interface class CountryRepository {
  /// Active countries; cached in memory after the first successful load.
  Future<Result<List<Country>>> getCountries({bool forceRefresh = false});

  /// Resolves from the cache, loading the list if needed (so a deep link or
  /// a browser refresh on a screen that only has the id still works).
  Future<Result<Country>> getById(String id);
}
