# PR Review — spec_11: 시니어 특화 UI/UX 고도화 (Claude, Round 1)

> 작성일: 2026-05-12
> PR: #10 (`feature/spec-11-senior-ui` → `master`)
> 요청 문서: `docs/PR_Review/2026-05-12-pr11-request.md`
> 판정: **REQUEST CHANGES** (Blocker 1, Major 2, Minor 3, Nit 1)

---

## 요약

- 마스코트 위젯, 폰트 스케일 영구 저장, 설정 화면 UI는 깔끔하게 구현되어 있고 테스트(111/111) 및 `flutter analyze` 0경고를 통과합니다.
- 그러나 **이 PR의 핵심 기능인 "앱 전체 동적 폰트 적용" 자체가 런타임에 동작하지 않습니다.** `MediaQuery`가 `MaterialApp` 상위에 배치되어 `textScaler` 오버라이드가 무시됩니다. 슬라이더를 움직여도 SharedPreferences에 값만 저장될 뿐, 화면 어디에서도 글자가 실제로 커지거나 작아지지 않습니다. 위젯 테스트가 통과한 이유는 텍스트 크기 변화 자체를 검증하지 않기 때문입니다.
- 또한 spec_11이 P0로 명시한 (1) 마스코트의 `JobListScreen`/`MyPageScreen` 배치, (2) "화면 모드" 고대비 토글 섹션이 누락되었습니다.

---

## Blocker

### B-1: `MediaQuery.textScaler` 오버라이드가 효과가 없습니다 (`lib/main.dart:24-39`)

```dart
return MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaler: TextScaler.linear(fontScale),
  ),
  child: MaterialApp.router(...),
)
```

`MaterialApp`(내부적으로 `WidgetsApp`)은 자신의 자식 트리에 `MediaQuery.fromView(view: View.of(context), ...)`로 **새로운 MediaQuery를 주입**합니다. 이 새 MediaQuery는 부모의 MediaQuery를 참조하지 않고 `View`로부터 직접 `MediaQueryData`를 만들기 때문에, `textScaler`를 포함한 어떤 값도 부모로부터 전파되지 않습니다. 결과적으로 본 PR의 핵심 가치인 "앱 전체 폰트 스케일링"이 실제 디바이스에서 동작하지 않습니다.

**원인 검증법 (수동)**

1. 디바이스/시뮬레이터에서 앱 실행 → 마이페이지 → 설정 진입
2. 슬라이더를 0.8 또는 1.4로 이동
3. 홈/지원현황/마이페이지 화면의 텍스트가 실제로 변화하는지 확인 → 변화 없음

(현재 테스트는 위 시나리오를 커버하지 않아 통과합니다. M-1 참조.)

**수정 방향 (택1)**

옵션 A — `MaterialApp.builder` 사용 (Flutter 공식 권장 패턴):

```dart
return MaterialApp.router(
  ...,
  builder: (context, child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(fontScale),
      ),
      child: child!,
    );
  },
);
```

옵션 B — `ThemeData.textTheme`에 스케일링된 TextStyle을 적용하거나, spec UI-11-05의 원안대로 `AppTextStyles.of(context, ref)` 패턴으로 모든 TextStyle을 동적으로 만들어 사용.

스펙 UI-11-05·UI-11-06은 "기존 고정 fontSize → fontSize × fontScale 적용" + "12pt 하한 / 32pt 상한"을 요구합니다. 옵션 A로 fix 시 `textScaler`는 상·하한을 강제하지 않으므로 별도 caption 12pt 하한 / headline 32pt 상한 보장 로직(혹은 scale 범위를 그에 맞게 산정하는 근거)이 필요합니다. 현재는 scale clamp(0.8~1.4)만 있고, 스펙이 명시한 per-style 하한/상한이 보장되지 않습니다.

---

## Major

### M-1: 폰트 스케일링이 실제로 적용되는지 검증하는 테스트 부재

`test/widgets/settings_screen_test.dart`는 슬라이더 존재와 100% 표시만 확인할 뿐, 슬라이더 조작 후 다른 화면(또는 동일 화면)의 텍스트가 실제로 다른 크기로 렌더링되는지 확인하지 않습니다. `test/providers/font_size_provider_test.dart`도 상태와 SharedPreferences만 검증합니다. 그 결과 B-1처럼 위젯이 통째로 깨져도 테스트는 그린입니다.

**제안**: `MyApp`을 펌프한 뒤 `fontSizeProvider`를 1.2로 변경하고, 특정 `Text`의 `TextScaler` 또는 렌더 박스 크기를 비교하는 테스트를 1건 이상 추가하세요. (TC-11-03이 정확히 이 케이스입니다.)

### M-2: 스펙 P0-1 (UI-11-02) 마스코트 배치 누락

