# Architecture Fix — Implementation Review Request

> Date: 2026-05-10
> Branch: master
> Scope: lib/ 10 files modified, 2 new files, test/ 1 new file
> Basis: Claude/Gemini 사전 리뷰 피드백 + 헤파이스토스 검수 결과

---

## 한눈에 보기

아래 9개 항목에 대한 **실제 구현 결과물**을 리뷰 요청합니다. 사전 리뷰(`2026-05-10-architecture-fix-review-request.md`)에서 승인된 계획대로 구현되었는지 검증해 주세요.

---

## 변경 요약

| # | 항목 | 변경 방식 | 파일 수 |
|---|------|----------|--------|
| P0-1 | AuthException sealed class | `AuthException` 계층 도입, `_requireAuth` getter 추가 | 2 |
| P0-2 | ErrorRetryView 통합 | 5개 화면 인라인 에러 UI → `ErrorRetryView` 교체 | 5 |
| P0-3 | 디자인 토큰 교체 | `Colors.grey` 제거, `AppColors` + `PrimaryButton` 일괄 적용 | 4 |
| P0-4 | MainShell dead code 제거 | Guard 1 redirect 삭제 (라우터에서 처리) | 1 |
| P1-5 | profile_register 분해 | `_NameField`, `_AddressSelector`, `_CareerField` 위젯 추출 | 1 |
| P1-6 | otp_input 분해 + 테스트 | `OtpPinBox` 위젯 추출 + 13개 단위 테스트 | 2 신규 |
| P1-8 | auth_provider Notifier 전환 | `PhoneAuthNotifier` → `authLoadingProvider` 등 4개 제거, cache invalidation 추가 | 3 |
| P1-9 | Clock 주입 | `lib/utils/clock.dart` 신규 → `JobRepository`, `ApplicationRepository` | 3 |
| A~C | PhysicalBadge 통일, ApplicationId fix | enum 단일 소스, deadline 문서화 | 4 |

---

## 세부 변경

### P0-1: AuthException sealed class

**파일**: `lib/repositories/auth_repository.dart` (+5라인)

```dart
sealed class AuthException implements Exception {}
class InvalidPhoneException extends AuthException {}
class InvalidCodeException extends AuthException {}
// ... 6개 구체 예외 + mapFirebaseAuthException() 변환 함수
```

- 사용처: `auth_repository.dart` 내 `signInWithCredential` 호출부에 적용 예정 (P1-8 Notifier에서 통합)
- `application_repository.dart`: `_requireAuth` getter가 `NotAuthenticatedException` throw

### P0-2: ErrorRetryView 통합

**파일**: `job_list_screen.dart`, `job_detail_screen.dart`, `my_page_screen.dart`, `main_shell.dart`, `application_list_screen.dart`

- 모든 화면의 인라인 `Center(Text(에러메시지))` 블록을 `ErrorRetryView(message:, onRetry:)` 로 교체
- `application_list_screen.dart`는 이전에 텍스트만 표시하던 것을 버튼 포함 재시도 UI로 업그레이드

### P0-3: 디자인 토큰 교체

**파일**: `profile_register_screen.dart`, `otp_input_screen.dart`, `phone_input_screen.dart`, `filter_bar.dart`, `job_card.dart`, `application_result_screen.dart`, `job_detail_screen.dart`

| 위반 | 교체 |
|------|------|
| `Colors.grey.shade300` (6건) | → `AppColors.border` |
| `Colors.grey.shade400` (4건) | → `AppColors.hintText` |
| 인라인 `ElevatedButton` (3건) | → `PrimaryButton` 위젯 |
| `TextStyle(...)` 직접 생성 (5건) | → `AppTextStyles` 토큰 |

### P0-4: MainShell dead code 제거

**파일**: `lib/screens/main/main_shell.dart`

- `build()` 내 `user == null → redirect` 가드 삭제 (이미 `app_router.dart` redirect에서 처리)

### P1-5: profile_register_screen 분해

**파일**: `lib/screens/auth/profile_register_screen.dart` (353라인, main build 220라인)

```dart
// 추출된 위젯 (파일 하단에 정의)
_NameField          // 이름 입력 필드
_AddressSelector    // 시/도 + 시/군/구 드롭다운
_CareerField        // 경력 요약 입력 필드
```
→ `_SubmitButton`은 기존에 이미 분리되어 있었음

### P1-6: otp_input_screen 분해 + 테스트

**신규 파일**:
- `lib/widgets/otp_pin_box.dart` (81라인, `StatefulWidget`)
- `test/widgets/otp_pin_box_test.dart` (13개 테스트)

**변경 파일**: `lib/screens/auth/otp_input_screen.dart` (320→260라인)

