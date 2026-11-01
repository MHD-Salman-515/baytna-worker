// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerProfileModel _$WorkerProfileModelFromJson(Map<String, dynamic> json) =>
    WorkerProfileModel(
      id: json['id'] as String,
      countryId: json['countryId'] as String,
      cityId: json['cityId'] as String?,
      bio: _localizedOrNull(json['bio']),
      yearsOfExperience: (json['yearsOfExperience'] as num?)?.toInt() ?? 0,
      languages:
          (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      serviceAreas:
          (json['serviceAreas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      verificationStatus: json['verificationStatus'] as String?,
      financialStatus: json['financialStatus'] as String?,
      rejectionReason: _localizedOrNull(json['rejectionReason']),
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      isAvailable: json['isAvailable'] as bool? ?? false,
    );
