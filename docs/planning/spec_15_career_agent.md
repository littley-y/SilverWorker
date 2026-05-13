# spec_16 — 대화형 커리어 에이전트 (AI Career Agent)

> 상태: 기획 확정 (2026-05-14)
> 범위: 음성으로 경력을 말하면 AI가 시니어 특화 이력서로 자동 변환
> 난이도: ↑↑↑ (STT + LLM + 이력서 생성 + 다단계 대화)
> 우선순위: P1 (2차 구현 3순위)
> 선행 조건: spec_14 (LLM 인프라), spec_15 (컨디션 분석)

---

## 1. 목표

시니어 구직자가 **음성으로 과거 경력을 말하면**, AI가 이를 듣고:
1. 직무 강점 키워드를 추출
2. 시니어 특화 이력서(간결형)로 자동 변환
3. 적합한 직종을 추천

- 복잡한 이력서 작성 대신 **대화 한 번**으로 완료
- 음성 입력 → 텍스트 변환 → AI 분석 → 이력서 생성 → 저장

---

## 2. 사용자 흐름

```
[마이페이지 → "이력서 만들기"]
    ↓
[에이전트 화면 진입]
    ↓
[음성 버튼 길게 누르기]
    ↓
[STT: "저는 30년 동안 아파트 경비원으로 일했어요..."]
    ↓
[AI 분석 중 로딩]
    ↓
[이력서 미리보기]
    ├── 키워드: [경비원, 아파트 관리, 방범, 고객응대]
    ├── 추천 직종: 경비/관리, 시설관리
    └── 한줄 소개: "30년 경비 경력의 신뢰할 수 있는 시니어 전문가"
    ↓
[사용자 확인 → 저장]
    ↓
[Firestore 저장 + 프로필 업데이트]
```

---

## 3. DB 스키마 확장

### 3.1 users 컬렉션 — 신규 필드

```
/users/{userId}
```

| 필드 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `aiResume` | map | AI 생성 이력서 | `{ keywords: [...], summary: "...", recommendedJobs: [...], generatedAt: timestamp }` |
| `aiResumeRawTranscript` | string | STT 원본 텍스트 | `"저는 30년 동안..."` |
| `careerAgentSession` | map | 마지막 대화 세션 | `{ sessionId, lastMessage, updatedAt }` |

### 3.2 ai_conversations 컬렉션 (신규)

```
/ai_conversations/{sessionId}
```

| 필드 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `sessionId` | string (문서ID) | 세션 ID | `sess_abc123` |
| `userId` | string | 사용자 ID | `user_abc` |
| `messages` | array&lt;map&gt; | 대화 기록 | `[{ role: "user", text: "..." }, { role: "ai", text: "..." }]` |
| `status` | string | 세션 상태 | `active` / `completed` / `error` |
| `createdAt` | timestamp | 생성 일시 | 2026-05-14T10:00:00Z |

---

## 4. 아키텍처

### 4.1 전체 흐름

```
[Flutter App]
    ├─ speech_to_text (OS 기본 STT, 묶음)
    │       ↓ 텍스트
    ├─ Cloud Function: `careerAgentChat`
    │       ↓
    ├─ Gemini 2.5 Flash (1,500 req/일 묶음)
    │       ↓ 이력서 JSON
    └─ Firestore 저장
```

### 4.2 Cloud Function: `careerAgentChat`

```typescript
// functions/src/career/careerAgentChat.ts

import { onCall } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { GoogleGenerativeAI } from '@google/generative-ai';

const db = getFirestore();
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);
const model = genAI.getGenerativeModel({ 
  model: 'gemini-2.5-flash',
  systemInstruction: SYSTEM_PROMPT,
});

const SYSTEM_PROMPT = `당신은 60대 이상 시니어 구직자를 돕는 커리어 에이전트입니다.
규칙:
1. 항상 존댓말 사용
2. 한 번에 하나의 질문만 던지기
3. 경력을 듣고 직무 강점 키워드를 3~5개 추출
4. 추천 직종 2~3개 제시
5. 200자 이내의 한줄 소개 문장 작성

