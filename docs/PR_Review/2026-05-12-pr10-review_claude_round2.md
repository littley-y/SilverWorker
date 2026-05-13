# PR Review — spec_11 (Claude, Round 2)

> 작성일: 2026-05-12
> PR: #10 / 대상 커밋: `e2ead0b fix(spec_11): address Claude Round 1 review feedback`
> 판정: **REQUEST CHANGES** (신규 Major 1, 미해결 Major 2, 그 외 모두 해결)

---

## Round 1 항목 정산

| ID | 항목 | Round 2 결과 |
|---|---|---|
| B-1 | textScaler 미적용 | ✅ `MaterialApp.builder`로 이동, 자식 트리에 정상 전파. 그러나 신규 이슈 N-1 발생 (아래) |
| M-1 | 폰트 스케일 실제 적용 검증 테스트 부재 | ❌ **미해결** (U-1 참조) |
| M-2 | 마스코트 JobList/MyPage 배치 | ✅ JobListScreen AppBar action + EmptyState, MyPageScreen 프로필카드 우상단 Stack 배치 |
| M-3 | 고대비 토글 누락 | ✅ spec_11에서 P1로 강등 표기, deferral 명시 |
| m-1 | AnimatedScale no-op | ✅ `TweenAnimationBuilder<double>` + `Curves.easeOutBack`로 교체 |
| m-2 | PR 번호 불일치 | ✅ 파일명 `pr10-request.md`로 정정 |
| m-3 | double 동등 비교 | ✅ `(state - clamped).abs() < 1e-9` 적용 |
| n-1 | SettingsScreen 타이틀 중복 | ✅ 본문 `'앱 설정'` 헤더 제거 (단 U-2 참조) |
| Round 1 후속 #2 | caption 12pt 하한 / headline 32pt 상한 보장 | ❌ **미해결** (U-3 참조) |

---

## 신규 이슈

### N-1 (Major). `MaterialApp.key = ValueKey<double>(fontScale)` 사용 — 회귀 위험

`lib/main.dart:22`에서 `MaterialApp.router`에 `key: ValueKey<double>(fontScale)`을 부여했습니다.

```dart
return MaterialApp.router(
  key: ValueKey<double>(fontScale),
  ...
  builder: (context, child) => MediaQuery(...),
);
```

**문제**: `fontScale` 값이 바뀔 때마다 ValueKey가 달라져 Flutter는 `MaterialApp` 위젯과 그 하위 Element 트리(GoRouter의 `Navigator` 포함)를 **모두 폐기·재생성**합니다. 즉 사용자가 설정 화면에서 슬라이더를 1회 움직일 때마다:

1. 라우터가 처음부터 다시 빌드되며 `initialLocation`(`/home`)으로 되돌아감
2. 네비게이션 스택, 화면 상태(스크롤 위치, 폼 입력 등)가 전부 초기화

설정 화면에서 슬라이더를 움직이는 즉시 홈으로 튕겨 나가는 UX 회귀가 발생합니다.

**원인 추정**: `builder` 안의 `MediaQuery`가 갱신되도록 강제하려고 추가한 것으로 보이지만, `MyApp`이 `ConsumerWidget`이고 `ref.watch(fontSizeProvider)`로 인해 `MyApp.build`가 재실행되면서 `MaterialApp`이 새 `builder` 클로저를 받아 자동으로 다시 빌드됩니다. 따라서 `ValueKey`는 **불필요할 뿐 아니라 유해**합니다.

**수정**: `key: ValueKey<double>(fontScale)` 줄을 제거하세요. 다른 변경은 필요 없습니다. 실기기 시나리오 테스트 권장: 마이페이지→설정 진입 후 슬라이더 조작 시 설정 화면이 유지되는지, 그리고 다른 화면들의 텍스트가 즉시 갱신되는지 확인.

---

## 미해결 (Round 1에서 지적된 항목)

### U-1 (Major, M-1 미해결). 추가된 테스트가 실제 와이어링을 검증하지 않음

`test/widgets/settings_screen_test.dart:71-90`의 신규 케이스는 다음을 합니다:

```dart
await tester.pumpWidget(
  ProviderScope(
    child: MediaQuery(
      data: const MediaQueryData().copyWith(
        textScaler: const TextScaler.linear(1.4),
      ),
      child: const Directionality(... Text('Test', ...)),
    ),
  ),
);
final textScaler = MediaQuery.textScalerOf(element);
expect(textScaler, const TextScaler.linear(1.4));
```

