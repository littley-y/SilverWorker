import 'package:flutter/material.dart';

class AppShadows {
  static List<BoxShadow> subtle(BuildContext context) => [
        BoxShadow(
          color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> normal(BuildContext context) => [
        BoxShadow(
          color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> elevated(BuildContext context) => [
        BoxShadow(
          color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];
}
