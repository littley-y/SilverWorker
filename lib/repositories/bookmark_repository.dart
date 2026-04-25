import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bookmark_model.dart';

/// Repository for bookmark (scrap) operations.
class BookmarkRepository {
  final FirebaseFirestore _firestore;

  BookmarkRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches all bookmarks for a given user.
  Future<List<BookmarkModel>> fetchBookmarks(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('bookmarkedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BookmarkModel.fromJson(doc.data()))
        .toList();
  }

  /// Adds or updates a bookmark.
  Future<void> saveBookmark(String userId, BookmarkModel bookmark) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(bookmark.jobId)
        .set(bookmark.toJson());
  }

  /// Removes a bookmark.
  Future<void> deleteBookmark(String userId, String jobId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(jobId)
        .delete();
  }
}
