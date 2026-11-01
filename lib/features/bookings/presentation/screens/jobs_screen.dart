import 'dart:async';

import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/format/money.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/router/app_routes.dart';
import 'package:baytna_worker/core/widgets/failure_view.dart';
import 'package:baytna_worker/core/widgets/language_toggle_button.dart';
import 'package:baytna_worker/core/widgets/ltr.dart';
import 'package:baytna_worker/features/bookings/domain/booking_context.dart';
import 'package:baytna_worker/features/bookings/domain/entities/booking.dart';
import 'package:baytna_worker/features/bookings/presentation/bloc/bookings/bookings_bloc.dart';
import 'package:baytna_worker/features/bookings/presentation/widgets/booking_labels.dart';
import 'package:baytna_worker/features/bookings/presentation/widgets/deadline_countdown.dart';
import 'package:baytna_worker/features/worker/domain/entities/verification_status.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Home for an approved worker: requests to answer, jobs in hand, history.
///
/// There are no push notifications yet, so new requests are found by polling
/// while the app is open, and on returning to the foreground.
class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  static const _pollInterval = Duration(seconds: 90);

  BookingsBloc? _bloc;
  late final AppLifecycleListener _lifecycle;
  late final Timer _poll;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    _poll = Timer.periodic(_pollInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _poll.cancel();
    _lifecycle.dispose();
    unawaited(_bloc?.close());
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    _bloc?.add(const BookingsRequested());
    context.read<WorkerBloc>().add(const WorkerRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final worker = context.watch<WorkerBloc>().state;
    // The router only shows this screen with a loaded profile.
    if (worker is! WorkerLoaded) return const SizedBox.shrink();
    final profile = worker.profile;
    final bloc = _bloc ??= getIt<BookingsBloc>(param1: profile.countryId)..add(const BookingsRequested());

    return BlocProvider.value(
      value: bloc,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.jobsTitle),
            actions: const [LanguageToggleButton(), SizedBox(width: 8)],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kTextTabBarHeight),
              child: BlocBuilder<BookingsBloc, BookingsState>(
                builder: (context, state) => TabBar(
                  tabs: [
                    Tab(key: const ValueKey('jobs-requests'), text: l10n.jobsRequests(state.requests.length)),
                    Tab(key: const ValueKey('jobs-active'), text: l10n.jobsActive(state.active.length)),
                    Tab(key: const ValueKey('jobs-history'), text: l10n.jobsHistory),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              _GateBanner(profile: profile),
              Expanded(
                child: BlocBuilder<BookingsBloc, BookingsState>(
                  builder: (context, state) => switch (state.load) {
                    BookingsLoading() => const Center(child: CircularProgressIndicator()),
                    BookingsFailed(:final failure) => FailureView(failure: failure, onRetry: _refresh),
                    BookingsLoaded() => TabBarView(
                      children: [
                        _BookingList(
                          bookings: state.requests,
                          empty: l10n.jobsRequestsEmpty,
                          ctx: state.context!,
                          profile: profile,
                          onChanged: _refresh,
                        ),
                        _BookingList(
                          bookings: state.active,
                          empty: l10n.jobsActiveEmpty,
                          ctx: state.context!,
                          profile: profile,
                          onChanged: _refresh,
                        ),
                        _BookingList(
                          bookings: state.history,
                          empty: l10n.jobsHistoryEmpty,
                          ctx: state.context!,
                          profile: profile,
                          onChanged: _refresh,
                          hasMore: state.hasMoreHistory,
                          loadingMore: state.loadingMore,
                        ),
                      ],
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The two gates, stated plainly. Each has its own message: neither implies
/// anything about the other.
class _GateBanner extends StatelessWidget {
  const _GateBanner({required this.profile});

  final WorkerProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final financial = profile.financialStatus != FinancialStatus.active;
    if (!financial && profile.isAvailable) return const SizedBox.shrink();
    final message = financial ? l10n.jobsBannerFinancial : l10n.jobsBannerUnavailable;
    final fg = financial ? scheme.onErrorContainer : scheme.onSecondaryContainer;
    final bg = financial ? scheme.errorContainer : scheme.secondaryContainer;
    return Material(
      key: ValueKey(financial ? 'banner-financial' : 'banner-unavailable'),
      color: bg,
      child: InkWell(
        onTap: () => context.go(financial ? AppRoutes.wallet : AppRoutes.work),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: fg),
              const SizedBox(width: 10),
              Expanded(child: Text(message, style: TextStyle(color: fg))),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.bookings,
    required this.empty,
    required this.ctx,
    required this.profile,
    required this.onChanged,
    this.hasMore = false,
    this.loadingMore = false,
  });

  final List<Booking> bookings;
  final String empty;
  final BookingContext ctx;
  final WorkerProfile profile;
  final VoidCallback onChanged;
  final bool hasMore;
  final bool loadingMore;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onChanged(),
      child: bookings.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 96),
                Icon(Icons.inbox_outlined, size: 48, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(empty, textAlign: TextAlign.center),
                ),
              ],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                for (final booking in bookings) ...[
                  _BookingCard(booking: booking, ctx: ctx, profile: profile, onChanged: onChanged),
                  const SizedBox(height: 12),
                ],
                if (hasMore)
                  OutlinedButton(
                    onPressed: loadingMore
                        ? null
                        : () => context.read<BookingsBloc>().add(const BookingsHistoryMoreRequested()),
                    child: Text(context.l10n.loadMore),
                  ),
              ],
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.ctx, required this.profile, required this.onChanged});

  final Booking booking;
  final BookingContext ctx;
  final WorkerProfile profile;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final service = ctx.service(booking.serviceId);
    final deadline = booking.responseDeadline;
    final at = booking.scheduledFor;
    final earnings = (booking.finalPricing ?? booking.pricing).earnings;

    return Card(
      key: ValueKey('booking-${booking.bookingNumber}'),
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: InkWell(
        onTap: () async {
          await context.push(AppRoutes.bookingFor(booking.id));
          onChanged();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      service == null ? ltrIsolate(booking.bookingNumber) : context.localize(service.name),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  BookingStatusChip(status: booking.status),
                ],
              ),
              const SizedBox(height: 8),
              // What she decides on: where it is.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.place_rounded, size: 20, color: scheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.address.landmark, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        Text(placeSummary(context, booking, ctx, profile.cityId), style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event_rounded, size: 18, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(child: Text(at == null ? '' : formatBookingTime(context, at, ctx.time), style: theme.textTheme.bodyMedium)),
                  if (earnings != null)
                    Text(formatMoney(earnings, language), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              if (booking.status == BookingStatus.pendingWorker && deadline != null) ...[
                const SizedBox(height: 8),
                DeadlineCountdown(deadline: deadline, onExpired: onChanged),
              ],
              if (booking.status == BookingStatus.expired) ...[
                const SizedBox(height: 8),
                Text(l10n.jobsExpiredNote, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
