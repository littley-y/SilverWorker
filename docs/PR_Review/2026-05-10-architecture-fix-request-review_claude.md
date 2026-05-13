---
title: Architecture Fix Review Request — Plan 자체에 대한 Claude 사전 리뷰
date: 2026-05-10
reviewer: Claude (Opus 4.7)
target: docs/PR_Review/2026-05-10-architecture-fix-review-request.md
basis: 요청 doc + 현재 master(ea29f52) 코드
verdict: ⚠️ CHANGES REQUESTED — 9개 항목 중 7개 채택 / 1개 수정 / 1개 거부 / 추가 4개
---

## 0. 요약

**구현 시작 전에 plan 자체를 검토**합니다. 헤파이스토스 검수의 9개 항목 중:

| 평가 | 개수 | 항목 |
|---|---|---|
| ✅ 채택 (그대로 진행) | 5 | P0-2, P0-3, P0-4, P1-5, P1-6 |
| ⚠️ 수정 후 채택 | 2 | P0-1, P1-9 |
| ❌ 거부 (안티패턴) | 1 | P0-1 중 Provider try-catch |
| 🔄 우선순위 강등 | 1 | P1-7 (선택) |
| ⚠️ 위험 — 별도 PR 분리 권장 | 1 | P1-8 |
| ➕ 추가 권장 | 4 | A~D 아래 |

전반적으로 방향성은 맞지만 **P0-1과 P1-8은 over-engineering 위험**이 있고, 일부 핵심 누락이 있습니다.

---

## 1. 항목별 평가

### P0-1: Repository try-catch + 예외 변환 — ⚠️ 절반만 채택

**찬성 부분**:
- `auth_repository.dart`에서 `FirebaseAuthException`을 도메인 예외(`InvalidPhoneException`, `InvalidCodeException`, `SessionExpiredException` 등)로 매핑 — ✅ 좋음. 현재는 `auth_provider.dart:140`의 `_mapAuthError`가 String만 반환 → 타입 정보 손실. 매핑 위치를 repo 경계로 옮기면 UI는 `on InvalidCodeException`으로 정확히 분기 가능.
- `application_repository.dart`의 `_auth.currentUser!` force-unwrap → `NotAuthenticatedException` 변환 — ✅ 필수.

**거부 부분**:
- ❌ **`job_provider.dart`, `application_provider.dart`에 try-catch 추가** — Riverpod의 `FutureProvider`는 thrown exception을 자동으로 `AsyncValue.error`로 wrap합니다. Provider 내부에 try-catch를 추가하면:
  - `AsyncValue.error`로 가지 않고 정상 데이터(예: 빈 list)를 반환하게 되어 UI의 `error` 분기가 영영 안 탐
  - `appLogger.e`만 부르고 rethrow하면 try-catch가 무용지물
  → **이 행은 삭제**. 로깅이 필요하면 `ProviderObserver`로 중앙 집중.

- ⚠️ **모든 Repository 메서드를 try-catch로 감싸지 말 것**. 의미 있는 변환만 하고, 변환할 게 없으면 그냥 throw 시키세요. `try { ... } on Exception catch (e) { appLogger.e(...); rethrow; }` 패턴은 안티 — `ProviderObserver` 한 곳에서 일괄 로깅하는 게 표준.

**수정안**:
```
P0-1 (수정):
- auth_repository: FirebaseAuthException → 도메인 예외 매핑 (현 _mapAuthError 로직 이전)
- application_repository: currentUser! → NotAuthenticatedException
- job_repository: 변환할 도메인 예외가 없으므로 try-catch 불필요. 그대로 둠.
- providers: try-catch 추가 금지. 로깅은 ProviderObserver로.
```

---

### P0-2: ErrorRetryView 통합 — ✅ 채택

이미 `c41be00`에서 `lib/widgets/error_retry_view.dart` 생성됨 (`51 LOC`). 다만 **현재 0개 화면이 사용 중** — 5개 화면에 실제 import + 교체가 이번 PR의 핵심.

