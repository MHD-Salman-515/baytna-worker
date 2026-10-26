import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/auth/domain/phone_number.dart';
import 'package:baytna_worker/features/cities/domain/entities/city.dart';
import 'package:baytna_worker/features/cities/domain/repositories/city_repository.dart';
import 'package:baytna_worker/features/worker/domain/entities/profile_input.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/domain/repositories/worker_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'profile_form_event.dart';
part 'profile_form_state.dart';

/// The profile form, prefilled from her current profile. Cities come from
/// `GET /cities?countryId=…` (her country) — the backend would accept a city from
/// another country, so the choice is constrained here.
@injectable
class ProfileFormBloc extends Bloc<ProfileFormEvent, ProfileFormState> {
  ProfileFormBloc(this._workers, this._cities, @factoryParam WorkerProfile profile)
    : super(ProfileFormState.fromProfile(profile)) {
    on<ProfileFormStarted>(_onStarted);
    on<ProfileBioArChanged>((e, emit) => emit(state.copyWith(bioAr: e.value, status: const ProfileFormEditing())));
    on<ProfileBioEnChanged>((e, emit) => emit(state.copyWith(bioEn: e.value, status: const ProfileFormEditing())));
    on<ProfileYearsChanged>((e, emit) => emit(state.copyWith(years: e.value, status: const ProfileFormEditing())));
    on<ProfileLanguageToggled>(_onLanguageToggled);
    on<ProfileCityChanged>(_onCityChanged);
    on<ProfileAreaToggled>(_onAreaToggled);
    on<ProfileFormSubmitted>(_onSubmitted);
  }

  final WorkerRepository _workers;
  final CityRepository _cities;

  static const maxYears = 60;
  static const maxBioLength = 1000;

  Future<void> _onStarted(ProfileFormStarted event, Emitter<ProfileFormState> emit) async {
    emit(state.copyWith(cities: const CitiesLoading()));
    final result = await _cities.getCities(state.countryId, forceRefresh: event.forceRefresh);
    switch (result) {
      case Ok(:final value):
        final ids = value.map((c) => c.id).toSet();
        // Drop anything that isn't a city of her country (e.g. data saved
        // before this check existed).
        emit(
          state.copyWith(
            cities: CitiesLoaded(value),
            cityId: () => ids.contains(state.cityId) ? state.cityId : null,
            serviceAreas: state.serviceAreas.where(ids.contains).toSet(),
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(cities: CitiesFailed(failure)));
    }
  }

  void _onLanguageToggled(ProfileLanguageToggled event, Emitter<ProfileFormState> emit) {
    final languages = {...state.languages};
    if (!languages.remove(event.code)) languages.add(event.code);
    emit(state.copyWith(languages: languages, status: const ProfileFormEditing()));
  }

  void _onCityChanged(ProfileCityChanged event, Emitter<ProfileFormState> emit) {
    // Her home city is almost always somewhere she works: preselect it.
    emit(
      state.copyWith(
        cityId: () => event.cityId,
        serviceAreas: {...state.serviceAreas, event.cityId},
        status: const ProfileFormEditing(),
      ),
    );
  }

  void _onAreaToggled(ProfileAreaToggled event, Emitter<ProfileFormState> emit) {
    final areas = {...state.serviceAreas};
    if (!areas.remove(event.cityId)) areas.add(event.cityId);
    emit(state.copyWith(serviceAreas: areas, status: const ProfileFormEditing()));
  }

  Future<void> _onSubmitted(ProfileFormSubmitted event, Emitter<ProfileFormState> emit) async {
    if (state.status is ProfileFormSaving) return;
    final errors = state.validate();
    if (errors.isNotEmpty) return emit(state.copyWith(status: ProfileFormInvalid(errors)));

    emit(state.copyWith(status: const ProfileFormSaving()));
    final bioAr = state.bioAr.trim();
    final bioEn = state.bioEn.trim();
    final result = await _workers.updateProfile(
      ProfileInput(
        countryId: state.countryId,
        cityId: state.cityId!,
        bio: bioAr.isEmpty && bioEn.isEmpty ? null : LocalizedText(ar: bioAr, en: bioEn),
        yearsOfExperience: state.parsedYears!,
        // Keep the server's order stable: the app's list order.
        languages: [for (final l in WorkerLanguages.all) if (state.languages.contains(l)) l],
        serviceAreas: [
          for (final c in state.cityList) if (state.serviceAreas.contains(c.id)) c.id,
        ],
      ),
    );
    emit(switch (result) {
      Ok(:final value) => state.copyWith(status: ProfileFormSaved(value)),
      Err(:final failure) => state.copyWith(status: ProfileFormFailed(failure)),
    });
  }
}
