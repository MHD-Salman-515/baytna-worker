import 'dart:async';

import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/format/money.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/router/app_routes.dart';
import 'package:baytna_worker/core/utils/clock.dart';
import 'package:baytna_worker/core/widgets/failure_view.dart';
import 'package:baytna_worker/core/widgets/ltr.dart';
import 'package:baytna_worker/core/widgets/primary_button.dart';
import 'package:baytna_worker/features/bookings/domain/booking_context.dart';
import 'package:baytna_worker/features/bookings/domain/entities/booking.dart';
import 'package:baytna_worker/features/bookings/presentation/bloc/booking_detail/booking_detail_bloc.dart';
import 'package:baytna_worker/features/bookings/presentation/widgets/booking_labels.dart';
import 'package:baytna_worker/features/bookings/presentation/widgets/deadline_countdown.dart';
import 'package:baytna_worker/features/bookings/presentation/widgets/reason_sheet.dart';
import 'package:baytna_worker/features/bookings/presentation/widgets/swipe_to_confirm.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// One booking from decision to money. The screen only ever offers the one
/// step that is legal now; the server stays the authority on order and actor.
class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({required this.bookingId, super.key});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final worker = context.read<WorkerBloc>().state;
    // The router only shows this screen with a loaded profile.
    if (worker is! WorkerLoaded) return const SizedBox.shrink();
    return BlocProvider(
      create: (_) =>
          getIt<BookingDetailBloc>(param1: bookingId, param2: worker.profile.countryId)..add(const BookingDetailRequested()),
      child: BlocListener<BookingDetailBloc, BookingDetailState>(
        listenWhen: (prev, next) => prev.action != next.action || prev.booking?.status != next.booking?.status,
        listener: (context, state) {
          if (state.action case ActionFailed(:final failure)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(bookingFailureMessage(failure, context.l10n))),
            );
          }
          // Commission can move her wallet past the floor, and suspension
          // follows it on the server: pick that up right away.
          if (state.booking?.status == BookingStatus.completed) {
            context.read<WorkerBloc>().add(const WorkerRefreshRequested());
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: BlocBuilder<BookingDetailBloc, BookingDetailState>(
              buildWhen: (a, b) => a.booking?.bookingNumber != b.booking?.bookingNumber,
              builder: (context, state) => Text(ltrIsolate(state.booking?.bookingNumber ?? '')),
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<BookingDetailBloc, BookingDetailState>(
              builder: (context, state) => switch (state.load) {
                DetailLoading() => const Center(child: CircularProgressIndicator()),
                DetailFailed(:final failure) => FailureView(
                  failure: failure,
                  onRetry: () => context.read<BookingDetailBloc>().add(const BookingDetailRequested()),
                ),
                DetailLoaded() => _Body(state: state, profile: worker.profile),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.profile});

  final BookingDetailState state;
  final WorkerProfile profile;

  @override
  Widget build(BuildContext context) {
    final booking = state.booking!;
    final ctx = state.context!;
    final status = booking.status;
    final bloc = context.read<BookingDetailBloc>();
    final deciding = status == BookingStatus.pendingWorker;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => bloc.add(const BookingDetailRequested()),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 20),
              children: [
                Row(
                  children: [
                    Expanded(child: _ServiceTitle(booking: booking, ctx: ctx)),
                    BookingStatusChip(key: ValueKey('booking-status-${status.apiValue}'), status: status),
                  ],
                ),
                const SizedBox(height: 16),
                if (status.isActiveJob) ...[_TripProgress(status: status), const SizedBox(height: 16)],
                // While she works, what she's earning matters more than where she
                // already is: keep it above the fold, right over the swipe.
                if (status == BookingStatus.inProgress) ...[
                  _EarningsEstimate(state: state),
                  const SizedBox(height: 12),
                ],
                if (deciding && booking.responseDeadline != null) ...[
                  Center(
                    child: DeadlineCountdown(
                      deadline: booking.responseDeadline!,
                      large: true,
                      onExpired: () => bloc.add(const BookingDetailRequested()),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _PlaceCard(booking: booking, ctx: ctx),
                const SizedBox(height: 12),
                _TimeCard(booking: booking, ctx: ctx),
                const SizedBox(height: 12),
                if (status == BookingStatus.completed)
                  _MoneyOutcome(state: state)
                else if (status != BookingStatus.inProgress && (!status.isFinished || status == BookingStatus.expired))
                  _EarningsEstimate(state: state),
                if (status == BookingStatus.cancelled) _CancelledNote(booking: booking),
                if (booking.customerNote case final note? when note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoCard(icon: Icons.sticky_note_2_outlined, title: context.l10n.bookingCustomerNote, body: note),
                ],
              ],
            ),
          ),
        ),
        _ActionBar(state: state, profile: profile),
      ],
    );
  }
}