이 테스트는 **Flutter의 `MediaQuery.textScalerOf` API가 동작한다는 것**만 보장합니다. `MyApp`을 펌프하지 않고, `fontSizeProvider`를 통한 경로도 거치지 않습니다. 즉 B-1과 같은 와이어링 버그(예: 이번 N-1의 ValueKey 회귀)가 발생해도 그린입니다.

**의도된 검증**: 슬라이더(또는 provider) 값을 바꿨을 때 트리 어딘가의 `Text`가 새 `textScaler`로 렌더되는지. 권장 형태:

```dart
testWidgets('fontSizeProvider change propagates textScaler to descendants', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [/* fontSizeProvider 1.4로 override */],
      child: const MyApp(),  // 또는 MyApp의 builder를 모사한 최소 wrapper
    ),
  );
  await tester.pumpAndSettle();
  final scaler = MediaQuery.textScalerOf(tester.element(find.text(/* 화면 내 텍스트 */)));
  expect(scaler, const TextScaler.linear(1.4));
});
```

`MyApp` 전체를 펌프하기 어렵다면 (Firebase init 등) `MaterialApp.router` + `builder` 패턴만 추출한 최소 wrapper를 별도 helper로 두고 검증해도 됩니다.

### U-2 (Major, Round 1 후속 #2 미해결). per-style 하한 12pt / 상한 32pt 보장 없음

Round 1에서 명시했듯 spec_11 UI-11-06은 caption 12pt 하한, headline 32pt 상한을 요구합니다. `textScaler` 방식은 본질적으로 곱셈만 적용하며 per-style cap을 강제하지 않습니다.

현 코드는 `fontScale.clamp(0.8, 1.4)`만 있어:

- caption(예: 14pt) × 0.8 = 11.2pt → 12pt 하한 위반
- headline(예: 24pt) × 1.4 = 33.6pt → 32pt 상한 위반

옵션:
- (A) 코드 수정: scale 범위를 per-style 산정 결과로 좁히거나, 핵심 스타일에 `clamp` wrapper를 두는 방식
- (B) spec 갱신: M-3처럼 spec UI-11-06을 현재 구현 범위(0.8~1.4 단순 클램프)에 맞게 정정하고 사유 명시

어느 쪽이든 spec과 코드의 정합성이 필요합니다. round 1 review 응답 코멘트에서 이 항목에 대한 언급이 없었습니다.

---

## 비-차단 관찰 (Nit, optional)

### n-2. `SettingsScreen` 상단 Row의 빈 Expanded

`lib/screens/settings/settings_screen.dart:35-42`:

```dart
const Row(
  children: <Widget>[
    Expanded(child: SizedBox.shrink()),
    MascotWidget(size: 60),
  ],
)
```

타이틀 텍스트가 사라지면서 마스코트만 우측에 떠 있는 형태가 되었습니다. AppBar에 이미 '설정' 타이틀이 있으니 이 Row 자체를 제거하고 마스코트를 AppBar `actions`로 옮기거나, 화면 상단 일러스트 영역으로 의도를 명확히 하는 편이 깔끔합니다. 기능 영향은 없습니다.

### n-3. `MascotWidget` width=120 케이스 fallback 분기

`m-1` 변경으로 `TweenAnimationBuilder`가 새로 들어왔는데, `mascot_widget_test.dart`의 size=120 케이스는 여전히 `Image`의 width를 검사합니다. 테스트 통과 자체는 OK지만, 실제 이미지 로드 실패 시 `errorBuilder`가 반환하는 `Container`는 width 120을 가지는지 별도 검증해 두면 fallback에 대한 회귀 방지가 됩니다.

---

## 머지 판정

**REQUEST CHANGES** — N-1 회귀는 사용자 입장에서 즉시 체감되며, U-1/U-2는 round 1에서 명시한 항목입니다. 다음 라운드에서 다음을 처리해 주세요:

1. (Major) `MaterialApp`의 `ValueKey<double>(fontScale)` 제거 + 실기기 슬라이더 조작 회귀 테스트
2. (Major) `MyApp`(또는 그 wrapper)을 펌프해 fontSize provider 변경이 트리에 전파됨을 검증하는 위젯 테스트
3. (Major) spec UI-11-06의 12pt/32pt cap 처리: 코드 보강 또는 spec 갱신 + 사유 기술

신규 m-1 ~ m-3, n-1, M-2, M-3, B-1의 builder 이동은 잘 처리되었습니다.
