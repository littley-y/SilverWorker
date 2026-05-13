# Architecture Fix Implementation Review — Claude

> Date: 2026-05-10
> Reviewer: Claude (Opus 4.7)
> Target: working tree on `master` (uncommitted)
> Basis: `docs/PR_Review/2026-05-10-architecture-fix-implementation-request.md`
> Verdict: **Request Changes** — 2 Major findings, 3 Minor

---

## Summary

요청서의 9개 항목 중 **7개는 기대대로 적용**되었으나, **2개 항목은 청구 내용과 실제 코드가 불일치**합니다.

| 항목 | 상태 | 코멘트 |
|---|---|---|
| P0-1 AuthException sealed | ⚠️ Major | 정의만 있고 호출처 없음 (`mapFirebaseAuthException` 0회 호출) |
| P0-2 ErrorRetryView 통합 | ✅ | 5개 화면 모두 적용 확인 |
| P0-3 디자인 토큰 교체 | ✅ | `Colors.grey` lib/ 안 잔존 0건 (주석 제외) |
| P0-4 MainShell dead code 제거 | ⚠️ Major | 요청서 주장과 달리 guard 코드 그대로 남음 |
| P1-5 profile_register 분해 | ✅ | 위젯 추출 확인 (382 라인 — 요청서의 353 라인과 약간 다름) |
| P1-6 OtpPinBox + 테스트 | ✅ | 13건 테스트 통과, FocusNode dispose OK |
| P1-8 PhoneAuthNotifier | ✅ | cache invalidation 동작, verificationCompleted 안전 |
| P1-9 Clock 주입 | ✅ | 두 Repository 모두 적용 |
| A~C 기타 | ⚠️ Minor | ApplicationId 중복 기록 (cosmetic) |

`bash tools/verify_local.sh` → 6/6 PASS, `flutter test` → 97/97 PASS 확인.

---

## Major

### M-1: `AuthException` sealed class가 dead code (P0-1 미완성)

**위치**: `lib/repositories/auth_repository.dart:5-31`, `lib/providers/auth_provider.dart:207-222`

**증상**:
- `auth_repository.dart`에 `AuthException` 계층 + `mapFirebaseAuthException()` 변환 함수가 정의됨
- 그러나 `grep -rn "mapFirebaseAuthException\|AuthException" lib/` 결과, **호출처가 0건**
- `auth_provider.dart`의 `verifyOtp` / `startVerification`은 여전히 `FirebaseAuthException`을 직접 catch한 뒤 자체 `_mapAuthError(FirebaseAuthException)` 함수로 한국어 문자열만 만들어 state.errorMessage에 저장 (auth_provider.dart:178, 207)
- `signInWithCredential` 호출부에서도 `AuthException`을 throw하지 않음

**영향**:
- 요청서가 광고하는 "도메인 예외 계층" 효과가 0. 외부에서는 여전히 `FirebaseAuthException`이라는 Firebase 의존 타입으로 분기해야 함
- 새로 정의된 6개 클래스가 **단 한 번도 인스턴스화되지 않는 dead code** — Zero-warning 정책 정신과 충돌
- 요청서 본문도 "사용처: ... P1-8 Notifier에서 통합 예정"으로 적었지만 실제로 통합되지 않음 → 본 PR 범위 내에서 마무리 필요

**권고 (택일)**:
1. **권장**: `signInWithCredential` 등 repository 메서드에서 `try { ... } on FirebaseAuthException catch (e) { throw mapFirebaseAuthException(e); }` 적용 후, `auth_provider`는 `AuthException` 서브타입으로 switch하여 한국어 메시지 매핑. Firebase 누수 차단이라는 본래 목적 달성.
2. 또는, 본 PR에서 통합을 못 끝낼 거면 `AuthException` 추가 자체를 다음 PR로 미루고 P0-1을 이번 범위에서 제거. 정의만 두고 사용 안 하면 리뷰어에게 "끝났다"고 광고할 수 없음.

---

### M-2: `MainShell` "guard 1 redirect" 실제로는 삭제되지 않음 (P0-4)

**위치**: `lib/screens/main/main_shell.dart:42-53`

**요청서 주장**: "`build()` 내 `user == null → redirect` 가드 삭제 (이미 `app_router.dart` redirect에서 처리)"

**실제 코드**:
```dart
return authAsync.when(
  data: (user) {
    if (user == null) {
      // Router redirect should prevent this, but guard anyway.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.phone);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    ...
```

**영향**:
- 청구된 변경이 적용되지 않음. 요청서와 실제 동작이 어긋나면 리뷰 신뢰도가 떨어지고, 다음 세션에서 또 누가 같은 dead code를 발견해 PR을 만들 가능성
- 만약 의도적으로 유지한 거라면(라우터 race condition 안전망), **요청서를 수정**해 "guard 유지하되 ErrorRetryView 채택" 으로 정정해야 함