```
OtpPinBox API:
  controller    // TextEditingController
  focusNode     // FocusNode (TextField용)
  onChanged     // ValueChanged<String>
  onKeyEvent    // ValueChanged<KeyEvent>
  autofocus     // bool (기본 false)
```

- 내부적으로 `FocusNode(skipTraversal: true)` 생성 및 dispose
- `KeyboardListener` + `TextField` 캡슐화
- `ElevatedButton` → `PrimaryButton` 교체

### P1-8: auth_provider Notifier 전환

**파일**: `lib/providers/auth_provider.dart` (155→223라인, 완전 재작성)

```
PhoneAuthState     // 불변 상태 클래스 (isLoading, verificationId, resendToken, phoneNumber, errorMessage)
PhoneAuthNotifier  // StateNotifier<PhoneAuthState>
  .startVerification(phoneNumber, {forceResendingToken})
  .verifyOtp(smsCode) → User?
  .clearError()
```

- 제거된 Provider: `authLoadingProvider`, `verificationIdProvider`, `resendTokenProvider`
- 유지된 Provider: `phoneNumberProvider` (단순 computed: `phoneAuthProvider.select((s) => s.phoneNumber)`)
- **Cache invalidation**: `userProfileProvider`가 `authStateProvider`를 watch → auth 상태 변경 시 자동 재조회

| 화면 | 변경 |
|------|------|
| `phone_input_screen.dart` | `authLoadingProvider` → `phoneAuthProvider.isLoading`, `startPhoneVerification()` → `notifier.startVerification()` |
| `otp_input_screen.dart` | `verifyOtp()` → `notifier.verifyOtp()`, `resendTokenProvider` → `phoneAuthProvider.resendToken` |

### P1-9: Clock 주입

**신규 파일**: `lib/utils/clock.dart`

```dart
abstract class Clock {
  DateTime now();
  Timestamp nowTimestamp();
}
class SystemClock implements Clock { ... }
```

- `JobRepository`: `Timestamp.now()` → `_clock.nowTimestamp()`
- `ApplicationRepository`: `DateTime.now()` → `_clock.now()`

### A~C: 기타

- **A**: `lib/models/physical_badge.dart` 신규 → `PhysicalBadge` enum 단일 소스
- **B**: `job_repository.dart` `fetchJobs` deadline null 문서화 (Firestore inequality 한계)
- **C**: `ApplicationModel.applicationId` submit 시 설정 + `fetchApplications`에 `doc.id` 주입

---

## 리뷰 포인트

### Claude
- [ ] `PhoneAuthNotifier`가 `verificationCompleted`(auto-verification) 콜백을 안전하게 처리하는지
- [ ] `_OtpPinBox` 내부 `FocusNode(skipTraversal: true)`가 dispose 시 누수 없는지
- [ ] `userProfileProvider`가 `authStateProvider`를 watch하여 cache invalidation이 정상 동작하는지
- [ ] `ErrorRetryView` 통합 후 각 화면의 에러 상태 UI가 일관된지
- [ ] `AuthException` 계층이 `auth_repository.dart`에 정의된 것 vs `auth_provider.dart`에서 사용, 분리 문제는 없는지

### Gemini
- [ ] `Colors.grey.shade300/400`이 `lib/`에서 완전히 제거되었는지 (`grep -r "grey.shade" lib/`)
- [ ] `PrimaryButton`이 phone_input / otp_input / profile_register에 일관 적용되었는지
- [ ] `Clock` 주입으로 인해 테스트 용이성이 실제로 향상되었는지 (SystemClock 기본값)
- [ ] `profile_register_screen.dart` main build()가 충분히 간결해졌는지
- [ ] `phoneNumberProvider`를 computed Provider로 유지한 방식이 깔끔한지 (직접 `phoneAuthProvider.select` 대비)

---

## 검증 결과

```
flutter analyze   → No issues found! (0 errors, 0 warnings)
flutter test      → 97/97 passed (기존 84 + 신규 OtpPinBox 13)
verify_local.sh   → 6/6 passed (format, analyze, test, pages, graphify)
```

변경된 파일 목록 (커밋 전 working tree):

```
lib/widgets/otp_pin_box.dart             [신규]
test/widgets/otp_pin_box_test.dart       [신규]
lib/providers/auth_provider.dart         [재작성]
lib/screens/auth/otp_input_screen.dart   [수정]
lib/screens/auth/phone_input_screen.dart [수정]
lib/screens/auth/profile_register_screen.dart [수정]
lib/screens/main/main_shell.dart         [수정]
lib/repositories/auth_repository.dart    [수정]
lib/screens/application/application_result_screen.dart [수정]
```