**주의**:
- `application_list_screen.dart`의 현 에러 UI는 텍스트만 — 재시도 버튼 추가는 UX 개선이지만, 재시도 시 `ref.invalidate(myApplicationsProvider(user.uid))` 호출이 정확히 들어가는지 확인.
- `main_shell.dart`의 에러는 `userProfileProvider` 대상, `my_page_screen.dart`의 에러도 `userProfileProvider` 대상 — `ErrorRetryView` API가 retry 콜백을 받게 설계되어 있는지 확인 필요.

---

### P0-3: 디자인 토큰 위반 교체 — ✅ 채택 (보강 필요)

`AppColors.border` / `AppColors.hintText`는 이미 `app_colors.dart:29-32`에 정의되어 있음 — replacement 가능.

**현재 위반 카운트** (직접 grep 결과):
- `lib/`에 `Colors.grey.shade300` **5건**, `Colors.grey.shade400` **5건** (요청 doc의 6/4와 약간 차이, 실측 우선)
- 모두 `profile_register_screen.dart`(8건)와 `otp_input_screen.dart`(1건)에 집중

**누락**:
- ⚠️ `Colors.grey.shade300` **1건이 `otp_input_screen.dart:294`** `disabledBackgroundColor`에도 있음 — 요청 doc에 빠져 있음. `AppColors.disabled` 사용.
- ⚠️ `profile_register_screen.dart:348`의 `disabledBackgroundColor: Colors.grey.shade300`도 마찬가지 — `AppColors.disabled`로.

**TextStyle 직접 생성**:
- 실측 결과: `filter_bar.dart:150` 1건, `job_card.dart:48 / :150` 2건. (`application_result_screen.dart`, `job_detail_screen.dart`도 필요시 grep로 재확인)
- `AppTextStyles.button`/`bodyBold`/`caption`을 `.copyWith(color: ..., fontSize: ...)` 패턴으로 교체.

---

### P0-4: MainShell dead code Guard 1 제거 — ✅ 채택 (단, 절차 주의)

`main_shell.dart:42-50`의 `user == null` 가드 — router redirect와 중복인 건 맞음.

**주의**:
- 라우터 redirect는 `_AuthRefresh` 스트림 이벤트 후 비동기 발화. 짧은 윈도우에서 MainShell이 user==null로 빌드될 수 있음. 가드를 완전히 제거하기보다 **redirect 호출은 빼고 로딩 fallback만 남기는** 게 안전:
  ```dart
  if (user == null) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
  ```
- M-1 수정으로 `authStateProvider` watch로 바꾸면 `AsyncValue.loading` 상태가 자연스럽게 처리되어 이 가드 자체가 불필요해짐. **P0-4와 M-1을 같이 묶어서** 처리하면 깔끔.

---

### P1-5: profile_register_screen.dart 분해 (373줄) — ✅ 채택

위젯 추출 4개(`_NameField`, `_AddressSelector`, `_CareerField`, `_SubmitButton`) 합당.

**추가 권장**:
- `_isFormValid`/`_onStart` 등 비즈니스 로직은 화면이 들고 있되, **위젯 추출 후 콜백으로 연결**하는 패턴 유지.
- 추출 후 `flutter test`에 위젯 단위 테스트 1~2개 추가 권장 (현재 profile_register 테스트 없음).

### P1-6: otp_input_screen.dart 분해 (320줄) — ✅ 채택 (테스트 필수)

**리스크**: OTP 입력의 6칸 키보드 처리(자동 이동/백스페이스/붙여넣기/auto-fill)는 회귀 위험이 가장 높음. 분해 자체는 옳지만:

- ⚠️ **`_OtpPinBox` 위젯 단위 테스트를 동일 PR에 포함**해야 함. 요청 doc의 "리뷰 포인트"에 기재만 되어 있고 작업 항목엔 없음.
- 최소 테스트 케이스: `(1) 숫자 1개 입력 시 다음 박스로 포커스`, `(2) 백스페이스로 이전 박스 포커스`, `(3) 6자리 붙여넣기`, `(4) onCompleted 콜백 발화`.

