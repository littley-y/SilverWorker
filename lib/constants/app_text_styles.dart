import 'package:flutter/material.dart';

/// Senior-friendly text styles.
///
/// Base font size is 18pt or larger for readability.
abstract final class AppTextStyles {
  static const String _fontFamily = 'Roboto'; // Material default, overridden later if needed

  static const TextStyle headline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    height: 1.4,
  );

  static const TextStyle title = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );
}