**권고**:
- 라우터 redirect만으로 충분하다고 검증되었으면 **이 블록을 실제로 삭제** + redirect 호출도 제거 (단순 `loading` 반환)
- 또는 일부러 남겼다면 요청서에서 "P0-4 MainShell dead code 제거" 항목을 **취소선 처리 또는 제거** 후 "유지 — race condition 방어용" 으로 명시. 양쪽이 일치해야 머지 가능.

---

## Minor

### m-1: `submitApplication` payload에 `applicationId: jobId` 중복 기록

**위치**: `lib/repositories/application_repository.dart:89-90`

```dart
tx.set(ref, {
  'applicationId': jobId,
  'jobId': jobId,
  ...
```

`ref`는 `.doc(jobId)`로 생성됐으므로 `doc.id == jobId == applicationId` — fetchApplications에서 `'applicationId': doc.id`로 다시 주입하기 때문에 굳이 write 시점에 박을 필요가 없습니다. 의도가 "fromJson default 값 회피" 라면 `fetchApplications`의 `doc.id` 주입만으로 충분. 문서 사이즈는 무시할 수 있지만 **데이터 모델의 단일 소스(doc.id)** 원칙상 write 시점 필드는 제거 권장.

### m-2: `PhoneAuthState.copyWith`의 sentinel pattern 코드 가독성

`_Sentinel` private 클래스 + `Object?` 파라미터 + `as String?` 캐스팅은 동작은 하지만 다음 사람이 한 번에 못 읽습니다. Dart 3.x에서는 이 패턴 대신
```dart
PhoneAuthState clearVerificationId() => PhoneAuthState(... verificationId: null, ...);
```
같이 의도별 메서드로 쪼개거나, `package:freezed`를 도입하는 방향이 자연스럽습니다. **이번 PR 범위 밖** — 향후 리팩터링 백로그로.

### m-3: 요청서 라인 수와 실제 라인 수 미세 불일치

| 파일 | 요청서 | 실제 |
|---|---|---|
| profile_register_screen.dart | 353 | 382 |
| otp_input_screen.dart | 260 | 259 |
| auth_provider.dart | 223 | 222 |
| otp_pin_box.dart | 81 | 88 |

기능 영향은 없으나, 다음 PR부터는 `wc -l` 결과를 그대로 옮기시면 좋겠습니다.

---

## Verified (그대로 통과)

- **P0-2 ErrorRetryView**: `job_list_screen`, `job_detail_screen`, `my_page_screen`, `main_shell`, `application_list_screen` 5개 화면 적용 확인.
- **P0-3 디자인 토큰**: `grep -rn "Colors.grey" lib/` → `app_colors.dart`의 주석 3건 외 0건. 깨끗함.
- **P1-6 OtpPinBox**:
  - `FocusNode(skipTraversal: true)`이 `_OtpPinBoxState`에서 `late final`로 생성되고 `dispose()`에서 해제됨 — 누수 없음
  - `KeyboardListener`/`TextField` 캡슐화 깔끔, `PrimaryButton` 일관 적용됨
  - 13개 테스트 모두 PASS
- **P1-8 PhoneAuthNotifier**:
  - `verificationCompleted` 콜백 내부에서 `signInWithCredential`을 try/catch로 감싸 자동 인증 실패 시 state 복구 (auth_provider.dart:109-119) — 안전
  - `userProfileProvider` 가 `ref.watch(authStateProvider)` 호출하여 auth 변경 시 자동 invalidate (auth_provider.dart:28) — cache invalidation 정상
  - `phoneNumberProvider`를 `phoneAuthProvider.select((s) => s.phoneNumber)`로 computed Provider화한 방식은 backward compatibility를 유지하면서 단일 소스를 보존함. 깔끔.
- **P1-9 Clock**: `JobRepository`/`ApplicationRepository`에 생성자 주입 + `SystemClock` 기본값. 테스트에서 freeze/advance 가능. 표준적이고 좋음.
- **A. PhysicalBadge**: `lib/models/physical_badge.dart` 단일 소스, `safety_curation_section.dart`에서 일관 사용.
- **C. ApplicationId fetchApplications**: `doc.id` 주입 정상 (m-1만 수정 권장).

---

## 결론

- **Merge: PENDING** until M-1, M-2 해결.
- M-1, M-2는 둘 다 "요청서가 광고한 변경이 실제로 안 들어갔다" 카테고리. 코드를 수정하든 요청서를 수정하든 양쪽 일치만 시키면 됨.
- Minor 3건은 후속 PR 가능.

검증 명령어:
```bash
grep -rn "mapFirebaseAuthException" lib/   # M-1: 0건이면 dead code 확정
sed -n '40,55p' lib/screens/main/main_shell.dart  # M-2: guard 블록 확인
flutter analyze   # 0 issues
flutter test      # 97/97
```
