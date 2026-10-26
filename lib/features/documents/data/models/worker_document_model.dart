import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/features/documents/domain/entities/worker_document.dart';
import 'package:json_annotation/json_annotation.dart';

part 'worker_document_model.g.dart';

/// Element of GET /workers/me/documents and `data` of POST (verified on staging):
///
/// ```json
/// { "workerProfileId": "…", "type": "NATIONAL_ID_FRONT", "storageKey": "documents/…",
///   "mimeType": "image/png", "sizeBytes": 178, "checksum": "<sha256>",
///   "status": "PENDING", "rejectionReason": null, "reviewedBy": null,
///   "reviewedAt": null, "expiresAt": null, "createdAt": "…", "id": "…" }
/// ```
///
/// `checksum` is NOT mapped: images are re-encoded server-side (sizes differ
/// from what was sent), so it can't be compared with the local file.
@JsonSerializable(createToJson: false)
class WorkerDocumentModel {
  const WorkerDocumentModel({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
    this.mimeType,
    this.sizeBytes,
    this.expiresAt,
    this.rejectionReason,
  });

  factory WorkerDocumentModel.fromJson(Map<String, dynamic> json) =>
      _$WorkerDocumentModelFromJson(json);

  final String id;
  final String type;
  final String status;
  final DateTime createdAt;
  final String? mimeType;
  final int? sizeBytes;
  final DateTime? expiresAt;
  @JsonKey(fromJson: _localizedOrNull)
  final LocalizedText? rejectionReason;

  WorkerDocument toEntity() => WorkerDocument(
    id: id,
    type: DocumentType.fromApi(type),
    status: DocumentStatus.fromApi(status),
    createdAt: createdAt,
    mimeType: mimeType,
    sizeBytes: sizeBytes,
    expiresAt: expiresAt,
    rejectionReason: rejectionReason,
  );
}

LocalizedText? _localizedOrNull(Object? json) {
  if (json == null) return null;
  final text = LocalizedText.fromJson(json);
  return text.ar.isEmpty && text.en.isEmpty ? null : text;
}
