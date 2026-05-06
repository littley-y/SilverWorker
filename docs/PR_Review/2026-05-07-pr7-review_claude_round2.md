# PR #7 Review — spec_07 마이페이지 (Claude · Round 2)

**날짜**: 2026-05-07
**리뷰어**: Claude Code
**대상 PR**: [#7 feat(mypage): implement spec_07 (Day 9)](https://github.com/littley-y/SilverWorker/pull/7)
**브랜치**: `feature/day9-mypage`
**기준 스펙**: [`docs/planning/spec_07_mypage.md`](../planning/spec_07_mypage.md)
**Round 1 리뷰**: [`2026-05-06-pr7-review_claude.md`](./2026-05-06-pr7-review_claude.md)
**판정**: 🟢 **APPROVE** — Round 1의 Major 3 / Minor 3 / Nit 2 모두 코드 레벨에서 적절히 해결됨.

---

## 요약

Round 1에서 지적한 8건이 모두 정확히 해결되었고, 단순히 요청을 따른 게 아니라 **각 이슈의 근본 원인을 짚은 수정**이다. 특히 M-1은 단순히 호출만 바꾼 게 아니라 mock에 `signOutCallCount` 카운터를 추가해 행동을 검증 가능하게 만들었고, M-2는 `addPostFrameCallback` 제거 후 router redirect 책임 분리가 명확히 문서화되어 있다.

| 라운드 | Blocker | Major | Minor | Nit | 머지 |
|---|---|---|---|---|---|
| Round 1 | 0 | 3 | 3 | 2 | ⛔ 보류 |
| Round 2 | 0 | 0 | 0 | 0 | ✅ 가능 |

---

## Round 1 이슈별 해결 검증

### 🟠 M-1 — `AuthRepository.signOut()` 경유 + 호출 검증 ✅

**Before** (`my_page_screen.dart`):
```dart
import 'package:firebase_auth/firebase_auth.dart';
// ...
await FirebaseAuth.instance.signOut();
```

**After** (commit range `cf4e1c3..2a4aa5b`):
```dart
// firebase_auth import 제거 — 화면 단에서 Firebase 직접 의존 끊음
// ...
void _showLogoutDialog(BuildContext context, WidgetRef ref) {  // ref 인자 추가
  // ...
  TextButton(
    onPressed: () async {
      Navigator.of(dialogContext).pop();
      await ref.read(authRepositoryProvider).signOut();   // ← 리포지토리 경유
    },
    child: Text('로그아웃', ...),
  ),
}
```

**검증** (`test/widgets/my_page_screen_test.dart`):
```dart
class _MockAuthRepository extends Fake implements AuthRepository {
  int signOutCallCount = 0;

  @override
  Future<void> signOut() async {
    signOutCallCount++;
  }
  // ...
}

testWidgets('tapping logout shows confirmation dialog and calls signOut', ...) {
  // ...
  await tester.tap(dialogLogoutAction);
  await tester.pumpAndSettle();
  expect(mockRepo.signOutCallCount, 1);   // ← 행동 검증
}
```

리포지토리 추상화 회복 + 1회 호출 행동 검증까지 완전히 닫힘. **Resolved.**

---

### 🟠 M-2 — Router redirect에 위임, Scaffold 중첩 제거 ✅

**Before**:
```dart
if (user == null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) context.go(AppRoutes.phone);
  });
  return const Scaffold(body: Center(child: CircularProgressIndicator()));
}
// profile == null 분기에서도 동일 패턴 + 또 한 번 Scaffold 중첩
```

**After**:
```dart
/// 인증 상태는 go_router redirect가 보장하므로 본 화면에서는
/// currentUser가 non-null임을 가정합니다.
class MyPageScreen extends ConsumerWidget { ... }

// user == null — defensive guard만 남김 (navigation side-effect 제거)
if (user == null) {
  return const Scaffold(body: Center(child: CircularProgressIndicator()));
}

// profile == null — Scaffold 중첩 제거, Center만 반환
if (profile == null) {
  return const Center(child: CircularProgressIndicator());
}
```

- `addPostFrameCallback` 양쪽 분기 모두 제거 → router refreshListenable과의 race 차단
- profile==null 분기는 외부 `Scaffold(appBar:..., body: ...)` 안에서 `Center`만 반환하도록 변경 → SemanticsNode 중복 해소
- 클래스 docstring으로 "user non-null 가정" 계약 명시

**Resolved.**

---

### 🟠 M-3 — 경력 소개 스타일 정정 ✅

**Before**:
```dart
style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
// sectionTitle = 16pt w600 + textSecondary  → 본문이 회색 + semi-bold로 약하게 보임
```

**After**:
```dart
style: AppTextStyles.body.copyWith(fontSize: 16),
// body = 18pt regular + textPrimary → 16pt로 축소, 본문 톤 유지
```

스펙 §2 "16pt"의 자연스러운 의도(regular weight + primary text)와 일치. **Resolved.**

---

### 🟡 m-1 — 다이얼로그 액션 검증 정밀화 ✅

```dart
// findsNWidgets(3) 폐기, descendant 사용
final dialogActions = find.descendant(
  of: find.byType(AlertDialog),
  matching: find.byType(TextButton),
);
final dialogLogoutAction = find.descendant(
  of: dialogActions,
  matching: find.text('로그아웃'),
);
expect(dialogLogoutAction, findsOneWidget);
```

`AlertDialog` → `TextButton` → `Text('로그아웃')` 2단계 좁히기로 다이얼로그 외부 "로그아웃" 텍스트와 분리. 다이얼로그 제목/메시지 변경에도 견고. **Resolved.**

---

### 🟡 m-2 — 날짜 zero-pad ✅

**Before**: `'${date.month}월 ${date.day}일'` → "5월 1일"
**After**:
```dart
String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${month}월 ${day}일';   // "05월 01일"
}
```

테스트 assertion (`'05월 01일'`, `'05월 03일'`)도 동기화. 스펙 "MM월 DD일" 표기와 정확히 일치. **Resolved.**

---

### 🟡 m-3 — Scaffold 중첩 제거 ✅

M-2와 함께 자연스럽게 해결됨. 외부 Scaffold 안에서 `Center(...)`만 반환. **Resolved.**

---

### ⚪ n-1 — `test/helpers/test_doubles.dart` 추출 ✅

**신규 파일**:
```dart
// test/helpers/test_doubles.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

/// A mock [User] for use in widget tests.
class MockUser extends Fake implements User {
  @override
  String get uid => 'test_uid';
}
```

`my_page_screen_test.dart`, `application_list_screen_test.dart` 양쪽이 `import '../helpers/test_doubles.dart';`로 공용 사용. 이후 마이페이지 흐름 테스트 추가 시 재사용 가능. **Resolved.**

---

### ⚪ n-2 — 테스트 이름 leading space 제거 ✅

**Before**: `' tapping logout shows confirmation dialog'`
**After**: `'tapping logout shows confirmation dialog and calls signOut'`

이름도 "and calls signOut"을 추가해 행동 검증 의도가 더 명확해짐 (M-1과 시너지). **Resolved.**

---

## CI 상태

PR Round 2 요청 문서 기재:
```
$ bash tools/verify_local.sh
✅ Dependencies resolved.
✅ Formatting is clean.
✅ Zero warnings. (flutter analyze)
✅ All tests passed. (62/62)
✅ Pages build simulation passed.
```

또한 round 2 diff에서 다른 테스트 파일들(`application_form_screen_test`, `application_result_screen_test`, `job_card_test`, `job_detail_screen_test`)에 `dart format`에 의한 줄바꿈 정리만 발생 — 로직 변경 없음. CI 사이드 이펙트 없음으로 판단.

---

## 잔여 사항 — 없음

이번 라운드에서 추가로 발견한 이슈 없음. Round 1에서 지적한 8건 모두 닫혔고, 새 회귀도 보이지 않는다.

---

## 머지 가이드

- ✅ Claude Round 2 — APPROVE
- Gemini도 round 1에서 이미 승인 (request 문서 기준) → 양측 합의 형성됨
- `gh pr merge 7` 진행 가능
- 머지 후 `docs/PROGRESS.md` spec_07 상태 → `✅ 완료`로 갱신

---

*Round 1 → Round 2까지 모든 수정이 단순 ad-hoc patch가 아니라 추상화 회복 / 책임 분리 / 행동 검증 추가까지 동반했다는 점을 강조하고 싶다. 좋은 작업.*
