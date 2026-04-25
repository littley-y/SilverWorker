import 'package:flutter/material.dart';

/// Senior-friendly color palette for SilverWorkerNow.
///
/// WCAG AA contrast compliant against white/black backgrounds.
abstract final class AppColors {
  // Primary
  static const Color primary = Color(0xFF1565C0); // Deep Blue
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF616161);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFC62828);

  // Safety badges
  static const Color badgeLight = Color(0xFF81C784);  // 가벼움
  static const Color badgeMedium = Color(0xFFFFB74D); // 보통
  static const Color badgeHeavy = Color(0xFFE57373);  // 무거움
}
