# PR #10 Code Review (Claude) — 2026-05-13

- **PR**: https://github.com/littley-y/SilverWorker/pull/10
- **Title**: `feat(spec_11): 시니어 특화 UI/UX 고도화`
- **Head SHA**: `7b57da43220868e9412ed196b39a38ca55318b28`
- **Branch**: `feature/spec-11-senior-ui`
- **Reviewer**: Claude (Opus 4.7)
- **Verdict**: **REQUEST CHANGES** — 6건 (Blocker 0 / Major 4 / Minor 2)

> 참고: 사용자가 명시적으로 새 리뷰를 요청(`docs/PR_Review/2026-05-13-pr11-request.md`)하여 진행. 이전 라운드(2026-05-12 R1~R3)는 별도 사이클이며 본 리뷰는 spec_12 코드를 포함한 현재 HEAD를 기준으로 함.

---

## 1. 분석 범위

- AGENTS.md / REVIEWER_PROMPT.md / spec_11 / spec_12 (signal: spec_*.md 우선)
- `gh pr diff 10` 전체 + HEAD 시점 파일 본문 (`gh api .../contents/...?ref=7b57da4`)
- `assets/mascot/` 디렉터리 실재 자산 목록
- 과거 PR #4 / #7 / #8 / #9 리뷰 로그 (`docs/PR_Review/*review*.md`)

## 2. 결함 목록

### Major

#### M-1. `MascotBanner`가 존재하지 않는 자산 참조 (`silver_dog.png`)

- **파일**: `lib/widgets/mascot_banner.dart:78-92`
- **현상**: `Image.asset('assets/mascot/silver_dog.png', ...)` 호출. 그러나 `assets/mascot/` 실제 디렉터리에는 `silver_bunny.png` 하나만 존재.
- **결과**: `errorBuilder`가 항상 작동 → 모든 사용자에게 `Icons.pets` fallback이 노출됨. 빌드 에러는 없으나 spec_12 홈 배너의 핵심 시각 요소가 의도대로 렌더되지 않음.
- **수정**: 경로를 `silver_bunny.png`로 통일하거나, `silver_dog.png` 자산을 실제로 추가.

```dart
// mascot_banner.dart:88
Image.asset(
  'assets/mascot/silver_dog.png',  // ← 존재하지 않음
  fit: BoxFit.contain,
  errorBuilder: ...,
)
```

#### M-2. `GrayChip` `fontSize: 13` — spec_09 §1 최소 14pt 위반

- **파일**: `lib/widgets/gray_chip.dart:21-30`
- **근거**: `lib/constants/app_text_styles.dart:7` dartdoc — `/// Minimum font size: 14pt. Smaller sizes are prohibited.`
- **사용처**: `JobCard` 메타 칩(구직형태·도보거리·D-day) — 모든 카드에서 노출되는 핵심 정보.
- **수정**: `fontSize: 14` 이상으로 상향 또는 `AppTextStyles.caption` (14pt) 재사용.

#### M-3. `FontSizeNotifier.minScale = 0.86` — caption을 ~12pt까지 축소 허용

- **파일**: `lib/providers/font_size_provider.dart:8-16`
- **현상**: 인라인 주석 `// caption 14pt × 0.86 ≈ 12pt 하한`이 직접 규정 위반을 인정.
- **영향**: 사용자가 슬라이더 최저값을 선택하면 앱 전역 텍스트가 14pt 미만으로 표시됨. spec_09 §1(시니어 가독성 14pt 하한)과 정면 충돌.
- **수정 옵션**:
  1. `minScale = 1.0` (축소 비허용)
  2. `minScale = 14/24 ≈ 0.59` 대신 caption만 비스케일링하는 별도 정책 도입
  3. spec_11에서 명시한 0.8~1.4 범위 vs 코드 0.86~1.33 불일치를 정리하면서 일관 정책 수립

#### M-4. spec_12 작업물이 spec_11 PR 안으로 섞여 머지 직전 추가됨

- **커밋**: `7b57da4 feat(spec_12): 홈 화면 UI 개선`
- **추가 파일**: `lib/widgets/mascot_banner.dart`, `gray_chip.dart`, `intensity_pill.dart`, `safety_curation_section.dart`, `docs/planning/spec_12_home_ui_refinement.md`, `docs/PR_Review/2026-05-13-pr11-request.md`, 관련 테스트.
- **근거**: AGENTS.md §3 — "Master Spec Priority: `docs/planning/spec_XX.md` is the source of truth". spec_11 DoD 파일 목록에 위 파일들은 존재하지 않음.
- **결과**: spec_11 R3 APPROVE 이후 별도 검토 없는 spec_12 코드가 동일 PR로 진입. 위 M-1/M-2가 모두 이 커밋에서 유입됨.
- **수정**: spec_12 변경분을 별도 PR로 분리하거나, 본 PR 제목/스코프를 spec_11+12 통합으로 명시하고 spec_12에 대한 별도 리뷰 사이클을 거칠 것.

### Minor

#### m-1. `docs/PROGRESS.md`가 머지 전 spec_11을 `✅ 완료`로 표기

- **파일**: `docs/PROGRESS.md:26`
- **근거**: REVIEWER_PROMPT §2 — "On approval: Update the Spec status in `docs/PROGRESS.md` to `✅ Completed`" (리뷰어 책임). 또한 AGENTS.md §3는 "After final review approval, the implementer may push/merge to master directly"라 명시하지만, 현재 PR은 오픈 상태.
- **수정**: 상태를 `🔄 Review Pending`으로 되돌릴 것.

#### m-2. 리뷰 요청 문서의 PR 번호 표기 오류

- **파일**: `docs/PR_Review/2026-05-12-pr10-request.md:3`, `docs/PR_Review/2026-05-12-pr11-request.md:3` (두 파일이 거의 동일 내용)
- **현상**: 본문에 `> PR 번호: #11 (예정)`로 기재되어 있으나 실제 PR은 #10. 동일 내용의 파일이 두 개 존재.
- **근거**: AGENTS.md §4 Pre-PR Checklist — 리뷰 요청 문서는 `YYYY-MM-DD-pr<N>-request.md`로 PR 번호와 일치해야 함.
- **수정**: 중복 파일 정리 + PR 번호를 `#10`으로 수정.

## 3. 확인했으나 결함 아닌 항목

- `FontSizeNotifier._load()`의 `mounted` 체크 부재: `StateNotifier`는 `mounted` 게터를 제공하므로 방어적 개선 여지는 있으나, 앱 lifetime 내 dispose 시나리오가 비현실적이라 실제 크래시 가능성 낮음. 후속 개선 대상.
- `phone_input_screen.dart`의 `await startVerification()` 직후 `verificationId` 읽기: Firebase Flutter 플러그인은 `verifyPhoneNumber`의 Future를 콜백 완료 후 resolve하므로 정상 동작. 라운드 1 리뷰에서도 통과됨.
- 북마크 관련 파일 삭제: 마스터에서 이미 정리된 항목, 본 PR diff는 base commit 차이로 인한 표시.

## 4. 결론

위 Major 4건(특히 M-1 자산 미스, M-3 폰트 하한 위반)이 머지 차단 사유. M-4 스코프 분리 여부는 팀 합의 사항이나, 분리하지 않을 경우 spec_11/12 통합 검토가 명시되어야 함.

게시된 GitHub 리뷰 코멘트:

- 1차(문서/프로세스): https://github.com/littley-y/SilverWorker/pull/10#issuecomment-4441854486
- 2차(코드): https://github.com/littley-y/SilverWorker/pull/10#issuecomment-4441940932
