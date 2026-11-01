import 'dart:async';

import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/router/app_routes.dart';
import 'package:baytna_worker/core/widgets/directional_icon.dart';
import 'package:baytna_worker/core/widgets/failure_message.dart';
import 'package:baytna_worker/core/widgets/failure_view.dart';
import 'package:baytna_worker/core/widgets/language_toggle_button.dart';
import 'package:baytna_worker/core/widgets/ltr.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:baytna_worker/features/offerings/presentation/bloc/offerings/offerings_bloc.dart';
import 'package:baytna_worker/features/offerings/presentation/widgets/offering_labels.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/availability_toggle/availability_toggle_cubit.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:baytna_worker/features/worker/presentation/widgets/account_standing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// What she controls: whether she's working, when, what she offers and at
/// what price, plus her account.
class WorkScreen extends StatelessWidget {
  const WorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final worker = context.watch<WorkerBloc>().state;
    // The router only shows this screen with a loaded profile.
    if (worker is! WorkerLoaded) return const SizedBox.shrink();
    final profile = worker.profile;
    final phone = switch (context.watch<AuthBloc>().state) {
      AuthAuthenticated(:final user) => user.phone,
      AuthUnknown() || AuthUnauthenticated() => '',
    };

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<OfferingsBloc>()..add(const OfferingsRequested())),
        BlocProvider(create: (_) => getIt<AvailabilityToggleCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.workTitle),
          actions: const [LanguageToggleButton(), SizedBox(width: 8)],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AvailabilityCard(profile: profile),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: ListTile(
                key: const ValueKey('open-schedule'),
                leading: const Icon(Icons.calendar_month_rounded),
                title: Text(l10n.workSchedule, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(l10n.workScheduleHint),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => unawaited(context.push(AppRoutes.availability)),
              ),
            ),
            const SizedBox(height: 20),
            _OfferingsSection(profile: profile),
            const SizedBox(height: 20),
            AccountStandingCard(profile: profile),
            const SizedBox(height: 12),
            Text(
              ltrIsolate(phone),
              key: const ValueKey('home-phone'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const ValueKey('logout'),
              onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
              icon: const DirectionalIcon(Icons.logout_rounded),
              label: Text(l10n.logout),
            ),
          ],
        ),
      ),
    );
  }
}

/// The toggle is her INTENT. The copy says what it doesn't do.
class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.profile});

  final WorkerProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return BlocConsumer<AvailabilityToggleCubit, AvailabilityToggleState>(
      listener: (context, state) {
        if (state.updated case final updated?) {
          context.read<WorkerBloc>().add(WorkerProfileChanged(updated));
        }
        if (state.failure case final failure?) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message(l10n))));
        }
      },
      builder: (context, state) => Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: profile.isAvailable ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      profile.isAvailable ? l10n.availabilityOn : l10n.availabilityOff,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Switch(
                    key: const ValueKey('availability-switch'),
                    value: profile.isAvailable,
                    onChanged: state.saving ? null : (v) => context.read<AvailabilityToggleCubit>().set(isAvailable: v),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(l10n.availabilityIntentNote, style: theme.textTheme.bodySmall),
              if (!profile.canTakeNewWork) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.availabilityNoEffectNow,
                  key: const ValueKey('availability-no-effect'),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferingsSection extends StatelessWidget {
  const _OfferingsSection({required this.profile});

  final WorkerProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<OfferingsBloc>();
    final language = Localizations.localeOf(context).languageCode;

    Future<void> open(String location) async {
      await context.push(location);
      bloc.add(const OfferingsRequested());
    }

    return BlocBuilder<OfferingsBloc, OfferingsState>(
      builder: (context, state) => switch (state) {
        OfferingsLoading() => const Center(child: CircularProgressIndicator()),
        OfferingsFailed(:final failure) => FailureView(
          failure: failure,
          onRetry: () => bloc.add(const OfferingsRequested()),
        ),
        OfferingsLoaded(:final offerings) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.workServices, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (offerings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.workNoServices),
              ),
            for (final offering in offerings) ...[
              _OfferingTile(
                offering: offering,
                service: state.service(offering.serviceId),
                summary: priceSummary(l10n, offering, language),
                onTap: () => open(AppRoutes.offeringFor(offering.id)),
              ),
              const SizedBox(height: 8),
            ],
            if (state.canAddMore)
              OutlinedButton.icon(
                key: const ValueKey('add-offering'),
                onPressed: () => open(AppRoutes.offeringNew),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.workAddService),
              ),
          ],
        ),
      },
    );
  }
}

class _OfferingTile extends StatelessWidget {
  const _OfferingTile({required this.offering, required this.service, required this.summary, required this.onTap});

  final Offering offering;
  final Service? service;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = service;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: ListTile(
        key: ValueKey('offering-${s?.key}'),
        leading: Icon(serviceIcon(s?.key ?? ''), color: theme.colorScheme.primary),
        title: Text(s == null ? '' : context.localize(s.name), style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(offering.isActive ? summary : '$summary\n${context.l10n.offeringPaused}'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
