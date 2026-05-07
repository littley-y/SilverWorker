import 'package:logger/logger.dart';

/// Global application logger instance.
///
/// Used across all layers (providers, repositories, screens).
/// Configure log level centrally here.
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: false,
  ),
);
