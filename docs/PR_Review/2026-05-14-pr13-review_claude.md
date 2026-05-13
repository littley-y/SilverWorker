# PR #13 Code Review (Claude) — 2026-05-14

- **PR**: https://github.com/littley-y/SilverWorker/pull/13
- **Title**: `fix: PR #12 follow-up — 10 items addressed`
- **Head SHA**: `7ff1133443f50ea9fd3d7bd859bc1c4edc64d31d`
- **Branch**: `hotfix/job-detail-fixes` → `master`
- **Reviewer**: Claude (Opus 4.7)
- **Verdict**: **REQUEST CHANGES** — 5건 (Blocker 1 / Major 2 / Minor 2)

---

## 1. 분석 범위

- 리뷰 요청 문서: `docs/PR_Review/2026-05-14-pr13-request.md`
- 변경 파일 14개 (+795 / −702), 1 커밋 (`614bd5e`)
- 코어 검토 대상:
  - `lib/providers/job_provider.dart` (`visibleJobListProvider` 신규)
  - `lib/repositories/application_repository.dart` (`fetchApplications` 쿼리 변경)
  - `lib/screens/auth/phone_input_screen.dart` (E.164 정규화 변경)
  - `lib/screens/job/job_detail_screen.dart`, `lib/screens/job/job_list_screen.dart`
  - `firestore.indexes.json` (인덱스 정합성)
- 참조 스펙: `spec_02_auth.md`, `spec_03_job_data.md`, `spec_06_application.md`

---

## 2. 결함 목록

### Blocker

#### B-1. `PhoneInputScreen` E.164 정규화에서 한국 mobile 선두 `0` 제거 로직 삭제 — 실제 SMS 발송 시 Firebase Phone Auth가 번호를 거부

- **파일**: `lib/screens/auth/phone_input_screen.dart:41-43`
- **변경 diff**:
  ```dart
  // 이전 (정상)
  final normalized = digits.startsWith('0') ? digits.substring(1) : digits;
  final phoneNumber = '+82$normalized';   // → "+821012345678"  (12자, 정상 E.164)

  // 현재 (회귀)
  final phoneNumber = '+82$digits';        // → "+8201012345678" (14자, 잘못된 E.164)
  ```
- **근거**:
  - 입력 검증부(`phone_input_screen.dart:29-32`)는 `digits.length == 11 && digits.startsWith('010')` 을 통과한 값만 받아들임. 즉 `digits` 는 항상 선두 `0`을 포함한 11자.
  - ITU-T E.164 한국 국가 코드(+82) 규약: 가입자 번호의 *선두 trunk prefix `0`은 제거*. Firebase Phone Auth는 E.164 형식을 엄격히 강제하며 `+8201012345678`은 `invalid-phone-number`로 거부됨.
  - 변경 사유가 PR 요청서에 명시되지 않음("+82 prefix 로직 수정 (leading 0 자동 제거 제거)" 한 줄). 회귀로 판단.
- **테스트 통과 이유**: 122/122는 위젯/단위 테스트로 실제 Firebase 호출 없음. Firebase 테스트 전화번호는 형식 검증을 우회할 수 있으나, **운영 환경의 일반 번호는 SMS 발송 단계에서 즉시 차단**됨.
- **수정**: 이전 정규화 로직(`startsWith('0') ? substring(1) : digits`) 복원. 또는 `digits.startsWith('0') ? digits.substring(1) : digits` 를 utility 함수로 분리하여 회귀 방지.

### Major

#### M-1. `hasApplied(jobId)`가 cancelled 문서를 그대로 `true`로 반환 — `visibleJobListProvider`/`fetchApplications`와 상태 일관성 깨짐 + 무한 재취소 가능

- **파일**: `lib/repositories/application_repository.dart:55-64`
- **현상**: `hasApplied`는 `doc(jobId).exists`만 검사하므로 `status == 'cancelled'` 문서에도 `true` 반환.
- **이번 PR로 새로 발생한 상태 정합성 모순**:
  - `fetchApplications` (이번 PR): `status != 'cancelled'` 만 반환 → `visibleJobListProvider`의 `appliedIds` Set에서 cancelled 공고 *제외* → 홈 목록에 다시 노출됨.
  - `hasApplied` (변경 없음): cancelled 문서를 그대로 `true` 처리 → 공고 상세 진입 시 `_CancelButton`(빨강) 표시.
