part of 'wallet_bloc.dart';

final class WalletState extends Equatable {
  const WalletState({
    this.wallet,
    this.policy = WalletPolicy.defaults,
    this.timezone = 'UTC',
    this.entries = const [],
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
    this.load = const WalletLoading(),
  });

  final Wallet? wallet;
  final WalletPolicy policy;
  final String timezone;
  final List<WalletEntry> entries;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final WalletLoad load;

  WalletStanding? get standing {
    final w = wallet;
    return w == null ? null : WalletStanding(balance: w.balance, policy: policy);
  }

  WalletState copyWith({
    Wallet? wallet,
    WalletPolicy? policy,
    String? timezone,
    List<WalletEntry>? entries,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    WalletLoad? load,
  }) => WalletState(
    wallet: wallet ?? this.wallet,
    policy: policy ?? this.policy,
    timezone: timezone ?? this.timezone,
    entries: entries ?? this.entries,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    load: load ?? this.load,
  );

  @override
  List<Object?> get props => [wallet, policy, timezone, entries, page, hasMore, loadingMore, load];
}

sealed class WalletLoad extends Equatable {
  const WalletLoad();

  @override
  List<Object?> get props => [];
}

final class WalletLoading extends WalletLoad {
  const WalletLoading();
}

final class WalletLoaded extends WalletLoad {
  const WalletLoaded();
}

final class WalletFailed extends WalletLoad {
  const WalletFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
