import 'package:flutter/material.dart';

/// A deliberate gesture for an action that can't be undone: drag the thumb
/// across the track, towards the END of the reading direction (leftwards in
/// Arabic). Letting go early springs it back. A tap does nothing.
///
/// Screen readers get a labelled action instead, since they can't drag.
class SwipeToConfirm extends StatefulWidget {
  const SwipeToConfirm({required this.label, required this.onConfirmed, this.enabled = true, super.key});

  final String label;
  final VoidCallback onConfirmed;
  final bool enabled;

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm> with SingleTickerProviderStateMixin {
  static const double _height = 64;
  static const double _thumb = 56;
  static const double _inset = 4;

  /// How far (0..1) she must drag for it to count.
  static const double _threshold = 0.9;

  late final AnimationController _position = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  void _onDrag(DragUpdateDetails details, double travel, bool rtl) {
    if (!widget.enabled || travel <= 0) return;
    final delta = (rtl ? -details.delta.dx : details.delta.dx) / travel;
    _position.value = (_position.value + delta).clamp(0.0, 1.0);
  }

  void _onDragEnd() {
    if (!widget.enabled) return;
    if (_position.value >= _threshold) {
      _position.value = 1;
      widget.onConfirmed();
    } else {
      _position.animateBack(0, curve: Curves.easeOut);
    }
  }

  @override
  void didUpdateWidget(SwipeToConfirm old) {
    super.didUpdateWidget(old);
    // Back to the start if the action was refused and it is offered again.
    if (widget.enabled && !old.enabled) _position.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final color = widget.enabled ? scheme.primary : scheme.outline;

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      onTap: widget.enabled ? widget.onConfirmed : null,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final travel = constraints.maxWidth - _thumb - 2 * _inset;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) => _onDrag(d, travel, rtl),
            onHorizontalDragEnd: (_) => _onDragEnd(),
            onHorizontalDragCancel: _onDragEnd,
            child: Container(
              height: _height,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(_height / 2),
              ),
              child: AnimatedBuilder(
                animation: _position,
                builder: (context, _) => Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 1 - _position.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: _thumb + 8),
                        child: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: _inset + travel * _position.value,
                      child: Container(
                        width: _thumb,
                        height: _thumb,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        // arrow_forward has matchTextDirection: it points the way to drag.
                        child: Icon(Icons.arrow_forward_rounded, color: scheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
