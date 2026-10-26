import 'package:flutter/material.dart';

/// Brand palette. Screens use `Theme.of(context).colorScheme`, not these
/// constants directly; this file only seeds the theme.
abstract final class AppColors {
  static const Color seed = Color(0xFF0F766E);
  static const Color accent = Color(0xFFE8A33D);
  static const Color surfaceLight = Color(0xFFF8F7F4);
  static const Color surfaceDark = Color(0xFF111614);
}
