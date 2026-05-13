# spec_13 — 리뷰 시스템 (Review System)

> 상태: 기획 확정 (2026-05-14)
> 범위: 공고 리뷰 CRUD (작성, 조회, 수정, 삭제) + 별점/평점
> 난이도: ↓ (Firestore CRUD, 백엔드 서버 불필요)
> 우선순위: P1 (2차 구현 1순위)
> 선행 조건: spec_05 (공고 상세), spec_06 (지원 기능), spec_12 (홈 화면 UI)

---

## 1. 목표

사용자가 근무를 마친 공고에 대해 **별점(1~5점) + 텍스트 리뷰**를 작성할 수 있는 기능을 제공합니다.

- 리뷰 작성: 근무 완료된 공고에 한해 작성 가능
- 리뷰 조회: 공고 상세에서 전체 리뷰 목록 확인
- 리뷰 수정/삭제: 본인 리뷰만 가능
- 공고별 평균 별점 및 리뷰 개수 집계

---

## 2. 사용자 흐름

### 2.1 리뷰 작성

```
[마이페이지 → 지원 내역]
    ↓
[근무 완료된 공고 선택]
    ↓
[리뷰 작성 버튼 클릭]
    ↓
[별점 선택 (1~5점)]
    ↓
[텍스트 리뷰 입력 (최소 10자, 최대 500자)]
    ↓
[작성 완료 → Firestore 저장]
    ↓
[AI 요약 트리거 (리뷰 N개 이상 시 → spec_14)]
```

### 2.2 리뷰 조회

```
[공고 상세 화면]
    ↓
[리뷰 탭 진입]
    ↓
[평균 별점 + 리뷰 개수 표시 (상단)]
    ↓
[리뷰 목록 표시 (하단, 최신순)]
    ↓
[페이징 로드 (10개씩)]
```

---

## 3. DB 스키마 확장

### 3.1 reviews 컬렉션 (신규)

```
/jobs/{jobId}/reviews/{reviewId}
```

| 필드 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `reviewId` | string (문서ID) | 자체 UUID | `rev_abc123` |
| `userId` | string | 작성자 ID | `user_abc` |
| `userName` | string | 작성자 이름 (비식별화) | `김OO` |
| `rating` | number | 별점 (1~5) | `4` |
| `content` | string | 리뷰 내용 (10~500자) | `"사장님이 친절하시고 간식도 챙겨주셨어요"` |
| `isEdited` | boolean | 수정 여부 | `false` |
| `createdAt` | timestamp | 작성 일시 | 2026-05-14T10:00:00Z |
| `updatedAt` | timestamp | 수정 일시 | 2026-05-14T10:00:00Z |

### 3.2 jobs 컬렉션 — 신규 필드

```
/jobs/{jobId}
```

| 필드 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `reviewCount` | number | 리뷰 개수 | `12` |
| `averageRating` | number | 평균 별점 (소수점 1자리) | `4.3` |

### 3.3 users/{userId}/applications — 신규 필드

| 필드 | 타입 | 설명 |
|---|---|---|
| `hasReviewed` | boolean | 리뷰 작성 여부 | `true` |
| `reviewId` | string | 작성한 리뷰 ID | `rev_abc123` |

---

## 4. Firestore 보안 규칙

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // reviews: 누구나 읽기 가능, 쓰기는 본인만
    match /jobs/{jobId}/reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null 
        && request.resource.data.userId == request.auth.uid
        && request.resource.data.rating >= 1
        && request.resource.data.rating <= 5
        && request.resource.data.content.size() >= 10
        && request.resource.data.content.size() <= 500;
      allow update, delete: if request.auth != null 
        && resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 5. Flutter 구현

### 5.1 모델

```dart
// lib/models/review_model.dart

class ReviewModel {
  final String reviewId;
  final String userId;
  final String userName;
  final int rating;
  final String content;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewModel({
    required this.reviewId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.content,
    required this.isEdited,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: json['reviewId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      rating: json['rating'] ?? 0,
      content: json['content'] ?? '',
      isEdited: json['isEdited'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'reviewId': reviewId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'content': content,
        'isEdited': isEdited,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
```

### 5.2 Provider

