import 'package:baytna_worker/core/dev/dev_otp.dart';
import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/error/failure.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/network/api_client.dart';
import 'package:flutter/material.dart';

/// Fetches the last OTP from the staging dev endpoint and hands it to
/// [onCode]. Only ever constructed under `if (DevOtp.enabled)`.
class DevOtpButton extends StatefulWidget {
  const DevOtpButton({required this.phoneE164, required this.onCode, super.key});

  final String phoneE164;
  final ValueChanged<String> onCode;

  @override
  State<DevOtpButton> createState() => _DevOtpButtonState();
}

class _DevOtpButtonState extends State<DevOtpButton> {
  bool _loading = false;

  Future<void> _fill() async {
    setState(() => _loading = true);
    try {
      final code = await DevOtp.fetchLastCode(getIt<ApiClient>(), widget.phoneE164);
      debugPrint('[dev-otp] fetched code for ${widget.phoneE164}');
      widget.onCode(code);
    } on Failure catch (f) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.devOtpUnavailable(f.toString()))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      key: const ValueKey('dev-otp-fill'),
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.tertiary,
        side: BorderSide(color: scheme.tertiary),
      ),
      onPressed: _loading ? null : _fill,
      icon: _loading
          ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.bug_report_outlined),
      label: Text(context.l10n.devFillOtp),
    );
  }
}
