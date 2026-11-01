import 'dart:async';

import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/format/money.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/widgets/failure_message.dart';
import 'package:baytna_worker/core/widgets/failure_view.dart';
import 'package:baytna_worker/core/widgets/page_scaffold.dart';
import 'package:baytna_worker/core/widgets/primary_button.dart';
import 'package:baytna_worker/features/offerings/domain/entities/pricing.dart';
import 'package:baytna_worker/features/offerings/domain/offering_failures.dart';
import 'package:baytna_worker/features/offerings/domain/offering_validator.dart';
import 'package:baytna_worker/features/offerings/presentation/bloc/offering_form/offering_form_bloc.dart';
import 'package:baytna_worker/features/offerings/presentation/widgets/offering_labels.dart';
import 'package:baytna_worker/features/worker/presentation/bloc/worker/worker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final _digits = FilteringTextInputFormatter.allow(RegExp('[0-9٠-٩۰-۹]'));

/// Add or edit a service. The allowed price range appears as soon as the
/// pricing model is chosen, before there is anything to type.
class OfferingFormScreen extends StatelessWidget {
  const OfferingFormScreen({this.offeringId, super.key});

  /// Null when adding.
  final String? offeringId;

  @override
  Widget build(BuildContext context) {
    final worker = context.read<WorkerBloc>().state;
    // The router only shows this screen with a loaded profile.
    if (worker is! WorkerLoaded) return const SizedBox.shrink();
    final l10n = context.l10n;
    return BlocProvider(
      create: (_) =>
          getIt<OfferingFormBloc>(param1: worker.profile.countryId, param2: offeringId)..add(const OfferingFormStarted()),
      child: BlocListener<OfferingFormBloc, OfferingFormState>(
        listenWhen: (prev, next) => prev.status != next.status && next.status is FormDone,
        listener: (context, state) => context.pop(),
        child: PageScaffold(
          title: offeringId == null ? l10n.offeringAddTitle : l10n.offeringEditTitle,
          body: BlocBuilder<OfferingFormBloc, OfferingFormState>(
            buildWhen: (prev, next) => (prev.status is FormLoading) != (next.status is FormLoading) || next.status is FormLoadFailed,
            builder: (context, state) => switch (state.status) {
              FormLoading() => const Center(child: CircularProgressIndicator()),
              FormLoadFailed(:final failure) => FailureView(
                failure: failure,
                onRetry: () => context.read<OfferingFormBloc>().add(const OfferingFormStarted()),
              ),
              _ => const _Form(),
            },
          ),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<OfferingFormBloc>();

    return BlocBuilder<OfferingFormBloc, OfferingFormState>(
      builder: (context, state) {
        final saving = state.status is FormSaving;
        final errors = switch (state.status) {
          FormInvalid(:final errors) => errors,
          _ => const <OfferingError>{},
        };
        final saveError = switch (state.status) {
          FormSaveFailed(:final failure) => _failureText(context, failure, state),
          _ => null,
        };
        final currency = state.currency;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  if (state.isEditing) ...[
                    if (state.service case final service?)
                      Text(
                        context.localize(service.name),
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                  ] else ...[
                    _Label(l10n.offeringService),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final service in state.selectable)
                          ChoiceChip(
                            key: ValueKey('service-${service.key}'),
                            avatar: Icon(serviceIcon(service.key), size: 18),
                            label: Text(context.localize(service.name)),
                            selected: state.serviceId == service.id,
                            onSelected: saving ? null : (_) => bloc.add(OfferingServiceSelected(service.id)),
                          ),
                      ],
                    ),
                  ],
                  if (state.serviceId != null) ...[
                    const SizedBox(height: 16),
                    _Label(l10n.offeringPricingModel),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final type in state.allowedTypes)
                          ChoiceChip(
                            key: ValueKey('pricing-${type.apiValue}'),
                            label: Text(type.label(l10n)),
                            selected: state.pricingType == type,
                            onSelected: saving ? null : (_) => bloc.add(OfferingPricingTypeSelected(type)),
                          ),
                      ],
                    ),
                  ],
                  if (state.pricingType case final type?) ...[
                    const SizedBox(height: 6),
                    Text(type.explain(l10n), style: theme.textTheme.bodySmall),
                    const SizedBox(height: 12),
                    _RangeNotice(rule: state.rule, currency: currency, type: type),
                    const SizedBox(height: 16),
                    KeyedSubtree(
                      key: ValueKey(type),
                      child: switch (type) {
                        PricingType.hourly => _HourlyFields(state: state, errors: errors),
                        PricingType.fixed => _AmountField(state: state, errors: errors, label: l10n.offeringFixedPrice),
                        PricingType.bySize => _TierFields(state: state, errors: errors),
                        PricingType.unknown => const SizedBox.shrink(),
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.offeringCurrencyFixed(currencySymbol(currency, Localizations.localeOf(context).languageCode)),
                            key: const ValueKey('currency-note'),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (state.isEditing) ...[
                    const SizedBox(height: 12),
                    SwitchListTile(
                      key: const ValueKey('offering-active'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.offeringActive),
                      subtitle: Text(l10n.offeringActiveHint),
                      value: state.isActive,
                      onChanged: saving ? null : (v) => bloc.add(OfferingActiveToggled(isActive: v)),
                    ),
                    TextButton.icon(
                      key: const ValueKey('offering-delete'),
                      onPressed: saving ? null : () => unawaited(_confirmDelete(context)),
                      icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                      label: Text(l10n.offeringDelete, style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  ],
                ],
              ),
            ),
            if (saveError != null) ...[
              Text(
                saveError,
                key: const ValueKey('offering-error'),
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              const SizedBox(height: 8),
            ],
            PrimaryButton(
              key: const ValueKey('offering-save'),
              label: l10n.offeringSave,
              loading: saving,
              onPressed: state.canSave ? () => bloc.add(const OfferingFormSubmitted()) : null,
            ),
          ],
        );
      },
    );
  }

  static String _failureText(BuildContext context, Failure failure, OfferingFormState state) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final currency = state.currency;
    String money(int amount) => formatMoney(Money(amount, currency), language);
    return switch (failure) {
      PriceOutOfRange(:final min, :final max) => l10n.offeringOutOfRange(money(min), money(max)),
      PricingTypeNotAllowed() => l10n.offeringTypeNotAllowed,
      OfferingAlreadyExists() => l10n.offeringAlreadyExists,
      _ => failure.message(l10n),
    };
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = context.l10n;
    final bloc = context.read<OfferingFormBloc>();
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.offeringDeleteTitle),
        content: Text(l10n.offeringDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.documentDiscard)),
          TextButton(
            key: const ValueKey('offering-delete-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.offeringDelete),
          ),
        ],
      ),
    );
    if (yes ?? false) bloc.add(const OfferingDeleteRequested());
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
  );
}

