import 'package:flutter/material.dart';

/// Mirrors a directional icon in RTL. Many Material icons already do this
/// (`IconData.matchTextDirection`: arrow_back, chevron_right…), but some
/// directional ones don't (e.g. logout_rounded) — wrap those in this.
class DirectionalIcon extends StatelessWidget {
  const DirectionalIcon(this.icon, {this.size, this.color, super.key});

  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: Directionality.of(context) == TextDirection.rtl && !icon.matchTextDirection,
      child: Icon(icon, size: size, color: color),
    );
  }
}
