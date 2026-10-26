import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:equatable/equatable.dart';

/// Body of POST /workers/me/profile (an upsert: fields left out are kept).
class ProfileInput extends Equatable {
  const ProfileInput({
    required this.countryId,
    required this.cityId,
    required this.yearsOfExperience,
    required this.languages,
    required this.serviceAreas,
    this.bio,
  });

  final String countryId;
  final String cityId;
  final LocalizedText? bio;
  final int yearsOfExperience;
  final List<String> languages;
  final List<String> serviceAreas;

  @override
  List<Object?> get props => [countryId, cityId, bio, yearsOfExperience, languages, serviceAreas];
}
