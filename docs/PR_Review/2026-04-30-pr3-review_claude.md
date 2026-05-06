# PR #3 Review — Claude

> **PR**: #3 — feat(job-data): Day 3 — Mock job data & Firestore repository (spec_03 path A)
> **Branch**: `feature/day3-job-data` → `master`
> **Spec**: `docs/planning/spec_03_job_data.md`
> **Reviewer**: Claude
> **Date**: 2026-04-30
> **Decision**: 🔴 **REQUEST CHANGES** (1 Blocker + 1 Major)

---

## 1. 종합 판단

스펙 §2 Mock 30개 분포(종로 12 / 중 8 / 용 7 / 기타 3)와 필수 필드 커버리지는 정확히 충족됩니다. `firestore.rules`는 `/jobs` write false 정책을 유지하고, `serviceAccount.json` / `seed_jobs.json`은 `.gitignore`에 정상 등록되어 git tree에서 추적되지 않음을 확인했습니다(`git ls-files | grep -iE "serviceaccount|seed_jobs.json"` 결과 없음). `flutter analyze` 0경고도 OK.

다만 **데이터 라이프사이클에서 `jobId`가 유실**되는 BLOCKER 1건과, **복합 필터 시 인덱스 미커버** MAJOR 1건이 있어 머지 전 수정이 필요합니다.

---

## 2. Blocker

### B-1. `jobId` 필드가 Firestore 문서에 저장되지 않아 `JobModel.jobId`가 항상 빈 문자열이 됨

**위치**: `tools/scripts/seed_jobs.py:322` + `lib/repositories/job_repository.dart:38-41, 45-52` + `lib/models/job_model.dart:69`

`seed_jobs.py`는 업로드 직전에 `jobId`를 데이터에서 제거하고 document ID로만 사용합니다.

```python
doc_ref = db.collection("jobs").document(doc_id)  # doc_id = job["jobId"]
data.pop("jobId", None)        # ← 필드 자체가 사라짐
batch.set(doc_ref, data)
```

반면 `JobRepository.fetchJobs()` / `fetchJobById()`는 `doc.id`를 모델에 주입하지 않고 `doc.data()`만 `JobModel.fromJson`에 넘기며, `JobModel.fromJson`은 `json['jobId'] as String? ?? ''`로 폴백합니다. 즉 Firestore에서 읽어온 모든 `JobModel.jobId`는 `""`가 됩니다.

**파급**: spec_05(상세 화면 라우팅), spec_06(지원 시 jobId로 application 문서 생성), spec_07(북마크 — 이미 `BookmarkRepository.deleteBookmark`가 `jobId`를 키로 사용)가 모두 깨집니다. `flutter test` 8/8은 `address_data_test.dart`, `user_model_test.dart`만 검증할 뿐 `JobRepository`/`JobModel.fromJson` round-trip 테스트가 없어 이 결함이 잡히지 않았습니다.

**수정안 (둘 중 하나)**:

옵션 A — Repository에서 `doc.id`를 주입 (권장):
```dart
final data = doc.data()! as Map<String, dynamic>;
return JobModel.fromJson({...data, 'jobId': doc.id});
```
또는 `JobModel.fromFirestore(QueryDocumentSnapshot doc)` 팩토리를 도입(spec_03 §4 예시 코드와도 일치).

옵션 B — `seed_jobs.py`에서 `data.pop("jobId", None)`를 제거하여 필드와 docID를 동시 보유.

옵션 A를 권장합니다. Firestore의 정석은 docID를 source of truth로 두는 것이고, 향후 경로 B의 Cloud Functions 작성 코드에도 같은 규칙을 강제할 수 있습니다.

**회귀 방지**: `test/repositories/` 또는 `test/models/job_model_test.dart`에 `fromJson`이 docID 주입 시 `jobId`를 채우는지 단언하는 유닛 테스트 추가를 요청합니다.

---

## 3. Major

### M-1. `locationCode` + `jobCategory` 동시 필터 시 인덱스 미커버

**위치**: `firestore.indexes.json` + `lib/repositories/job_repository.dart:29-34`

`JobFilter`는 `locationCode`와 `jobCategory`를 동시에 지정 가능하지만, 배포된 인덱스는 단일 필터만 커버합니다.

| 쿼리 형태 | 필요 인덱스 | 배포됨? |
|---|---|---|
| isActive + deadline | (isActive, deadline) | ✅ |
| + locationCode | (locationCode, isActive, deadline) | ✅ |
| + jobCategory | (jobCategory, isActive, deadline) | ✅ |
| + locationCode + jobCategory | (locationCode, jobCategory, isActive, deadline) | ❌ |

