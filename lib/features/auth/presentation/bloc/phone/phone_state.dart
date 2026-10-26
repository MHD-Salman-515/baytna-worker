part of 'phone_bloc.dart';

/// Form data plus a sealed [status]: the data persists across statuses,
/// the status is what the UI switches on exhaustively.
final class PhoneState extends Equatable {
  const PhoneState({this.country, this.input = '', this.status = const PhoneCountryLoading()});

  final Country? country;
  final String input;
  final PhoneStatus status;

  PhoneState copyWith({Country? country, String? input, PhoneStatus? status}) => PhoneState(
    country: country ?? this.country,
    input: input ?? this.input,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [country, input, status];
}

sealed class PhoneStatus extends Equatable {
  const PhoneStatus();

  @override
  List<Object?> get props => [];
}

final class PhoneCountryLoading extends PhoneStatus {
  const PhoneCountryLoading();
}

final class PhoneCountryLoadFailed extends PhoneStatus {
  const PhoneCountryLoadFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class PhoneIdle extends PhoneStatus {
  const PhoneIdle();
}

/// Failed local E.164 normalization — nothing was sent.
final class PhoneInvalidInput extends PhoneStatus {
  const PhoneInvalidInput();
}

final class PhoneSubmitting extends PhoneStatus {
  const PhoneSubmitting();
}

final class PhoneCodeSent extends PhoneStatus {
  const PhoneCodeSent(this.e164);

  final String e164;

  @override
  List<Object?> get props => [e164];
}

final class PhoneSubmitFailed extends PhoneStatus {
  const PhoneSubmitFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
