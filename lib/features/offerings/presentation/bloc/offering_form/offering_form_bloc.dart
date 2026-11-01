import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/auth/domain/phone_number.dart';
import 'package:baytna_worker/features/countries/domain/repositories/country_repository.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:baytna_worker/features/offerings/domain/offering_validator.dart';
import 'package:baytna_worker/features/offerings/domain/repositories/offering_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'offering_form_event.dart';
part 'offering_form_state.dart';

/// Add a service, or edit one (`offeringId` set). Inputs stay as typed text;
/// numbers are parsed (Arabic-Indic digits included) only to validate/save.
@injectable
class OfferingFormBloc extends Bloc<OfferingFormEvent, OfferingFormState> {
  OfferingFormBloc(
    this._repository,
    this._countries,
    @factoryParam String countryId,
    @factoryParam String? offeringId,
  ) : super(OfferingFormState(countryId: countryId, offeringId: offeringId)) {
    on<OfferingFormStarted>(_onStarted);
    on<OfferingServiceSelected>(_onServiceSelected);
    on<OfferingPricingTypeSelected>((e, emit) => emit(state.copyWith(pricingType: e.type, status: const FormEditing())));
    on<OfferingAmountChanged>((e, emit) => emit(state.copyWith(amount: e.value, status: const FormEditing())));
    on<OfferingMinHoursChanged>((e, emit) => emit(state.copyWith(minHours: e.value, status: const FormEditing())));
    on<OfferingTierAdded>((e, emit) => emit(state.copyWith(tiers: [...state.tiers, const TierDraft()], status: const FormEditing())));
    on<OfferingTierRemoved>(_onTierRemoved);
    on<OfferingTierChanged>(_onTierChanged);
    on<OfferingActiveToggled>(_onActiveToggled);
    on<OfferingFormSubmitted>(_onSubmitted);
    on<OfferingDeleteRequested>(_onDeleteRequested);
  }

  final OfferingRepository _repository;
  final CountryRepository _countries;

  Future<void> _onStarted(OfferingFormStarted event, Emitter<OfferingFormState> emit) async {
    emit(state.copyWith(status: const FormLoading()));
    final (services, rules, offerings, country) = await (
      _repository.getServices(),
      _repository.getPricingRules(state.countryId),
      _repository.getOfferings(),
      _countries.getById(state.countryId),
    ).wait;
    switch ((services, rules, offerings, country)) {
      case (Ok(value: final s), Ok(value: final r), Ok(value: final o), Ok(value: final c)):
        final existing = o.where((x) => x.id == state.offeringId).firstOrNull;
        final taken = o.map((x) => x.serviceId).toSet();
        final loaded = state.copyWith(
          services: s,
          rules: r,
          // The backend applies her country's currency on creation.
          currency: c.currencyCode,
          // A new offering can only be a service she doesn't offer yet.
          selectable: existing != null ? s : s.where((x) => !taken.contains(x.id)).toList(),
          status: const FormEditing(),
        );
        emit(existing == null ? loaded : loaded.prefilledFrom(existing));
      case (Err(:final failure), _, _, _) ||
          (_, Err(:final failure), _, _) ||
          (_, _, Err(:final failure), _) ||
          (_, _, _, Err(:final failure)):
        emit(state.copyWith(status: FormLoadFailed(failure)));
    }
  }

  void _onServiceSelected(OfferingServiceSelected event, Emitter<OfferingFormState> emit) {
    final service = state.services.where((s) => s.id == event.serviceId).firstOrNull;
    if (service == null) return;
    final allowed = service.allowedPricingTypes.where((t) => t != PricingType.unknown);
    final keep = allowed.contains(state.pricingType);
    emit(
      state.copyWith(
        serviceId: () => service.id,
        pricingType: keep ? state.pricingType : allowed.firstOrNull,
        status: const FormEditing(),
      ),
    );
  }

  void _onTierRemoved(OfferingTierRemoved event, Emitter<OfferingFormState> emit) {
    final tiers = [...state.tiers]..removeAt(event.index);
    emit(state.copyWith(tiers: tiers, status: const FormEditing()));
  }

  void _onTierChanged(OfferingTierChanged event, Emitter<OfferingFormState> emit) {
    final tiers = [...state.tiers];
    final tier = tiers[event.index];
    tiers[event.index] = TierDraft(maxRooms: event.maxRooms ?? tier.maxRooms, price: event.price ?? tier.price);
    emit(state.copyWith(tiers: tiers, status: const FormEditing()));
  }

  /// Applied at once: pausing a service is not a price edit.
  Future<void> _onActiveToggled(OfferingActiveToggled event, Emitter<OfferingFormState> emit) async {
    final id = state.offeringId;
    if (id == null || state.status is FormSaving) return;
    emit(state.copyWith(status: const FormSaving()));
    final result = await _repository.update(id, isActive: event.isActive);
    emit(switch (result) {
      Ok(:final value) => state.copyWith(isActive: value.isActive, status: const FormEditing()),
      Err(:final failure) => state.copyWith(status: FormSaveFailed(failure)),
    });
  }

  Future<void> _onSubmitted(OfferingFormSubmitted event, Emitter<OfferingFormState> emit) async {
    if (state.status is FormSaving) return;
    final price = state.parsedPrice;
    final errors = state.errors;
    if (price == null || errors.isNotEmpty) {
      return emit(state.copyWith(status: FormInvalid(errors)));
    }
    emit(state.copyWith(status: const FormSaving()));
    final id = state.offeringId;
    final result = id == null
        ? await _repository.create(serviceId: state.serviceId!, price: price)
        : await _repository.update(id, price: price);
    emit(switch (result) {
      Ok() => state.copyWith(status: const FormDone()),
      Err(:final failure) => state.copyWith(status: FormSaveFailed(failure)),
    });
  }

  Future<void> _onDeleteRequested(OfferingDeleteRequested event, Emitter<OfferingFormState> emit) async {
    final id = state.offeringId;
    if (id == null || state.status is FormSaving) return;
    emit(state.copyWith(status: const FormSaving()));
    final result = await _repository.delete(id);
    emit(switch (result) {
      Ok() => state.copyWith(status: const FormDone()),
      Err(:final failure) => state.copyWith(status: FormSaveFailed(failure)),
    });
  }
}
