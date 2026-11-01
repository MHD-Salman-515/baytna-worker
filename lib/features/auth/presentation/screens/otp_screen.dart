import 'package:baytna_worker/core/dev/dev_otp.dart';
import 'package:baytna_worker/core/dev/dev_otp_button.dart';
import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/widgets/failure_message.dart';
import 'package:baytna_worker/core/widgets/ltr.dart';
import 'package:baytna_worker/core/widgets/page_scaffold.dart';
import 'package:baytna_worker/core/widgets/primary_button.dart';
import 'package:baytna_worker/features/auth/domain/otp_policy.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_worker/features/auth/presentation/bloc/otp/otp_bloc.dart';
import 'package:baytna_worker/features/auth/presentation/widgets/otp_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({required this.countryId, required this.phone, super.key});

  final String countryId;

  /// E.164.
  final String phone;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OtpBloc>(param1: countryId, param2: phone)..add(const OtpStarted()),
      child: BlocListener<OtpBloc, OtpState>(
        listenWhen: (prev, next) => prev.status != next.status,
        listener: (context, state) {
          switch (state.status) {
            case OtpVerified(:final session):
              // AuthBloc takes over; the router redirects to home.
              context.read<AuthBloc>().add(AuthLoggedIn(session));
            case OtpResent():
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.otpResent)));
            case OtpEditing() ||
                OtpVerifying() ||
                OtpInvalidCode() ||
                OtpTooManyAttempts() ||
                OtpResending() ||
                OtpFailed():
              break;
          }
        },
        child: PageScaffold(
          title: context.l10n.otpTitle,
          subtitle: context.l10n.otpSubtitle(ltrIsolate(phone)),
          body: const _OtpBody(),
        ),
      ),
    );
  }
}

class _OtpBody extends StatelessWidget {
  const _OtpBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return BlocBuilder<OtpBloc, OtpState>(
      builder: (context, state) {
        final bloc = context.read<OtpBloc>();
        final status = state.status;
        final message = switch (status) {
          OtpInvalidCode() => l10n.otpInvalid,
          OtpTooManyAttempts() => l10n.otpTooManyAttempts,
          OtpFailed(:final failure) => failure.message(l10n),
          OtpEditing() || OtpVerifying() || OtpResending() || OtpResent() || OtpVerified() => null,
        };
        final locked = switch (status) {
          OtpVerifying() || OtpTooManyAttempts() || OtpVerified() => true,
          OtpEditing() || OtpInvalidCode() || OtpResending() || OtpResent() || OtpFailed() => false,
        };

        // Pins the verify button to the bottom when there's room, and scrolls
        // when there isn't (small phones, the keyboard, the dev button).
        return LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OtpCodeField(
                      code: state.code,
                      length: OtpPolicy.codeLength,
                      enabled: !locked,
                      hasError: message != null,
                      onChanged: (v) => bloc.add(OtpCodeChanged(v)),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        message,
                        key: const ValueKey('otp-message'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _ResendRow(state: state),
                    // Constant-false in release: the compiler removes this branch.
                    if (DevOtp.enabled) ...[
                      const SizedBox(height: 16),
                      DevOtpButton(phoneE164: bloc.phone, onCode: (code) => bloc.add(OtpCodeChanged(code))),
                    ],
                    const Spacer(),
                    PrimaryButton(
                      key: const ValueKey('verify'),
                      label: l10n.otpVerify,
                      loading: status is OtpVerifying || status is OtpVerified,
                      onPressed: state.canSubmit ? () => bloc.add(const OtpSubmitted()) : null,
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => context.pop(), child: Text(l10n.changeNumber)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({required this.state});

  final OtpState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (state.resendIn > 0) {
      return Text(
        l10n.otpResendIn(state.resendIn),
        key: const ValueKey('otp-countdown'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }
    final resending = state.status is OtpResending;
    return Center(
      child: TextButton.icon(
        key: const ValueKey('otp-resend'),
        onPressed: state.canResend ? () => context.read<OtpBloc>().add(const OtpResendRequested()) : null,
        icon: resending
            ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.refresh_rounded),
        label: Text(l10n.otpResend),
      ),
    );
  }
}
