# Architecture Review — SilverWorker (Gemini CLI)

**Date**: 2026-05-10
**Reviewer**: Gemini CLI
**Target**: Entire `lib/` directory & Architecture

## Overview
전체 파일 구조와 내부 코드를 분석한 결과, 현재 프로젝트는 전반적으로 훌륭한 뼈대(Riverpod + GoRouter)를 가지고 있지만, 유지보수성과 확장성을 저해하는 몇 가지 치명적인 안티패턴과 아키텍처 결함이 존재합니다. 비판적 관점에서 도출한 리팩토링 필수 사항들을 정리했습니다.

---

## Critical Issues & Refactoring Opportunities

### 🚨 1. Riverpod 안티패턴 및 상태 관리 파편화
**📍 대상 파일:** `lib/providers/auth_provider.dart`

**[문제점]**
* 전역 함수인 `startPhoneVerification`과 `verifyOtp`가 매개변수로 `WidgetRef ref`를 직접 전달받아 사용하고 있습니다. 이는 **Riverpod의 핵심 안티패턴**입니다. 비즈니스 로직이 UI(Widget)의 생명주기와 강하게 결합되어 테스트가 극도로 어려워집니다.
* 상태가 `authLoadingProvider`, `verificationIdProvider`, `resendTokenProvider` 등 개별 `StateProvider`로 파편화되어 있어 응집도가 떨어집니다.

**[개선 방안]**
* 해당 로직들을 `Notifier` 또는 `AsyncNotifier` 클래스로 캡슐화해야 합니다.
* `WidgetRef`를 넘기는 대신, Notifier 내부의 `state`를 업데이트하고, UI는 단순히 `ref.read(authNotifierProvider.notifier).verifyOtp(...)` 형태로 호출하도록 리팩토링해야 합니다.

### 🎨 2. 관심사 분리(SoC) 원칙 위배 및 UI 하드코딩
**📍 대상 파일:** `lib/models/job_model.dart`, `lib/screens/job/job_detail_screen.dart`, `lib/screens/auth/profile_register_screen.dart`

**[문제점]**
* **모델 내부에 UI 로직 혼재:** `JobModel` 안에 `employmentTypeLabel`, `physicalIntensityLabel`과 같은 UI 한글 포매팅 로직이 들어있습니다. 순수 데이터 모델이 View 계층의 책임을 지고 있습니다.
* **디자인 시스템 무시:** `AppColors`, `AppTextStyles`, `PrimaryButton`과 같은 훌륭한 공통 위젯/상수를 만들어두고도 실제 화면에서는 `Colors.grey.shade400`이나 `TextStyle(fontSize: 22, fontWeight: FontWeight.bold)`를 하드코딩한 곳이 수십 군데(`grep` 결과 100건 이상) 발견되었습니다.
* **중복 코드:** `JobDetailScreen` 등 여러 곳에서 `PrimaryButton`을 쓰지 않고 `ElevatedButton`의 스타일을 매번 새로 정의하고 있습니다.

**[개선 방안]**
* `JobModel`의 Label 변환 로직은 `extension JobModelUIExt on JobModel` 형태의 UI 헬퍼나 별도의 Presentation Model로 분리하세요.
* 일괄 Find/Replace를 통해 `AppColors`와 `AppTextStyles`로 전부 교체해야 합니다.

### 🏗️ 3. 거대 단일 위젯 (Monolithic Widget)
**📍 대상 파일:** `lib/screens/auth/profile_register_screen.dart`, `lib/screens/auth/otp_input_screen.dart`

**[문제점]**
* `profile_register_screen.dart`의 파일 길이가 400라인에 육박하며 하나의 거대한 위젯으로 구성되어 있습니다.
* UI 렌더링뿐만 아니라 유효성 검사 로직, 폼 상태 관리, 직접적인 리포지토리 호출 로직이 한 곳에 뒤엉켜 있습니다. (God Object화)

**[개선 방안]**
* 위젯을 더 작은 단위(Atomic)로 쪼개야 합니다. (예: `_ProfileFormSection`, `_TermsAgreementSection` 등)
* 비즈니스 로직(Firestore 저장 및 검증)은 Riverpod Notifier나 Controller 레이어로 분리하여 화면은 오직 '그리는' 역할만 하도록 다이어트가 필요합니다.

### 💣 4. 리포지토리의 불완전한 예외 처리 및 테스트 불가 구조
**📍 대상 파일:** `lib/repositories/job_repository.dart`

**[문제점]**
* `fetchJobs` 메서드 등에 `try-catch` 블록이 전혀 없습니다. Firebase 네트워크 오류나 인덱스 부족 에러가 발생할 경우 UI까지 알 수 없는 에러가 그대로 전파됩니다.
* `where('deadline', isGreaterThan: Timestamp.now())` 구문에서 `Timestamp.now()`를 내부에서 직접 호출하고 있습니다. 이는 시간 의존성을 만들어내어 단위 테스트(Unit Test) 작성을 매우 까다롭게 만듭니다.

**[개선 방안]**
* Repository 계층에서 `try-catch`로 Firebase Exception을 잡아내어 도메인 에러(예: `JobFetchException`)로 변환(Mapping)해 던져주는 레이어가 필요합니다.
* `Timestamp.now()` 대신 현재 시간을 외부에서 파라미터로 주입받거나, `clock` 패키지를 사용하여 테스트 시 시간을 고정(Mocking)할 수 있도록 구조를 변경해야 합니다.

---

## Action Items Checklist
- [ ] `auth_provider.dart`를 `Notifier` 구조로 전면 리팩토링
- [ ] 하드코딩된 `Colors.` 및 `TextStyle()` 찾아내어 디자인 시스템 상수로 교체
- [ ] `JobModel`의 View 종속적인 getter들을 `extension`으로 분리
- [ ] `profile_register_screen.dart` 위젯 컴포넌트화 및 비즈니스 로직 분리
- [ ] `JobRepository` 예외 처리 추가 및 시간 의존성 제거
