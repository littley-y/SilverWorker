# spec_14 — AI 리뷰 자동 요약 (AI Review Summarization)

> 상태: 기획 확정 (2026-05-14)
> 범위: spec_13의 리뷰 데이터를 AI가 분석 → 3줄 키워드 변환
> 난이도: ↓ (Cloud Function 단일 엔드포인트)
> 우선순위: P1 (2차 구현 2순위)
> 선행 조건: spec_13 (리뷰 시스템), spec_05 (공고 상세)

---

## 1. 목표

spec_13에서 작성된 리뷰들을 AI가 분석하여 **"사장님이 친절해요", "간식을 줘요", "휴게시간이 짧아요"**와 같은 직관적인 3줄 키워드로 자동 변환합니다.

- 사용자는 리뷰 원문을 읽지 않고도 공고의 핵심 특징을 파악 가능
- 캐시를 활용하여 동일 공고의 반복 요청 비용 90% 절감

---

## 2. 사용자 흐름

```
[공고 상세 화면]
    ↓
[리뷰 탭 진입]
    ↓
[AI 요약 카드 표시 (상단)]
    ├── 캐시 있음 → 즉시 표시 (0ms)
    └── 캐시 없음 → Cloud Function 호출
            ↓
    [Gemini 2.5 Flash API]
            ↓
    [Firestore 캐시 저장 (TTL 7일)]
            ↓
    [3줄 요약 표시]
```

---

## 3. DB 스키마 확장

### 3.1 jobs 컬렉션 — 신규 필드

```
/jobs/{jobId}
```

| 필드 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `reviewSummary` | map | AI 요약 결과 | `{ keywords: ["사장님 친절", "간식 제공", "휴게 짧음"], sentiment: "positive", generatedAt: timestamp }` |
| `reviewSummaryVersion` | string | 요약 생성 버전 (프롬프트 변경 시 무효화) | `v1.2` |

### 3.2 ai_cache 컬렉션 (신규)

```
/ai_cache/{cacheKey}
```

| 필드 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `cacheKey` | string (문서ID) | `review_summary_{jobId}_{version}` | `review_summary_KJJ_12345678_v1.2` |
| `type` | string | 캐시 타입 | `review_summary` |
| `sourceId` | string | 원본 ID | `KJJ_12345678` |
| `result` | map | AI 응답 결과 | `{ keywords: [...], sentiment: ... }` |
| `promptVersion` | string | 프롬프트 버전 | `v1.2` |
| `expiresAt` | timestamp | 캐시 만료 (기본 7일) | 2026-05-21T00:00:00Z |
| `createdAt` | timestamp | 생성 일시 | 2026-05-14T00:00:00Z |

---

## 4. Cloud Function: `summarizeReviews`

### 4.1 엔드포인트

```typescript
// functions/src/reviews/summarizeReviews.ts

import { onCall } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { GoogleGenerativeAI } from '@google/generative-ai';

const db = getFirestore();
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);
const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

export const summarizeReviews = onCall(
  {
    region: 'asia-northeast3',
    secrets: ['GEMINI_API_KEY'],
    cors: true,
  },
  async (request) => {
    const { jobId } = request.data;
    const cacheKey = `review_summary_${jobId}_v1.2`;

    // 1. 캐시 확인
    const cacheDoc = await db.collection('ai_cache').doc(cacheKey).get();
    if (cacheDoc.exists) {
      const data = cacheDoc.data()!;
      if (data.expiresAt.toMillis() > Date.now()) {
        return { success: true, cached: true, result: data.result };
      }
    }

    // 2. 리뷰 데이터 조회 (최근 50개)
    const reviewsSnap = await db
      .collection('jobs')
      .doc(jobId)
      .collection('reviews')
      .orderBy('createdAt', 'desc')
      .limit(50)
      .get();

    const reviews = reviewsSnap.docs.map(doc => doc.data().content);
    if (reviews.length === 0) {
      return { success: true, cached: false, result: null };
    }

    // 3. Gemini 호출
    const prompt = buildReviewPrompt(reviews);
    const result = await model.generateContent(prompt);
    const response = result.response.text();
    const parsed = parseReviewResponse(response);

    // 4. 캐시 저장
    await db.collection('ai_cache').doc(cacheKey).set({
      type: 'review_summary',
      sourceId: jobId,
      result: parsed,
      promptVersion: 'v1.2',
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      createdAt: new Date(),
    });

    // 5. jobs 컬렉션 업데이트
    await db.collection('jobs').doc(jobId).update({
      reviewSummary: parsed,
      reviewSummaryVersion: 'v1.2',
    });

    return { success: true, cached: false, result: parsed };
  }
);
```

### 4.2 프롬프트 설계

```
당신은 시니어 구직자를 위한 리뷰 요약 전문가입니다.
다음 리뷰들을 읽고, 아래 형식의 JSON으로 응답하세요.

규칙:
1. 키워드는 최대 3개까지만 추출
2. 각 키워드는 10자 이내의 짧은 문장
3. 시니어에게 중요한 정보 위주: 근무 환경, 사장님 태도, 휴게시간, 식사 제공 등
4. 긍정/부정/중립 감정 분류
5. 응답은 반드시 아래 JSON 형식만 사용 (코드 블록 없이)

응답 형식:
{
  "keywords": ["키워드1", "키워드2", "키워드3"],
  "sentiment": "positive" | "neutral" | "negative",
  "confidence": 0.0~1.0
}

리뷰:
{{reviews}}
```

