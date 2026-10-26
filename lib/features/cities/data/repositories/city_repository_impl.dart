import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/cities/data/datasources/city_remote_data_source.dart';
import 'package:baytna_worker/features/cities/domain/entities/city.dart';
import 'package:baytna_worker/features/cities/domain/repositories/city_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CityRepository)
class CityRepositoryImpl implements CityRepository {
  CityRepositoryImpl(this._remote);

  final CityRemoteDataSource _remote;
  final Map<String, List<City>> _cache = {};

  /// Upper bound on pages, so a backend that misreports `totalPages` can't
  /// make this loop forever.
  static const _maxPages = 20;

  @override
  Future<Result<List<City>>> getCities(String countryId, {bool forceRefresh = false}) async {
    final cached = _cache[countryId];
    if (cached != null && !forceRefresh) return Ok(cached);
    final result = await guard(() async {
      final cities = <City>[];
      for (var page = 1; page <= _maxPages; page++) {
        final batch = await _remote.fetchPage(countryId, page: page);
        cities.addAll(batch.items.map((m) => m.toEntity()));
        if (!batch.meta.hasNext) break;
      }
      return List<City>.unmodifiable(cities);
    });
    if (result case Ok(:final value)) _cache[countryId] = value;
    return result;
  }
}
