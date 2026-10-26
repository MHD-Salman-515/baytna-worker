import 'package:baytna_worker/core/network/api_client.dart';
import 'package:baytna_worker/core/network/json.dart';
import 'package:baytna_worker/features/countries/data/models/country_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CountryRemoteDataSource {
  CountryRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<CountryModel>> fetchActive() => _api.get(
    '/countries',
    decode: (data) => asJsonList(data).map(CountryModel.fromJson).toList(),
    authenticated: false,
  );
}