### 4.3 Rate Limiting

```typescript
// 사용자당 일 10회 제한
const userId = request.auth?.uid;
const today = new Date().toISOString().split('T')[0];
const userDailyKey = `rate_limit_${userId}_${today}`;

const rateDoc = await db.collection('rate_limits').doc(userDailyKey).get();
const count = rateDoc.exists ? rateDoc.data()!.count : 0;
if (count >= 10) {
  throw new HttpsError('resource-exhausted', '일일 요청 한도 초과');
}
```

---

## 5. Flutter 구현

### 5.1 모델

```dart
// lib/models/review_summary_model.dart

class ReviewSummaryModel {
  final List<String> keywords;
  final String sentiment;
  final double confidence;
  final DateTime? generatedAt;

  const ReviewSummaryModel({
    required this.keywords,
    required this.sentiment,
    required this.confidence,
    this.generatedAt,
  });

  factory ReviewSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReviewSummaryModel(
      keywords: List<String>.from(json['keywords'] ?? []),
      sentiment: json['sentiment'] ?? 'neutral',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'keywords': keywords,
        'sentiment': sentiment,
        'confidence': confidence,
        'generatedAt': generatedAt?.toIso8601String(),
      };
}
```

### 5.2 Provider

```dart
// lib/providers/review_summary_provider.dart

@riverpod
class ReviewSummaryNotifier extends _$ReviewSummaryNotifier {
  @override
  FutureOr<ReviewSummaryModel?> build(String jobId) async {
    return _fetchSummary(jobId);
  }

  Future<ReviewSummaryModel?> _fetchSummary(String jobId) async {
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('summarizeReviews');
    
    final result = await callable.call<Map<String, dynamic>>({
      'jobId': jobId,
    });

    if (result.data['success'] == true && result.data['result'] != null) {
      return ReviewSummaryModel.fromJson(result.data['result']);
    }
    return null;
  }
}
```

### 5.3 UI 위젯

```dart
// lib/widgets/review_summary_card.dart

class ReviewSummaryCard extends ConsumerWidget {
  final String jobId;

  const ReviewSummaryCard({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reviewSummaryNotifierProvider(jobId));

    return summaryAsync.when(
      data: (summary) {
        if (summary == null) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('근무자 한마디', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: summary.keywords.map((keyword) {
                    return Chip(
                      label: Text(keyword),
                      backgroundColor: _sentimentColor(summary.sentiment),
                    );
                  }).toList(),
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

  Color _sentimentColor(String sentiment) {
    return switch (sentiment) {
      'positive' => AppColors.success.withOpacity(0.1),
      'negative' => AppColors.error.withOpacity(0.1),
      _ => AppColors.background,
    };
  }
}
```

---

## 6. 비용 예측

| 항목 | 가정 | 월 비용 |
|---|---|---|
| 캐시 히트율 | 80% (동일 공고 반복 조회) | - |
| 실제 LLM 호출 | 1,000회/월 (캐시 미스 20%) | **묶음** (1,500 req/일 한도 내) |
| Firestore 쓰기 (캐시) | 1,250회/월 | ~$0.18 |
| **합계 (1,000명 사용자)** | | **~$0/월** (묶음 티어 내) |

---

## 7. 테스트 계획

### 7.1 Cloud Function 단위 테스트

| 시나리오 | 입력 | 기대 결과 |
|---|---|---|
| 정상 요약 | 5개 리뷰 | keywords 3개, sentiment 분류, confidence > 0.7 |
| 캐시 히트 | 동일 jobId 2회 호출 | 2번째는 cached: true |
| Rate Limit | 동일 사용자 11회 호출 | 11번째는 429 에러 |
| 빈 리뷰 | 리뷰 0개 | result: null |
| 한국어 리뷰 | 한글 10개 | keywords 한글, sentiment 정확 |

### 7.2 Flutter 위젯 테스트

| 시나리오 | 검증 |
|---|---|
| 로딩 상태 | ShimmerLoading 표시 |
| 성공 상태 | 3개 Chip 표시, 감정색상 적용 |
| 에러 상태 | UI 미표시 ( SizedBox.shrink ) |
| 캐시 데이터 | 로컬 Firestore에서 즉시 로드 |

---

## 8. Definition of Done

- [ ] `summarizeReviews` Cloud Function 배포 및 동작 확인
- [ ] `ReviewSummaryModel` 구현
- [ ] `ReviewSummaryCard` 위젯 구현 (공고 상세 리뷰 탭 상단에 통합)
- [ ] Firestore 캐시 및 Rate Limiting 적용
- [ ] Gemini 2.5 Flash API 연동
- [ ] spec_13의 `ReviewTab`에 `ReviewSummaryCard` 통합
- [ ] 단위 테스트 8개 이상 통과
- [ ] `flutter analyze` 0 errors, 0 warnings
- [ ] 비용 모니터링 로그 확인 (묶음 한도 내)