spec_11 §2 P0-1에서 마스코트는 다음 3곳에 배치되어야 합니다:
- `JobListScreen` 상단 또는 Empty State 중앙
- `MyPageScreen` 프로필 카드 상단 우측
- `SettingsScreen` 상단 타이틀 옆

본 PR은 `SettingsScreen`에만 배치되어 있습니다(`lib/screens/settings/settings_screen.dart:43`). `JobListScreen`과 `MyPageScreen`에는 변경이 없습니다 (`git diff` 확인). 스펙 P0 항목이 부분 구현 상태입니다.

### M-3: 스펙 P0-3 (UI-11-07) "화면 모드" 섹션 누락

spec_11 §2 P0-3는 SettingsScreen에 다음 3개 섹션을 요구합니다:
- 글자 크기 ✅
- **화면 모드 — 고대비 모드 ON/OFF 토글** ❌
- 앱 정보 ✅

PR 본문(§7 후속 작업)에서는 "향후 추가 가능"으로 미뤘으나, 스펙은 이를 P0(즉시 구현)로 분류하고 있습니다. 토글이 빠지더라도 진행하려면 스펙을 먼저 갱신하거나 PROGRESS.md에 명시적 deferral을 기록해야 합니다. 현 상태로는 spec-first 원칙(AGENTS.md §3)에 어긋납니다.

---

## Minor

### m-1: `AnimatedScale`이 사실상 no-op (`lib/widgets/mascot_widget.dart:39-43`)

`scale: 1.0`이 상수로 고정되어 있어 등장 애니메이션이 발생하지 않습니다. `AnimatedScale`은 scale 값이 변할 때만 보간합니다. 스펙 UI-11-01의 "부드러운 등장/퇴장"을 의도했다면 `TweenAnimationBuilder<double>`(begin 0.0→end 1.0) 또는 `initState`에서 setState로 1.0로 전환하는 방식으로 바꾸세요. 의도적이라면 `AnimatedScale` 래핑 자체를 제거하는 것이 정직합니다.

### m-2: PR 번호 표기 불일치

요청 문서명/본문이 `pr11`로 되어 있지만 실제 PR은 #10입니다(`gh pr list`). 후속 리뷰·머지 트래킹 혼란 방지를 위해 `2026-05-12-pr10-request.md`로 rename하거나, 본문 PR 번호를 정정해 주세요. (본 리뷰 파일은 실제 번호 `pr10`을 따랐습니다.)

### m-3: `font_size_provider.dart`의 `state == clamped` 비교 (`lib/providers/font_size_provider.dart:30`)

double 동등 비교는 부동소수 누적 오차에 약합니다. Slider의 6 divisions라면 실용상 안전하지만, 향후 외부 입력이 들어올 때를 대비해 `(state - clamped).abs() < 1e-9` 형태가 더 견고합니다. 단, 현재 사용 범위에서는 실제 문제로 이어지지 않습니다.

---

## Nit

### n-1: AppBar 타이틀 `'설정'` + 본문 헤더 `'앱 설정'` 중복

같은 화면 상단에 두 개의 타이틀 라벨이 노출됩니다(`settings_screen.dart:19`, `:39`). 시니어 사용자 대상의 정보 간결성을 고려해 둘 중 하나로 통일을 고려하세요. 기능에 영향은 없습니다.

---

## 확인 사항 (긍정적)

- `flutter analyze` 0경고, 111/111 테스트 통과, `verify_local.sh` 6/6 ✅
- `FontSizeNotifier`의 `initialized` Future 패턴은 테스트 가능성을 잘 확보하고 있어 적절합니다.
- `MascotWidget.errorBuilder` fallback과 SharedPreferences 영구 저장은 깔끔합니다.
- 금지 파일 / 리뷰어 파일 미포함 확인 완료.

---

## 머지 판정

**REQUEST CHANGES** — B-1로 인해 본 PR이 의도한 사용자 가치(폰트 동적 변경)가 실제로 동작하지 않습니다. M-2/M-3는 spec-first 원칙 위반입니다. 다음 라운드에서 다음을 처리해 주세요:

1. (Blocker) `MaterialApp.builder` 또는 동등한 방식으로 textScaler가 실제 자식 트리에 전파되도록 수정
2. (Blocker 연계) caption 12pt 하한 / headline 32pt 상한을 어떤 방식으로 보장할지 결정 — 코드 또는 스펙 갱신
3. (Major) JobListScreen / MyPageScreen에 마스코트 배치
4. (Major) 고대비 모드 토글 구현 또는 스펙 deferral 문서화
5. (Major) 폰트 스케일이 실제 렌더링에 적용됨을 검증하는 위젯 테스트 추가
6. (Minor) m-1 ~ m-3 정리
