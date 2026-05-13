# PR #12 Code Review (Claude) — 2026-05-14

- **PR**: https://github.com/littley-y/SilverWorker/pull/12
- **Title**: `feat(ui): redesign job detail, add cancel flow, lock font scale`
- **Head SHA**: `aa6021ba00cfcdb712988487e8177ee1edf188d4`
- **Branch**: `hotfix/job-detail-redesign` → `master`
- **Reviewer**: Claude (Opus 4.7)
- **Verdict**: **REQUEST CHANGES** — 5건 (Blocker 0 / Major 3 / Minor 2)

---

## 1. 분석 범위

- 리뷰 요청 문서: `docs/PR_Review/2026-05-14-pr12-request.md`
- 변경 파일 32개 (+2,676 / −1,445), 두 커밋: `17c646c`(메인 개편) + `aa6021b`(마스코트)
- 관련 스펙: `spec_05_job_detail.md`, `spec_06_application.md`, `spec_09_ui_system.md`, `spec_11_senior_ui_enhancement.md`
- 코어 검토 대상:
  - `lib/screens/job/job_detail_screen.dart`
  - `lib/providers/application_provider.dart`
  - `lib/repositories/application_repository.dart`
  - `lib/providers/font_size_provider.dart`
  - `lib/widgets/mascot_banner.dart`, `lib/screens/mypage/application_list_screen.dart`
