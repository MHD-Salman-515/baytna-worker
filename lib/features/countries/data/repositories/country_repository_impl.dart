import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/countries/data/datasources/country_remote_data_source.dart';
import 'package:baytna_worker/features/countries/domain/entities/country.dart';
import 'package:baytna_worker/features/countries/domain/repositories/country_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CountryRepository)
class CountryRepositoryImpl implements CountryRepository {
  CountryRepositoryImpl(this._remote);

  final CountryRemoteDataSource _remote;
  List<Country>? _cache;

  @override
  Future<Result<List<Country>>> getCountries({bool forceRefresh = false}) async {
    final cached = _cache;
    if (cached != null && !forceRefresh) return Ok(cached);
    final result = await guard(() async {
      final models = await _remote.fetchActive();
      return models.map((m) => m.toEntity()).toList(growable: false);
    });
    if (result case Ok(:final value)) _cache = value;
    return result;
  }

  @override
  Future<Result<Country>> getById(String id) async {
    return switch (await getCountries()) {
      Ok(:final value) => switch (value.where((c) => c.id == id).firstOrNull) {
        final Country c => Ok(c),
        null => Err(NotFoundFailure('Country $id')),
      },
      Err(:final failure) => Err(failure),
    };
  }
}
