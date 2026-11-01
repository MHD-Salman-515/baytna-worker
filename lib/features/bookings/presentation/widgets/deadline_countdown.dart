import 'dart:async';

import 'package:baytna_worker/core/di/injection.dart';
import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/utils/clock.dart';
import 'package:baytna_worker/core/widgets/ltr.dart';
import 'package:flutter/material.dart';

/// "H:MM:SS", always left-to-right. Hours may exceed 24 on purpose: she
/// counts down to one moment, not to a date.
String formatCountdown(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final clamped = d.isNegative ? Duration.zero : d;
  return ltrIsolate('${clamped.inHours}:${two(clamped.inMinutes % 60)}:${two(clamped.inSeconds % 60)}');
}

/// Ticks every second towards [deadline], turning urgent in the last hour.
/// [onExpired] fires once, so the screen can reload the (now EXPIRED) booking.
class DeadlineCountdown extends StatefulWidget {
  const DeadlineCountdown({required this.deadline, this.onExpired, this.large = false, super.key});

  final DateTime deadline;
  final VoidCallback? onExpired;
  final bool large;

  @override
  State<DeadlineCountdown> createState() => _DeadlineCountdownState();
}

class _DeadlineCountdownState extends State<DeadlineCountdown> {
  static const _urgent = Duration(hours: 1);

  final Clock _clock = getIt<Clock>();
  late final Timer _timer;
  bool _fired = false;

  Duration get _left => widget.deadline.difference(_clock.now());

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (_left <= Duration.zero && !_fired) {
        _fired = true;
        widget.onExpired?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final left = _left;
    final color = left <= _urgent ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant;
    if (left <= Duration.zero) {
      return Text(context.l10n.bookingDeadlinePassed, style: theme.textTheme.titleSmall?.copyWith(color: color));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, size: widget.large ? 22 : 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            context.l10n.bookingAnswerWithin(formatCountdown(left)),
            key: const ValueKey('deadline-countdown'),
            style: (widget.large ? theme.textTheme.titleMedium : theme.textTheme.labelLarge)?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

/// Counts UP from [since] while she works: the time the final price uses.
class ElapsedTimer extends StatefulWidget {
  const ElapsedTimer({required this.since, super.key});

  final DateTime since;

  @override
  State<ElapsedTimer> createState() => _ElapsedTimerState();
}

class _ElapsedTimerState extends State<ElapsedTimer> {
  final Clock _clock = getIt<Clock>();
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatCountdown(_clock.now().difference(widget.since)),
      key: const ValueKey('elapsed-timer'),
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
