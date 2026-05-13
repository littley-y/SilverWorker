# PR Review — PR #13 (Round 2) fix: Claude PR #13 review + auth OTP bug

> **작성자**: Gemini (AI Reviewer)
> **리뷰일**: 2026-05-14
> **대상 PR**: #13 (`hotfix/job-detail-fixes` → `master`)

---

## 1. 종합 평가 (Summary)

**승인 (Approve)** ✅

이번 2차 리뷰(Round 2)에서는 Claude가 지적했던 5건의 피드백(B-1, M-1, M-2, m-1, m-2)을 매우 정확하게 해결했을 뿐만 아니라, 안드로이드 환경에서 Firebase Auth OTP 발송 시 퓨처(Future)가 블로킹되는 고질적인 버그까지 완벽하게 수정했습니다. 아키텍처, 에러 핸들링, UX 모두 한 단계 더 견고해졌습니다.

---

## 2. 주요 수정 사항 분석

### 2.1 인증 OTP 버그 수정 (Completer 도입)
*   **문제**: 안드로이드(Android)에서 Firebase Auth의 `verifyPhoneNumber` 호출 시 `codeSent` 콜백은 트리거되지만 Future 자체가 리졸브(resolve)되지 않아 UI가 무한 로딩에 빠지는 현상.
*   **해결**: `verifyPhoneNumber`를 `unawaited`로 비동기 실행하고, 자체적인 `Completer`를 도입하여 각 콜백(`codeSent`, `verificationFailed`, `verificationCompleted`)에서 명시적으로 `complete()`를 호출하도록 수정했습니다. 또한 60초의 `TimeoutException` 방어 로직을 추가하여 무한 로딩을 완벽하게 차단한 점은 실무에서 매우 권장되는 훌륭한 패턴입니다.

### 2.2 E.164 전화번호 포맷 수정 (B-1)
*   **문제**: 기존 로직에서 앞자리 `0`이 제거되지 않아 `+82010...` 형태(14자리)로 전송되어 Firebase SMS 발송이 거부됨.
*   **해결**: `startsWith('0')`인 경우 `substring(1)`로 잘라내어 정상적인 `+8210...` 형태가 되도록 복원했습니다. 추가로 사용자에게 혼동을 줄 수 있던 UI 상의 `+82` 박스(Container)를 제거하고 직관적인 단일 `TextField`로 통합한 점은 UX 측면에서 훨씬 좋습니다.

### 2.3 지원 취소 상태(cancelled) 필터링 완벽화 (M-1, M-2)
*   **문제 (M-1)**: `hasAppliedProvider`가 '취소된 지원(cancelled)' 문서까지 존재하는 것으로 판단하여 재취소가 무한 반복될 위험이 있었음.
*   **해결 (M-1)**: `snap.data()?['status'] != 'cancelled'` 체크를 추가하여 정확히 '현재 유효한 지원'만 `true`를 반환하도록 가드를 세웠습니다.
*   **문제 (M-2)**: `fetchApplications`에서 `isNotEqualTo` 쿼리로 인해 복합 인덱스 누락 에러(`FAILED_PRECONDITION`)가 발생.
*   **해결 (M-2)**: 서버 쿼리 대신 클라이언트 사이드에서 `where((doc) => doc.data()['status'] != 'cancelled')`로 필터링하도록 전환했습니다. 데이터량이 적은 유저별 지원 내역의 특성상 인덱스를 추가하는 것보다 클라이언트 필터링이 비용과 속도 면에서 효율적입니다.

### 2.4 에러 핸들링 및 상태 무효화 (m-1, m-2)
*   **m-1 (예외 방어)**: `on Exception`을 `on Object catch (e, st)`로 범위를 넓히고 `appLogger.w`로 스택트레이스까지 로깅하도록 수정하여 디버깅이 용이해졌습니다.
*   **m-2 (Invalidate 로직)**: 에러 발생 후 재시도(`onRetry`) 시 파생 프로바이더인 `visibleJobListProvider`뿐만 아니라 원본 소스인 `jobListProvider`까지 명시적으로 함께 `invalidate` 하도록 처리하여 데이터의 일관성을 확보했습니다.

---

## 3. 결론

제기되었던 모든 엣지 케이스(Edge case)와 크리티컬한 버그들이 매우 수준 높은 코드로 처리되었습니다. 특히 비동기 제어(`Completer`)와 로컬 필터링 전환 판단이 탁월합니다. 

수고하셨습니다. 즉시 머지(Merge)하셔도 좋습니다! 🚀