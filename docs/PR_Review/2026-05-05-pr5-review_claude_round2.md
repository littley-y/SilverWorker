# PR #5 Review Round 2 (Claude) — Day 5: 공고 상세 + 세이프티 큐레이션

- **PR**: [#5](https://github.com/littley-y/SilverWorker/pull/5) `feature/day5-job-detail` → `master`
- **대상 커밋**: `26ca18c` (fix(review): resolve PR #5 review feedback)
- **리뷰어**: Claude (Reviewer)
- **날짜**: 2026-05-05
- **결과**: 🟢 **Approve** — 1차 지적 사항 전부 해결, 머지 가능

---

## 1차 지적 사항 해결 검증

| ID | 등급 | 처리 | 검증 근거 |
|---|---|---|---|
| **M-1** "지원하기" 무반응 | 🟠 Major | ✅ | `lib/screens/job/job_detail_screen.dart:109-113` — `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('지원 기능은 곧 제공될 예정입니다')))`. `_JobDetailBody` 가 `BuildContext` 를 직접 보유한 상태에서 호출하므로 Scaffold ancestor 정상. |
| **m-1** `_formatSalary` 코드 중복 | 🟡 Minor | ✅ | `lib/models/job_model.dart:192-201` — `formattedSalary` getter 추가, NumberFormat + switch expression 으로 단일 진실 공급원. `JobCard`(`job_card.dart:47`), `_HeaderSection`(`job_detail_screen.dart:147`), `_WorkConditionSection`(`job_detail_screen.dart:176`) 모두 호출. PR #4 에서부터 끌려온 잔존 nit 가 본 PR 에서 정리됨. |
| **m-2** 에러 상태 재시도 누락 | 🟡 Minor | ✅ | `job_detail_screen.dart:33-50` — Icon(48dp error_outline) + 메시지(`AppTextStyles.body`) + "다시 시도"(56dp primary) + `ref.invalidate(jobDetailProvider(jobId))`. `JobListScreen` 의 `_ErrorState` 패턴과 시각적으로 일치. |
| **m-3** 시급/일급 회귀 누락 | 🟡 Minor | ✅ | `test/widgets/job_detail_screen_test.dart:138-219` — "JobDetailScreen shows hourly salary correctly" + "shows daily salary correctly" 2건. `salaryAmount: 12000` → "시급 12,000원", `salaryAmount: 80000` → "일급 80,000원" 검증. |
| **m-4** 화이트스페이스 처리 | 🟡 Minor | ✅ | `job_detail_screen.dart:223` — `content.trim().isNotEmpty`. |
| **n-1** private static 호출 | 🟢 Nit | ✅ | m-1 해결로 자동 소멸. `_HeaderSection._formatSalary` 메서드 자체가 제거됨. |

### 미처리 항목 — 사유 인정
- **n-2** `foregroundColor: Colors.white` 중복: `AppTextStyles.button` 의 `Colors.white` 와 중복이지만 ripple 색상에 영향 있어 의도된 부분. 머지 비차단.
- **n-3** 알 수 없는 `physicalIntensity` 폴백 시 색·라벨 의미 충돌: 본 mock 데이터 범위에서 발생하지 않음. JobModel `fromJson` 화이트리스트 검사와 묶어 후속 PR 가능.

---

## 2차 검증 (실행 결과)

```
flutter analyze     → No issues found!
flutter test        → 44/44 passed (기존 42 + 신규 2)
```

추가 코드 직접 검토:

- `JobModel.formattedSalary` 가 model 레벨로 올라가면서 `intl` 의존이 `widgets/` → `models/` 로 이동. `JobCard` 의 `intl` import 제거됨(`job_card.dart:1` diff). 의존 그래프 정리도 함께 이뤄짐. ✅
- SnackBar 호출부의 `context` 는 `_JobDetailBody.build` 의 인자 — `Scaffold` ancestor 가 `JobDetailScreen` 의 `Scaffold` 라 정상 발견. ✅
- `ref.invalidate(jobDetailProvider(jobId))` 는 `family` provider 인스턴스 단위로 무효화 → 다른 jobId 의 캐시는 보존. 정확한 사용. ✅
- 에러 상태의 "다시 시도" 버튼이 `AppTextStyles.button` (20pt bold) + 56dp 높이로 spec_09 §3 CTA 기준 충족. ✅

---

## Spec DoD 최종 충족

| DoD | 결과 |
|---|---|
| 카드 탭 → 상세 진입 | ✅ |
| physicalIntensity 색·텍스트 | ✅ |
| physicalBadges 1개+ 표시 | ✅ |
| 하단 버튼 스크롤 시 고정 (탭 시 안내 SnackBar) | ✅ |
| 뒤로가기 복귀 | ✅ |
| 14pt 미만 텍스트 없음 (spec_09) | ✅ |

---

## 양호한 부분 (Keep doing)

- 1차 리뷰 6개 항목 전부 + Gemini 의 N-1 까지 단일 fix 커밋(`26ca18c`)으로 일괄 처리. 회귀 테스트도 함께 추가됨.
- m-1 의 `formattedSalary` getter 이전이 PR #4 부터 누적된 코드 부채를 깨끗이 청산. 향후 spec_06/07 에서도 같은 getter 재사용 가능 — 디자인 시스템적으로 정확한 방향.
- 에러 상태 위젯이 `JobListScreen._ErrorState` 와 시각적으로 통일됨. (차후 공통 위젯 추출 여지 있음 — 본 PR 비차단)
- M-1 의 SnackBar 안내 메시지("지원 기능은 곧 제공될 예정입니다") 가 시니어 사용자에게 명확한 기대치를 전달.

---

## 머지 권고

🟢 **Approve**.

- `flutter analyze` / `flutter test` 클린.
- spec_05 §1~4 + DoD 5/5 충족.
- 1차 Major / Minor 전부 해결, 잔존 nit 2건은 머지 비차단.

PROGRESS.md 의 spec_05 상태를 `✅ 완료` 로 갱신하고 머지 진행하시면 됩니다.
