# PR #4 Review Round 2 (Claude) — Day 4: 공고 목록 UI

- **PR**: [#4](https://github.com/littley-y/SilverWorker/pull/4) `feature/day4-job-list-ui` → `master`
- **대상 커밋**: `fc59d48` (fix(review): resolve PR #4 review feedback)
- **리뷰어**: Claude (Reviewer)
- **날짜**: 2026-05-05
- **결과**: 🟢 **Approve** — 1차 리뷰 지적 사항 전부 해결, 머지 가능

---

## 1차 지적 사항 해결 검증

| ID | 등급 | 해결 여부 | 검증 근거 |
|---|---|---|---|
| **B-1** 시급/일급 금액 손실 | 🔴 Blocker | ✅ 해결 | `lib/widgets/job_card.dart:89-104` — `salaryType` 별 분기. hourly → "시급 12,000원", daily → "일급 80,000원", monthly 만 만원 단위 유지. `intl.NumberFormat('#,###')` 적용. 회귀 테스트 2건(`test/widgets/job_card_test.dart` "hourly", "daily") 추가. |
| **M-1** 12pt 폰트 하한 위반 | 🟠 Major | ✅ 해결 | `_EmploymentTypeChip` → `AppTextStyles.caption` (14pt), padding `vertical: 4 → 6` 으로 카드 높이 흡수. `_IntensityBadge` 텍스트 14pt + 아이콘 16dp 로 상향. spec_09 §1 14pt 하한 충족. |
| **M-2** copyWith null 재설정 불가 | 🟠 Major | ✅ 해결 | `lib/models/job_filter.dart:6, 25-49` — `_unset` sentinel 패턴 도입. `FilterBar` (`lib/widgets/filter_bar.dart:48, 58`) 가 직접 생성 우회 코드 제거하고 `currentFilter.copyWith(...)` 호출로 정리. `code: null` 전달 시 정상 클리어 동작. |
| **m-1** AppBar headline 클리핑 | 🟡 Minor | ✅ 해결 | `lib/screens/job/job_list_screen.dart:26` — `toolbarHeight: 64` 명시. |
| **m-2** 스켈레톤 색상 옅음 | 🟡 Minor | ✅ 해결 | `lib/constants/app_colors.dart:21` — `skeleton = Color(0xFFCCCCCC)` 신설, 4 군데 모두 적용. |
| **n-2** JobListScreen 상태 테스트 부재 | 🟢 Nit | ✅ 해결 | `test/widgets/job_list_screen_test.dart` 신규 — empty / error / data / AppBar / FilterBar 5건. `ProviderScope.overrides` 로 `jobListProvider` 오버라이드 패턴 정확. |

### 미처리 항목 — 사유 인정
- **m-3** Roboto → NotoSansKR: spec_09 마무리 단계(Day 11)에서 처리. 본 PR 의 권고는 "추적 항목" 이었으므로 별도 이슈 등록만 확인되면 충분.
- **n-1** `_formatSalary`/`_formatDeadline` model getter 이전: 선택 사항. 후속 PR 가능.

---

## 2차 검증 (실행 결과)

```
flutter analyze     → No issues found!
flutter test        → 33/33 passed (기존 26 + 신규 7)
```

다음 항목들은 코드 직접 검토로 확인:

- `JobFilter.copyWith` sentinel: `_unset == _unset` (identical Object 인스턴스) 비교가 Dart 에서 안전하게 동작. `Object?` 타입으로 받은 뒤 `as String?` / `as bool?` 캐스트 시 사용자가 잘못된 타입을 넘길 가능성은 named 파라미터 시그니처 문서화로 충분히 방어됨. ✅
- `FilterBar` 호출부: `currentFilter.copyWith(locationCode: code)` — `code` 가 `String?` 이고 `Object?` 슬롯에 들어가도 sentinel 분기에서 `code as String?` 캐스트가 안전. ✅
- 회귀 테스트가 실제 mock 데이터 케이스를 직접 반영(`salaryAmount: 12000`, `salaryAmount: 80000`). seed_jobs.json 의 시급 데이터(12,000/14,000/15,000)에 동일 포맷 적용 시 정확한 표시 보장. ✅
- 스켈레톤 색 #CCCCCC 는 배경 #F5F5F5 대비 약 1.36:1 — 비텍스트 시각 요소이므로 WCAG 1.4.11 (3:1) 의 엄격한 적용 대상은 아니지만 1차보다 대비가 충분히 개선됨. ✅

---

## 추가 발견 (신규 — Nit only, 머지 비차단)

### n-3. (Nit) `JobFilter.copyWith` 의 sentinel 패턴 — `Object?` 슬롯 타입 안전성 보강 가능

`lib/models/job_filter.dart:25-29` — 호출자가 실수로 `copyWith(locationCode: 123)` 같은 잘못된 타입을 전달하면 런타임 `TypeError` 가 발생합니다(컴파일 타임 검출 불가). 이는 sentinel 패턴 자체의 한계로, 본 프로젝트 규모에서는 수용 가능. 다만 향후 모델이 늘어날 경우 [`freezed`](https://pub.dev/packages/freezed) 같은 코드 생성기 도입을 권고합니다 (선택, 후속 PR).

### n-4. (Nit) JobListScreen 에러 상태 테스트 — 콘솔 노이즈

`test/widgets/job_list_screen_test.dart:33-49` 의 error 케이스는 `Future.error(Exception(...))` 를 사용하는데, Riverpod 의 기본 `errorHandler` 가 `flutter test` 콘솔에 `FlutterError: Exception: Network error` 를 출력합니다(테스트는 통과). 차후 `runZonedGuarded` 또는 `FlutterError.onError` 일시 무음 처리로 정리 가능 (선택).

---

## 양호한 부분 (Keep doing)

- 1차 리뷰 6개 항목 전부에 대해 **회귀 방지 코드/테스트가 함께 들어옴**. 특히 B-1 의 hourly·daily 분기 테스트와 n-2 의 5종 상태 테스트는 향후 변경 시 안전망으로 작동.
- copyWith sentinel 패턴이 1차 리뷰에서 제안한 그대로 정확히 구현됨 + 호출부까지 정리되어 의도치 않은 사일런트 버그 가능성이 일관되게 제거됨.
- `AppColors.skeleton` 을 별도 색상 토큰으로 분리 — `divider` 의 의미(경계선)와 `skeleton` 의 의미(로딩 placeholder)를 분리한 점이 디자인 시스템 관점에서 적절.
- `_EmploymentTypeChip` 폰트 키움 + 패딩 보정으로 카드 레이아웃이 깨지지 않게 처리한 미세 조정 양호.

---

## 머지 권고

🟢 **Approve**.

- `flutter analyze` / `flutter test` 모두 클린.
- spec_04 §1~5 + spec_09 §1~2 DoD 모두 충족.
- 1차 리뷰 모든 Blocker / Major / 처리 약속한 Minor·Nit 해결.
- m-3 / n-1 / n-3 / n-4 는 본 PR 머지 비차단.

PROGRESS.md 의 spec_04 상태를 `✅ 완료` 로 갱신하고 머지 진행하시면 됩니다. spec_09 는 Day 11 마무리분이 남아있으므로 `🔄 진행 중` 유지.
