import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Unified mapping for physical intensity enum values.
///
/// Centralizes label, color, and icon so UI layers don't duplicate
/// switch expressions. Aligned with `spec_09` design system.
class IntensityHelper {
  IntensityHelper._();

  /// Korean label for the intensity code.
  static String label(String intensity) => switch (intensity) {
        'light' => '가벼움',
        'moderate' => '보통',
        'heavy' => '무거움',
        _ => '알 수 없음',
      };

  /// Color for the intensity grade.
  static Color color(String intensity) => switch (intensity) {
        'light' => AppColors.intensityLight,
        'moderate' => AppColors.intensityModerate,
        'heavy' => AppColors.intensityHeavy,
        _ => AppColors.intensityModerate,
      };

  /// Icon for the intensity grade.
  static IconData icon(String intensity) => switch (intensity) {
        'light' => Icons.eco_outlined,
        'moderate' => Icons.directions_walk,
        'heavy' => Icons.fitness_center,
        _ => Icons.fitness_center,
      };
}
