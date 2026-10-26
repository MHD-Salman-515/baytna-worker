import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/auth/domain/phone_number.dart';
import 'package:baytna_worker/features/auth/domain/repositories/auth_repository.dart';
import 'package:baytna_worker/features/countries/domain/entities/country.dart';
import 'package:baytna_worker/features/countries/domain/repositories/country_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'phone_event.dart';
part 'phone_state.dart';

/// Phone entry: resolves the country (from its id, so a browser refresh
/// works), normalizes the input to E.164 and requests the OTP.
@injectable
class PhoneBloc extends Bloc<PhoneEvent, PhoneState> {
  PhoneBloc(this._auth, this._countries, @factoryParam this._countryId)
    : super(const PhoneState()) {
    on<PhoneStarted>(_onStarted);
    on<PhoneNumberChanged>(_onChanged);
    on<PhoneSubmitted>(_onSubmitted);
  }

  final AuthRepository _auth;
  final CountryRepository _countries;
  final String _countryId;

  Future<void> _onStarted(PhoneStarted event, Emitter<PhoneState> emit) async {
    emit(state.copyWith(status: const PhoneCountryLoading()));
    final result = await _countries.getById(_countryId);
    emit(switch (result) {
      Ok(:final value) => state.copyWith(country: value, status: const PhoneIdle()),
      Err(:final failure) => state.copyWith(status: PhoneCountryLoadFailed(failure)),
    });
  }

  void _onChanged(PhoneNumberChanged event, Emitter<PhoneState> emit) {
    // Any edit clears a previous error.
    emit(state.copyWith(input: event.input, status: const PhoneIdle()));
  }

  Future<void> _onSubmitted(PhoneSubmitted event, Emitter<PhoneState> emit) async {
    final country = state.country;
    if (country == null || state.status is PhoneSubmitting) return;

    final e164 = PhoneNumber.toE164(state.input, prefix: country.phonePrefix);
    if (e164 == null) return emit(state.copyWith(status: const PhoneInvalidInput()));

    emit(state.copyWith(status: const PhoneSubmitting()));
    final result = await _auth.requestOtp(countryId: country.id, phone: e164);
    emit(switch (result) {
      Ok() => state.copyWith(status: PhoneCodeSent(e164)),
      Err(:final failure) => state.copyWith(status: PhoneSubmitFailed(failure)),
    });
  }
}
