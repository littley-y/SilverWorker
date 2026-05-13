---
title: PR #10 (spec_10 / Day 12) — Claude Review
date: 2026-05-10
reviewer: Claude (Opus 4.7)
target: master @ 9adae2e (직접 커밋, GH PR 미존재)
spec: docs/planning/spec_10_test_criteria.md
verdict: ✅ APPROVE (Minor 1건)
---

## 1. 변경 범위 확인

대상 커밋:
- `b8f2519` fix(android): MainActivity.kt + INTERNET 권한
- `4c6fde3` test(spec_10): 테스트 3종 + ApplicationRepository DI 리팩토링
- `71375f7` docs: 리뷰 요청 + history
- `9adae2e` chore(graphify)

코드 변경 영향 파일 (`git diff 0a6b04a..9adae2e --stat`):
- `lib/repositories/application_repository.dart` (+8/-4)
- `test/repositories/application_repository_test.dart` (+162, 신규)
- `test/models/job_filter_test.dart` (+88, 신규)
- `test/models/physical_badge_test.dart` (+256, 신규)
- `android/app/src/main/AndroidManifest.xml` (+1)
- `android/app/src/main/kotlin/.../MainActivity.kt` (+5, 신규)
- `android/app/google-services.json` (SHA-1 갱신)

---

## 2. Spec 준수 검증

`spec_10_test_criteria.md` §3 "작성 대상 테스트" 4개 파일 요구사항:

| 요구 파일 | 상태 | 비고 |
|---|---|---|
| `job_model_test.dart` | 기존 보유 | 사전 작업으로 존재 |
| `application_repository_test.dart` | ✅ 신규 7테스트 | 중복 지원 방지 + 예외 4종 모두 커버 |
| `job_filter_test.dart` | ✅ 신규 6테스트 | sentinel 패턴 명시적 검증 포함 |
| `physical_badge_test.dart` | ✅ 신규 8테스트 | 4개 강도 + 6개 배지 타입 |

§3 코드 품질 기준 (`flutter analyze`/`flutter test`)도 요청 doc에 0경고/84테스트로 보고됨. 자체 재실행은 생략(별도 CI에서 검증).

---

## 3. 변경 사항별 평가

### 3.1 ApplicationRepository DI 리팩토링 — ✅ Good

`FirebaseAuth.instance` 직접 호출을 생성자 주입으로 전환:

```dart
ApplicationRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;
```

- 기본값 fallback 유지로 기존 호출부(`lib/providers/application_provider.dart:7`) 무영향. ✅
- `firestore` 주입 패턴과 일관 — 리뷰 포인트 1번 만족.
- 테스트의 `_FakeFirebaseAuth` + `_FakeUser`로 `currentUser!.uid` 경로가 안전하게 검증됨.

### 3.2 application_repository_test.dart — ✅ Solid

- `fake_cloud_firestore` 기반 시나리오 6종이 spec §2 T-APP-01/02/03 및 마감일/비활성 케이스를 모두 커버.
- `submitApplication` 트랜잭션 분기 4개(open / Already / NotFound / Inactive / DeadlinePassed) 모두 검증. 리뷰 포인트 2번 통과.
- 다만 트랜잭션 자체의 동시성(예: 동시에 두 번 호출 시 1건만 생성)은 직접 검증하지 않음 — 단위 테스트 범위로는 적절. UI 측에서는 anti-double-tap 가드(PR #6 B-1)로 별도 보장됨.

### 3.3 job_filter_test.dart — ✅ sentinel 패턴 검증 정확

리뷰 포인트 3번:
- `copyWith(locationCode: null)` → null로 클리어
- `copyWith()` → 기존 값 보존
두 케이스 모두 명시적으로 검증되어 sentinel 동작이 회귀 테스트로 보호됨. ✅

### 3.4 physical_badge_test.dart — ⚠️ Minor

리뷰 포인트 4번 ("const 생성자 호출이 번거롭지 않은지"):
- 4개 강도 라벨 테스트가 각각 ~25줄짜리 `const JobModel(...)` 필드 전체를 반복 — 약 100줄이 boilerplate.
- 단순 라벨 분기 검증이므로 헬퍼 1개로 90% 줄일 수 있음. (Minor / Nit)

**제안 (선택)**: `JobModel _jobWithIntensity(String intensity)` 헬퍼를 테스트 파일 상단에 두고 4개 라벨 테스트를 1줄짜리로 축약. JSON 파싱 테스트(3개)는 의도적으로 Map을 노출해야 하므로 그대로 둠.

이 항목은 **Minor**이며 머지 차단 요인 아님.

### 3.5 Android 수정 — ✅ 최소 변경

- `MainActivity.kt`: `FlutterActivity` 상속 5줄. 표준 템플릿. ✅
- `INTERNET` 권한: Firebase 통신을 위해 release 빌드 필수. 다른 신규 권한 없음 — 최소 권한 원칙 준수. ✅
- `google-services.json` SHA-1 갱신은 코드 리뷰 범위 외(빌드 환경 설정).

이 변경들은 spec_10과 직접 관련은 없지만 "데모 시나리오"(§4) 통과를 위한 사실상 전제 조건이므로 함께 다루는 것이 합리적.

---

## 4. 보안/안정성 점검

- `currentUser!.uid` non-null bang은 인증 가드 이후 진입 가정에 의존. 기존 동작 유지(변경 없음). 별도 이슈 아님.
- 외부 입력(자기소개) 길이/sanitize는 UI 레이어 책임으로 spec_06/08에서 다룸. 본 PR 범위 외.
- 누출 가능 비밀(`google-services.json` 내 API 키)은 Firebase 공식 권장에 따라 클라이언트 키로 분류 — 보안 등급에 영향 없음.

---

## 5. 최종 판정

| 항목 | 결과 |
|---|---|
| Spec 충족 | ✅ |
| 0-warning | ✅ (요청 doc 보고) |
| 테스트 신뢰도 | ✅ |
| 보안 | ✅ |
| Blocker | 0 |
| Major | 0 |
| Minor | 1 (physical_badge_test boilerplate) |

**Verdict: ✅ APPROVE**

Minor 1건은 후속 정리 시 처리해도 무방. spec_10 DoD 충족으로 `docs/PROGRESS.md`의 `🔄 Review Pending → ✅ Completed` 전환 권고.

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
