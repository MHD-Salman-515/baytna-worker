part of 'apply_bloc.dart';

sealed class ApplyEvent extends Equatable {
  const ApplyEvent();

  @override
  List<Object?> get props => [];
}

final class ApplySubmitted extends ApplyEvent {
  const ApplySubmitted();
}
