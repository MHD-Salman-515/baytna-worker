import 'package:baytna_worker/core/network/api_client.dart';
import 'package:baytna_worker/core/network/json.dart';
import 'package:baytna_worker/features/worker/data/models/worker_profile_model.dart';
import 'package:baytna_worker/features/worker/domain/entities/profile_input.dart';
import 'package:injectable/injectable.dart';

/// 1:1 with the /workers/me profile endpoints. Every route except `apply`
/// requires the WORKER role IN THE ACCESS TOKEN (403 "Insufficient role").
@lazySingleton
class WorkerRemoteDataSource {
  WorkerRemoteDataSource(this._api);

  final ApiClient _api;

  WorkerProfileModel _decode(Object? data) => WorkerProfileModel.fromJson(asJson(data));

  Future<WorkerProfileModel> apply() => _api.post('/workers/me/apply', decode: _decode);

  Future<WorkerProfileModel> getProfile() => _api.get('/workers/me/profile', decode: _decode);

  Future<WorkerProfileModel> upsertProfile(ProfileInput input) => _api.post(
    '/workers/me/profile',
    body: {
      'countryId': input.countryId,
      'cityId': input.cityId,
      if (input.bio case final bio?) 'bio': bio.toJson(),
      'yearsOfExperience': input.yearsOfExperience,
      'languages': input.languages,
      'serviceAreas': input.serviceAreas,
    },
    decode: _decode,
  );

  /// Answers with the updated profile.
  Future<WorkerProfileModel> setAvailability({required bool isAvailable}) => _api.patch(
    '/workers/me/availability',
    body: {'isAvailable': isAvailable},
    decode: _decode,
  );

  Future<WorkerProfileModel> submit() => _api.post('/workers/me/submit', decode: _decode);
}