- **재현 시나리오** (시니어 사용자가 직면):
  1. 사용자가 공고 A 지원 → 취소.
  2. 홈에서 공고 A가 다시 노출됨 (정상, 재지원 가능 의도).
  3. 카드 탭 → 공고 상세 → 하단 버튼이 **"지원 취소"(빨강)** 로 표시 (`hasApplied=true`).
  4. 사용자가 "지원하기"를 기대했는데 빨간 취소 버튼만 봐서 혼란 → 탭 시 `cancelApplication` 호출 → snap.exists → `status: 'cancelled'` 재update + 플로팅 "지원이 취소되었습니다" 표시 → 사실상 *무의미한 재취소 루프*.
  5. PR #12 M-2(취소 후 재지원 가능 정책)가 사실상 무효화됨.
- **수정**: `hasApplied`에 동일 cancelled 가드 추가.
  ```dart
  Future<bool> hasApplied(String jobId) async {
    final snap = await _firestore...doc(jobId).get();
    if (!snap.exists) return false;
    return snap.data()?['status'] != 'cancelled';
  }
  ```
  이렇게 하면 cancelled 문서는 "미지원"으로 분류되어 상세 화면도 "지원하기" 버튼으로 일관 표시.

#### M-2. `fetchApplications`의 `isNotEqualTo + orderBy` 쿼리에 대한 Firestore 복합 인덱스가 `firestore.indexes.json`에 미선언 — 운영 첫 호출 시 `FAILED_PRECONDITION`

- **파일**: `lib/repositories/application_repository.dart:31-39`, `firestore.indexes.json`
- **쿼리**:
  ```dart
  .where('status', isNotEqualTo: 'cancelled')
  .orderBy('status')
  .orderBy('submittedAt', descending: true)
  ```
- **인덱스 요구**: `users/{uid}/applications` 서브컬렉션에 `(status ASC, submittedAt DESC)` 복합 인덱스 필요.
- **현재 `firestore.indexes.json`** (전수 확인): `jobs` 컬렉션 인덱스 4종만 존재. **`applications` 서브컬렉션 인덱스 0건**. PR 요청서 §3.2 "기존에 이미 배포됨" 기재는 사실과 부합하지 않거나, Console에서 수동 추가만 되어 *코드 형상관리에 없음*(disaster recovery / 신규 env 시 즉시 깨짐).
- **추가 부수 효과**: Firestore `isNotEqualTo`는 *해당 필드가 존재하지 않거나 null인 문서를 결과에서 자동 제외*함. 따라서 과거 데이터에 `status` 필드 누락 문서가 1개라도 있으면 마이페이지/홈 양쪽에서 동시에 사라짐 (조용한 데이터 손실).
- **수정 권장**:
  1. `firestore.indexes.json` 에 다음 추가 + `firebase deploy --only firestore:indexes`:
     ```json
     {
       "collectionGroup": "applications",
       "queryScope": "COLLECTION",
       "fields": [
         {"fieldPath": "status", "order": "ASCENDING"},
         {"fieldPath": "submittedAt", "order": "DESCENDING"}
       ]
     }
     ```
  2. 또는 더 안전한 *client-side filter*: 서버에선 정렬만 (`.orderBy('submittedAt', descending: true)`), `cancelled` 제외는 메모리에서 처리. 데이터셋 규모가 사용자당 수십~수백 건 수준이라 비용 문제 없음. 이 방법은 `status` null 문서 손실 위험도 동시 해소.

### Minor

#### m-1. `visibleJobListProvider`가 `on Exception`으로만 catch — Error 계열 미방어, graceful degradation 범위가 좁음

- **파일**: `lib/providers/job_provider.dart:31-38`
- **현상**: `Firestore`는 대부분 `FirebaseException`(Exception 구현체)을 throw하므로 정상 동작이지만, `StateError`/`TypeError`/`AssertionError` 등 `Error` 계열은 통과됨. 의도는 "applications 조회 실패해도 전체 공고는 보여주자"인데, 일부 비정상 상황(e.g., 캐스팅 실패)에서 사용자에게 빈 화면이 노출됨.
- **수정**: 의도된 좁은 catch라면 주석으로 명시 + `Exception` 로깅. 또는 `on Object` 로 확장.

