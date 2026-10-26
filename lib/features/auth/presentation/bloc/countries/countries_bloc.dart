import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/countries/domain/entities/country.dart';
import 'package:baytna_worker/features/countries/domain/repositories/country_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'countries_event.dart';
part 'countries_state.dart';

@injectable
class CountriesBloc extends Bloc<CountriesEvent, CountriesState> {
  CountriesBloc(this._repository) : super(const CountriesLoading()) {
    on<CountriesRequested>(_onRequested);
  }

  final CountryRepository _repository;

  Future<void> _onRequested(CountriesRequested event, Emitter<CountriesState> emit) async {
    emit(const CountriesLoading());
    final result = await _repository.getCountries(forceRefresh: event.forceRefresh);
    emit(switch (result) {
      Ok(:final value) => CountriesLoaded(value),
      Err(:final failure) => CountriesFailure(failure),
    });
  }
}