/// Shown BEFORE she types.
class _RangeNotice extends StatelessWidget {
  const _RangeNotice({required this.rule, required this.currency, required this.type});

  final PricingRule? rule;
  final String currency;
  final PricingType type;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final r = rule;
    final unit = switch (type) {
      PricingType.hourly => l10n.offeringRangePerHour,
      PricingType.bySize => l10n.offeringRangePerTier,
      _ => l10n.offeringRangePerJob,
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.price_check_rounded, color: scheme.onSecondaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                r == null
                    ? l10n.offeringNoRange
                    : l10n.offeringRange(
                        formatMoney(Money(r.minPrice, currency), language),
                        formatMoney(Money(r.maxPrice, currency), language),
                        unit,
                      ),
                key: const ValueKey('price-range'),
                style: theme.textTheme.titleSmall?.copyWith(color: scheme.onSecondaryContainer, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _priceError(BuildContext context, Set<OfferingError> errors, OfferingFormState state) {
  final l10n = context.l10n;
  if (errors.contains(OfferingError.priceMissing)) return l10n.offeringPriceMissing;
  if (errors.contains(OfferingError.priceOutOfRange)) {
    final rule = state.rule;
    if (rule == null) return l10n.offeringPriceMissing;
    final language = Localizations.localeOf(context).languageCode;
    final currency = state.currency;
    return l10n.offeringOutOfRange(
      formatMoney(Money(rule.minPrice, currency), language),
      formatMoney(Money(rule.maxPrice, currency), language),
    );
  }
  return null;
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.state, required this.errors, required this.label});

  final OfferingFormState state;
  final Set<OfferingError> errors;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const ValueKey('offering-amount'),
      initialValue: state.amount,
      keyboardType: TextInputType.number,
      inputFormatters: [_digits],
      decoration: InputDecoration(labelText: label, errorText: _priceError(context, errors, state), errorMaxLines: 2),
      onChanged: (v) => context.read<OfferingFormBloc>().add(OfferingAmountChanged(v)),
    );
  }
}

class _HourlyFields extends StatelessWidget {
  const _HourlyFields({required this.state, required this.errors});

  final OfferingFormState state;
  final Set<OfferingError> errors;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AmountField(state: state, errors: errors, label: l10n.offeringHourlyRate),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('offering-min-hours'),
          initialValue: state.minHours,
          keyboardType: TextInputType.number,
          inputFormatters: [_digits, LengthLimitingTextInputFormatter(2)],
          decoration: InputDecoration(
            labelText: l10n.offeringMinHours,
            helperText: l10n.offeringMinHoursHint,
            helperMaxLines: 2,
            errorText: errors.contains(OfferingError.minHoursInvalid) ? l10n.offeringMinHoursInvalid : null,
          ),
          onChanged: (v) => context.read<OfferingFormBloc>().add(OfferingMinHoursChanged(v)),
        ),
      ],
    );
  }
}

class _TierFields extends StatelessWidget {
  const _TierFields({required this.state, required this.errors});

  final OfferingFormState state;
  final Set<OfferingError> errors;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<OfferingFormBloc>();
    final message = errors.contains(OfferingError.tiersNotAscending) || errors.contains(OfferingError.tiersEmpty)
        ? l10n.offeringTiersInvalid
        : _priceError(context, errors, state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, tier) in state.tiers.indexed)
          Padding(
            key: ObjectKey(i),
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('tier-$i-rooms'),
                    initialValue: tier.maxRooms,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_digits, LengthLimitingTextInputFormatter(2)],
                    decoration: InputDecoration(labelText: l10n.offeringTierRooms),
                    onChanged: (v) => bloc.add(OfferingTierChanged(i, maxRooms: v)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    key: ValueKey('tier-$i-price'),
                    initialValue: tier.price,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_digits],
                    decoration: InputDecoration(labelText: l10n.offeringTierPrice),
                    onChanged: (v) => bloc.add(OfferingTierChanged(i, price: v)),
                  ),
                ),
                if (state.tiers.length > 1)
                  IconButton(
                    tooltip: l10n.documentDiscard,
                    onPressed: () => bloc.add(OfferingTierRemoved(i)),
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
            ),
          ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              message,
              key: const ValueKey('tiers-error'),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            key: const ValueKey('tier-add'),
            onPressed: () => bloc.add(const OfferingTierAdded()),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.offeringTierAdd),
          ),
        ),
      ],
    );
  }
}
