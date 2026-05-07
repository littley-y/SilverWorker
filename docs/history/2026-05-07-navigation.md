# 2026-05-07 — Day 10 네비게이션 구현 (spec_08)

## 개요

`spec_08_navigation.md` 요구사항을 구현: `go_router` `ShellRoute` 기반 Bottom Navigation Bar, 인증 redirect, Android 백 버튼 처리, 화면 간 데이터 전달.

---

## 주요 변경사항

### 신규 파일

| 파일 | 용도 |
|---|---|
| `lib/screens/main/main_shell.dart` | `BottomNavigationBar` 3탭 (홈/지원현황/마이페이지) + profile guard redirect |

### 수정 파일

| 파일 | 주요 변경 |
|---|---|
| `lib/router/app_router.dart` | `ShellRoute`로 `/home`, `/applications`, `/mypage` 감쌈. `initialLocation` → `/home`. `/mypage/applications` → `/applications`로 통합 |
| `lib/screens/auth/phone_input_screen.dart` | `PopScope` 추가 (Android 백 버튼 → `SystemNavigator.pop()`) |
| `lib/screens/auth/otp_input_screen.dart` | `PopScope` 추가. AppBar 백 버튼 → `context.go(AppRoutes.phone)` |
| `lib/screens/job/job_detail_screen.dart` | `'/apply/${job.jobId}'` 하드코딩 → `AppRoutes.applyRoute()` |
| `lib/screens/application/application_result_screen.dart` | `AppRoutes.main` → `AppRoutes.home` |
| `lib/screens/auth/profile_register_screen.dart` | `AppRoutes.main` → `AppRoutes.home` |
| `test/widgets/my_page_screen_test.dart` | "지원 내역" 텍스트 assertion 제거 (BottomNav 중복 메뉴 제거로 인한 테스트 수정) |

### 제거 파일

| 파일 | 사유 |
|---|---|
| `lib/screens/main/main_screen.dart` | `MainShell`이 대체. profile guard도 `MainShell`로 이전 |

---

## 리뷰 피드백 반영 (Claude Round 1)

| 항목 | 위치 | 수정 내용 |
|---|---|---|
| m-1 | `my_page_screen.dart` | "지원 내역" 메뉴 제거 (BottomNav `/applications` 탭과 중복) |
| m-3 | `phone_input_screen.dart`, `otp_input_screen.dart` | `Colors.grey.shade300/400` → `AppColors.border`/`AppColors.hintText` |
| n-1 | `main_shell.dart` | `_tabs` 리스트 포맷 정리 (trailing comma, 한 줄당 한 필드) |
| n-2 | `main_shell.dart` | `_TabItem` 생성자 포맷 정리 |

---

## 검증

```bash
$ bash tools/verify_local.sh
[1/6] Installing dependencies (flutter pub get)...
✅ Dependencies resolved.
[2/6] Checking code formatting (dart format)...
✅ Formatting is clean.
[3/6] Running static analysis (flutter analyze)...
✅ Zero warnings.
[4/6] Running unit tests (flutter test)...
✅ All tests passed. (62/62)
[5/6] Simulating GitHub Pages build (pages.yml)...
✅ Pages build simulation passed.
[6/6] Checking for uncommitted graphify changes...
✅ Graphify check done.

🚀 LOCAL CI PASSED (6/6 steps, 9s)
```

---

## PR

- **브랜치**: `feature/day10-navigation`
- **PR**: #9
- **리뷰 요청**: `docs/PR_Review/2026-05-07-pr9-request.md`
- **리뷰 피드백**: `docs/PR_Review/2026-05-07-pr9-review_claude.md`, `docs/PR_Review/2026-05-07-pr9-review_gemini.md`
- **커밋**: `68b6419` (구현) → `e799583` (리뷰 반영)

---

## 남은 기술부채

| 우선순위 | 항목 | 사유 |
|---|---|---|
| Low | 딥링킹 시 profile guard bypass | Gemini m-1: `JobDetailScreen`/`ApplicationFormScreen`이 `ShellRoute` 밖에 있어 profile 없이 접근 가능. 현재 MVP에서는 딥링킹 미사용 |
| Low | OTP 화면 시스템 백 vs AppBar 백 비대칭 | Claude m-2: 스펙 §4에 부합하나 UX 개선 여지 있음 |

---

*세션 종료: Sisyphus (OpenCode)*
