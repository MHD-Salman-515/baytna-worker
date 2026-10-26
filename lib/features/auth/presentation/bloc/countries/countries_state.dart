part of 'countries_bloc.dart';

sealed class CountriesState extends Equatable {
  const CountriesState();

  @override
  List<Object?> get props => [];
}

final class CountriesLoading extends CountriesState {
  const CountriesLoading();
}

final class CountriesLoaded extends CountriesState {
  const CountriesLoaded(this.countries);

  final List<Country> countries;

  @override
  List<Object?> get props => [countries];
}

final class CountriesFailure extends CountriesState {
  const CountriesFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
