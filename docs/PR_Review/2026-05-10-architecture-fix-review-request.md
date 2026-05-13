# Architecture Fix Review Request — 헤파이스토스 검수 결과 반영

> Date: 2026-05-10
> Branch: master (direct commit 후 리뷰 요청)
> Scope: lib/ 전체 + test/ 1개 파일
> Basis: Claude/Gemini 아키텍처 리뷰 미처리 항목 + 헤파이스토스 추가 검수

---

## 변경 요약

헤파이스토스 최종 검수에서 발견된 **9개 문제점**(P0 4건 + P1 5건)을 일괄 수정합니다.

1. **Repository 3개에 try-catch + 예외 변환 추가**
2. **ErrorRetryView를 5개 화면에 통합**
3. **디자인 토큰 위반 교체 (Colors.grey.shade300/400)**
4. **MainShell dead code Guard 1 제거**
5. **profile_register_screen.dart 분해 (373줄)**
6. **otp_input_screen.dart 분해 (320줄)**
7. **JobModel UI getter 추출 (extension)**
8. **auth_provider.dart 안티패턴 정리 (Notifier)**
9. **JobRepository 시간 의존성 제거 (Clock 주입)**

---

## 세부 항목

### P0-1: Repository try-catch 추가 + 예외 변환

| 파일 | 현재 | 변경 |
|---|---|---|
| `auth_repository.dart` | try-catch 0개 | `createProfile`, `fetchProfile`, `signInWithCredential` 등에 try-catch + `appLogger` + 도메인 예외 변환 |
| `job_repository.dart` | try-catch 0개, `Timestamp.now()` 하드코딩 | `fetchJobs`, `fetchJobById`에 try-catch + `JobFetchException` 도입 |
| `application_repository.dart` | try-catch 0개, `DateTime.now()` 하드코딩, `currentUser!` force-unwrap | try-catch + time source DI + 안전한 user null 체크 |
| `job_provider.dart` | 에러 처리 없음 | try-catch + `appLogger` |
| `application_provider.dart` | 에러 처리 없음 | try-catch + `appLogger` |

### P0-2: ErrorRetryView 통합

| 파일 | 현재 | 변경 |
|---|---|---|
| `job_list_screen.dart` | 인라인 에러 UI | `ErrorRetryView`로 교체 |
| `job_detail_screen.dart` | 인라인 에러 UI | `ErrorRetryView`로 교체 |
| `my_page_screen.dart` | 인라인 에러 UI (아이콘 없음) | `ErrorRetryView`로 교체 |
| `main_shell.dart` | 인라인 에러 UI (아이콘 없음) | `ErrorRetryView`로 교체 |
| `application_list_screen.dart` | 텍스트만 (재시도 버튼 없음) | `ErrorRetryView`로 교체 |

### P0-3: 디자인 토큰 위반 교체

| 위반 | 횟수 | 파일 | 교체 |
|---|---|---|---|
| `Colors.grey.shade300` | 6 | `profile_register_screen.dart`, `otp_input_screen.dart` | → `AppColors.border` |
| `Colors.grey.shade400` | 4 | `profile_register_screen.dart` | → `AppColors.hintText` |
| `TextStyle(` 직접 생성 | 5 | `filter_bar.dart`, `job_card.dart(×2)`, `application_result_screen.dart`, `job_detail_screen.dart` | → `AppTextStyles` 기반 |

### P0-4: MainShell dead code 제거

| 파일 | 현재 | 변경 |
|---|---|---|
| `main_shell.dart:47-53` | `user == null` → redirect guard (라우터와 중복) | **삭제** |

### P1-5: profile_register_screen.dart 분해

| 현재 | 변경 |
|---|---|
| 373줄, all-in-one | `_NameField`, `_AddressSelector`, `_CareerField`, `_SubmitButton` 위젯 추출 |

### P1-6: otp_input_screen.dart 분해

| 현재 | 변경 |
|---|---|
| 320줄, OTP 로직/타이머/API 혼재 | `_OtpPinBox` 위젯 추출 (6자리 입력 + 붙여넣기 + 자동 이동 + 백스페이스) |

### P1-7: JobModel UI getter 추출

| 현재 | 변경 |
|---|---|
| `JobModel.employmentTypeLabel` 등 3개 getter | `extension JobModelUiLabels on JobModel` → `lib/extensions/job_model_extensions.dart` |

### P1-8: auth_provider 안티패턴 정리

| 현재 | 변경 |
|---|---|
| `startPhoneVerification`/`verifyOtp`가 `WidgetRef`를 매개변수로 받음 | `PhoneAuthNotifier extends Notifier<PhoneAuthState>` 로 캡슐화 |
| 상태가 4개 `StateProvider`로 파편화 | `PhoneAuthState` 불변 클래스 하나로 통합 |

### P1-9: JobRepository 시간 의존성 제거

| 현재 | 변경 |
|---|---|
| `Timestamp.now()` 하드코딩 | `Clock` 클래스 주입 (default: `DateTime.now`) |

---

## 리뷰 포인트

### Claude
- [ ] Repository try-catch가 적절한 예외 계층 구조로 변환되는지
- [ ] `PhoneAuthNotifier`가 기존 callback 패턴을 깨지 않고 마이그레이션되는지
- [ ] `ErrorRetryView` 통합이 기존 UI를 깨지 않는지 (아이콘/버튼 크기 차이)
- [ ] `_OtpPinBox` 위젯 추출이 복잡한 keyboard/paste 로직을 정확히 캡슐화하는지
- [ ] `JobModelUiLabels` extension이 call site 변경을 최소화하는지

### Gemini
- [ ] 디자인 토큰 교체(`Colors.grey.shade300 → AppColors.border`)가 완전한지
- [ ] Repository 시간 의존성 제거가 테스트 가능성을 향상시키는지
- [ ] 프로필 등록 화면 분해가 SoC 원칙을 만족하는지
- [ ] `MainShell` dead code 제거가 부작용 없이 안전한지
- [ ] `currentUser!` force-unwrap이 적절한 예외 변환으로 대체되는지

---

## 품질 기대 기준

- [ ] `flutter analyze` 0경고
- [ ] `flutter test` 모두 통과
- [ ] `ErrorRetryView`가 5개 화면에서 실제로 import/사용
- [ ] `Colors.grey.shade300/400`이 `lib/`에 0건
- [ ] `profile_register_screen.dart` ≤ 200줄
- [ ] `otp_input_screen.dart` ≤ 200줄
