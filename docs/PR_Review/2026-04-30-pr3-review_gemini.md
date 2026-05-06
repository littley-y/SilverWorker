# PR #3 Review Report — Gemini

**Status**: ❌ CHANGES REQUESTED  
**Date**: 2026-04-30  
**Target Spec**: `docs/planning/spec_03_job_data.md`

---

## 1. 종합 평점

| 항목 | 평점 | 비고 |
|:---|:---:|:---|
| **명세 충실도** | 🌕🌕🌕🌑🌑 | Mock 데이터 구성은 완벽하나, 기능적 데이터 정합성 결여 |
| **코드 품질** | 🌕🌕🌕🌑🌑 | Firestore 쿼리 패턴 및 타입 처리 보완 필요 |
| **보안/설정** | 🌕🌕🌕🌕🌕 | .gitignore 및 Firestore Rules 설정 완벽 |
| **검증 수준** | 🌕🌕🌕🌕🌑 | 유닛 테스트 100%이나 Repository 통합 테스트 누락 |

---

## 2. 주요 리뷰 의견

### 2.1 Blocker (수정 필수)

#### ① JobModel.jobId 누락 이슈
- **발견**: `seed_jobs.py`에서 업로드 시 `jobId` 필드를 `pop()`하여 문서 바디에서 제외합니다. 이는 Firestore Best Practice(ID 중복 방지)에 부합하나, `JobRepository.fetchJobs`에서 `doc.id`를 모델에 주입하지 않고 `doc.data()`만 넘기고 있습니다.
- **결과**: `JobModel.fromJson`의 폴백 로직에 의해 모든 공고의 `jobId`가 `""`로 로드됩니다.
- **파급**: spec_05(상세 화면), spec_06(지원하기), spec_07(북마크) 등 공고 ID를 식별자로 사용하는 모든 기능이 동작하지 않게 됩니다.
- **수정 제안**: `JobRepository`에서 데이터를 변환할 때 `doc.id`를 수동으로 주입하거나, `JobModel`에 `fromFirestore` 팩토리를 추가하십시오.

#### ② 복합 인덱스 누락 (다중 필터링 시)
- **발견**: `fetchJobs()`는 `locationCode`와 `jobCategory`를 동시에 필터링할 수 있도록 구현되어 있으나, `firestore.indexes.json`에는 두 필드가 동시에 포함된 복합 인덱스가 없습니다.
- **결과**: 사용자가 지역과 직종을 모두 선택하고 검색할 경우 Firestore에서 `FAILED_PRECONDITION` 에러가 발생하며 앱이 중지됩니다.
- **수정 제안**: `locationCode ASC, jobCategory ASC, isActive ASC, deadline ASC` 조합의 인덱스를 추가하십시오.

### 2.2 Major (권장 사항)

#### ① withConverter 도입 권장
- **의견**: 현재 `doc.data()! as Map<String, dynamic>`와 같이 강제 캐스팅을 사용하고 있습니다. `withConverter<JobModel>`을 사용하면 Repository 코드가 훨씬 간결해지고, ID 주입 로직을 한 곳(converter)에서 처리할 수 있어 타입 안전성이 향상됩니다.

#### ② 에러 처리 세분화
- **의견**: Firestore 쿼리 실패(인덱스 미비, 권한 오류 등) 시 현재는 예외가 그대로 전파됩니다. 사용자에게 친숙한 에러 메시지를 제공하기 위해 커스텀 Exception으로 래핑하는 것을 고려해 보십시오.

### 2.3 Minor / Nit

- **seed_jobs.py 시드 고정**: 현재 랜덤 생성이므로 실행 시마다 데이터가 변합니다. `random.seed(42)` 등을 사용하여 재현 가능한 Mock 데이터를 생성하면 테스트 안정성에 도움이 됩니다.

---

## 3. 항목별 검토 결과

| 항목 | 검토 내용 | 결과 |
|:---|:---|:---:|
| **Firestore 쿼리** | `where` 체이닝 및 `orderBy` 정렬 순서 적절함 (인덱스 부족 제외) | ⚠️ 보완 |
| **Mock 데이터 품질** | 지역별 분포(12:8:7:3) 및 연령대, 배지 조합 요구사항 완벽 준수 | ✅ 통과 |
| **보안 설정** | `serviceAccount.json`, `seed_jobs.json` 커밋 방지 확인 | ✅ 통과 |
| **Firestore Rules** | `/jobs` 컬렉션 쓰기 차단 설정 확인 | ✅ 통과 |
| **Riverpod 연동** | `jobRepositoryProvider`를 통한 전역 접근 구조 적절 | ✅ 통과 |

---

## 4. 실행 가이드 (Implementer)

1. `lib/repositories/job_repository.dart`에서 문서 ID 주입 로직 추가.
2. `firestore.indexes.json`에 다중 필터용 인덱스 추가 후 `firebase deploy` 재실행.
3. 수정 후 `fetchJobs` 호출 시 `jobId`가 정상적으로 채워지는지 로그로 확인.
