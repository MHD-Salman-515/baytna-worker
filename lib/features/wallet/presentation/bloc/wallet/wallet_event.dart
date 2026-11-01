part of 'wallet_bloc.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

final class WalletRequested extends WalletEvent {
  const WalletRequested();
}

final class WalletMoreRequested extends WalletEvent {
  const WalletMoreRequested();
}