- 자산 확인: `assets/mascot/silver_dog.png` 실재(이전 PR #10 M-1 회귀 차단 확인), `pubspec.yaml`에 `assets/mascot/` 등록됨.

---

## 2. 결함 목록

### Major

#### M-1. `hasAppliedProvider`의 `userId` 파라미터가 실제 조회에 무시됨 — Riverpod 캐시 키와 데이터 불일치

- **파일**: `lib/providers/application_provider.dart:18-21`, `lib/repositories/application_repository.dart:51-60`
- **현상**:
  ```dart
  // application_provider.dart
  final hasAppliedProvider =
      FutureProvider.family<bool, ({String userId, String jobId})>((ref, params) {
    return ref.read(applicationRepositoryProvider).hasApplied(params.jobId);
    //                                                       ^^^^^^^^^^^^^^^
    //                                       params.userId 는 캐시 키로만 쓰이고 실제 조회에 미사용
  });

  // application_repository.dart
  Future<bool> hasApplied(String jobId) async {
    final uid = _requireAuth.uid;  // ← family 파라미터의 userId 대신 currentUser 사용
    ...
  }
  ```
- **영향**:
  1. Riverpod family 캐시 키는 `(userId, jobId)`로 분리되지만, repository는 `_auth.currentUser`만 본다. 다른 `userId`로 호출해도 같은 결과가 캐시별로 중복 저장됨.
  2. `_CancelButton` 분기(`job_detail_screen.dart:469-474`)에서 invalidate 키를 `(userId: authStateProvider.value!.uid, jobId: ...)`로 정확히 맞추지 못하면 stale `true`가 남아 취소 후에도 "지원 취소" 버튼이 표시될 위험.
  3. 추후 관리자/대리 조회 등 multi-user 시나리오에서 silent bug 됨.
- **수정안**: `family` 파라미터에서 `userId`를 제거하고 `String jobId`만 키로 사용하거나, `hasApplied(String userId, String jobId)`로 인자 정합화 후 repository에서 명시 인자를 사용. 후자가 일관성 측면에서 권장.

#### M-2. 취소 후 동일 공고 재지원이 영구 불가 — 문서 keying 정책과 cancel의 부정합

- **파일**: `lib/repositories/application_repository.dart:62-99` (`submitApplication`), `101-119` (`cancelApplication`)
- **현상**:
  - `submitApplication`은 `_firestore.collection('users').doc(uid).collection('applications').doc(jobId)`를 사용하며, 트랜잭션 내에서 `if (snap.exists) throw AlreadyAppliedException()`.
  - `cancelApplication`은 같은 doc을 **삭제하지 않고** `status: 'cancelled'`로 update만 수행.
  - 결과: 사용자가 한 번 지원 → 취소 후, 동일 jobId의 doc은 status=`cancelled` 상태로 잔존 → 이후 재지원 시 `snap.exists`가 true → `AlreadyAppliedException` 발생.
- **근거**:
  - spec_06 §5는 "확인 시 ... 상태를 'cancelled'로 업데이트"만 규정, 재지원 가능 여부 미명시. 그러나 UX 관점에서 "취소"의 통상적 의미는 *원상 복귀 + 재지원 가능*.
  - spec_06 §3의 예시는 `.add()`(autoId)와 `.where('jobId', ...)` 기반이라 실제 구현(doc(jobId)) 과는 다른 정책. 따라서 cancel 정책도 명시되어야 함.
- **수정안 (택1)**:
  1. `cancelApplication`을 `ref.delete()`로 변경하고, 지원 내역 표시를 위해 history 서브컬렉션에 보존.
  2. `submitApplication`의 존재 체크를 `snap.exists && snap.data()?['status'] != 'cancelled'`로 변경 + tx.set 시 status 갱신(`merge` 또는 set 새 본문).
  3. 재지원 불가가 정책이라면 spec_06에 명시 + 클라이언트 측에서 카드 탭 시 "취소된 공고로 재지원 불가" 안내.

#### M-3. 스코프 폭증 + 브랜치명 불일치: `hotfix/`로 명명된 단일 PR이 spec_05 전면 개편·spec_06 신규 흐름·spec_11 정책 reversal·마스코트 자산·spec 번호 재정렬을 한꺼번에 포함

- **브랜치/제목**: `hotfix/job-detail-redesign` / `feat(ui): redesign job detail, add cancel flow, lock font scale`
- **포함 변경**:
  - `JobDetailScreen` 전면 재설계(2×2 그리드 + 상세 카드 + 강도 카드, 복리후생 제거)
  - 지원 취소 플로우 신규 (`cancelApplication`, `hasAppliedProvider`, 빨강 취소 버튼)
  - `JobModel.workHoursPerDay`, `displayTitle` 추가 (Firestore 스키마 영향)
  - 글자 크기 정책 변경: `0.86~1.33` 가변 → `1.3` 고정 (spec_11 핵심 산출물의 사실상 reversal)
  - 마스코트 자산 교체(`silver_bunny.png` → `silver_dog.png`) + Banner/Widget 애니메이션 재작성
  - 목업 데이터 회사명 일괄 교체(`tools/scripts/update_seed_data.py` 신규 153줄, `seed_jobs.py` 변경)
  - **스펙 번호 재배치**: `spec_15_condition_matching.md` 삭제, `spec_16→15`, `spec_17→16` 리네임 (다운스트림 참조 영향)
  - 디자인 산출물 커밋: `docs/mockup_before_after.html` (458줄), `docs/은일이.jpg`
- **근거 위반**:
  - AGENTS.md §3 — "Master Spec Priority: `spec_*.md` is the source of truth". spec 번호 재배치는 단일 PR이 책임지기에 위험(외부 참조/링크/PROGRESS.md 의존).
  - 브랜치명이 `hotfix/`인데 실 변경은 신규 기능 + 정책 변경 + 문서 재배열. 후속 cherry-pick/revert 운용 곤란.
  - spec_11에서 R1~R2 검토를 거쳐 확정된 가변 폰트 시스템(`FontSizeNotifier minScale=0.86`, `SettingsScreen` Slider)을 동일 검토 사이클 없이 본 PR에서 단방향 폐기. 이는 PR #10 M-3에 대한 사실상의 정답이지만, 별 PR로 분리하여 명시적 정책 변경 사유와 함께 머지되는 편이 옳음.
- **수정안 (택1)**:
  1. 본 PR을 그대로 통합 머지하되, 브랜치/제목을 `feat/job-detail-and-policy-overhaul` 류로 정정하고, 본문에 "spec_11 폰트 정책 reversal", "spec 번호 재배치" 두 항목을 *명시적 변경 결정*으로 기재.
  2. 또는 (1) JobDetail 리디자인 + 취소 플로우, (2) 폰트 고정 정책 reversal + spec_11 갱신, (3) 마스코트/시드/스펙 번호 정리 — 3개 PR로 분리.

### Minor

#### m-1. `cancelApplication`이 `Exception('지원 내역이 없습니다')` 비타입 예외 사용 — sealed 위계 깨짐

- **파일**: `lib/repositories/application_repository.dart:111-113`
- **현상**: 같은 파일에 `sealed class ApplicationException` + `NotAuthenticated / AlreadyApplied / JobClosed / JobNotFound` 4종이 정의되어 있으나, cancel만 raw `Exception` 사용.
- **결과**: UI(`_CancelButton`)에서 catch 분기 시 타입 식별 불가, 메시지 매칭에 의존. `try/catch (e) { ScaffoldMessenger ... '취소에 실패했습니다: $e' }`가 사용자에게 raw 문자열 노출 가능.
- **수정안**: `NoApplicationException` 추가 후 sealed 패턴 매칭. spec_06 §5의 예시 코드도 함께 갱신 필요.

#### m-2. `PROGRESS.md`가 머지 전 본 PR 변경을 사실상 "완료 이력"에 기재 + spec_15/16 상태 라인 갱신

- **파일**: `docs/PROGRESS.md:73` (`2026-05-14` 항목 추가)
- **근거**: REVIEWER_PROMPT §2 — "On approval: Update the Spec status in `docs/PROGRESS.md` to `✅ Completed`"는 리뷰어 책임. PR #10 / #11 리뷰에서도 동일 지적이 반복됨.
- **수정안**: 머지 이전엔 본 변경분을 `🔄 Review Pending`만 표기, "완료 이력" 추가는 승인 후로 이전.

### 확인했으나 결함 아닌 항목

- **silver_dog.png 자산 실재**: `assets/mascot/` 디렉터리에 `silver_dog.png`, `silver_bunny.png` 두 파일 존재. PR #10 M-1(자산 미스) 회귀 차단됨.
- **`pubspec.yaml` 자산 등록**: `assets: - assets/mascot/` 디렉터리 일괄 등록되어 추가 등록 불필요.
- **`MascotBanner.AnimationController` dispose**: `dispose()`에서 `_floatController.dispose()` 호출, `Future.delayed` 콜백 내 `if (mounted)` 가드 적용 — 누수/크래시 위험 없음.
- **`BuildContext` async gap**: `_CancelButton` 내 `await showDialog` / `await cancelApplication` 이후 모든 `context` 사용처에 `if (mounted)` 가드 존재.
- **`GrayChip` 14pt**: 본 PR diff 외이지만 PR #10 M-2 회귀 차단 확인됨(`gray_chip.dart:25` `fontSize: 14`).
- **`FontSizeNotifier.setScale` 사실상 no-op**: 정책상 고정값이므로 의도된 동작. 단, 호출처가 없는 경우 dead-code 정리 권고(별도 PR로 처리해도 무방).

---

## 3. 결론

- **머지 차단 사유(Major 3)**:
  - M-1: `hasAppliedProvider` 캐시 키와 실 조회의 불일치 — Riverpod 캐시 정합성 깨짐, multi-user/대리 시나리오에서 latent bug.
  - M-2: 취소 후 재지원 영구 불가 — 사용자가 즉시 부딪치는 UX 결함. 정책이라면 spec 명시 + UI 안내 필요.
  - M-3: 단일 PR에 스펙 번호 재배치·정책 reversal·신규 기능·자산 교체가 혼재 — 리뷰/되돌리기 비용이 큼.
- **Minor 2건**은 머지 진행과 별개로 후속 정리.

**다음 단계 권장**:
1. M-1: `hasAppliedProvider` family 시그니처를 `String jobId`로 축소하거나 repository에 `userId` 인자 통과.
2. M-2: 정책 선택(재지원 허용 vs. 영구 차단) → 선택에 따라 코드/스펙/UX 안내 동시 갱신.
3. M-3: 최소한 PR 제목/브랜치명 정정 + 본문에 *정책 reversal 결정*과 *spec 번호 재배치 사유*를 명시.

---

## 4. 참고

- PR #10 / #11에서 지적된 항목 회귀 여부:
  - PR #10 M-1 (`silver_dog.png` 누락) → ✅ 해소됨.
  - PR #10 M-2 (`GrayChip fontSize 13`) → ✅ 해소됨(`fontSize: 14`).
  - PR #10 M-3 (`FontSizeNotifier minScale 0.86` 14pt 미만 허용) → ✅ 본 PR에서 `1.3` 고정으로 사실상 해소 (단 M-3 스코프 이슈 참고).
- AGENTS.md §1 STRICT_RULE에 따라 `IMPLEMENTER_PROMPT.md` 및 `docs/history/`는 미열람.
- 본 리뷰는 head `aa6021b` 기준이며, 이후 추가 커밋이 푸시되면 재검토 필요.