class _ServiceTitle extends StatelessWidget {
  const _ServiceTitle({required this.booking, required this.ctx});

  final Booking booking;
  final BookingContext ctx;

  @override
  Widget build(BuildContext context) {
    final service = ctx.service(booking.serviceId);
    return Text(
      service == null ? '' : context.localize(service.name),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

/// accepted → on the way → arrived → working.
class _TripProgress extends StatelessWidget {
  const _TripProgress({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final at = BookingStatus.activeJob.indexOf(status);
    return Row(
      children: [
        for (final (i, s) in BookingStatus.activeJob.indexed) ...[
          Expanded(
            child: Column(
              children: [
                Icon(
                  i <= at ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: i <= at ? scheme.primary : scheme.outlineVariant,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  s.label(context.l10n),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: i == at ? FontWeight.w800 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Before acceptance the landmark and city are ALL there is, and the screen
/// says so. After acceptance: street, floor, phone, map.
class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.booking, required this.ctx});

  final Booking booking;
  final BookingContext ctx;

  Future<void> _open(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.bookingCannotOpen;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((Object _) => false);
    if (!opened) messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final address = booking.address;
    final deciding = booking.status == BookingStatus.pendingWorker;
    final phone = booking.customerPhone;
    final point = address.point;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.place_rounded, color: scheme.primary, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.landmark,
                        key: const ValueKey('booking-landmark'),
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cityName(context, booking, ctx),
                        key: const ValueKey('booking-place'),
                        style: theme.textTheme.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (deciding) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 18, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.bookingHiddenUntilAccepted,
                      key: const ValueKey('booking-hidden-note'),
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
            if (address.text case final text? when text.isNotEmpty) ...[
              const Divider(height: 24),
              Text(text, key: const ValueKey('booking-address'), style: theme.textTheme.bodyLarge),
            ],
            if (address.floor case final floor? when floor.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(l10n.bookingFloor(floor), style: theme.textTheme.bodyMedium),
            ],
            if (address.notes case final notes? when notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(notes, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            ],
            if (booking.status.isActiveJob && phone != null) ...[
              const SizedBox(height: 12),
              // Full width: a truncated number is a useless number.
              OutlinedButton.icon(
                key: const ValueKey('call-customer'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: () => _open(context, Uri(scheme: 'tel', path: phone)),
                icon: const Icon(Icons.call_rounded, size: 20),
                label: Text(ltrIsolate(phone)),
              ),
            ],
            if (booking.status.isActiveJob && point != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const ValueKey('open-map'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: () => _open(
                  context,
                  Uri.parse('geo:${point.latitude},${point.longitude}?q=${point.latitude},${point.longitude}'),
                ),
                icon: const Icon(Icons.map_outlined, size: 20),
                label: Text(l10n.bookingOpenMap),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.booking, required this.ctx});

  final Booking booking;
  final BookingContext ctx;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final at = booking.scheduledFor;
    return _InfoCard(
      icon: Icons.event_rounded,
      title: at == null ? '' : formatBookingTime(context, at, ctx.time),
      body: l10n.bookingDuration(formatDuration(l10n, Duration(minutes: booking.estimatedDurationMinutes))),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(body, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Everything up to completion is an ESTIMATE, and it says so, including how
/// the real figure will be worked out.
class _EarningsEstimate extends StatelessWidget {
  const _EarningsEstimate({required this.state});

  final BookingDetailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final booking = state.booking!;
    final language = Localizations.localeOf(context).languageCode;
    final earnings = booking.pricing.earnings;
    final hourly = booking.pricing.pricingType == PricingType.hourly;
    final started = booking.startedAt;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (booking.status == BookingStatus.inProgress && started != null) ...[
              Text(l10n.bookingWorkingFor, style: theme.textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer)),
              ElapsedTimer(since: started),
              const Divider(height: 24),
            ],
            Text(l10n.bookingEstimatedEarnings, style: theme.textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer)),
            const SizedBox(height: 2),
            Text(
              earnings == null ? '—' : formatMoney(earnings, language),
              key: const ValueKey('estimated-earnings'),
              style: theme.textTheme.headlineSmall?.copyWith(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              _basis(l10n, booking, hourly),
              key: const ValueKey('estimate-basis'),
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }

  String _basis(AppLocalizations l10n, Booking booking, bool hourly) {
    if (!hourly) return l10n.bookingEstimateFixed;
    final hours = booking.pricing.hours;
    final minHours = state.minHours;
    final base = hours == null ? l10n.bookingEstimateHourlyNoHours : l10n.bookingEstimateHourly('$hours');
    return minHours == null ? base : '$base ${l10n.bookingMinimumHours(minHours)}';
  }
}

/// THE MONEY MOMENT. The final figure, set against the estimate, with the
/// reason they differ and exactly what left her wallet.
class _MoneyOutcome extends StatelessWidget {
  const _MoneyOutcome({required this.state});

  final BookingDetailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final booking = state.booking!;
    final language = Localizations.localeOf(context).languageCode;
    final estimate = booking.pricing.earnings;
    final finalPricing = booking.finalPricing;
    final finalEarnings = finalPricing?.earnings ?? estimate;
    final differs = estimate != null && finalEarnings != null && estimate != finalEarnings;
    final commission = state.commission;
    final started = booking.startedAt;
    final completed = booking.completedAt;
    final worked = started != null && completed != null ? completed.difference(started) : null;

    Widget row(String label, String value, {Key? key, Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: color))),
          Text(value, key: key, style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: scheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.bookingFinalEarnings, style: theme.textTheme.labelLarge),
                Text(
                  finalEarnings == null ? '—' : formatMoney(finalEarnings, language),
                  key: const ValueKey('final-earnings'),
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Divider(height: 24),
                if (estimate != null)
                  row(l10n.bookingEstimateWas, formatMoney(estimate, language), key: const ValueKey('estimate-was')),
                if (worked != null) row(l10n.bookingTimeWorked, formatDuration(l10n, worked), key: const ValueKey('time-worked')),
                if (finalPricing?.hours case final hours?) row(l10n.bookingHoursCharged, '$hours', key: const ValueKey('hours-charged')),
                if (commission != null)
                  row(
                    l10n.bookingCommissionCharged,
                    formatMoney(commission.money, language),
                    key: const ValueKey('commission-charged'),
                    color: scheme.error,
                  ),
                if (differs) ...[
                  const SizedBox(height: 8),
                  Text(
                    _whyDifferent(l10n, booking, worked),
                    key: const ValueKey('why-different'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
        // The wallet tab is closed if she was suspended mid-job.
        if (context.read<WorkerBloc>().state case WorkerLoaded(:final profile) when profile.verificationStatus.isApproved) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey('see-wallet'),
            onPressed: () => context.go(AppRoutes.wallet),
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: Text(l10n.bookingSeeWallet),
          ),
        ],
      ],
    );
  }

  String _whyDifferent(AppLocalizations l10n, Booking booking, Duration? worked) {
    if (booking.pricing.pricingType != PricingType.hourly) return l10n.bookingDifferenceGeneric;
    final min = state.minHours;
    if (min != null && worked != null && worked < Duration(hours: min)) {
      return l10n.bookingDifferenceMinimum(min);
    }
    return l10n.bookingDifferenceActualTime;
  }
}

class _CancelledNote extends StatelessWidget {
  const _CancelledNote({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = booking.cancellation;
    if (c == null) return const SizedBox.shrink();
    return _InfoCard(
      icon: Icons.cancel_outlined,
      title: c.byCustomer ? l10n.bookingCancelledByCustomer : l10n.bookingCancelledByYou,
      body: c.reason ?? '',
    );
  }
}

/// The single legal next step. Financial suspension blocks ACCEPTING only: a
/// job she already took stays fully workable.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.state, required this.profile});

  final BookingDetailState state;
  final WorkerProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final booking = state.booking!;
    final bloc = context.read<BookingDetailBloc>();
    final next = JobAction.next(booking.status);
    final running = state.action is ActionRunning;
    if (next == null) return const SizedBox.shrink();

    final deadline = booking.responseDeadline;
    final overdue = deadline != null && !deadline.isAfter(getIt<Clock>().now());

    Future<void> cancel() async {
      final penalty = state.context?.country.walletPolicy.workerCancellationPenaltyAmount ?? 0;
      final language = Localizations.localeOf(context).languageCode;
      final reason = await askForReason(
        context,
        title: l10n.bookingCancelTitle,
        confirmLabel: l10n.bookingCancelConfirm,
        presets: [l10n.reasonCancelEmergency, l10n.reasonCancelTransport, l10n.reasonCancelCustomerAsked],
        notice: penalty > 0 ? l10n.bookingCancelPenalty(formatMoney(Money(penalty, booking.pricing.currency), language)) : null,
      );
      if (reason != null) bloc.add(BookingCancelRequested(reason));
    }

    Future<void> reject() async {
      final reason = await askForReason(
        context,
        title: l10n.bookingRejectTitle,
        confirmLabel: l10n.bookingRejectConfirm,
        presets: [l10n.reasonRejectFar, l10n.reasonRejectBusy, l10n.reasonRejectNotSuitable],
      );
      if (reason != null) bloc.add(BookingRejectRequested(reason));
    }

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            switch (next) {
              JobAction.accept when overdue => Text(l10n.bookingDeadlinePassed, textAlign: TextAlign.center),
              JobAction.accept => _Decision(
                canAccept: profile.canTakeNewWork,
                running: running,
                onAccept: () => bloc.add(const JobActionRequested(JobAction.accept)),
                onReject: reject,
              ),
              JobAction.complete => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwipeToConfirm(
                    key: const ValueKey('swipe-complete'),
                    label: l10n.bookingSwipeComplete,
                    enabled: !running,
                    onConfirmed: () => bloc.add(const JobActionRequested(JobAction.complete)),
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.bookingCompleteHint, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                ],
              ),
              JobAction.onTheWay || JobAction.arrived || JobAction.start => PrimaryButton(
                key: ValueKey('step-${next.path}'),
                label: switch (next) {
                  JobAction.onTheWay => l10n.bookingStepOnTheWay,
                  JobAction.arrived => l10n.bookingStepArrived,
                  _ => l10n.bookingStepStart,
                },
                loading: running,
                onPressed: () => bloc.add(JobActionRequested(next)),
              ),
            },
            if (booking.status.workerCanCancel) ...[
              const SizedBox(height: 4),
              TextButton(
                key: const ValueKey('cancel-booking'),
                onPressed: running ? null : () => unawaited(cancel()),
                child: Text(l10n.bookingCancelAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Decision extends StatelessWidget {
  const _Decision({required this.canAccept, required this.running, required this.onAccept, required this.onReject});

  final bool canAccept;
  final bool running;
  final VoidCallback onAccept;
  final Future<void> Function() onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!canAccept) ...[
          Text(
            l10n.bookingCannotAcceptNow,
            key: const ValueKey('accept-blocked'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const ValueKey('reject-booking'),
                onPressed: running ? null : () => unawaited(onReject()),
                child: Text(l10n.bookingReject),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                key: const ValueKey('accept-booking'),
                label: l10n.bookingAccept,
                loading: running,
                onPressed: canAccept ? onAccept : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
