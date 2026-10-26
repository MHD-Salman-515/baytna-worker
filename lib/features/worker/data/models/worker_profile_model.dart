import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/features/worker/domain/entities/verification_status.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:json_annotation/json_annotation.dart';

part 'worker_profile_model.g.dart';

/// Shape verified against staging (GET /workers/me/profile; also the `data`
/// of POST apply, POST profile and POST submit):
///
/// ```json
/// { "userId": "…", "countryId": "…", "cityId": null, "yearsOfExperience": 0,
///   "languages": [], "serviceAreas": [], "verificationStatus": "DRAFT",
///   "rejectionReason": null, "submittedAt": null, "reviewedBy": null,
///   "reviewedAt": null, "isAvailable": false, "financialStatus": "ACTIVE",
///   "rating": 0, "completedBookings": 0, "bio": {"ar": "…", "en": "…"},
///   "createdAt": "…", "updatedAt": "…", "id": "…" }
/// ```
///
/// `bio` is ABSENT (not null) until set. Availability, rating and bookings
/// belong to later phases and aren't mapped yet.
@JsonSerializable(createToJson: false)
class WorkerProfileModel {
  const WorkerProfileModel({
    required this.id,
    required this.countryId,
    this.cityId,
    this.bio,
    this.yearsOfExperience = 0,
    this.languages = const [],
    this.serviceAreas = const [],
    this.verificationStatus,
    this.financialStatus,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
  });

  factory WorkerProfileModel.fromJson(Map<String, dynamic> json) =>
      _$WorkerProfileModelFromJson(json);

  final String id;
  final String countryId;
  final String? cityId;
  @JsonKey(fromJson: _localizedOrNull)
  final LocalizedText? bio;
  final int yearsOfExperience;
  final List<String> languages;
  final List<String> serviceAreas;
  final String? verificationStatus;
  final String? financialStatus;
  @JsonKey(fromJson: _localizedOrNull)
  final LocalizedText? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  WorkerProfile toEntity() => WorkerProfile(
    id: id,
    countryId: countryId,
    cityId: cityId,
    bio: bio,
    yearsOfExperience: yearsOfExperience,
    languages: languages,
    serviceAreas: serviceAreas,
    verificationStatus: VerificationStatus.fromApi(verificationStatus),
    financialStatus: FinancialStatus.fromApi(financialStatus),
    rejectionReason: rejectionReason,
    submittedAt: submittedAt,
    reviewedAt: reviewedAt,
  );
}

/// The admin's reason is `{ar, en}` (ReviewWorkerDto); tolerate a plain
/// string, and treat empty as absent.
LocalizedText? _localizedOrNull(Object? json) {
  if (json == null) return null;
  final text = LocalizedText.fromJson(json);
  return text.ar.isEmpty && text.en.isEmpty ? null : text;
}