---

### P1-7: JobModel UI getter extension 추출 — 🔄 우선순위 강등 (선택)

**반대 근거**:
- `employmentTypeLabel` / `physicalIntensityLabel` / `formattedSalary`는 모델 자체 데이터에 1:1 매핑되는 표시명. 모델 안에 두는 게 발견성/응집도 면에서 자연스러움.
- Extension으로 빼면:
  - `JobModel`만 import하던 곳에서 extension 파일도 import 해야 함 (call site 수정량 ↑)
  - `physical_badge_test.dart` 등 기존 테스트가 import 추가 필요 → 회귀 위험
  - "모델은 데이터만"이라는 신념이 강하다면 의미 있지만, MVP에선 yagni
- spec_10이 갓 안정화된 직후 — 이 정도 stylistic refactor는 **다음 사이클로 미루기** 권장.

**판단**: 다른 8개 P0/P1과 같은 PR에 묶지 말 것. 별도 PR로 추후.

---

### P1-8: auth_provider Notifier 정리 — ⚠️ 별도 PR 분리

**찬성**:
- `WidgetRef`를 일반 함수 매개변수로 받는 건 명백한 안티패턴 ✅
- 4개 `StateProvider`(loading/verificationId/resendToken/phoneNumber) → 1개 불변 state로 통합 ✅

**리스크**:
- `phone_input_screen` / `otp_input_screen`이 모두 영향. P1-6(otp 분해)와 P1-8을 한 PR에 묶으면 OTP 화면이 **분해 + provider migration 동시**에 변경 → 회귀 추적 곤란.
- `verifyPhoneNumber` callback 6개를 Notifier 내부에서 처리해야 함 — 콜백 경계가 복잡(verificationCompleted/Failed/codeSent/codeAutoRetrievalTimeout). 한 번에 옮기다 race condition 들어가기 쉬움.

**권장 순서**:
1. 이 PR(architecture-fix): P0-1~P0-4, P1-5, P1-6, P1-9, ErrorRetryView 통합
2. 다음 PR: P1-8 (auth Notifier) 단독 — phone/otp 화면 양쪽 동시 검증 + 통합 테스트

---

### P1-9: JobRepository Clock 주입 — ⚠️ 채택 (범위 확장)

`Timestamp.now()` (`job_repository.dart:31`) 외에 **`application_repository.dart:70`의 `DateTime.now()`도 동일 문제**. 요청 doc은 JobRepo만 언급.

**수정안**:
```dart
// lib/utils/clock.dart
abstract class Clock {
  DateTime now();
  Timestamp nowTimestamp();
}
class SystemClock implements Clock { ... }
```
- `JobRepository`, `ApplicationRepository` 양쪽 생성자에 `Clock? clock` 추가 (default `SystemClock()`).
- 기존 deadline 만료 테스트(`application_repository_test.dart`의 "throws JobClosedException when deadline has passed")가 `SystemClock`에 의존 — 주입 후 fake clock 기반으로 결정론적 테스트로 강화.

---

## 2. 누락된 추가 권장 항목

### A. ➕ `physicalBadges` 진짜 단일화 (M-2 후속)

`c41be00`에서 "테스트 값을 UI에 맞춰 정렬"한 것은 **workaround**입니다. 근본 해결:

```dart
// lib/models/physical_badge.dart
abstract final class PhysicalBadge {
  static const standing = 'standing';
  static const sitting = 'sitting';
  static const heavyLifting = 'heavy_lifting';
  static const outdoor = 'outdoor';
  static const repetitive = 'repetitive';
  static const stairs = 'stairs';

  static const values = <String>[standing, sitting, heavyLifting, outdoor, repetitive, stairs];
  static String label(String code) => switch (code) { ... };
  static IconData icon(String code) => switch (code) { ... };
}
```

