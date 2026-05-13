# 05. AI/LLM 기능 도입 기술 분석 및 기술 스택 확정

> 상태: 기획 확정 (2026-05-14)
> 범위: 2차 구현 대상 AI 기능 (리뷰 요약, 컨디션 매칭, 커리어 에이전트, 안면 확인)
> 선행 조건: spec_01~12 MVP 완료

---

## 1. 개요

본 문서는 SilverWorkerNow의 2차 AI 기능 도입에 필요한 **기술 스택 확정, 비용 분석, 구현 우선순위**를 정의합니다. 사업계획서에 기재된 AI 기능을 실제로 구현 가능한 형태로 구체화하며, **묶음 MVP 구성**과 **본격 운영 단계**를 명확히 구분합니다.

---

## 2. 백엔드 서버 필요 여부 — 결론: **필수**

| 이유 | 설명 |
|---|---|
| API 키 보안 | OpenAI/Anthropic/Gemini/AWS 키는 클라이언트에 절대 임베드 불가. Flutter APK는 디컴파일 시 키 추출 가능 |
| 비용 통제 | 클라이언트가 직접 LLM 호출하면 악성 사용자가 API quota를 고갈시킴. 서버에서 사용자당 RPM/RPD 제한 필요 |
| 데이터 가공 | 리뷰 요약은 N건을 배치 처리해야 비용 효율. 클라이언트 1:1 호출은 N배 비쌈 |
| AWS Rekognition | AWS SDK 자격증명을 클라이언트에 둘 수 없음 |

**현재 스택에 맞는 백엔드 옵션**:

| 옵션 | 묶음 한도 | 적합도 |
|---|---|---|
| **Firebase Cloud Functions (Blaze 플랜)** | 2M 호출/월 묶음, 이후 $0.40/M | ⭐ 추천 — 이미 Firebase 쓰고 있어 Firestore/Auth 연동 0-config |
| Cloudflare Workers | 100K 호출/일 묶음, CPU 10ms | 저렴하나 Firebase 연동 추가 작업 필요 |
| Cloud Run | 2M 호출/월 + 360K GB-s | 컨테이너 자유도 필요시 |

→ 현 스택과 결합 측면에서 **Firebase Cloud Functions (Node.js 20)** 확정.

**⚠️ 중요: Firebase Cloud Functions는 Blaze(종량제) 플랜 필수**
- Spark(묶음) 플랜은 **Cloud Functions 자체를 지원하지 않음** (Node.js 10+ 런타임 이후, 2021년~)
- Blaze 플랜 가입 후에도 묶음 한도 내에서는 실제 청구액 $0
- 예상 비용: MVP 개발 기간 중 월 $5~20

---

## 3. 기능별 기술 분석 및 비용

### 3.1 음성 입력 (STT)

| 옵션 | 한국어 정확도 | 비용 | 백엔드 필요 |
|---|---|---|---|
| **Flutter `speech_to_text` 패키지** (iOS Speech / Android SpeechRecognizer) | 양호 | **OS 기본 기능 묶음** | ❌ |
| Google Cloud STT | 우수 | 60분/월 묶음 후 $0.024/분 | ✅ |
| OpenAI Whisper API | 우수 | $0.006/분 | ✅ |

**정확한 기술 현황**:
- `speech_to_text` 패키지는 **기본값이 클라우드 기반** (`onDevice: false`)
- 오프라인(on-device) 모드는 **Android 12+ (API 31)**에서만 지원되며, 별도 설정 필요
- 한국어 지원은 패키지 자체가 아닌 **기기의 한국어 음성 인식 언어팩 설치 여부에 전적으로 의존**
- iOS의 경우 `requiresOnDeviceRecognition` 지원 여부가 기기/로케일에 따라 다름

**MVP 구성안**: OS 기본 STT 묶음 사용. 정확도 불만 시 Whisper 서버 라우팅.

---

### 3.2 LLM (커리어 에이전트 / 컨디션 매칭 / 리뷰 요약)

요청당 토큰 가정: **입력 2K + 출력 500토큰** (이력서 변환), **입력 1K + 출력 300토큰** (요약/매칭)

**1M 토큰당 가격 (2026년 5월 기준)**:

| 모델 | Input | Output | 묶음 티어 |
|---|---|---|---|
| **Gemini 2.5 Flash** | $0.10 | $0.40 | **1,500 req/일 묶음** ⭐ |
| GPT-4o mini | $0.15 | $0.60 | 없음 |
| Claude Haiku 4.5 | $1.00 | $5.00 | 없음 |
| Groq Llama 3.3 70B | $0.59 | $0.79 | **30 RPM 묶음** ⭐ |

