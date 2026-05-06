import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

/// A mock [User] for use in widget tests.
class MockUser extends Fake implements User {
  @override
  String get uid => 'test_uid';
}
