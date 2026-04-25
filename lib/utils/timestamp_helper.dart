import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper for converting Firestore [Timestamp] to/from [DateTime].
abstract final class TimestampHelper {
  static DateTime? toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static Timestamp? fromDateTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }
}
