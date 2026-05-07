import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Shows a red error snackbar.
void showErrorSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: AppTextStyles.body),
      backgroundColor: AppColors.error,
    ),
  );
}

/// Shows a green success snackbar.
void showSuccessSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: AppTextStyles.body),
      backgroundColor: AppColors.success,
    ),
  );
}

/// Shows a snackbar with a custom background colour and optional action.
void showSnack(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: AppTextStyles.body),
      backgroundColor: backgroundColor ?? AppColors.primary,
      action: action,
    ),
  );
}