**⚠️ 주의: Gemini 2.0 Flash는 2026년 6월 1일 deprecated.** 신규 프로젝트는 **2.5 Flash** 사용.

**스케일 시뮬레이션 (Gemini 2.5 Flash)**:

| 사용자 수 | 월간 LLM 호출 (가정) | 비용 |
|---|---|---|
| 100명 (베타) | 1,000회 | **묶음** (일 1,500 한도 내) |
| 1,000명 (MVP) | 10,000회 | ~$4 |
| 10,000명 | 100,000회 | ~$40 |

**묶음 MVP 구성안**:
```
Flutter app
  └─ speech_to_text (OS 기본, 묶음)
  └─ Firebase Auth (기존)
       ↓ 사용자 토큰
  Firebase Cloud Functions (2M 호출/월 묶음)
       ↓ 서버 측 API 키
  Gemini 2.5 Flash API (1,500 req/일 묶음)
       ↓ 결과
  Firestore 저장 (캐시 — 같은 사용자의 같은 요청 재호출 방지)
```

리뷰 요약은 **결과를 Firestore에 캐시**해서 동일 공고 반복 호출 차단 → 비용 90% 절감.

---

### 3.3 안면 확인 (Liveness)

**정확한 기술 현황**: ML Kit Face Detection은 **liveness/anti-spoofing 기능이 내장되어 있지 않음**. 얼굴을 감지(detection)할 뿐, 실제 사람인지(verification/liveness) 판단하지 않음.

| 옵션 | 정확도 | 비용 | 백엔드 |
|---|---|---|---|
| **AWS Rekognition Face Liveness** | 매우 우수 (스푸핑 차단 고성능) | **$0.015/세션** (첫 50만회) | ✅ |
| Google ML Kit Face Detection + 블링크/헤드무브 자체 구현 | 보통 (사진 일부 탐지 가능) | **묶음** | ❌ |
| MediaPipe Face Mesh + 헤드무브 챌린지 | 보통 | **묶음** | ❌ |

**⚠️ AWS Rekognition Face Liveness 가격 수정**: 기존 분석의 $0.0025/세션은 **오류이며 실제 가격은 $0.015/세션** (첫 50만회 기준, 다음 50만회 $0.0125, 이후 $0.01).

**ML Kit의 실제 한계**:
- 눈 깜빡임/고개 각도 **raw 데이터만 제공**. 이를 이용한 liveness 알고리즘은 **직접 구현**해야 함
- 정면 얼굴(-18°~18°)에서만 분류 동작
- **비디오 재생 공격, 3D 마스크, 딥페이크에 취약**
- 제품 수준의 신뢰성 없음 (커뮤니티 확인: "핸드폰 화면의 사진도 얼굴로 인식됨")

**비용 시뮬레이션 (AWS Rekognition Liveness, $0.015/세션)**:

| 출퇴근 체크 빈도 | 월 세션 | 월 비용 |
|---|---|---|
| 사용자 100명 × 일 2회 × 22일 | 4,400 | $66 |
| 1,000명 × 일 2회 × 22일 | 44,000 | $660 |
| 10,000명 | 440,000 | $6,600 (볼륨 할인 적용 시 $4,400) |

**권장 단계 전략**:
1. **베타/MVP**: ML Kit 묶음 구현 + 사용자 행동 패턴 분석 (블링크 + 헤드무브). 마케팅 문구는 "기본 안면 확인" 수준.
2. **유료 전환 시점**: AWS Rekognition Liveness 도입. 사업계획서 "스마트 안면 인증" 카피 활성화.

---

## 4. 종합 권장안

### 4.1 묶음 MVP (사용자 100~500명 규모까지)

| 영역 | 도구 | 월 비용 |
|---|---|---|
| 백엔드 | Firebase Cloud Functions (Blaze, 묶음 한도 내) | $0 |
| STT | Flutter `speech_to_text` (OS 기본) | $0 |
| LLM | Gemini 2.5 Flash API 묶음 티어 | $0 |
| 안면 확인 | ML Kit Face Detection + 자체 블링크/헤드무브 챌린지 | $0 |
| **합계** | | **$0** |

### 4.2 본격 운영 (1,000명+)

| 영역 | 도구 | 월 비용 (1,000명 기준) |
|---|---|---|
| 백엔드 | Firebase Functions | ~$5 |
| STT | OS 기본 유지 + Whisper 폴백 | ~$5 |
| LLM | Gemini Flash 유료 + 캐시 | ~$10 |
| 안면 확인 | AWS Rekognition Liveness | ~$660 |
| Firestore 추가 | | ~$10 |
| **합계** | | **~$690/월** |

