# Day 3 — Mock Job Data & Firestore Repository (spec_03 path A)

> **Date**: 2026-04-30  
> **Spec**: `docs/planning/spec_03_job_data.md`  
> **Path**: 경로 A (Mock 데이터)  
> **Commit**: 4a960f8

---

## Summary

고용24 API 키 미발급으로 경로 A(Mock 데이터)를 선택하여 Day 3 스펙을 완료했습니다. Firestore `/jobs` 컬렉션에 30개의 시니어 일자리 Mock 데이터를 등록하고, Flutter Repository에서 조회할 수 있도록 연동했습니다.

---

## What was done

1. **JobRepository Firestore 연동** (`lib/repositories/job_repository.dart`)
   - `fetchJobs(JobFilter)` 구현: `isActive`, `deadline`, `locationCode`, `jobCategory` 필터 + `orderBy('deadline').limit(50)`
   - `fetchJobById(String)` 추가: 단일 공고 상세 조회 (spec_05 준비)
   - `doc.data()! as Map<String, dynamic>` 캐스트로 `cloud_firestore` 5.x 타입 이슈 해결

2. **Mock 데이터 생성 스크립트** (`tools/scripts/seed_jobs.py`)
   - Python 스크립트: 5개 직종 × 3개 지역 × 현실적인 시니어 일자리 데이터
   - Firebase Admin SDK 연동: `--upload` 옵션으로 Firestore 직접 업로드
   - `serviceAccount.json` 필요 (`.gitignore` 등록)

3. **Firestore 복합 인덱스** (`firestore.indexes.json`)
   - `isActive ASC, deadline ASC`
   - `locationCode ASC, isActive ASC, deadline ASC`
   - `jobCategory ASC, isActive ASC, deadline ASC`
   - `firebase deploy --only firestore:indexes` 로 배포 완료

4. **기타**
   - `.gitignore`: `serviceAccount.json`, `seed_jobs.json`, `docs/study/`, `*:Zone.Identifier` 추가
   - `requirements.txt`: `firebase-admin` 추가

---

## CI Verification

```
flutter pub get        ✅
dart format            ✅ (0 changed)
flutter analyze        ✅ (0 issues)
flutter test           ✅ (8/8 passed)
```

---

## Decisions

- **경로 A 선택**: API 키 발급 대기 중 Mock 데이터로 빠르게 진행. Flutter Repository 코드는 경로 B(Cloud Functions) 전환 시에도 변경 불필요.
- **Admin SDK 사용**: Firestore rules의 `allow write: if false`를 우회하여 Mock 데이터 업로드. 서비스 계정 키는 `.gitignore`로 보호.
- **타입 캐스트**: `cloud_firestore` 5.x의 `DocumentSnapshot.data()` 반환 타입이 `Object?`로 추론되는 문제 → `as Map<String, dynamic>` 명시적 캐스트로 해결.

---

## Next

Day 4 → spec_04: 공고 목록 UI (`JobListView`, `JobCard`, 필터 UI)
