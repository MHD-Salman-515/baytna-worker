import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/widgets/failure_message.dart';
import 'package:flutter/material.dart';

/// Full-area error state with a retry action.
class FailureView extends StatelessWidget {
  const FailureView({required this.failure, required this.onRetry, super.key});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              failure.message(context.l10n),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