spec_04(공고 목록 UI)에서 지역·직종 동시 필터가 사용될 가능성이 높으므로 (`overview/03_mvp_specs.md` 검색 시나리오 참고) 사전에 막아둡니다. 두 가지 방향 중 하나를 택해 주세요:

1. 인덱스 추가: `(locationCode ASC, jobCategory ASC, isActive ASC, deadline ASC)` 한 줄 추가 후 `firebase deploy --only firestore:indexes`.
2. 또는 `JobRepository.fetchJobs`에서 두 필터 동시 사용을 막고 둘 중 하나만 서버 쿼리, 나머지는 클라이언트 필터로 처리한다는 주석/검증을 추가.

운영에서 이 케이스가 발생하면 `failed-precondition` 예외와 함께 콘솔에 인덱스 자동생성 링크가 뜨지만, MVP 데모 중에 노출되면 시연 자체가 막힙니다.

---

## 4. Minor / Nit

### N-1. 사용되지 않는 `JobFilter` 필드 (`employmentType`, `physicalIntensity`)
`JobFilter`에 정의되어 있으나 `fetchJobs`에서 적용되지 않습니다. 의도가 "클라이언트 사이드 후처리"라면 doc comment에 명시해 주세요. 그렇지 않으면 spec_04~05에서 자연스럽게 dead field로 남습니다.

### N-2. `as Map<String, dynamic>` 캐스트 회피 가능
```dart
Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(_collection)...
```
로 제네릭을 명시하면 `doc.data()! as Map<String, dynamic>` 캐스트가 사라집니다. 또는 `withConverter<JobModel>`를 도입하면 `fromJson` 호출 자체가 깔끔해집니다(향후 spec_05~06 리팩터 시 고려).

### N-3. Mock 데이터 회사명·세부코드의 시연 가독성
`companyName`이 `아파트_경비원_1_관리사무소`처럼 underscore와 인덱스가 그대로 노출됩니다. spec_03 §2 예시(`OO아파트 관리사무소`) 톤과 다릅니다. 데모 화면에서 어색해 보일 수 있으니 `f"{title_prefix} {index}호 관리사무소"` 정도로 다듬어 주세요. `jobCategoryDetail`도 `apt_security` 식 코드 톤을 권장합니다.

### N-4. `seed_jobs.py` 재현성
`random.seed`가 고정되지 않아 실행마다 데이터가 달라집니다. 알려진 제한 사항 §3에 명시되어 있으나, `--seed <int>` 옵션을 추가해 두면 디버깅·리뷰 재현이 쉬워집니다. (선택)

### N-5. Repository 단위 테스트 부재
`fake_cloud_firestore` 또는 mocking으로 `fetchJobs(filter)` 경로를 한 줄이라도 검증해 두면 B-1·M-1 같은 결함을 다음번에 자동으로 잡아낼 수 있습니다. spec_10 도래 전이라도 도입을 권장합니다.

---

## 5. 스펙 / 데이터 일치 검증 (체크리스트)

- ✅ 분포: 종로 5+4+3=12 / 중 4+4=8 / 용 4+3=7 / 기타 1+1+1=3 = 30 (`seed_jobs.py:251-262`)
- ✅ `physicalBadges` 1~3개 (`BADGE_POOLS` 모든 엔트리 length 1~3)
- ✅ 사용 배지 도메인: `standing/sitting/heavy_lifting/outdoor/repetitive/stairs` — spec_03 §2와 일치
- ✅ `minAge ∈ {55,60,65}`, `maxAge ∈ {70,75,80}` — 시니어 범위 적합
- ✅ `firestore.rules` `/jobs` `allow write: if false` 유지 (Admin SDK는 rules bypass — 정상)
- ✅ `**/serviceAccount.json`, `**/seed_jobs.json` 미커밋
- ⚠️  `deadline`은 `_random_date_in_future(3, 60)` → 일부 문서가 3일 뒤 마감. 시연 직전 expiry로 `isActive` 필터에서 누락될 수 있음 — 데모 안정성을 위해 최소 14일 정도 권장.

---

## 6. 결론

**Blocker B-1**(`jobId` 유실)과 **Major M-1**(복합 인덱스 미커버) 수정 후 재리뷰 요청 부탁드립니다. 나머지 N-x는 선택 사항이며 머지를 막지 않습니다.

수정 완료 시 다음을 함께 첨부해 주세요:
1. `JobModel.fromJson` round-trip 테스트 또는 Repository fake test
2. `firestore.indexes.json` 갱신 후 `firebase deploy` 결과
3. 갱신된 시드 데이터의 Firestore 콘솔 스크린샷(혹은 `gcloud firestore documents list` 발췌) — 첫 문서에 `jobId` 필드가 보이는지 확인용 (옵션 B 채택 시)
