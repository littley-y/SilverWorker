import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/application_repository.dart';
import '../models/application_model.dart';

/// Global instance of [ApplicationRepository].
final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository();
});

/// Fetches all applications for a given user ID.
final myApplicationsProvider =
    FutureProvider.family<List<ApplicationModel>, String>((ref, userId) {
  return ref.read(applicationRepositoryProvider).fetchApplications(userId);
});
