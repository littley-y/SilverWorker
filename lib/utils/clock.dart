import 'package:cloud_firestore/cloud_firestore.dart';

/// Injectable time source for repositories.
///
/// Eliminates hardcoded `DateTime.now()` / `Timestamp.now()` calls
/// so unit tests can freeze or advance time deterministically.
abstract class Clock {
  /// Current wall-clock time.
  DateTime now();

  /// Current Firestore server-compatible timestamp.
  Timestamp nowTimestamp();
}

/// Production [Clock] backed by the real system clock.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();

  @override
  Timestamp nowTimestamp() => Timestamp.now();
}
