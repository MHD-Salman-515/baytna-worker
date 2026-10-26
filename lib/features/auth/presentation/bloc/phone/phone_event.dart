part of 'phone_bloc.dart';

sealed class PhoneEvent extends Equatable {
  const PhoneEvent();

  @override
  List<Object?> get props => [];
}

final class PhoneStarted extends PhoneEvent {
  const PhoneStarted();
}

final class PhoneNumberChanged extends PhoneEvent {
  const PhoneNumberChanged(this.input);

  final String input;

  @override
  List<Object?> get props => [input];
}

final class PhoneSubmitted extends PhoneEvent {
  const PhoneSubmitted();
}