```dart
// lib/providers/review_provider.dart

@riverpod
class ReviewListNotifier extends _$ReviewListNotifier {
  @override
  FutureOr<List<ReviewModel>> build(String jobId) async {
    return _fetchReviews(jobId);
  }

  Future<List<ReviewModel>> _fetchReviews(String jobId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .doc(jobId)
        .collection('reviews')
        .orderBy('createdAt', 'desc')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => ReviewModel.fromJson(doc.data())).toList();
  }

  Future<void> addReview(String jobId, int rating, String content) async {
    final user = FirebaseAuth.instance.currentUser!;
    final reviewRef = FirebaseFirestore.instance
        .collection('jobs')
        .doc(jobId)
        .collection('reviews')
        .doc();

    final review = ReviewModel(
      reviewId: reviewRef.id,
      userId: user.uid,
      userName: user.displayName ?? '익명',
      rating: rating,
      content: content,
      isEdited: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await reviewRef.set(review.toJson());

    // 지원 내역에 리뷰 작성 표시
    await _markApplicationAsReviewed(jobId, reviewRef.id);

    // jobs 컬렉션 리뷰 통계 업데이트
    await _updateJobReviewStats(jobId);

    ref.invalidateSelf();
  }

  Future<void> _markApplicationAsReviewed(String jobId, String reviewId) async {
    final user = FirebaseAuth.instance.currentUser!;
    final appQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();

    if (appQuery.docs.isNotEmpty) {
      await appQuery.docs.first.reference.update({
        'hasReviewed': true,
        'reviewId': reviewId,
      });
    }
  }

  Future<void> _updateJobReviewStats(String jobId) async {
    final reviews = await FirebaseFirestore.instance
        .collection('jobs')
        .doc(jobId)
        .collection('reviews')
        .get();

    final total = reviews.docs.length;
    final avg = total > 0
        ? reviews.docs.fold<double>(0, (sum, doc) => sum + (doc.data()['rating'] ?? 0)) / total
        : 0.0;

    await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
      'reviewCount': total,
      'averageRating': double.parse(avg.toStringAsFixed(1)),
    });
  }

  Future<void> deleteReview(String jobId, String reviewId) async {
    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(jobId)
        .collection('reviews')
        .doc(reviewId)
        .delete();

    await _updateJobReviewStats(jobId);
    ref.invalidateSelf();
  }
}

// 내 리뷰 여부 확인 Provider
@riverpod
Stream<bool> hasReviewedProvider(Ref ref, String jobId) async* {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) yield false;

  final appQuery = await FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('applications')
      .where('jobId', isEqualTo: jobId)
      .limit(1)
      .get();

  if (appQuery.docs.isEmpty) {
    yield false;
  } else {
    yield appQuery.docs.first.data()['hasReviewed'] ?? false;
  }
}
```

### 5.3 UI 위젯

```dart
// lib/widgets/review_rating_header.dart

class ReviewRatingHeader extends ConsumerWidget {
  final String jobId;

  const ReviewRatingHeader({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailProvider(jobId));

    return jobAsync.when(
      data: (job) {
        if (job == null) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '${job.averageRating ?? 0.0}',
                  style: AppTextStyles.heading1.copyWith(fontSize: 48),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (job.averageRating ?? 0).round()
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.warning,
                        );
                      }),
                    ),
                    Text(
                      '${job.reviewCount ?? 0}개의 리뷰',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const ShimmerLoading(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// lib/widgets/review_list.dart

class ReviewList extends ConsumerWidget {
  final String jobId;

  const ReviewList({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewListNotifierProvider(jobId));

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return const Center(child: Text('아직 리뷰가 없어요'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return ReviewListTile(review: review, jobId: jobId);
          },
        );
      },
      loading: () => const ShimmerLoading(),
      error: (_, __) => const Center(child: Text('리뷰를 불러올 수 없어요')),
    );
  }
}

// lib/widgets/review_list_tile.dart

class ReviewListTile extends ConsumerWidget {
  final ReviewModel review;
  final String jobId;

  const ReviewListTile({super.key, required this.review, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isMine = currentUser?.uid == review.userId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(review.userName, style: AppTextStyles.bodyBold),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: AppColors.warning,
                      size: 16,
                    );
                  }),
                ),
                const Spacer(),
                Text(
                  DateFormat('yyyy.MM.dd').format(review.createdAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.content, style: AppTextStyles.body),
            if (review.isEdited)
              Text('(수정됨)', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            if (isMine)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showEditDialog(context, ref),
                    child: const Text('수정'),
                  ),
                  TextButton(
                    onPressed: () => _deleteReview(context, ref),
                    child: const Text('삭제', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReview(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('리뷰 삭제'),
        content: const Text('리뷰를 삭제하시겠어요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(reviewListNotifierProvider(jobId).notifier)
          .deleteReview(jobId, review.reviewId);
    }
  }
}

// lib/screens/review/review_write_screen.dart

class ReviewWriteScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const ReviewWriteScreen({super.key, required this.jobId, required this.jobTitle});

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  int _rating = 0;
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('리뷰 작성')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(widget.jobTitle, style: AppTextStyles.heading2),
            const SizedBox(height: 24),
            Text('별점을 선택해 주세요', style: AppTextStyles.bodyBold),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 48,
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _contentController,
              maxLength: 500,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '근무 경험을 솔직하게 적어주세요 (최소 10자)',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: '리뷰 등록',
              onPressed: _rating > 0 && _contentController.text.length >= 10
                  ? () => _submitReview()
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    final container = ProviderScope.containerOf(context);
    await container.read(reviewListNotifierProvider(widget.jobId).notifier)
        .addReview(widget.jobId, _rating, _contentController.text);
    if (mounted) Navigator.pop(context);
  }
}
```

