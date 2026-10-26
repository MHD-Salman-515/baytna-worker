import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/features/documents/presentation/widgets/document_labels.dart';
import 'package:baytna_worker/features/worker/domain/entities/verification_status.dart';
import 'package:baytna_worker/features/worker/domain/entities/worker_profile.dart';
import 'package:flutter/material.dart';

/// Verification and financial standing, on SEPARATE rows with separate
/// badges. They are independent on the backend (a verified worker can be
/// financially suspended, and vice versa), so the UI never merges them into
/// a single "account status".
class AccountStandingCard extends StatelessWidget {
  const AccountStandingCard({required this.profile, super.key});

  final WorkerProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (vLabel, vIcon, vFg, vBg) = switch (profile.verificationStatus) {
      VerificationStatus.draft => (l10n.verificationDraft, Icons.edit_note_rounded, scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
      VerificationStatus.pendingReview => (l10n.verificationPending, Icons.hourglass_top_rounded, scheme.onSecondaryContainer, scheme.secondaryContainer),
      VerificationStatus.approved => (l10n.verificationApproved, Icons.verified_rounded, scheme.onPrimaryContainer, scheme.primaryContainer),
      VerificationStatus.rejected => (l10n.verificationRejected, Icons.report_rounded, scheme.onErrorContainer, scheme.errorContainer),
      VerificationStatus.suspended => (l10n.verificationSuspended, Icons.block_rounded, scheme.onErrorContainer, scheme.errorContainer),
      VerificationStatus.unknown => (l10n.verificationUnknown, Icons.help_outline_rounded, scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
    };
    final (fLabel, fIcon, fFg, fBg, fBody) = switch (profile.financialStatus) {
      FinancialStatus.active => (l10n.financialActive, Icons.account_balance_wallet_outlined, scheme.onSurfaceVariant, scheme.surfaceContainerHighest, null),
      FinancialStatus.suspended => (l10n.financialSuspended, Icons.money_off_rounded, scheme.onErrorContainer, scheme.errorContainer, l10n.financialSuspendedBody),
      FinancialStatus.unknown => (l10n.financialUnknown, Icons.help_outline_rounded, scheme.onErrorContainer, scheme.errorContainer, l10n.financialUnknownBody),
    };

    Widget row(String label, Widget badge, Key key) => Row(
      key: key,
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        badge,
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.accountSectionTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            row(
              l10n.verificationLabel,
              StatusChip(label: vLabel, icon: vIcon, foreground: vFg, background: vBg),
              const ValueKey('verification-status'),
            ),
            const Divider(height: 24),
            row(
              l10n.financialLabel,
              StatusChip(label: fLabel, icon: fIcon, foreground: fFg, background: fBg),
              const ValueKey('financial-status'),
            ),
            if (fBody != null) ...[
              const SizedBox(height: 8),
              Text(fBody, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}
