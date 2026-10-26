import 'dart:async';

import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/localization/localized_text.dart';
import 'package:baytna_worker/core/router/app_routes.dart';
import 'package:baytna_worker/core/widgets/failure_message.dart';
import 'package:baytna_worker/core/widgets/failure_view.dart';
import 'package:baytna_worker/core/widgets/page_scaffold.dart';
import 'package:baytna_worker/core/widgets/primary_button.dart';
import 'package:baytna_worker/features/auth/domain/auth_failures.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/phone/phone_bloc.dart';
import 'package:baytna_worker/features/auth/presentation/widgets/phone_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PhoneEntryScreen extends StatelessWidget {
  const PhoneEntryScreen({required this.countryId, super.key});

  final String countryId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PhoneBloc>(param1: countryId)..add(const PhoneStarted()),
      child: BlocListener<PhoneBloc, PhoneState>(
        listenWhen: (prev, next) => prev.status != next.status && next.status is PhoneCodeSent,
        listener: (context, state) {
          final sent = state.status as PhoneCodeSent;
          unawaited(context.push(AppRoutes.otpFor(countryId: countryId, phoneE164: sent.e164)));
        },
        child: PageScaffold(
          title: context.l10n.phoneTitle,
          subtitle: context.l10n.phoneSubtitle,
          body: BlocBuilder<PhoneBloc, PhoneState>(
            builder: (context, state) => switch (state.status) {
              PhoneCountryLoading() => const Center(child: CircularProgressIndicator()),
              PhoneCountryLoadFailed(:final failure) => FailureView(
                failure: failure,
                onRetry: () => context.read<PhoneBloc>().add(const PhoneStarted()),
              ),
              PhoneIdle() ||
              PhoneInvalidInput() ||
              PhoneSubmitting() ||
              PhoneCodeSent() ||
              PhoneSubmitFailed() => _PhoneForm(state: state),
            },
          ),
        ),
      ),
    );
  }
}

class _PhoneForm extends StatelessWidget {
  const _PhoneForm({required this.state});

  final PhoneState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<PhoneBloc>();
    final country = state.country!;
    final submitting = state.status is PhoneSubmitting;
    final errorText = switch (state.status) {
      PhoneInvalidInput() => l10n.phoneInvalid,
      PhoneSubmitFailed(failure: InvalidPhoneNumber()) => l10n.phoneRejected,
      PhoneSubmitFailed(:final Failure failure) => failure.message(l10n),
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(country.flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(context.localize(country.name), style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 16),
        PhoneInput(
          prefix: country.phonePrefix,
          label: l10n.phoneFieldLabel,
          errorText: errorText,
          enabled: !submitting,
          onChanged: (v) => bloc.add(PhoneNumberChanged(v)),
          onSubmitted: () => bloc.add(const PhoneSubmitted()),
        ),
        const Spacer(),
        PrimaryButton(
          key: const ValueKey('send-code'),
          label: l10n.sendCode,
          loading: submitting,
          onPressed: state.input.trim().isEmpty ? null : () => bloc.add(const PhoneSubmitted()),
        ),
      ],
    );
  }
}
