import 'package:baytna_worker/core/localization/l10n.dart';
import 'package:baytna_worker/core/network/server_status.dart';
import 'package:flutter/material.dart';

/// Wraps the whole app (see `app.dart`). Slides in a calm notice while the
/// server is cold-starting, so a 30–60 s first request reads as "waking up"
/// rather than "broken".
class WakingUpBanner extends StatelessWidget {
  const WakingUpBanner({required this.status, required this.child, super.key});

  final ServerStatus status;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        child,
        ValueListenableBuilder<bool>(
          valueListenable: status.wakingUp,
          builder: (context, waking, _) => AnimatedPositionedDirectional(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            start: 16,
            end: 16,
            bottom: waking ? 24 + MediaQuery.paddingOf(context).bottom : -120,
            child: Semantics(
              liveRegion: true,
              child: Material(
                color: scheme.inverseSurface,
                elevation: 6,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onInverseSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.l10n.serverWakingUp,
                          style: TextStyle(color: scheme.onInverseSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
