# spec_15 — 컨디션 기반 가변 매칭 (AI Condition-Based Matching)

> 상태: 기획 확정 (2026-05-14)
> 범위: 사용자 신체 조건을 AI가 분석하여 공고 우선순위 재배치
> 난이도: ↓↓ (기존 검색/필터 로직 보완)
> 우선순위: P1 (2차 구현 2순위)
> 선행 조건: spec_04 (공고 목록), spec_14 (LLM 연동 인프라)

---

## 1. 목표

사용자가 입력한 신체 조건(예: "무릎이 안 좋음", "오래 서기 어려움")을 AI가 자연어로 분석하여, 기존 공고 목록의 **우선순위를 재배치**합니다.

- 기존 정적 필터(locationCode, jobCategory)는 유지
- AI가 추가로 "무릎에 무리가 적은 공고"를 상단으로 끌어올림
- 사용자는 별도의 복잡한 필터 설정 없이 자연어로 의사 표현

---

## 2. 사용자 흐름

```
[홈 화면: 공고 목록]
    ↓
[컨디션 입력 FAB 클릭]
    ↓
[음성 또는 텍스트 입력: "무릎이 좀 안 좋아요"]
    ↓
[Cloud Function: 컨디션 분석]
    ↓
[Gemini 2.5 Flash: 키워드 추출]
    ↓
[Firestore: 사용자 컨디션 저장]
    ↓
[공고 목록 재정렬]
    ├── 1순위: 무릎 부담 없는 공고 (좌식, 경비실 등)
    ├── 2순위: 보통 강도 공고
    └── 3순위: 무릎 부담 공고 (계단, 장시간 서있기 등)
```

---

## 3. DB 스키마 확장

### 3.1 users 컬렉션 — 신규 필드

```
/users/{userId}
```

| 필드 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `conditionText` | string | 사용자가 입력한 원문 | `"무릎이 안 좋아서 오래 서기 힘들어요"` |
| `conditionKeywords` | array&lt;string&gt; | AI가 추출한 키워드 | `["knee_pain", "cannot_stand_long"]` |
| `conditionUpdatedAt` | timestamp | 마지막 업데이트 | 2026-05-14T10:00:00Z |

### 3.2 jobs 컬렉션 — 기존 필드 활용

| 필드 | 매칭 로직 |
|---|---|
| `physicalIntensity` | `light` → 1순위, `moderate` → 2순위, `heavy` → 3순위 |
| `physicalBadges` | `standing`/`stairs`/`heavy_lifting` 키워드 매칭 시 하위 배치 |

---

## 4. Cloud Function: `analyzeCondition`

### 4.1 엔드포인트

```typescript
// functions/src/matching/analyzeCondition.ts

import { onCall } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { GoogleGenerativeAI } from '@google/generative-ai';

const db = getFirestore();
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);
const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

const CONDITION_KEYWORDS = [
  'knee_pain', 'cannot_stand_long', 'back_pain', 
  'cannot_lift_heavy', ' prefers_sitting', 'outdoor_ok',
];

export const analyzeCondition = onCall(
  {
    region: 'asia-northeast3',
    secrets: ['GEMINI_API_KEY'],
    cors: true,
  },
  async (request) => {
    const { userId, conditionText } = request.data;

    // 1. Gemini로 키워드 추출
    const prompt = buildConditionPrompt(conditionText);
    const result = await model.generateContent(prompt);
    const response = result.response.text();
    const keywords = parseConditionKeywords(response);

    // 2. 사용자 컨디션 저장
    await db.collection('users').doc(userId).update({
      conditionText,
      conditionKeywords: keywords,
      conditionUpdatedAt: new Date(),
    });

    return { success: true, keywords };
  }
);
```

### 4.2 프롬프트 설계

```
당신은 시니어 구직자의 신체 조건을 분석하는 전문가입니다.
다음 문장에서 해당하는 키워드만 JSON 배열로 반환하세요.

가능한 키워드:
- "knee_pain": 무릎 관련 불편
- "cannot_stand_long": 오래 서있기 어려움
- "back_pain": 허리 관련 불편
- "cannot_lift_heavy": 무거운 것 들기 어려움
- "prefers_sitting": 앉아서 일하고 싶음
- "outdoor_ok": 야외 근무 가능

응답 형식 (코드 블록 없이):
["키워드1", "키워드2"]

문장: "{{conditionText}}"
```

---

## 5. Flutter 구현

### 5.1 모델

```dart
// lib/models/condition_model.dart

class ConditionModel {
  final String text;
  final List<String> keywords;
  final DateTime updatedAt;

  const ConditionModel({
    required this.text,
    required this.keywords,
    required this.updatedAt,
  });

  factory ConditionModel.fromJson(Map<String, dynamic> json) {
    return ConditionModel(
      text: json['conditionText'] ?? '',
      keywords: List<String>.from(json['conditionKeywords'] ?? []),
      updatedAt: DateTime.parse(json['conditionUpdatedAt']),
    );
  }
}
```

