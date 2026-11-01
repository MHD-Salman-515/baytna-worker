import 'dart:async';

import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/format/money.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/time/country_time.dart';
import 'package:baytna_worker/core/widgets/failure_view.dart';
import 'package:baytna_worker/core/widgets/language_toggle_button.dart';
import 'package:baytna_worker/features/bookings/presentation/widgets/booking_labels.dart';
import 'package:baytna_worker/features/wallet/domain/entities/wallet.dart';
import 'package:baytna_worker/features/wallet/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:baytna_worker/features/worker/domain/entities/verification_status.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Her balance, how far it is from the floor, and every line that moved it.
/// A negative balance is normal here. Top-ups are recorded by Baytna staff,
/// and the screen says so instead of offering a button that does nothing.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  WalletBloc? _bloc;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refresh);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    unawaited(_bloc?.close());
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    _bloc?.add(const WalletRequested());
    context.read<WorkerBloc>().add(const WorkerRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final worker = context.watch<WorkerBloc>().state;
    // The router only shows this screen with a loaded profile.
    if (worker is! WorkerLoaded) return const SizedBox.shrink();
    final bloc = _bloc ??= getIt<WalletBloc>(param1: worker.profile.countryId)..add(const WalletRequested());

    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.walletTitle),
          actions: const [LanguageToggleButton(), SizedBox(width: 8)],
        ),
        body: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) => switch (state.load) {
            WalletLoading() => const Center(child: CircularProgressIndicator()),
            WalletFailed(:final failure) => FailureView(failure: failure, onRetry: _refresh),
            WalletLoaded() => RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _BalanceCard(state: state, financial: worker.profile.financialStatus),
                  const SizedBox(height: 12),
                  const _TopupNote(),
                  const SizedBox(height: 20),
                  Text(l10n.walletLedger, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  if (state.entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(l10n.walletLedgerEmpty, textAlign: TextAlign.center),
                    ),
                  for (final entry in state.entries) _EntryTile(entry: entry, time: CountryTime(state.timezone), fallbackCurrency: state.wallet!.currency),
                  if (state.hasMore)
                    OutlinedButton(
                      key: const ValueKey('wallet-more'),
                      onPressed: state.loadingMore ? null : () => bloc.add(const WalletMoreRequested()),
                      child: Text(l10n.loadMore),
                    ),
                ],
              ),
            ),
          },
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.state, required this.financial});

  final WalletState state;
  final FinancialStatus financial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final wallet = state.wallet!;
    final standing = state.standing!;
    String money(int amount) => formatMoney(Money(amount, wallet.currency), language);

    final (notice, color) = switch (standing.health) {
      WalletHealth.belowFloor => (l10n.walletBelowFloor, scheme.error),
      WalletHealth.low => (l10n.walletLowWarning(money(standing.policy.lowBalanceWarningThreshold)), scheme.error),
      WalletHealth.healthy => (null, scheme.primary),
    };

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: standing.health == WalletHealth.healthy ? scheme.primaryContainer : scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.walletBalance, style: theme.textTheme.labelLarge),
            Text(
              formatMoney(wallet.money, language),
              key: const ValueKey('wallet-balance'),
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: standing.meter, minHeight: 8, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              standing.roomToFloor >= 0
                  ? l10n.walletRoomToFloor(money(standing.roomToFloor), money(standing.policy.negativeBalanceFloor))
                  : l10n.walletPastFloor(money(-standing.roomToFloor), money(standing.policy.negativeBalanceFloor)),
              key: const ValueKey('wallet-room'),
              style: theme.textTheme.bodyMedium,
            ),
            if (notice != null) ...[
              const SizedBox(height: 8),
              Text(
                notice,
                key: const ValueKey('wallet-warning'),
                style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onErrorContainer, fontWeight: FontWeight.w700),
              ),
            ],
            // From the profile, not derived from the balance: the server decides.
            if (financial != FinancialStatus.active) ...[
              const SizedBox(height: 8),
              Text(
                l10n.financialSuspendedBody,
                key: const ValueKey('wallet-suspended'),
                style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onErrorContainer),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopupNote extends StatelessWidget {
  const _TopupNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            context.l10n.walletTopupNote,
            key: const ValueKey('wallet-topup-note'),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.time, required this.fallbackCurrency});

  final WalletEntry entry;
  final CountryTime time;
  final String fallbackCurrency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final currency = entry.currency.isEmpty ? fallbackCurrency : entry.currency;
    final label = switch (entry.type) {
      WalletEntryType.topup => l10n.entryTopup,
      WalletEntryType.commissionCharge => l10n.entryCommission,
      WalletEntryType.cancellationFee => l10n.entryCancellationFee,
      WalletEntryType.adjustment => l10n.entryAdjustment,
      WalletEntryType.refund => l10n.entryRefund,
      WalletEntryType.reversal => l10n.entryReversal,
      WalletEntryType.unknown => l10n.entryOther,
    };
    final credit = entry.amount > 0;
    final after = entry.balanceAfter;

    return ListTile(
      key: ValueKey('entry-${entry.type.apiValue}'),
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        credit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
        color: credit ? scheme.primary : scheme.error,
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(formatBookingTime(context, entry.createdAt, time)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatSignedMoney(Money(entry.amount, currency), language),
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: credit ? scheme.primary : scheme.error),
          ),
          if (after != null)
            Text(
              l10n.entryBalanceAfter(formatMoney(Money(after, currency), language)),
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
