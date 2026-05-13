# PR Architecture Fix Request Review — Gemini CLI

**Date**: 2026-05-10
**Reviewer**: Gemini CLI
**Target**: `docs/PR_Review/2026-05-10-architecture-fix-review-request.md` (Implementation Plan)

## Overview
아직 코드 구현 전 단계에서 작성해주신 '리팩토링 계획(Review Request)'의 타당성과 완전성을 검토했습니다. 

전반적으로 앞서 진행된 아키텍처 리뷰에서 지적되었던 안티패턴(Notifier 미사용), 거대 위젯(Monolithic), 예외 처리 누락, 하드코딩 등 핵심 결함들이 9개의 세부 항목으로 완벽하게 타겟팅되어 있습니다. 방향성과 항목 도출이 매우 훌륭합니다.

## Suggested Additions

계획을 더욱 견고하게 만들기 위해 다음 두 가지 항목을 리뷰 요청서(Plan)에 추가할 것을 권장합니다.

### 1. `PrimaryButton` 공통 위젯 적용 (디자인 시스템 통합)
- **현황**: 세부 항목 P0-3(디자인 토큰 위반 교체)에 `AppColors`와 `AppTextStyles` 교체는 잘 명시되어 있으나, "버튼 디자인 파편화" 문제 해결이 누락되어 있습니다.
- **권장 사항**: `JobDetailScreen`, `ProfileSetupScreen` 등 여러 화면에서 `ElevatedButton`의 스타일을 매번 새로 정의해서 쓰고 있는 부분들을 기존에 만들어둔 `PrimaryButton` 위젯으로 일괄 통일하는 작업을 P0-3 항목에 추가해 주세요.

### 2. 리팩토링에 따른 테스트 코드 업데이트 명시
- **현황**: 품질 기대 기준에 `flutter test` 통과가 명시되어 있으나, 리팩토링 범위가 넓어 기존 테스트의 대대적인 수정이 불가피합니다.
- **권장 사항**: `auth_provider`를 `Notifier`로 캡슐화하거나, `JobRepository`에 `Clock` 객체 주입(DI)을 추가하는 등 구조적 변화가 큰 부분들에 대해 **"변경된 Notifier 구조와 주입된 Repository에 대한 단위 테스트 코드 수정 및 보강"**을 리뷰 포인트나 체크리스트에 명시적으로 추가해 두면 훨씬 더 안전한 리팩토링이 될 것입니다.

## Conclusion
계획된 방향성은 완벽합니다. 위 2가지 포인트만 요청서에 보완하신 후, 해당 계획을 바탕으로 실제 코드 리팩토링 구현을 시작하시면 되겠습니다. 작업이 완료된 후 최종 코드 리뷰를 요청해 주시면 꼼꼼히 검증해 드리겠습니다!
