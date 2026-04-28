import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/bookmark_repository.dart';
import '../models/bookmark_model.dart';

/// Global instance of [BookmarkRepository].
final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository();
});

/// Fetches all bookmarks for a given user ID.
final myBookmarksProvider =
    FutureProvider.family<List<BookmarkModel>, String>((ref, userId) {
  return ref.read(bookmarkRepositoryProvider).fetchBookmarks(userId);
});
