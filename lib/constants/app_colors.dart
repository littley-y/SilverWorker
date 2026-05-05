import 'package:flutter/material.dart';

/// Senior-friendly color palette for SilverWorkerNow.
///
/// WCAG AA contrast compliant against white/black backgrounds.
/// Aligned with spec_09 §2.
abstract final class AppColors {
  // Primary — WCAG AA compliant (4.5:1+ against white)
  static const Color primary = Color(0xFF1565C0); // Deep blue
  static const Color primaryLight =
      Color(0xFFE3F2FD); // Light blue (badge background)

  // Text
  static const Color textPrimary = Color(0xFF212121); // Contrast 16:1
  static const Color textSecondary = Color(0xFF757575); // Contrast 4.6:1

  // Background
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE0E0E0);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFC62828);

  // Physical intensity (safety badges)
  static const Color intensityLight = Color(0xFF4CAF50);
  static const Color intensityModerate = Color(0xFFFF9800);
  static const Color intensityHeavy = Color(0xFFF44336);

  // Application status badges
  static const Color statusSubmitted = Color(0xFF1976D2);
  static const Color statusReviewing = Color(0xFFFF9800);
  static const Color statusAccepted = Color(0xFF4CAF50);
  static const Color statusRejected = Color(0xFFF44336);
  static const Color statusCancelled = Color(0xFF9E9E9E);
}