### 5.4 공고 상세 — 리뷰 탭 통합

```dart
// lib/screens/job/job_detail_screen.dart — 리뷰 탭

class JobDetailScreen extends StatelessWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('공고 상세'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '정보'),
              Tab(text: '리뷰'),
              Tab(text: '근무지'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            JobInfoTab(jobId: jobId),
            ReviewTab(jobId: jobId),  // 리뷰 탭
            JobLocationTab(jobId: jobId),
          ],
        ),
      ),
    );
  }
}

// lib/screens/job/review_tab.dart

class ReviewTab extends ConsumerWidget {
  final String jobId;

  const ReviewTab({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasReviewed = ref.watch(hasReviewedProvider(jobId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // AI 요약 카드 (spec_14)
          ReviewSummaryCard(jobId: jobId),
          const SizedBox(height: 16),
          // 평균 별점
          ReviewRatingHeader(jobId: jobId),
          const SizedBox(height: 16),
          // 리뷰 목록
          ReviewList(jobId: jobId),
        ],
      ),
    );
  }
}
```

---

## 6. 비용 예측

| 항목 | 가정 | 월 비용 (1,000명) |
|---|---|---|
| Firestore 쓰기 (리뷰) | 2,000회/월 | ~$0.27 |
| Firestore 읽기 (리뷰 목록) | 10,000회/월 | ~$0.30 |
| **합계** | | **~$0.57/월** |

---

## 7. 테스트 계획

### 7.1 단위 테스트

| 시나리오 | 입력 | 기대 결과 |
|---|---|---|
| 리뷰 작성 | rating=5, content="좋았어요" | Firestore에 저장, reviewCount 증가 |
| 별점 미선택 | rating=0 | 등록 버튼 비활성화 |
| 내용 9자 | content="너무좋음" | 등록 버튼 비활성화 |
| 내용 500자 초과 | 501자 입력 | 500자 까지만 입력 가능 |
| 리뷰 목록 | jobId 조회 | 최신순 10개 표시 |
| 평균 별점 | 4점, 5점 리뷰 2개 | averageRating=4.5 |
| 본인 리뷰 삭제 | 본인 reviewId | 삭제 성공, reviewCount 감소 |
| 타인 리뷰 삭제 | 타인 reviewId | Firestore 보안 규칙으로 거부 |
| 근무 미완료 공고 | status != "completed" | 리뷰 작성 버튼 비활성화 |

### 7.2 위젯 테스트

| 시나리오 | 검증 |
|---|---|
| 별점 탭 | 아이콘 색상 변경, 등록 버튼 활성화 |
| 리뷰 목록 | ReviewListTile 정렬, 날짜 표시 |
| 빈 상태 | "아직 리뷰가 없어요" 메시지 |
| 본인 리뷰 | 수정/삭제 버튼 표시 |
| 타인 리뷰 | 수정/삭제 버튼 미표시 |

---

## 8. Definition of Done

- [ ] `ReviewModel` 구현
- [ ] `ReviewListNotifier` 구현 (CRUD + 통계 업데이트)
- [ ] `ReviewRatingHeader`, `ReviewList`, `ReviewListTile` 위젯 구현
- [ ] `ReviewWriteScreen` 구현 (별점 + 텍스트 입력)
- [ ] Firestore `reviews` 서브컬렉션 CRUD 연동
- [ ] `jobs.reviewCount`, `jobs.averageRating` 자동 업데이트
- [ ] 지원 내역(`applications.hasReviewed`) 연동
- [ ] 본인 리뷰만 수정/삭제 가능하도록 Firestore 보안 규칙 적용
- [ ] 근무 완료 공고에만 리뷰 작성 버튼 활성화
- [ ] 공고 상세 화면에 리뷰 탭 통합
- [ ] 단위 테스트 10개 이상 통과
- [ ] `flutter analyze` 0 errors, 0 warnings
