import 'package:baytna_worker/core/network/api_client.dart';
import 'package:baytna_worker/core/network/paged.dart';
import 'package:baytna_worker/features/cities/data/models/city_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CityRemoteDataSource {
  CityRemoteDataSource(this._api);

  final ApiClient _api;

  /// The backend caps `limit` at 100. `countryId` is REQUIRED (400 without it).
  static const maxPageSize = 100;

  Future<Paged<CityModel>> fetchPage(String countryId, {int page = 1}) => _api.getPage(
    '/cities',
    query: {'countryId': countryId, 'page': page, 'limit': maxPageSize},
    decodeItem: CityModel.fromJson,
    authenticated: false,
  );
}
