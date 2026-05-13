# PR #9 Review — Claude (Round 1)

**날짜**: 2026-05-07
**리뷰어**: Claude Code
**대상 PR**: #9 — `feat(navigation): implement spec_08 — BottomNavigationBar with ShellRoute`
**브랜치**: `feature/day10-navigation` (HEAD: `68b6419`)
**판정**: ✅ **APPROVED** (Blocker 0 / Major 0 / Minor 3 / Nit 2)

---

## TL;DR

`spec_08_navigation.md`의 모든 핵심 요구사항(ShellRoute + BottomNav 3탭, 라우트 구조, PopScope 기반 인증 화면 종료, 데이터 전달, 뒤로가기 규칙)을 정확히 구현했습니다. `flutter analyze` 0경고, 62/62 테스트 통과 확인. Blocker/Major 없음 — 머지 가능 수준입니다. 다만 Minor 3건과 Nit 2건은 후속 정리 권장.

---

## ✅ Spec 일치 검증

| Spec 항목 | 구현 | 결과 |
|---|---|---|
| §1 라우트 구조 (ShellRoute + 3 child routes) | `app_router.dart:111-130` | ✅ |
| §1 `initialLocation: '/home'` | `app_router.dart:64` | ✅ |
| §1 `redirect` (미로그인 → /auth/phone) | `app_router.dart:67-90` | ✅ |
| §2 BottomNav 3 탭 (홈/지원현황/마이페이지) | `main_shell.dart:18-32` | ✅ |
| §2 iconSize 28, fontSize 14 | `main_shell.dart:104-106` | ✅ |
| §2 selected = primary, unselected = 회색 | `main_shell.dart:101-102` (textSecondary) | ✅ |
| §3 path parameter (jobId) 전달 | `app_router.dart:131-156` | ✅ |
| §4 ApplicationResult → 홈 (`go()` 사용) | `application_result_screen.dart:48,69` | ✅ |
| §4 ApplicationForm 제출 후 result로 `go()` | `application_form_screen.dart:61` | ✅ |
| §4 인증 화면 PopScope → 앱 종료 | `phone_input_screen.dart:69-75`, `otp_input_screen.dart:194-200` | ✅ |
| §5 전역 로딩 오버레이 미사용 | (각 화면 개별 처리) | ✅ |

---

## 🔴 Blocker

없음.

## 🟡 Major

없음.

## 🟢 Minor

### m-1. `MyPageScreen` 메뉴 "지원 내역"이 BottomNav 탭과 중복

**위치**: `lib/screens/mypage/my_page_screen.dart:67`

```dart
onTap: () => context.go(AppRoutes.applications),
```

이번 PR로 `/applications`가 BottomNav 탭이 되었으므로, 마이페이지 메뉴에서 같은 화면으로 가는 동선이 **두 군데** 생겼습니다. 의도된 디자인이라면 OK이지만, 사용자 입장에서는 마이페이지 안에서 항목을 누르고 다시 마이페이지로 돌아오는 것이 다소 어색할 수 있습니다.

**옵션**:
- (A) 메뉴 항목을 제거하고 BottomNav로만 진입 (스펙 §2와 일관)
- (B) 메뉴를 유지하되 시각적 구분 (예: "탭에서 보기 →" 같은 보조 텍스트)
- (C) 의도된 디자인이면 그대로 유지 (이 경우 별도 액션 불필요)

스펙 §2/3에는 명확한 규정이 없으므로 디자인 의사결정.

---

### m-2. OTP 화면 시스템 백 제스처가 앱을 종료시킴 — UX 토론

**위치**: `lib/screens/auth/otp_input_screen.dart:194-200`

```dart
return PopScope(
  canPop: false,
  onPopInvokedWithResult: (bool didPop, Object? result) {
    if (!didPop) {
      SystemNavigator.pop();   // 앱 종료
    }
  },
  ...
);
```

스펙 §4 표 마지막 행("인증 화면 → Android 뒤로가기 → 앱 종료")에 부합하므로 **스펙 우선 원칙상 승인** 대상입니다. 다만:

- AppBar 좌측 화살표(`onPressed: () => context.go(AppRoutes.phone)`)는 Phone 화면으로 돌아가는데, 시스템 백은 앱을 종료합니다 — 두 백 진입점의 동작이 비대칭.
- 사용자가 OTP 입력 중 실수로 백 제스처를 하면 앱 자체가 종료되어 처음부터 다시 시작해야 합니다.

스펙 변경 가능성에 대한 디자인/PM 합의가 있다면 OTP 화면만은 phone으로 돌아가는 편이 자연스럽습니다. 본 PR에서 변경할 필요는 없으며, 토론 포인트로 기록합니다.

---

### m-3. `Colors.grey.shade300/400` 하드코딩 잔존 (PR #8에서 도입한 `AppColors.border/hintText` 미적용)

**위치**:
- `lib/screens/auth/phone_input_screen.dart:115, 142, 154, 156, 167` 등 — `Colors.grey.shade300/400` 다수
- `lib/screens/auth/otp_input_screen.dart:228` — `Colors.grey.shade300`

PR #8에서 `AppColors.border` (#E0E0E0), `AppColors.hintText` (#BDBDBD) 상수를 추가했으나 이번 PR이 같은 파일을 PopScope로 감싸는 등 손대면서도 회색 상수 교체는 누락했습니다. 본 PR의 직접 스코프(`navigation`)는 아니므로 별도 PR로 후속 정리 권장.

---

## ⚪️ Nit

### n-1. `MainShell._tabs` 선언 포맷 비일관

**위치**: `lib/screens/main/main_shell.dart:18-32`

```dart
static const _tabs = <_TabItem>[
  _TabItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: '홈',
      route: AppRoutes.home),
  ...
];
```

여는 괄호와 첫 named arg가 같은 줄에 있고 닫는 괄호 위치가 일관되지 않습니다. 프로젝트 다른 곳의 multi-line constructor 호출 스타일(`final widget = Foo(\n  arg: ...,\n);`)에 맞춰 `dart format` 결과대로 두는 편이 좋습니다 (현재도 분석기는 통과하지만 가독성 측면).

### n-2. `_TabItem` 생성자도 동일 포맷 이슈

**위치**: `main_shell.dart:135-140`

별도 위젯이 아닌 단순 데이터 보관 클래스라면 `({...this.icon})` 식의 한 줄 또는 한 줄당 한 필드의 표준 정렬을 권장.

---

## 검증 결과

| 항목 | 결과 |
|---|---|
| `flutter analyze` | ✅ No issues found |
| `flutter test` | ✅ 62/62 passed |
| Spec §1~§6 항목 | ✅ 전부 일치 |
| 잔여 `AppRoutes.main` / `'/'` 참조 | ✅ 없음 (grep 확인) |
| 잔여 `/mypage/applications` 참조 | ✅ 없음 |

---

## ✅ 승인

스펙 §1~§4 모든 항목을 정확히 구현했고 (특히 ShellRoute 구조와 `_resolveIndex` 기반의 currentIndex 도출, PopScope 기반 인증 화면 종료) 회귀도 발견되지 않았습니다. Minor/Nit 5건은 모두 후속 PR에서 다룰 수 있는 수준입니다.

`docs/PROGRESS.md`의 spec_08 상태를 ✅ Completed로 갱신 후 master 머지 진행 가능합니다.

---

*Reviewed by Claude Code · 2026-05-07*