### 5.2 매칭 로직 (클라이언트 사이드)

```dart
// lib/providers/job_filter_provider.dart

List<JobModel> applyConditionSort(
  List<JobModel> jobs,
  ConditionModel? condition,
) {
  if (condition == null || condition.keywords.isEmpty) return jobs;

  return jobs.sorted((a, b) {
    final scoreA = _calculateConditionScore(a, condition.keywords);
    final scoreB = _calculateConditionScore(b, condition.keywords);
    return scoreB.compareTo(scoreA); // 높은 점수가 상단
  });
}

int _calculateConditionScore(JobModel job, List<String> keywords) {
  int score = 0;
  
  // 기본 강도 점수
  score += switch (job.physicalIntensity) {
    'light' => 100,
    'moderate' => 50,
    'heavy' => 0,
    _ => 50,
  };

  // 키워드 매칭 페널티
  if (keywords.contains('knee_pain') || keywords.contains('cannot_stand_long')) {
    if (job.physicalBadges.contains('standing')) score -= 50;
    if (job.physicalBadges.contains('stairs')) score -= 50;
    if (job.physicalBadges.contains('sitting')) score += 30;
  }

  if (keywords.contains('cannot_lift_heavy')) {
    if (job.physicalBadges.contains('heavy_lifting')) score -= 50;
  }

  if (keywords.contains('prefers_sitting')) {
    if (job.physicalBadges.contains('sitting')) score += 50;
    if (job.physicalBadges.contains('standing')) score -= 30;
  }

  return score.clamp(0, 150);
}
```

### 5.3 UI — 컨디션 입력 FAB

```dart
// lib/widgets/condition_input_fab.dart

class ConditionInputFab extends ConsumerWidget {
  const ConditionInputFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showConditionDialog(context, ref),
      icon: const Icon(Icons.accessibility_new),
      label: const Text('내 컨디션'),
    );
  }

  void _showConditionDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('오늘 몸 상태는?', style: AppTextStyles.heading2),
              const SizedBox(height: 16),
              // 음성 입력 버튼
              ElevatedButton.icon(
                onPressed: () => _startVoiceInput(context, ref),
                icon: const Icon(Icons.mic),
                label: const Text('음성으로 말하기'),
              ),
              const SizedBox(height: 8),
              // 빠른 선택 버튼
              Wrap(
                spacing: 8,
                children: [
                  '무릎이 안 좋아요',
                  '허리가 뻐근해요',
                  '앉아서 일하고 싶어요',
                  '무거운 건 못 들어요',
                ].map((text) => ActionChip(
                  label: Text(text),
                  onPressed: () => _submitCondition(text, ref),
                )).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 6. 비용 예측

| 항목 | 가정 | 월 비용 |
|---|---|---|
| 컨디션 업데이트 빈도 | 사용자당 주 1회 | 4,000회/월 (1,000명) |
| Gemini 호출 | 4,000회/월 | **묶음** (1,500 req/일 = 45,000/월 한도 내) |
| Firestore 쓰기 | 4,000회/월 | ~$0.54 |
| **합계 (1,000명)** | | **~$0.54/월** |

---

## 7. 테스트 계획

### 7.1 매칭 로직 테스트

| 사용자 컨디션 | 공고 A (좌식) | 공고 B (서있기) | 기대 순위 |
|---|---|---|---|
| "무릎이 안 좋아요" | sitting | standing | A > B |
| "앉아서 일하고 싶어요" | sitting | standing | A > B |
| "무거운 건 못 들어요" | light | heavy_lifting | A > B |
| 컨디션 없음 | - | - | 기본 정렬 유지 |

### 7.2 AI 키워드 추출 테스트

| 입력 문장 | 기대 키워드 |
|---|---|
| "무릎이 아파서 오래 서기 힘들어요" | `["knee_pain", "cannot_stand_long"]` |
| "허리가 뻐근해서 무거운 건 못 들겠어요" | `["back_pain", "cannot_lift_heavy"]` |
| "그냥 편하게 앉아서 하고 싶어요" | `["prefers_sitting"]` |

---

## 8. Definition of Done

- [ ] `analyzeCondition` Cloud Function 배포
- [ ] `ConditionModel` 및 매칭 로직 구현
- [ ] `ConditionInputFab` 위젯 구현 (음성 + 텍스트 입력)
- [ ] 공고 목록에 컨디션 기반 정렬 적용
- [ ] 단위 테스트 8개 이상 통과
- [ ] `flutter analyze` 0 errors, 0 warnings