→ 사용자당 **$0.69/월**. 시니어 채용 수수료(공고당 수만 원대) 모델이면 충분히 흡수 가능.

---

## 5. 구현 우선순위 제안 (Spec 시퀀스)

| 순위 | Spec | 기능 | 난이도 | 가치 | 비고 |
|---|---|---|---|---|---|
| 1 | **spec_13a** | 리뷰 자동 요약 | ↓ | ↑↑ | 난이도 낮음, 캐시 효과 큼, 사용자 가치 높음 |
| 2 | **spec_13b** | 컨디션 기반 가변 매칭 | ↓↓ | ↑↑ | 검색/필터 로직 보완으로 구현 가능 |
| 3 | **spec_13c** | 대화형 커리어 에이전트 | ↑↑↑ | ↑↑↑ | STT + LLM 이력서 변환. 가장 임팩트 높음 |
| 4 | **spec_13d** | 안면 확인 출근 인증 | ↑↑ | ↑ | 백엔드 + AWS 통합. 유료 전환 시점에 맞춰 도입 |

---

## 6. 기술 스택 확정 요약

| 계층 | 기술 | 결정 이유 |
|---|---|---|
| LLM | **Gemini 2.5 Flash** | 묶음 티어 1,500 req/일, 한국어 우수, Firebase/Google 스택 일관성 |
| 백엔드 | **Firebase Cloud Functions (Blaze)** | 기존 Firebase 스택과 0-config 연동. Spark 플랜은 Functions 불가 |
| STT | **`speech_to_text` (OS 기본)** | 묶음. 오프라인 모드는 Android 12+/iOS 13+ 제한 |
| 안면 확인 (MVP) | **ML Kit Face Detection** | 묶음. "기본 안면 확인" 수준. 제품 수준 liveness 불가 |
| 안면 확인 (운영) | **AWS Rekognition Face Liveness** | $0.015/세션. 사진/비디오/딥페이크 차단 가능 |
| 캐시 | **Firestore + Cloud Function 메모리** | 동일 요청 재호출 방지, 비용 90% 절감 |

---

## 7. 즉시 결정해야 할 사항

| 결정 사항 | 옵션 | 추천 |
|---|---|---|
| LLM 벤더 | Gemini / OpenAI / Anthropic | **Gemini 2.5 Flash** (묶음 티어 + 가격 + Google 스택) |
| 백엔드 | Firebase Functions / Cloudflare / Cloud Run | **Firebase Functions (Blaze)** — 스택 일관성 |
| Firebase 플랜 | Spark / Blaze | **Blaze 필수** — Functions 사용 가능. 실제 청구는 묶음 한도 내 $0 |
| 안면 확인 MVP | ML Kit 묶음 / AWS 유료 | **ML Kit 묶음 시작** + 마케팅은 "기본 안면 확인" 수준 |
| 안면 확인 운영 | AWS Rekognition | 유료 전환 시 도입. $0.015/세션 |

---

## 8. 리스크 및 주의사항

| 리스크 | 영향 | 대응 |
|---|---|---|
| Gemini 2.5 Flash 묶음 한도 초과 | LLM 기능 일시 중단 | 캐시 강화 + Rate Limiting + Fallback to Groq 묶음 |
| MLKit 안면 확인 우회 (사진/비디오) | 보안 사고 | MVP 단계에서는 "기본 확인"으로 명확히 고지. 운영 시 AWS로 전환 |
| AWS Rekognition 비용 급증 (1,000명+) | 월 $660+ | 단계별 도입. MLKit으로 시작해서 성과 검증 후 AWS 전환 |
| Android 12 미만 STT 오프라인 불가 | 네트워크 불안정 지역 사용자 불편 | 클라우드 STT 폴백 또는 안내 메시지 |

---

## 9. Definition of Done

- [ ] Firebase Blaze 플랜 가입 완료
- [ ] Gemini 2.5 Flash API 키 발급 및 Cloud Functions 환경변수 등록
- [ ] 리뷰 요약 Cloud Function 구현 + Firestore 캐시 연동
- [ ] `speech_to_text` 패키지 연동 및 한국어 인식 테스트
- [ ] ML Kit Face Detection 블링크/헤드무브 챌린지 POC 완료
- [ ] 비용 모니터링 대시보드 구축 (Firebase/GCP Billing Alert)
