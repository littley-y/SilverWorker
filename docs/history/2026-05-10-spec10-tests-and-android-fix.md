# Session History — 2026-05-10: spec_10 테스트 기준 + Android 버그 수정

## 개요

- **세션 목표**: spec_10 (Day 12) 테스트 기준 및 DoD 구현 + Android release APK 디버깅
- **완료 상태**: ✅ 전체 완료
- **총 커밋**: 2건

---

## 작업 내역

### 1. Android Release APK 크래시 수정

**문제**: Mi9 실제 기기에서 APK 설치 후 실행 불가

**원인 분석**:
- `ClassNotFoundException: com.silverworkernow.app.MainActivity` — `MainActivity.kt` 파일이 프로젝트에 존재하지 않음
- `INTERNET` 권한 누락 — release 빌드에서는 Flutter 툴이 자동으로 주입하지 않음

**해결**:
- `android/app/src/main/kotlin/com/silverworkernow/app/MainActivity.kt` 신규 생성
- `AndroidManifest.xml`에 `<uses-permission android:name="android.permission.INTERNET"/>` 추가
- `google-services.json` 업데이트 (Firebase Console SHA-1 지문 반영)

**검증**: Mi9 실제 기기에서 APK 정상 실행 확인

### 2. spec_10 테스트 구현

**목표**: spec_10에 명시된 4개 테스트 파일 중 누락된 3개 파일 작성

| 파일 | 테스트 수 | 핵심 커버리지 |
|---|---|---|
| `test/repositories/application_repository_test.dart` | 7 | `hasApplied` (true/false), `submitApplication` (성공/중복/없는공고/마감/비활성) |
| `test/models/job_filter_test.dart` | 6 | empty 필터, copyWith 단일/다중 필드, null로 필드 초기화, sentinel 동작 |
| `test/models/physical_badge_test.dart` | 8 | `physicalIntensityLabel` (light/moderate/heavy/unknown), `physicalBadges` 파싱/기본값/6종배지 |

**리팩토링**: `ApplicationRepository`에 `FirebaseAuth` 생성자 주입 추가 → 단위 테스트 mock 가능

### 3. Firebase Phone Auth 디버깅

**문제**: Mi9에서 번호 인증 시 `CONFIGURATION_NOT_FOUND` 에러

**원인**: Firebase Console에 SHA-1 인증서 지문 미등록

**해결**: `gradlew signingReport`로 SHA-1 추출 → Firebase Console 등록 → `google-services.json` 재다운로드

**결과**: 인증 정상 작동 (테스트 번호 `+821072977226`로 확인)

---

## 품질 지표

| 항목 | 결과 |
|---|---|
| `flutter analyze` | 0 errors, 0 warnings |
| `flutter test` | 84/84 passing |
| 총 테스트 파일 | 15개 |
| 총 테스트 수 | 84개 |

---

## 커밋 기록

1. `b8f2519` — fix(android): add missing MainActivity.kt and INTERNET permission
2. `4c6fde3` — test(spec_10): add missing unit tests for Day 12 DoD

---

## 알게 된 점

- **Flutter release APK**는 `AndroidManifest.xml`에 `INTERNET` 권한을 **수동으로 선언**해야 함 (debug는 자동 주입)
- **Firebase Phone Auth**는 SHA-1 인증서 지문 **필수 등록** (debug keystore의 SHA-1을 Firebase Console에 추가)
- `fake_cloud_firestore`는 `runTransaction`을 지원하여 Firestore 트랜잭션 로직 단위 테스트 가능
- `FirebaseAuth.instance`에 직접 의존하는 코드는 **생성자 주입**으로 리팩토링하여 테스트 가능하게 만들어야 함
