import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A single 6-digit field (one input, so paste and SMS autofill just work),
/// always LTR. Kept in sync with the bloc: when the bloc clears the code
/// after a wrong attempt, the field clears too.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    required this.code,
    required this.length,
    required this.onChanged,
    this.enabled = true,
    this.hasError = false,
    super.key,
  });

  final String code;
  final int length;
  final bool enabled;
  final bool hasError;
  final ValueChanged<String> onChanged;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  late final TextEditingController _controller = TextEditingController(text: widget.code);
  final FocusNode _focus = FocusNode();

  @override
  void didUpdateWidget(OtpCodeField old) {
    super.didUpdateWidget(old);
    if (widget.code != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.code,
        selection: TextSelection.collapsed(offset: widget.code.length),
      );
    }
    if (widget.enabled && !old.enabled) _focus.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        key: const ValueKey('otp-field'),
        controller: _controller,
        focusNode: _focus,
        enabled: widget.enabled,
        autofocus: true,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        maxLength: widget.length,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9٠-٩۰-۹]'))],
        style: theme.textTheme.headlineMedium?.copyWith(
          letterSpacing: 14,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: '•' * widget.length,
          hintStyle: TextStyle(color: scheme.outlineVariant, letterSpacing: 14),
          enabledBorder: widget.hasError
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: scheme.error),
                )
              : null,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
