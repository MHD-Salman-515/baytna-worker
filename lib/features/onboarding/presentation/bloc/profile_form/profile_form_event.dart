part of 'profile_form_bloc.dart';

sealed class ProfileFormEvent extends Equatable {
  const ProfileFormEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the cities of her country.
final class ProfileFormStarted extends ProfileFormEvent {
  const ProfileFormStarted({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

final class ProfileBioArChanged extends ProfileFormEvent {
  const ProfileBioArChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class ProfileBioEnChanged extends ProfileFormEvent {
  const ProfileBioEnChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class ProfileYearsChanged extends ProfileFormEvent {
  const ProfileYearsChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class ProfileLanguageToggled extends ProfileFormEvent {
  const ProfileLanguageToggled(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

final class ProfileCityChanged extends ProfileFormEvent {
  const ProfileCityChanged(this.cityId);

  final String cityId;

  @override
  List<Object?> get props => [cityId];
}

final class ProfileAreaToggled extends ProfileFormEvent {
  const ProfileAreaToggled(this.cityId);

  final String cityId;

  @override
  List<Object?> get props => [cityId];
}

final class ProfileFormSubmitted extends ProfileFormEvent {
  const ProfileFormSubmitted();
}