이걸 `safety_curation_section.dart` / 시드 데이터 / 테스트가 모두 참조하도록. 그래야 "다음번에 또 드리프트"가 안 생김.

### B. ➕ `JobRepository.fetchJobs` deadline null 처리 — 잠재 기능 버그

`fetchJobs`(`job_repository.dart:31`)는 `where('deadline', isGreaterThan: Timestamp.now())`. Firestore의 inequality 쿼리는 **해당 필드가 누락된 문서를 제외**합니다. 따라서:

- `deadline: null`인 "상시 모집" 공고는 **목록에 절대 안 뜸**.
- spec_04가 "상시" 케이스를 허용하는지 확인 필요. 스키마(`overview/04_db_schema.md`)에서 deadline이 required면 OK. nullable이면 두 쿼리 union 필요.

이 항목은 P0-1/P0-2와 무관한 **별도 기능 검증** — 요청 doc에 없으나 데모에 영향.

### C. ➕ `ApplicationModel.applicationId` 미설정 (m-5 미반영)

`submitApplication`이 `applicationId` 필드를 set하지 않아 `fetchApplications` 결과에 `applicationId: ''`로 들어감. Firestore doc id를 fromJson에서 주입하거나 toJson 시점에 set. 요청 doc에 빠짐.

### D. ➕ `userProfileProvider` family 캐시 무효화

`auth_provider.dart:26-29`의 `userProfileProvider`는 `family<UserModel?, String>`로 uid별 캐시. 로그아웃 후 다른 uid로 재로그인 시 이전 uid의 캐시는 남음. P1-8 작업 시 `ref.listen(authStateProvider, (prev, next) { if (prev?.value?.uid != next.value?.uid) ref.invalidate(userProfileProvider); })` 한 줄 추가 권장.

---

## 3. PR 분할 제안

요청 doc은 9개를 한 PR로 묶으려 하지만 **scope가 너무 큼**. 권장 분할:

| PR | 항목 | 이유 |
|---|---|---|
| **PR-A (architecture-fix-1)** | P0-1(수정안), P0-2, P0-3, P0-4, P1-9, A, B, C | 의존성 적음, 회귀 위험 낮음, 한 번에 가능 |
| **PR-B (screen-decomposition)** | P1-5, P1-6 + OTP 위젯 테스트 | 화면 분해 단독, 시각 회귀 검증 분리 |
| **PR-C (auth-notifier)** | P1-8 + D | 가장 위험. 단독으로 통합 테스트 |
| **(보류)** | P1-7 | 다음 사이클 |

---

## 4. 품질 기대 기준 보강

요청 doc의 6개 기준은 좋으나 추가:

- [ ] `grep -rn "Colors.grey.shade" lib/` → **0건** (요청 doc은 "shade300/400만 0건" 명시 — 다른 shade도 잡아둘 것)
- [ ] `grep -rn "DateTime.now\|Timestamp.now" lib/repositories/` → **0건** (Clock 주입 검증)
- [ ] `grep -rn "WidgetRef" lib/providers/` → **0건** (P1-8 적용 시. 별도 PR이면 보류)
- [ ] `grep -rn "ErrorRetryView" lib/screens/` → **5건 이상** (실제 사용 검증)
- [ ] `_OtpPinBox` 단위 테스트 ≥ 4 케이스
- [ ] `flutter test --coverage` → 신규 코드 90% 이상

---

## 5. 결론

**요청 doc은 방향 정확, 디테일 보강 필요**:
- ❌ Provider try-catch는 빼야 함 (안티패턴)
- ⚠️ P1-7은 yagni — 다음으로
- ⚠️ P1-8은 별도 PR로 분리
- ➕ A(badge enum 근본해결), B(deadline null 쿼리), C(applicationId), D(profile cache invalidation) 추가
- 📦 9개를 3개 PR로 분할 권장

이대로 진행하면 PR 한 개가 ~15개 파일을 동시에 만지게 되어 리뷰/롤백 모두 어려움. 단계적으로 가시면 좋겠습니다.

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
