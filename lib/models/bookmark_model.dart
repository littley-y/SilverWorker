import '../utils/timestamp_helper.dart';

/// Bookmark (scrap) model.
///
/// Aligned with `overview/04_db_schema.md` §2.4.
/// Stored under `/users/{userId}/bookmarks/{jobId}`.
class BookmarkModel {
  final String jobId;
  final String jobTitle; // denormalized
  final String companyName; // denormalized
  final DateTime? bookmarkedAt;

  const BookmarkModel({
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.bookmarkedAt,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      jobId: json['jobId'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      bookmarkedAt: TimestampHelper.toDateTime(json['bookmarkedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'bookmarkedAt': TimestampHelper.fromDateTime(bookmarkedAt),
    };
  }

  BookmarkModel copyWith({
    String? jobId,
    String? jobTitle,
    String? companyName,
    DateTime? bookmarkedAt,
  }) {
    return BookmarkModel(
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      bookmarkedAt: bookmarkedAt ?? this.bookmarkedAt,
    );
  }
}
