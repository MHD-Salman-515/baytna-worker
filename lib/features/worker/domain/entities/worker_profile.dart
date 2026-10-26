import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/features/worker/domain/entities/verification_status.dart';
import 'package:equatable/equatable.dart';

/// GET /workers/me/profile (also returned by apply, profile upsert and submit).
class WorkerProfile extends Equatable {
  const WorkerProfile({
    required this.id,
    required this.countryId,
    required this.verificationStatus,
    required this.financialStatus,
    this.cityId,
    this.bio,
    this.yearsOfExperience = 0,
    this.languages = const [],
    this.serviceAreas = const [],
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
  });

  final String id;
  final String countryId;
  final String? cityId;

  /// Absent until she writes one.
  final LocalizedText? bio;
  final int yearsOfExperience;

  /// Language codes, e.g. ["ar", "ku"]. The backend accepts any string; the
  /// app offers a fixed list (see WorkerLanguages).
  final List<String> languages;

  /// City ids she is willing to work in.
  final List<String> serviceAreas;

  final VerificationStatus verificationStatus;
  final FinancialStatus financialStatus;

  /// Set by the admin on REJECTED (and possibly SUSPENDED).
  final LocalizedText? rejectionReason;

  /// When she last submitted for review — "waiting since …".
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  /// What the app requires before documents/submission. The backend itself
  /// only enforces documents at submit time.
  bool get isProfileComplete => cityId != null && languages.isNotEmpty && serviceAreas.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    countryId,
    cityId,
    bio,
    yearsOfExperience,
    languages,
    serviceAreas,
    verificationStatus,
    financialStatus,
    rejectionReason,
    submittedAt,
    reviewedAt,
  ];
}

/// Languages offered in the profile form, as stored on the server.
abstract final class WorkerLanguages {
  static const all = ['ar', 'ku', 'en', 'tr', 'fr'];
}
