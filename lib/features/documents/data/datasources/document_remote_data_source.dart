import 'package:baytna_worker/core/network/api_client.dart';
import 'package:baytna_worker/core/network/json.dart';
import 'package:baytna_worker/core/network/upload_file.dart';
import 'package:baytna_worker/features/documents/data/models/worker_document_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DocumentRemoteDataSource {
  DocumentRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<WorkerDocumentModel>> list() => _api.get(
    '/workers/me/documents',
    decode: (data) => asJsonList(data).map(WorkerDocumentModel.fromJson).toList(),
  );

  /// multipart/form-data: `type`, optional `expiresAt` (ISO date), `file`.
  Future<WorkerDocumentModel> upload({
    required String type,
    required UploadFile file,
    String? expiresAt,
    UploadProgress? onProgress,
  }) => _api.upload(
    '/workers/me/documents',
    fields: {'type': type, 'expiresAt': ?expiresAt},
    file: file,
    onProgress: onProgress,
    decode: (data) => WorkerDocumentModel.fromJson(asJson(data)),
  );

  /// Responds `{ "success": true }` with no `data`.
  Future<void> delete(String id) =>
      _api.delete('/workers/me/documents/$id', decode: ApiClient.ignore);
}
