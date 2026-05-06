# PR #7 Review — spec_07 마이페이지 (Claude · Round 1)

**날짜**: 2026-05-06
**리뷰어**: Claude Code
**대상 PR**: [#7 feat(mypage): implement spec_07 (Day 9)](https://github.com/littley-y/SilverWorker/pull/7)
**브랜치**: `feature/day9-mypage`
**기준 스펙**: [`docs/planning/spec_07_mypage.md`](../planning/spec_07_mypage.md)
**판정**: 🟡 **REQUEST_CHANGES** — Major 3건. 머지 보류.

---

## 요약

스펙 §1~§3의 가시적 구성요소(프로필 카드 / 메뉴 / 다이얼로그 / 5종 상태 배지 / 정렬)는 충실하게 구현되었고 테스트 11건도 의미 있는 케이스를 다룬다. 다만 **로그아웃 흐름이 리포지토리 추상화를 깨고 Firebase 싱글톤을 직접 호출**하고 있어 테스트로 행동 검증이 불가능하다. 또한 프로필 화면의 redirect 처리가 race를 일으킬 가능성이 있고, 경력 소개의 텍스트 스타일이 스펙 의도(regular)와 다르게 semi-bold + 보조 색상으로 적용돼 있다.

| 등급 | 건수 | 항목 |
|---|---|---|
| 🔴 Blocker | 0 | — |
| 🟠 Major | 3 | M-1 / M-2 / M-3 |
| 🟡 Minor | 3 | m-1 / m-2 / m-3 |
| ⚪ Nit | 2 | n-1 / n-2 |

---

## 🟠 Major

### M-1. 로그아웃이 `AuthRepository.signOut()`을 우회하고 `FirebaseAuth.instance.signOut()`을 직접 호출

**위치**: `lib/screens/mypage/my_page_screen.dart` (확인 다이얼로그 액션)

```dart
TextButton(
  onPressed: () async {
    Navigator.of(dialogContext).pop();
    await FirebaseAuth.instance.signOut();   // ← 직접 호출
  },
  child: Text('로그아웃', ...),
),
```

**문제**:
1. `AuthRepository.signOut()`이 이미 `lib/repositories/auth_repository.dart:89`에 정의돼 있음에도 우회한다 — 코드베이스의 리포지토리 패턴을 깨는 단발성 결합.
2. `_MockAuthRepository`로 mocking된 테스트에서는 이 경로가 **검증되지 않는다**. `tapping logout shows confirmation dialog` 테스트는 다이얼로그가 뜨는 것까지만 보고, "로그아웃" 액션을 탭했을 때 실제 sign-out이 호출되는지를 확인할 수 없다.
3. spec_07 §2 "로그아웃 처리"의 의사코드 (`FirebaseAuth.instance.signOut()`)는 동작 명세이지 호출 경로 강제가 아니다 — 같은 동작을 리포지토리 경유로 하면 모든 면에서 우월하다.

**권장 수정**:

```dart
// my_page_screen.dart — ConsumerWidget이므로 ref 접근 가능
TextButton(
  onPressed: () async {
    Navigator.of(dialogContext).pop();
    await ref.read(authRepositoryProvider).signOut();
  },
  child: Text('로그아웃', ...),
),
```

`_showLogoutDialog`에 `WidgetRef ref`를 인자로 전달하도록 시그니처 수정 필요.

테스트도 mock에 `signOut` 호출을 캡처하는 카운터를 추가해 다이얼로그 → 확인 → `signOut()` 정확히 1회 호출을 검증할 것.

---

### M-2. 프로필 null/유저 null 시 `addPostFrameCallback` + `context.go()` 패턴이 redirect 루프 위험

**위치**: `lib/screens/mypage/my_page_screen.dart`

```dart
if (user == null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) context.go(AppRoutes.phone);
  });
  return const Scaffold(body: Center(child: CircularProgressIndicator()));
}
// ...
profileAsync.when(
  data: (profile) {
    if (profile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.profile);
      });
      return const Scaffold(...);   // ← Scaffold 내부에 또 Scaffold
    }
```

**문제**:
1. **이중 Scaffold**: `profileAsync.when` 안에서 또 `Scaffold`를 반환한다. 외부 Scaffold(`appBar` 포함) 안에서 또 Scaffold가 그려져 layout/semantic 트리가 어긋난다.
2. **Redirect 책임 중복**: `app_router.dart:62~91`의 `redirect:` 핸들러가 이미 `currentUser == null` 시 `/phone`으로 보내도록 설계돼 있다. 화면이 또 한 번 redirect를 호출하면, refreshListenable이 fire되는 타이밍에 따라 router redirect와 화면 redirect가 동시에 트리거되어 의도치 않은 navigation race가 발생할 수 있다.
3. **다중 fire 위험**: `userProfileProvider`가 invalidate(예: 에러 후 "다시 시도")되면 다시 null 상태를 거쳐 또 한 번 `addPostFrameCallback`이 push되어 navigation이 중복 실행될 가능성.

**권장 수정**:
- `user == null` 분기는 router redirect에 위임하고, 본 화면에서 제거. 도달 시점엔 user는 항상 non-null이라고 가정해도 안전하다(redirect listenable이 보장).
- `profile == null`은 router redirect에 ProfileSetup 가드를 추가하거나(권장), 최소한 본 화면에서 단발성 플래그(`bool _redirected = false`)로 중복 호출을 막을 것.
- 내부 분기에서 또 `Scaffold`를 반환하지 말고 `Center(child: CircularProgressIndicator())`만 반환.

```dart
// 단발성 플래그 패턴 (최소 변경)
class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  bool _redirected = false;

  void _redirectOnce(String route) {
    if (_redirected) return;
    _redirected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(route);
    });
  }
  // ...
}
```

(또는 `MyPageScreen`을 `ConsumerStatefulWidget`으로 변경)

---

### M-3. 경력 소개 텍스트 스타일이 스펙 의도와 다름 (semi-bold + 보조색상)

**위치**: `lib/screens/mypage/my_page_screen.dart` `_ProfileSummaryCard.build`

```dart
Text(
  careerSummary,
  style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
  // sectionTitle = 16pt w600 + AppColors.textSecondary
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
),
```

**문제**:
- spec_07 §2 UI 구성: "경력 소개 (16pt, 최대 2줄 + 말줄임)" — Bold 명시 없음. 기본 의도는 `body` 톤(regular).
- `AppTextStyles.sectionTitle`은 `FontWeight.w600` + `color: AppColors.textSecondary`로 정의돼 있어, 본문이 **반강조 + 회색**으로 렌더링된다. 시니어 가독성 측면에서도 본문 텍스트가 textSecondary로 보이는 것은 의도치 않은 위계 약화.
- 이름은 `title.copyWith(fontSize: 22)`로 22pt Bold(spec 정확히 일치), 거주 지역은 `body`(18pt regular, primary)로 정확. 경력 소개만 톤이 어긋난다.

**권장 수정**:

```dart
Text(
  careerSummary,
  style: AppTextStyles.body.copyWith(fontSize: 16),
  // 18pt body → 16pt로 축소, weight/color는 본문 그대로
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
),
```

또는 spec_09 정렬 차원에서 16pt regular용 토큰(`bodySmall` 등)을 새로 추가하는 것도 일관된 옵션.

---

## 🟡 Minor

### m-1. 다이얼로그 검증이 `findsNWidgets(3)`에 의존하여 깨지기 쉬움

**위치**: `test/widgets/my_page_screen_test.dart:177`

```dart
expect(find.text('로그아웃'),
    findsNWidgets(3)); // button + dialog title + dialog action
```

다이얼로그 제목 문구가 변경되거나(예: "로그아웃 확인") 화면 어딘가에 동일 문구가 추가되면 곧바로 false-positive/negative. `find.descendant(of: find.byType(AlertDialog), ...)`로 좁히는 편이 견고하다.

```dart
final inDialog = find.descendant(
  of: find.byType(AlertDialog),
  matching: find.text('로그아웃'),
);
expect(inDialog, findsOneWidget);  // 다이얼로그 액션 버튼만 카운트
```

### m-2. 날짜 포맷이 zero-pad 미적용 — 스펙 "MM월 DD일"과 표기 차이

**위치**: `lib/screens/mypage/application_list_screen.dart` `ApplicationCard._formatDate`

```dart
String _formatDate(DateTime date) {
  return '${date.month}월 ${date.day}일';   // "5월 1일"
}
```

스펙 §3 ApplicationCard 표 "MM월 DD일 형식" — 한국어 관용으로는 "5월 1일"이 자연스럽지만, 표기를 엄격히 따르려면 `intl.DateFormat('M월 d일')` 또는 `'MM월 dd일'`로 명확히 결정. 현재 테스트(`'5월 1일'` assertion)는 비-pad 형식에 록인되어 있어 스펙 표기와 향후 충돌 가능. 본 PR에서 의도(non-pad)를 스펙에 메모로 반영하거나 zero-pad 적용을 제안.

### m-3. `MyPageScreen`이 `Scaffold` 안에서 또 `Scaffold`를 반환 (M-2와 별도 케이스)

**위치**: `my_page_screen.dart` `profileAsync.when(data: ...)` 내부의 profile-null 분기

위 M-2와 묶어서 함께 해결되면 자연히 사라지는 문제이나, 별도로도 `Scaffold` 중첩은 SemanticsNode 중복과 dark mode 등 future-proofing에서 문제를 일으킬 수 있어 명시.

---

## ⚪ Nit

### n-1. 두 테스트 파일이 동일한 `_MockUser` 구현을 중복 정의

`test/widgets/my_page_screen_test.dart`와 `test/widgets/application_list_screen_test.dart` 양쪽이 같은 `_MockUser extends Fake implements User`를 갖고 있다. `test/helpers/test_doubles.dart`로 추출하면 이후 마이페이지 흐름 테스트 추가 시 재사용 가능.

### n-2. `testWidgets(' tapping logout shows confirmation dialog', ...)`에 leading space

테스트 이름 첫 글자에 공백이 들어가 있다. `' tapping ...'` → `'tapping ...'`. 리포트 정렬에서 어색하게 노출됨.

---

## ✅ 잘된 부분 (유지)

- **상태 배지 색상 매핑이 스펙과 1:1 일치** — `AppColors.statusSubmitted/Reviewing/Accepted/Rejected/Cancelled`로 5종 정확히 매핑되고, 테스트가 5건 모두를 색상 단위로 검증한다.
- **정렬은 repository 레벨**(`orderBy('submittedAt', descending: true)`)에서 처리 — 화면 단에서 sort하지 않고 backend boundary에서 결정한 것은 옳은 선택.
- **이름·거주 지역 스타일이 스펙과 정확히 매칭** — `title.copyWith(fontSize: 22)` (22pt Bold), `body` (18pt). spec_09 토큰을 그대로 활용.
- **EmptyState · Error · Loading 3가지 비-happy-path 모두 분기 처리** + 각각 테스트 존재. spec §3 "EmptyState"만 명시적으로 요구되었으나 한 단계 더 견고하게 처리한 점이 좋다.
- **`Address.display` getter** 활용으로 "서울 종로구" 조합 로직이 모델 레벨에 집약돼 있고 화면이 그것을 그대로 사용 — 좋은 분리.

---

## 머지 가이드

- M-1, M-2, M-3 해결 후 round 2 요청.
- m-* / n-* 는 round 2에서 묶어서 또는 별도 follow-up PR로 가능.
- 회귀: 수정 후 `bash tools/verify_local.sh` 재실행 + 새 테스트(특히 mock signOut 호출 카운터) 추가 권장.

---

*Spec_07을 단독 기준으로 본 1차 리뷰. Gemini 리뷰는 별도 진행, 본 문서를 참조하지 않음.*
