import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Digits (ASCII, Arabic-Indic, Persian) plus the separators people type.
final phoneInputFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹+\s\-()]'));

/// The country prefix and the number field, laid out LEFT-TO-RIGHT even in
/// Arabic: a phone number reads "+963 911 111 111" in every locale. The label
/// and error text around it stay in the app's direction.
class PhoneInput extends StatelessWidget {
  const PhoneInput({
    required this.prefix,
    required this.label,
    required this.onChanged,
    required this.onSubmitted,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final String prefix;
  final String label;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  prefix,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const ValueKey('phone-field'),
                  enabled: enabled,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  inputFormatters: [phoneInputFormatter],
                  style: theme.textTheme.titleMedium?.copyWith(letterSpacing: 1.2),
                  decoration: InputDecoration(
                    enabledBorder: hasError
                        ? OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: scheme.error),
                          )
                        : null,
                  ),
                  onChanged: onChanged,
                  onSubmitted: (_) => onSubmitted(),
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          child: hasError
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(top: 8, start: 4),
                  child: Text(
                    errorText!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
