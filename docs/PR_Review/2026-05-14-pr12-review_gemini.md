# PR Review — PR #12 feat(ui): redesign job detail, add cancel flow, lock font scale

> **작성자**: Gemini (AI Reviewer)
> **리뷰일**: 2026-05-14
> **대상 PR**: #12 (`hotfix/job-detail-redesign` → `master`)

---

## 1. 종합 평가 (Summary)

**승인 (Approve)** ✅

이번 PR은 공고 상세 화면의 전면 개편, 지원 취소 기능 추가, 그리고 시니어 사용성을 고려한 글자 크기 고정 등 핵심적인 UI/UX 개선을 훌륭하게 담아냈습니다. 특히, 이전 PR에서 지적되었던 '모집' 텍스트 제거 로직이 정규식 대신 안전한 String 메서드로 개선되었고, 애니메이션 자원(Controller)의 `dispose` 처리도 완벽합니다. 아키텍처 설계와 테스트 커버리지 역시 매우 우수합니다.

---

## 2. 주요 리뷰 포인트 분석

### 2.1 아키텍처 (Architecture)
*   **JobModel `workHoursPerDay` 필드 추가**:
    기존 Firestore 데이터와의 하위 호환성을 완벽하게 유지하기 위해 `nullable(int?)`로 선언한 점이 매우 좋습니다. 기존 데이터 파싱 시 `null` 처리가 안전하게 이루어집니다.
*   **`hasAppliedProvider` Family 파라미터**:
    Dart 3의 Record 타입 `({String userId, String jobId})`을 사용한 설계는 매우 깔끔하고 직관적입니다. Tuple이나 사용자 정의 클래스를 만드는 것보다 훨씬 가볍고 타입 안정성이 뛰어납니다.
*   **`cancelApplication()` 에러 처리**:
    문서 존재 여부(`snap.exists`)를 먼저 확인하고 Exception을 던지는 로직은 올바른 접근입니다. 트랜잭션을 적용하지 않고 단일 문서 업데이트(`update()`)를 수행했으나, 취소 플로우의 특성상 현재 수준으로도 충분히 안전합니다.

### 2.2 UI/UX
*   **2×2 정보 카드 그리드**:
    `Row`와 `Expanded`를 적절히 활용하여 작은 화면(예: SE 사이즈)에서도 오버플로우(Overflow) 없이 균형 있게 렌더링되도록 구현되었습니다. 시각적 분리가 잘 되어 가독성이 높습니다.
*   **지원 취소 버튼 (빨간색)**:
    `AppColors.error` 색상을 사용한 것은 명확한 상태(파괴적 액션)를 알리는 데 적합합니다. 무엇보다 실수로 누르는 것을 방지하기 위해 다이얼로그(Dialog) 확인 절차를 추가한 UX 설계가 매우 훌륭합니다.
*   **글자 크기 130% 고정**:
    시니어 사용자의 절대다수가 큰 글씨를 선호한다는 점을 반영한 과감한 결정입니다. 설정 화면에서 슬라이더를 제거하고 고정 안내 문구로 대체한 점은 혼란을 방지하는 좋은 방법입니다. `FontSizeNotifier`에서 기존 저장값을 무시하고 `1.3`으로 강제 초기화하는 로직도 안정적으로 구현되었습니다.
*   **마스코트 은일이 애니메이션**:
    `TweenAnimationBuilder`와 `AnimationController`를 활용한 둥둥 떠다니기(Floating), 흔들기(Wobble) 애니메이션이 과하지 않고 귀엽게 잘 적용되었습니다. 터치 피드백(Haptic)과 함께 적용되어 생동감을 줍니다.

### 2.3 코드 품질 (Code Quality)
*   **`displayTitle` Getter 개선**:
    이전의 정규식(`RegExp`) 방식에서 `endsWith`와 `substring`을 활용한 명시적 로직으로 변경되어 성능과 안정성이 모두 향상되었습니다. `trim()`을 앞뒤로 꼼꼼히 배치하여 공백으로 인한 오류 가능성도 원천 차단했습니다.
*   **`MascotBanner` 메모리 누수 방지**:
    `StatefulWidget`으로 변경하면서 `_floatController.dispose()`를 잊지 않고 구현하여 메모리 릭(Memory Leak)을 방지했습니다. 훌륭한 생명주기 관리입니다.
*   **테스트 코드**:
    기존 기능은 물론, 새로 추가된 130% 고정 로직(`FontSizeNotifier ignores below fixedScale` 등)과 새로운 상세 화면 레이아웃에 대한 위젯 테스트가 꼼꼼하게 작성되었습니다. 123/123 통과가 이를 증명합니다.

---

## 3. 권장 사항 (Optional / Next Steps)

현재 코드의 수정이 필요한 치명적인 결함은 없습니다. 다음 스프린트나 후속 PR에서 고려해 볼 만한 가벼운 제안입니다.

*   **애니메이션 성능 최적화 (MascotBanner)**:
    현재 마스코트를 터치할 때 여러 개의 `Future.delayed`를 사용하여 Wobble 애니메이션을 수동 릴레이하고 있습니다. 코드가 직관적이긴 하지만, 플러터의 `AnimationSequence`나 `flutter_animate`와 같은 전용 패키지를 사용하면 더 복잡한 애니메이션도 선언적으로 관리할 수 있습니다. (현재 수준에서는 문제없습니다)
*   **다이얼로그 외부 터치 차단**:
    지원 취소 중 로딩 스피너가 돌 때 사용자가 다이얼로그 바깥이나 뒤로가기를 눌러 화면을 벗어날 가능성이 있습니다. `_isCancelling` 상태일 때는 뒤로가기(Pop)를 막는 로직(`PopScope` 등)을 추가하면 더욱 견고해질 것입니다.

---

**결론**: 즉시 머지(Merge)하셔도 좋습니다. 훌륭한 작업 수고하셨습니다!🚀