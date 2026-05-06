# PR #3 Review (Round 2) — Claude

> **PR**: #3 — feat(job-data): Day 3 — Mock job data & Firestore repository (spec_03 path A)
> **Round**: 2 (re-review after `faf7348`)
> **Reviewer**: Claude
> **Date**: 2026-05-01
> **Decision**: ✅ **APPROVE**

---

## 1. 1차 리뷰 지적 사항 처리 확인

| ID | 등급 | 내용 | 수정 커밋 | 결과 |
|---|---|---|---|---|
| B-1 | 🔴 Blocker | `jobId` 유실 | `faf7348` | ✅ 해결 — `JobRepository.fetchJobs/fetchJobById` 모두 `JobModel.fromJson({...data, 'jobId': doc.id})`로 docID 주입. `test/models/job_model_test.dart`에 round-trip + injection + fallback 3 케이스 추가. |
| M-1 | 🟠 Major | 복합 필터 인덱스 미커버 | `faf7348` | ✅ 해결 — `firestore.indexes.json`에 `(locationCode, jobCategory, isActive, deadline)` 인덱스 4번째로 추가. |
| N-3 | Minor | Mock 회사명 톤 | `faf7348` | ✅ 개선 — `f"{title_prefix} {index}호 {suffix}"` (예: `아파트 경비원 5호 관리사무소`)로 사람이 읽을 만하게 변경. |
| N-4 | Minor | `random.seed` 미고정 | `faf7348` | ✅ 해결 — `generate_all(seed: int = 42)` 기본값 도입으로 재현성 확보. |
| N-1 | Nit | 미사용 `JobFilter` 필드 | — | 미수정 (선택 사항이라 머지 무방) |
| N-2 | Nit | `Object?` 캐스트 회피 | — | 미수정 (선택 사항) |
| N-5 | Nit | Repository 단위 테스트 | 부분적으로 | `JobModel` 테스트 신설로 모델 라운드트립은 커버. Repository fake 테스트는 spec_10에서 다뤄도 OK. |

---

## 2. Round 2 추가 검증

- ✅ `JobRepository.fetchJobs:39-42` — `{...data, 'jobId': doc.id}` 스프레드 순서 OK (data에 잔존 `jobId`가 있어도 `doc.id`가 덮어씀).
- ✅ `JobRepository.fetchJobById:52` — 동일 패턴 적용.
- ✅ `firestore.indexes.json` — 신규 인덱스의 필드 순서(`equality → equality → equality → range/order`)가 Firestore 규칙에 부합.
- ✅ `test/models/job_model_test.dart` — 3 케이스 모두 의미 있음. 특히 두 번째 테스트(주석에 `data.pop('jobId')` 시뮬레이션 명시)가 회귀 방지에 직접 작용.
- ✅ `seed_jobs.py:247-249` — `random.seed(seed)` 호출 위치가 모든 random 사용 이전. 결정성 보장.

⚠️ **운영 체크 (Implementer 확인 부탁)**:
1. 신규 `(locationCode, jobCategory, isActive, deadline)` 인덱스가 실제 Firebase 프로젝트에 `firebase deploy --only firestore:indexes`로 배포되었는지 확인. 콘솔에 BUILDING이 아닌 ENABLED 상태여야 spec_04에서 사용 가능.
2. `seed_jobs.py`로 재업로드했다면, 기존 30개 문서 위에 동일 docID로 덮어써졌을 것이므로(`batch.set`) 정상. 이전 회사명(`아파트_경비원_X_…`) 잔재 없이 모두 새 포맷으로 갱신되었는지 콘솔에서 한 건 확인 권장.

---

## 3. 결론

1차 Blocker / Major 이슈 모두 해결되었고 회귀 방지 테스트도 동반되었습니다. **APPROVE**합니다. 머지 후 Day 4 (spec_04: 공고 목록 UI) 진행해 주세요.

`docs/PROGRESS.md` spec_03 상태를 `✅ 완료`로 업데이트하고, "완료 이력"에 `JobRepository.doc.id 주입 + 복합 인덱스 추가` 한 줄 추가 권장.
