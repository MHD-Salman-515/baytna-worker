part of 'profile_form_bloc.dart';

enum ProfileField { years, languages, city, serviceAreas }

/// Form data plus a sealed [status] and a sealed [cities] load state.
final class ProfileFormState extends Equatable {
  const ProfileFormState({
    required this.countryId,
    this.bioAr = '',
    this.bioEn = '',
    this.years = '0',
    this.languages = const {},
    this.cityId,
    this.serviceAreas = const {},
    this.cities = const CitiesLoading(),
    this.status = const ProfileFormEditing(),
  });

  factory ProfileFormState.fromProfile(WorkerProfile p) => ProfileFormState(
    countryId: p.countryId,
    bioAr: p.bio?.ar ?? '',
    bioEn: p.bio?.en ?? '',
    years: '${p.yearsOfExperience}',
    languages: p.languages.toSet(),
    cityId: p.cityId,
    serviceAreas: p.serviceAreas.toSet(),
  );

  final String countryId;
  final String bioAr;
  final String bioEn;

  /// As typed (may contain Arabic-Indic digits); see [parsedYears].
  final String years;
  final Set<String> languages;
  final String? cityId;
  final Set<String> serviceAreas;
  final CitiesState cities;
  final ProfileFormStatus status;

  List<City> get cityList => switch (cities) {
    CitiesLoaded(:final cities) => cities,
    CitiesLoading() || CitiesFailed() => const [],
  };

  int? get parsedYears {
    final n = int.tryParse(PhoneNumber.asciiDigits(years.trim()));
    return n != null && n >= 0 && n <= ProfileFormBloc.maxYears ? n : null;
  }

  Set<ProfileField> validate() => {
    if (parsedYears == null) ProfileField.years,
    if (languages.isEmpty) ProfileField.languages,
    if (cityId == null) ProfileField.city,
    if (serviceAreas.isEmpty) ProfileField.serviceAreas,
  };

  /// Errors are shown only after a submit attempt.
  Set<ProfileField> get visibleErrors => switch (status) {
    ProfileFormInvalid(:final errors) => errors,
    _ => const {},
  };

  ProfileFormState copyWith({
    String? bioAr,
    String? bioEn,
    String? years,
    Set<String>? languages,
    String? Function()? cityId,
    Set<String>? serviceAreas,
    CitiesState? cities,
    ProfileFormStatus? status,
  }) => ProfileFormState(
    countryId: countryId,
    bioAr: bioAr ?? this.bioAr,
    bioEn: bioEn ?? this.bioEn,
    years: years ?? this.years,
    languages: languages ?? this.languages,
    cityId: cityId != null ? cityId() : this.cityId,
    serviceAreas: serviceAreas ?? this.serviceAreas,
    cities: cities ?? this.cities,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [countryId, bioAr, bioEn, years, languages, cityId, serviceAreas, cities, status];
}

sealed class CitiesState extends Equatable {
  const CitiesState();

  @override
  List<Object?> get props => [];
}

final class CitiesLoading extends CitiesState {
  const CitiesLoading();
}

final class CitiesLoaded extends CitiesState {
  const CitiesLoaded(this.cities);

  final List<City> cities;

  @override
  List<Object?> get props => [cities];
}

final class CitiesFailed extends CitiesState {
  const CitiesFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

sealed class ProfileFormStatus extends Equatable {
  const ProfileFormStatus();

  @override
  List<Object?> get props => [];
}

final class ProfileFormEditing extends ProfileFormStatus {
  const ProfileFormEditing();
}

final class ProfileFormInvalid extends ProfileFormStatus {
  const ProfileFormInvalid(this.errors);

  final Set<ProfileField> errors;

  @override
  List<Object?> get props => [errors];
}

final class ProfileFormSaving extends ProfileFormStatus {
  const ProfileFormSaving();
}

final class ProfileFormSaved extends ProfileFormStatus {
  const ProfileFormSaved(this.profile);

  final WorkerProfile profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileFormFailed extends ProfileFormStatus {
  const ProfileFormFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
