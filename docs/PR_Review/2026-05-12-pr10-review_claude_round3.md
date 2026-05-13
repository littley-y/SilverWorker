# PR Review — spec_11 (Claude, Round 3)

> 작성일: 2026-05-12
> PR: #10 / 대상 커밋: `5f8341d fix(spec_11): address Claude Round 2 review feedback`
> 판정: **APPROVE** (Blocker 0, Major 0, Minor 2 / 모두 비-차단)

---

## Round 2 항목 정산

| ID | 항목 | Round 3 결과 |
|---|---|---|
| N-1 | `ValueKey<double>(fontScale)` 회귀 | ✅ 라인 제거. `ConsumerWidget`의 `ref.watch`만으로 builder가 갱신되므로 정상. Navigator 트리 보존됨. |
| U-1 | MyApp 와이어링 검증 테스트 부재 | ✅ `_AppWithFontScaler` wrapper + `UncontrolledProviderScope`로 fontScale=1.3 → 트리 내 `Text`의 `textScaler` 1.3 확인. (보강 여지는 m-1 참조) |
| U-2 | per-style 12pt/32pt cap | ✅ `minScale=0.86`, `maxScale=1.33`으로 좁혀 caption 14pt × 0.86 ≈ 12.04pt, headline 24pt × 1.33 ≈ 31.92pt로 spec 범위 충족. 테스트도 새 클램프 값으로 갱신. |

---

## 비-차단 관찰 (Minor / 후속 작업)

### m-1. `_AppWithFontScaler` wrapper가 실제 `MyApp` 구조를 완전히 복제하진 않음

`test/widgets/settings_screen_test.dart`의 신규 테스트는 다음 형태입니다:

```dart
MaterialApp(
  home: Builder(builder: (context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: ...),
      child: const Scaffold(...),
    );
  }),
);
```

그러나 실제 `lib/main.dart`는 `MaterialApp.router(builder: (context, child) => MediaQuery(...))` 패턴, 즉 **MaterialApp의 `builder` 콜백**을 사용합니다. 새 테스트는 `home`+`Builder`로 우회한 형태라서, 향후 누군가 `MyApp`의 `builder` 인자를 실수로 제거하거나 위치를 옮겨도 그린일 수 있습니다.

권장(차단 아님): 테스트의 wrapper도 `MaterialApp.router(routerConfig: ..., builder: ...)` 패턴으로 정렬하면 코드 패스와 1:1 회귀 방지가 됩니다. 단 `MyApp` 자체는 Firebase 초기화에 의존해 직접 펌프가 어렵다는 점을 감안하면 현재 형태도 합리적 절충입니다.

### m-2. spec_11 본문과 코드 상수 불일치 사소 조정 필요

`lib/providers/font_size_provider.dart`는 0.86~1.33로 좁혔지만, `docs/planning/spec_11_senior_ui_enhancement.md`는 여전히 다음과 같이 기재되어 있습니다:

- §UI-11-04: "범위 0.8 ~ 1.4"
- §UI-11-06: "최소 0.8 시 11.2pt → 12pt 하한 적용", "최대 1.4 시 33.6pt → 32pt 상한 적용"
- TC-11-06/07: "scale 0.5 / 2.0 설정 시"

코드와 spec 텍스트의 표기를 일치시키는 편이 좋습니다 (예: "scale 범위를 0.86~1.33으로 사전 클램프하여 per-style cap 충족"). spec-first 원칙상 코드를 spec에 맞추거나 spec을 코드에 맞추거나 둘 중 하나로 통일 필요. M-3(고대비 토글) 강등 표기와 동일한 형태로 한 줄 보강이면 충분합니다.

### n-1. Slider divisions=6과 범위 0.86~1.33의 정합성 (Nit)

범위 폭이 0.47, divisions=6이면 step ≈ 0.0783. 기본값 1.0이 정확한 division 위치(0.86, 0.94, 1.02, …)에 떨어지지 않아, 초기화 후 슬라이더 손잡이가 division 사이에 표시될 수 있습니다. 시각상의 어색함만 있고 기능 영향은 없습니다. divisions를 변경하거나 step을 정수%로 맞추는 정도의 후속 정리만 권장.

---

## 머지 판정

**APPROVE**. Round 1 → Round 2 → Round 3에 걸쳐 Blocker 1건, Major 3건, 그 외 Minor/Nit가 모두 해소되었습니다. m-1·m-2·n-1은 차단 사유가 아니며 별도 PR 또는 후속 커밋에서 정리해도 무방합니다.

**검증 확인**:
- `flutter analyze`: 0 issues
- `flutter test`: 113/113 통과
- spec_11 P0 항목: 마스코트 3곳 배치 ✅, 동적 폰트 ✅(per-style cap 보장), 설정 화면 ✅, MyPage 메뉴 ✅. P1 강등된 고대비 토글은 차후 작업.

머지 진행하셔도 됩니다. AGENTS.md §3에 따라 최종 리뷰 승인 후 implementer가 master로 직접 머지 가능합니다. `docs/PROGRESS.md`의 spec_11 상태를 `✅ 완료`로 업데이트 부탁드립니다.
