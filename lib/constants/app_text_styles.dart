import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Senior-friendly text styles aligned with spec_09 §1.
///
/// Minimum font size: 14pt. Smaller sizes are prohibited.
abstract final class AppTextStyles {
  static const String _fontFamily =
      'Roboto'; // Material default, overridden later if needed

  /// 24pt Bold — screen main titles.
  static const TextStyle headline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// 20pt Bold — card titles, section headers.
  static const TextStyle title = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// 18pt Regular — body text, input fields.
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// 18pt Bold — body text with emphasis.
  static const TextStyle bodyBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// 14pt Regular — auxiliary text, dates, captions.
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// 16pt Semi-bold — section sub-titles.
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// 20pt Bold — primary button text.
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );
}
