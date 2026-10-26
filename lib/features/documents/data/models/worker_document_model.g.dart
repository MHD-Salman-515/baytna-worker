// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerDocumentModel _$WorkerDocumentModelFromJson(Map<String, dynamic> json) =>
    WorkerDocumentModel(
      id: json['id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      mimeType: json['mimeType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      rejectionReason: _localizedOrNull(json['rejectionReason']),
    );
