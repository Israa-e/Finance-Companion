import 'package:flutter/material.dart';

class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────
  static const Color bg        = Color(0xFF0A0C10);
  static const Color bg2       = Color(0xFF111318);
  static const Color bg3       = Color(0xFF181C22);
  static const Color bg4       = Color(0xFF1F2430);
  static const Color card      = Color(0xFF161A23);
  static const Color card2     = Color(0xFF1C2030);

  // ── Accents ────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF7C6FFF);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark  = Color(0xFF4B44CC);

  static const Color income  = Color(0xFF2ECC89);
  static const Color expense = Color(0xFFFF5063);
  static const Color savings = Color(0xFFF5A623);

  // ── Neutral (Light Theme Support) ───────────────────────────
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color cardBg     = Color(0xFFFFFFFF);

  // ── Text ───────────────────────────────────────────────────────
  static const Color textPrimaryDark   = Color(0xFFF0F2FF);
  static const Color textSecondaryDark = Color(0xFF8B91A8);
  static const Color textHintDark      = Color(0xFF555B70);

  static const Color textPrimaryLight   = Color(0xFF1A1D1E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textHintLight      = Color(0xFFB0B7C3);

  // Generic semantic text colors used by current default theme
  static const Color textPrimary   = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textHint      = textHintLight;

  // ── Borders ────────────────────────────────────────────────────
  static const Color border  = Color(0x12FFFFFF); // 7%
  static const Color border2 = Color(0x1FFFFFFF); // 12%

  // ── Category palette ───────────────────────────────────────────
  static const List<Color> categoryColors = [
    Color(0xFF7C6FFF),
    Color(0xFF2ECC89),
    Color(0xFFF5A623),
    Color(0xFFFF5063),
    Color(0xFF60A5FA),
    Color(0xFFC084FC),
    Color(0xFFFB923C),
    Color(0xFF34D399),
  ];

  // ── Gradients (helpers) ────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceGradient = LinearGradient(
    colors: [Color(0xFF1A1640), Color(0xFF0F1028), Color(0xFF160A1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