응답 형식 (JSON):
{
  "message": "사용자에게 보여줄 대화 메시지",
  "keywords": ["키워드1", "키워드2"],
  "recommendedJobs": ["직종1", "직종2"],
  "summary": "한줄 소개",
  "isComplete": false
}`;

export const careerAgentChat = onCall(
  {
    region: 'asia-northeast3',
    secrets: ['GEMINI_API_KEY'],
    cors: true,
  },
  async (request) => {
    const { userId, message, sessionId } = request.data;

    // 1. 세션 불러오기
    const sessionRef = db.collection('ai_conversations').doc(sessionId);
    const session = await sessionRef.get();
    const history = session.exists ? session.data()!.messages : [];

    // 2. Gemini 대화
    const chat = model.startChat({ history });
    const result = await chat.sendMessage(message);
    const response = JSON.parse(result.response.text());

    // 3. 세션 저장
    history.push(
      { role: 'user', text: message, timestamp: new Date() },
      { role: 'model', text: response.message, timestamp: new Date() }
    );
    await sessionRef.set({
      userId,
      messages: history,
      status: response.isComplete ? 'completed' : 'active',
      updatedAt: new Date(),
    }, { merge: true });

    // 4. 완료 시 이력서 저장
    if (response.isComplete) {
      await db.collection('users').doc(userId).update({
        aiResume: {
          keywords: response.keywords,
          summary: response.summary,
          recommendedJobs: response.recommendedJobs,
          generatedAt: new Date(),
        },
      });
    }

    return { success: true, ...response };
  }
);
```

---

## 5. Flutter 구현

### 5.1 모델

```dart
// lib/models/ai_resume_model.dart

class AiResumeModel {
  final List<String> keywords;
  final String summary;
  final List<String> recommendedJobs;
  final DateTime generatedAt;

  const AiResumeModel({
    required this.keywords,
    required this.summary,
    required this.recommendedJobs,
    required this.generatedAt,
  });

  factory AiResumeModel.fromJson(Map<String, dynamic> json) {
    return AiResumeModel(
      keywords: List<String>.from(json['keywords'] ?? []),
      summary: json['summary'] ?? '',
      recommendedJobs: List<String>.from(json['recommendedJobs'] ?? []),
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }
}
```

### 5.2 Provider

```dart
// lib/providers/career_agent_provider.dart

@riverpod
class CareerAgentNotifier extends _$CareerAgentNotifier {
  @override
  FutureOr<AiResumeModel?> build() => null;

  final _speech = SpeechToText();
  bool _isListening = false;

  Future<void> startListening() async {
    if (!_isListening) {
      _isListening = true;
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _sendMessage(result.recognizedWords);
          }
        },
        localeId: 'ko_KR',
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('careerAgentChat');
    
    final result = await callable.call<Map<String, dynamic>>({
      'message': text,
      'sessionId': _sessionId,
    });

    if (result.data['isComplete'] == true) {
      state = AsyncValue.data(AiResumeModel.fromJson(result.data));
    }
  }
}
```

### 5.3 UI — 에이전트 화면

```dart
// lib/screens/career/career_agent_screen.dart

class CareerAgentScreen extends ConsumerWidget {
  const CareerAgentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentState = ref.watch(careerAgentNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('이력서 만들기')),
      body: Column(
        children: [
          // 대화 기록 영역
          Expanded(child: _ChatHistory()),
          // 이력서 미리보기 (완료 시)
          if (agentState.valueOrNull != null)
            _ResumePreview(resume: agentState.value!),
          // 음성 입력 버튼
          _VoiceInputButton(
            onPressed: () => ref.read(careerAgentNotifierProvider.notifier).startListening(),
          ),
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
| 사용자당 평균 세션 | 2회/월 | 2,000회 |
| 세션당 평균 턴 | 3턴 | 6,000 호출 |
| Gemini 2.5 Flash | 6,000회/월 | **묶음** (1,500 req/일 = 45,000/월 한도 내) |
| Firestore 쓰기 | 6,000회/월 | ~$0.81 |
| **합계** | | **~$0.81/월** |

---

## 7. 테스트 계획

### 7.1 대화 흐름 테스트

| 단계 | 사용자 입력 | 기대 AI 응답 |
|---|---|---|
| 1 | "안녕하세요" | 인사 + 경력 질문 |
| 2 | "30년 경비원 했어요" | 키워드 추출 + 추가 질문 |
| 3 | "아파트 경비요" | 직종 추천 + 마무리 질문 |
| 4 | "네 맞아요" | 이력서 완성 + isComplete: true |

### 7.2 이력서 출력 테스트

| 입력 | 기대 키워드 | 기대 추천 직종 |
|---|---|---|
| "공장에서 20년 일했어요" | ["제조", "공장", "생산"] | ["단순 노무", "공장 보조"] |
| "식당에서 주방 일했어요" | ["주방", "조리", "위생"] | ["식당 보조", "주방 보조"] |

---

## 8. Definition of Done

- [ ] `careerAgentChat` Cloud Function 배포 (대화 컨텍스트 유지)
- [ ] `AiResumeModel` 및 `CareerAgentNotifier` 구현
- [ ] `CareerAgentScreen` UI 구현 (음성 입력 + 대화 기록 + 이력서 미리보기)
- [ ] STT 한국어 인식 테스트 (Android/iOS 각각)
- [ ] 이력서 자동 저장 및 마이페이지 연동
- [ ] 단위 테스트 10개 이상 통과
- [ ] `flutter analyze` 0 errors, 0 warnings
