import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/utils/result.dart';
import 'package:baytna_worker/features/countries/domain/entities/country.dart';
import 'package:baytna_worker/features/countries/domain/repositories/country_repository.dart';
import 'package:baytna_worker/features/wallet/domain/entities/wallet.dart';
import 'package:baytna_worker/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

@injectable
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc(this._repository, this._countries, @factoryParam String countryId)
    : _countryId = countryId,
      super(const WalletState()) {
    on<WalletRequested>(_onRequested);
    on<WalletMoreRequested>(_onMore);
  }

  final WalletRepository _repository;
  final CountryRepository _countries;
  final String _countryId;

  Future<void> _onRequested(WalletRequested event, Emitter<WalletState> emit) async {
    if (state.load is! WalletLoaded) emit(state.copyWith(load: const WalletLoading()));
    final (wallet, entries, country) = await (
      _repository.getWallet(),
      _repository.entries(),
      _countries.getById(_countryId),
    ).wait;
    switch ((wallet, entries, country)) {
      case (Ok(value: final w), Ok(value: final e), Ok(value: final c)):
        emit(
          state.copyWith(
            wallet: w,
            policy: c.walletPolicy,
            timezone: c.timezone,
            entries: e.items,
            page: 1,
            hasMore: e.meta.hasNext,
            load: const WalletLoaded(),
          ),
        );
      case (Err(:final failure), _, _) || (_, Err(:final failure), _) || (_, _, Err(:final failure)):
        if (state.load is! WalletLoaded) emit(state.copyWith(load: WalletFailed(failure)));
    }
  }

  Future<void> _onMore(WalletMoreRequested event, Emitter<WalletState> emit) async {
    if (!state.hasMore || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    final next = state.page + 1;
    switch (await _repository.entries(page: next)) {
      case Ok(:final value):
        emit(
          state.copyWith(
            entries: [...state.entries, ...value.items],
            page: next,
            hasMore: value.meta.hasNext,
            loadingMore: false,
          ),
        );
      case Err():
        emit(state.copyWith(loadingMore: false));
    }
  }
}
