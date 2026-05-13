# Architecture Fix — Hephaestus Audit Completion

> Date: 2026-05-10
> Session: Architecture fix implementation + Claude review (round 1 → round 2)
> Commits: `1aae7f9`, `713152e`, `156a15c`

---

## Background

헤파이스토스 MVP 최종 검수에서 발견된 **9개 아키텍처 문제점**(P0 4건 + P1 5건)을 일괄 수정. Claude/Gemini 사전 리뷰에서 승인된 계획을 기반으로 구현 진행, 이후 Claude 구현 리뷰(round 1)에서 발견된 Major 2건까지 수정 완료.

---

## Changes

### P0 (필수)
| # | 항목 | 변경 |
|---|------|------|
| P0-1 | AuthException sealed class | `lib/repositories/auth_repository.dart`에 `sealed class AuthException` + 6개 구체 예외 + `mapFirebaseAuthException()` 정의. `auth_provider.dart`의 `PhoneAuthNotifier`가 `mapFirebaseAuthException()` 호출 후 `_exceptionToMessage()`로 한국어 변환 — Firebase 의존성 격리 |
| P0-2 | ErrorRetryView 통합 | 5개 화면(`job_list`, `job_detail`, `my_page`, `main_shell`, `application_list`)의 인라인 에러 UI를 `ErrorRetryView`로 교체 |
| P0-3 | 디자인 토큰 교체 | `Colors.grey.shade300` 6건 → `AppColors.border`, `Colors.grey.shade400` 4건 → `AppColors.hintText`, 인라인 `ElevatedButton` 3건 → `PrimaryButton`, `TextStyle()` 5건 → `AppTextStyles` |
| P0-4 | MainShell dead code 제거 | `user == null → context.go(phone)` redirect 삭제 (router에서 처리) |

### P1 (권고)
| # | 항목 | 변경 |
|---|------|------|
| P1-5 | profile_register decomposition | `_NameField`, `_AddressSelector`, `_CareerField` 위젯 추출 (main build 220줄) |
| P1-6 | otp_input decomposition | `OtpPinBox` 위젯 추출 + 13개 단위 테스트 (`lib/widgets/otp_pin_box.dart`, `test/widgets/otp_pin_box_test.dart`) |
| P1-8 | auth_provider Notifier | `PhoneAuthNotifier extends StateNotifier<PhoneAuthState>` + cache invalidation (`userProfileProvider`가 `authStateProvider` watch) |
| P1-9 | Clock 주입 | `lib/utils/clock.dart` → `JobRepository`, `ApplicationRepository`에 DI |

### 기타
| # | 항목 |
|---|------|
| A | `PhysicalBadge` enum 단일 소스 (`lib/models/physical_badge.dart`) |
| B | `deadline` null Firestore 쿼리 한계 문서화 |
| C | `ApplicationModel.applicationId` submit 시 설정 + `fetchApplications` `doc.id` 주입 |

---

## Review Rounds

### Round 1 (Claude)
- **Verdict**: Request Changes — Major 2건 (M-1, M-2), Minor 3건 (m-1~m-3)
- **M-1**: `mapFirebaseAuthException()` 호출처 0건 → dead code
- **M-2**: `MainShell` redirect guard 실제 미삭제
- Review log: `docs/PR_Review/2026-05-10-architecture-fix-implementation-review_claude.md`

### Round 2 (Claude)
- **Verdict**: Approve — M-1, M-2 모두 해소
- `_mapAuthError(FirebaseAuthException)` → `_exceptionToMessage(mapFirebaseAuthException(e))` 로 통합
- `MainShell` redirect 삭제 완료
- Review log: `docs/PR_Review/2026-05-10-architecture-fix-implementation-review_claude_round2.md`

---

## Verification

```bash
flutter analyze   # 0 errors, 0 warnings
flutter test      # 97/97 passed (기존 84 + OtpPinBox 13)
verify_local.sh   # 6/6 PASSED
```

---

## Files Changed

| File | Status |
|------|--------|
| `lib/providers/auth_provider.dart` | Rewrite (StateNotifier) |
| `lib/screens/auth/otp_input_screen.dart` | Decomposed (OtpPinBox) |
| `lib/screens/auth/phone_input_screen.dart` | Use PhoneAuthNotifier + PrimaryButton |
| `lib/screens/auth/profile_register_screen.dart` | Decomposed (3 widgets) |
| `lib/screens/main/main_shell.dart` | Remove redirect guard |
| `lib/repositories/auth_repository.dart` | AuthException sealed class |
| `lib/screens/application/application_result_screen.dart` | Design token fix |
| `lib/widgets/otp_pin_box.dart` | **New** |
| `test/widgets/otp_pin_box_test.dart` | **New** (13 tests) |
