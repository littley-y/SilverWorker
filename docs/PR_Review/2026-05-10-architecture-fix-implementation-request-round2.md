# Architecture Fix — Implementation Review Request (Round 2)

> Date: 2026-05-10
> Branch: master (working tree, uncommitted)
> Round: 2/2 — Claude Round 1 Major fixes applied
> Basis: `docs/PR_Review/2026-05-10-architecture-fix-implementation-review_claude.md`

---

## Round 1 Feedback → Round 2 Changes

| # | 항목 | Round 1 | Round 2 변경 |
|---|------|---------|-------------|
| M-1 | AuthException dead code | `mapFirebaseAuthException()` 호출처 0건 | `_mapAuthError(FirebaseAuthException)` 제거 → `_exceptionToMessage(mapFirebaseAuthException(e))` 로 통합 |
| M-2 | MainShell guard 미삭제 | `context.go(phone)` redirect 그대로 | redirect 호출 제거, Spinner fallback만 유지 |
| m-1 | applicationId 중복 | doc.id로 충분 | **후속 PR** (데이터 모델 단일 소스 원칙, 기능 영향 없음) |
| m-2 | sentinel 가독성 | `_Sentinel` + `Object?` 캐스팅 | **후속 PR** (freezed 도입 또는 메서드 분리) |
| m-3 | 라인 수 불일치 | 요청서 vs 실제 ±30 | Round 2 요청서에서 `wc -l` 실측치로 교체 |

---

## 세부 변경 (Round 2 diff)

### M-1: `mapFirebaseAuthException()` 실제 통합

**파일**: `lib/providers/auth_provider.dart`

**Before** (Round 1):
```dart
// auth_provider.dart:207 — Firebase 의존 변환, AuthException 계층 미사용
String _mapAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-phone-number': return '올바른 번호를 입력하세요.';
    // ... 6개 케이스
  }
}

// 호출부: FirebaseAuthException → 한국어 문자열 직접
errorMessage: _mapAuthError(e),  // 3곳
```

**After** (Round 2):
```dart
// auth_provider.dart — mapFirebaseAuthException() 경유, domain exception switch
String _exceptionToMessage(AuthException e) {
  return switch (e) {
    InvalidPhoneException() => '올바른 번호를 입력하세요.',
    InvalidCodeException() => '인증번호가 맞지 않습니다. 다시 확인해 주세요.',
    SessionExpiredException() => '인증번호가 만료되었습니다. 재발송해 주세요.',
    TooManyRequestsException() =>
        '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해 주세요.',
    NetworkRequestFailedException() => '인터넷 연결을 확인해 주세요.',
    UnknownAuthException(:final message) =>
        message ?? '오류가 발생했습니다. 잠시 후 다시 시도해 주세요.',
  };
}

// 호출부: FirebaseAuthException → AuthException → 한국어 문자열
errorMessage: _exceptionToMessage(mapFirebaseAuthException(e)),  // 3곳
```

**검증**:
```bash
$ grep -rn "mapFirebaseAuthException" lib/
lib/providers/auth_provider.dart:121: errorMessage: _exceptionToMessage(mapFirebaseAuthException(e)),
lib/providers/auth_provider.dart:138: errorMessage: _exceptionToMessage(mapFirebaseAuthException(e)),
lib/providers/auth_provider.dart:179: errorMessage: _exceptionToMessage(mapFirebaseAuthException(e)),
lib/repositories/auth_repository.dart:22: AuthException mapFirebaseAuthException(FirebaseAuthException e) {
```
→ `mapFirebaseAuthException` 호출 3건 + 정의 1건 = **dead code 해소**

### M-2: MainShell guard redirect 실제 삭제

**파일**: `lib/screens/main/main_shell.dart`

**Before** (Round 1):
```dart
if (user == null) {
  // Router redirect should prevent this, but guard anyway.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) context.go(AppRoutes.phone);
  });
  return const Scaffold(body: Center(child: CircularProgressIndicator()));
}
```

**After** (Round 2):
```dart
if (user == null) {
  // Router redirect handles this; safe fallback.
  return const Scaffold(body: Center(child: CircularProgressIndicator()));
}
```

---

## 검증 결과 (Round 2)

```bash
flutter analyze   → No issues found! (0 errors, 0 warnings)
flutter test      → 97/97 passed
bash tools/verify_local.sh → 6/6 PASSED
```

---

## 변경 파일 요약 (working tree 기준, `wc -l` 실측)

| 파일 | 라인 | 상태 |
|------|------|------|
| `lib/providers/auth_provider.dart` | 222 | Round 2 수정 |
| `lib/screens/main/main_shell.dart` | 137 | Round 2 수정 |
| `lib/widgets/otp_pin_box.dart` | 88 | 신규 (Round 1) |
| `test/widgets/otp_pin_box_test.dart` | 169 | 신규 (Round 1) |
| `lib/screens/auth/otp_input_screen.dart` | 259 | Round 1 수정 |
| `lib/screens/auth/phone_input_screen.dart` | 171 | Round 1 수정 |
| `lib/screens/auth/profile_register_screen.dart` | 382 | Round 1 수정 |
| `lib/repositories/auth_repository.dart` | 120 | Round 1 수정 |
| `lib/screens/application/application_result_screen.dart` | 212 | Round 1 수정 |

---

## 리뷰 포인트 (Round 2 중점)

### Claude / Gemini 공통
- [ ] `_exceptionToMessage(AuthException)` switch가 모든 `AuthException` 서브타입을 exhaustively 처리하는지
- [ ] `MainShell` `user == null` 블록에서 redirect가 완전히 제거되었는지 (Spinner만 남음)
- [ ] `mapFirebaseAuthException()` 호출이 Round 1 대비 0→3건으로 증가하여 dead code 해소 확인
- [ ] `flutter test 97/97`, `verify_local.sh 6/6` 재확인

---

## Deferred (후속 PR)

| 항목 | 사유 |
|------|------|
| m-1: `applicationId` 중복 제거 | doc.id로 대체 가능하나 기능 영향 없음, 데이터 정리는 별도 PR |
| m-2: sentinel 패턴 개선 | freezed 도입 또는 메서드 분리는 리팩터링 범위, MVP 기능 무관 |