#### m-2. `JobListScreen._ErrorState`의 retry가 `visibleJobListProvider`만 invalidate — 상위 `jobListProvider`/`myApplicationsProvider` 회복 불가

- **파일**: `lib/screens/job/job_list_screen.dart:71`
- **현상**: `visibleJobListProvider` 자체는 derive provider라 본인을 invalidate해도 *내부에서 read하는 두 provider*는 재호출되지만 캐시 무효화는 직접적이지 않음. 명시적으로 둘 다 invalidate하지 않아 retry가 "Firestore 실패 후 캐시된 실패 상태"를 새로고치지 못할 위험.
- **수정**:
  ```dart
  onRetry: () {
    ref.invalidate(jobListProvider);
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid != null) ref.invalidate(myApplicationsProvider(uid));
    ref.invalidate(visibleJobListProvider);
  }
  ```

### 확인했으나 결함 아닌 항목

- **`hasAppliedProvider` family 단순화** (`String jobId`): PR #12 M-1 권고 정확히 반영. `_CancelButton`의 invalidate 키도 일치.
- **`NoApplicationException` typed catch**: `_CancelButton`에서 `e is NoApplicationException` 분기 + 사용자 메시지 분기 적절.
- **`_CancelButton` 플로팅 성공 카드**: `Future.delayed` 콜백에 `if (mounted)` 가드 적용. AnimationController 미사용으로 dispose 누수 없음.
- **`MyPageScreen` 마스코트 제거**: 홈/마이페이지 마스코트 중복 노출 해소. 기능적 결함 없음.
- **`SettingsScreen` 글자 크기 섹션 제거**: 사용자가 조정 불가능한 정책이므로 빈 컨트롤 제거는 합리적. 단, *시니어 사용자가 "글자 크기 조절은 어디 있나"를 찾을 가능성*은 사용성 리스크로 남음 → spec_09/spec_16(접근성) 후속 검토 권장.
- **`seed_jobs.py walkingMinutes` 5~30분 랜덤**: 시니어 도보 한계(통상 평균 5km/h → 1km ≈ 12분) 고려 시 적절.

---

## 3. 결론

- **머지 차단 사유 (Blocker 1 + Major 2)**:
  - **B-1**: `+82` E.164 정규화에서 선두 `0` 제거가 사라져 *운영 환경의 모든 신규 가입 차단* 위험. 즉시 복원 필수.
  - **M-1**: `hasApplied`가 cancelled 문서를 `true`로 봄 → 취소 후 재지원 흐름이 사실상 막힘 + 무의미한 재취소 루프. 단순한 한 줄 수정.
  - **M-2**: `applications` 인덱스가 `firestore.indexes.json`에 미선언 → 신규 환경/CI/DR 시 첫 호출 폭발. JSON 추가 또는 client-side filter로 전환.
- **Minor 2건**은 머지 진행과 별개로 후속 정리 가능.

**다음 단계 권장**:
1. **B-1 즉시 수정**: `final normalized = digits.startsWith('0') ? digits.substring(1) : digits;` 복원 + 회귀 방지용 단위 테스트(`+82` 정규화 결과가 12자임을 assert).
2. **M-1 즉시 수정**: `hasApplied`에 `status != 'cancelled'` 가드.
3. **M-2 선택 수정**:
   - (권장) client-side filter로 변경 → 인덱스 불필요 + null safety 회복.
   - 또는 `firestore.indexes.json` 갱신 + 배포.

---

## 4. 참고

- 회귀 검증:
  - PR #12 M-1 (`hasAppliedProvider` userId 키): ✅ 정상 유지.
  - PR #12 M-2 (취소 후 재지원): ⚠️ `submitApplication`은 정상이나 `hasApplied`/`_CancelButton` 분기에서 **실질적으로 무효화** (본 PR M-1 참조).
  - PR #12 m-1 (`NoApplicationException`): ✅ 정상.
- AGENTS.md §1 STRICT_RULE에 따라 `IMPLEMENTER_PROMPT.md` 및 `docs/history/`는 미열람.
- 본 리뷰는 head `7ff1133` 기준. 이후 추가 커밋이 푸시되면 재검토 필요.
