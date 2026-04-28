# PR #2 Review — Day 2 Phone Auth & Profile Setup (spec_02)

- Reviewer: Claude (Opus 4.7)
- Date: 2026-04-28
- Target: `feature/day2-auth` → `master`
- Spec: `docs/planning/spec_02_auth.md`
- Verdict: **REQUEST CHANGES** (Blocker 2건 / Major 3건 / Minor 3건)

---

## 1. 종합 평가

전반적인 구조(go_router redirect, AuthRepository 분리, Riverpod provider 구성, 위젯 트리)는 spec_02 의도에 잘 들어맞고 0 warning을 유지한 점은 긍정적이다. 다만 **End-to-End 인증 흐름을 한 번이라도 실기로 돌려봤다면 즉시 발견됐을 결함이 두 건**(휴대폰 번호 E.164 변환 누락, 헤드라인 오타) 남아 있어 spec §6 DoD를 통과할 수 없다. 또한 프로필 생성 직후 `userProfileProvider` 캐시가 무효화되지 않아 redirect loop가 발생할 가능성이 높다. 머지 전 반드시 수정 필요.

PR 본문의 “verify_local.sh ✅” 만으로는 검증 불충분 — 실기 또는 emulator로 SMS 인증/프로필 저장/재진입 흐름을 한 번 더 돌릴 것.

---

## 2. Blocker

### B-1. `+82` 변환 시 leading 0을 제거하지 않음 — Firebase가 모든 국내 번호를 거부함
- 파일: `lib/screens/auth/phone_input_screen.dart:28-40`
- 현재 로직:
  ```dart
  final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
  // digits.length 10~11 모두 허용, 그대로 prefix만 붙임
  final phoneNumber = '+82$digits';
  ```
- 사용자가 hint(`01012345678`) 그대로 11자리를 입력하면 결과는 `+8201012345678` (13자리). Firebase는 E.164 형식(국내 번호의 leading 0 제거: `+821012345678`)을 요구하므로 `verifyPhoneNumber` 가 `invalid-phone-number` 로 즉시 실패한다.
- 결과: spec §6 DoD “실제 휴대폰 번호로 SMS 인증 완료” 자체가 불가능.
- 조치: 11자리 입력 시 leading 0 제거. 예:
  ```dart
  final normalized = digits.startsWith('0') ? digits.substring(1) : digits;
  if (normalized.length != 10) { /* error */ }
  final phoneNumber = '+82$normalized';
  ```
  hint도 `1012345678` 또는 `010-1234-5678` 둘 중 하나로 명확히. 테스트도 추가.

### B-2. 헤드라인 한국어 오타 “휴전폰” — 첫 화면 첫 줄
- 파일: `lib/screens/auth/phone_input_screen.dart:77`
  ```dart
  Text('휴전폰 번호로 시작하세요', ...)
  ```
- spec §3 UI 요소: `"휴대폰 번호로 시작하세요"` (24pt Bold)
- 시니어 타겟 앱의 진입 첫 텍스트가 오자라는 것은 신뢰도 측면에서 치명적.
- 조치: `휴대폰`으로 수정. (참고: `docs/history/2026-04-28-day2-auth.md` 본문에는 `휴대폰`으로 적혀 있음 — 코드에만 오타)

---

## 3. Major

### M-1. Profile 생성 직후 redirect loop 위험 — `userProfileProvider` 캐시 미무효화
- 파일: `lib/screens/auth/profile_register_screen.dart:57-69`, `lib/screens/main/main_screen.dart:30-46`
- 흐름:
  1. ProfileSetupScreen이 `userProfileProvider(uid)` 를 watch하여 `null` 을 캐싱(처음 진입 시).
  2. `createProfile()` 호출 후 `context.go(AppRoutes.main)`.
  3. MainScreen이 동일한 `userProfileProvider(uid)` 를 watch하지만 **family + FutureProvider** 라 이전 `null` 이 그대로 반환됨.
  4. MainScreen은 `profile == null` 분기를 타고 다시 `/auth/profile` 로 redirect → 이전 캐시 `null` 그대로 → 무한 루프 또는 정지.
- `authStateProvider`는 변하지 않으므로 `_AuthRefresh` 도 안 깨움.
- 조치: `createProfile` 성공 직후 `ref.invalidate(userProfileProvider(user.uid))` 호출 (또는 `ref.refresh`). 가능하면 `userProfileProvider` 를 `StreamProvider` 로 바꿔 Firestore 변경에 반응시키는 것이 더 안전.
- 검증 방법: 실제 디바이스에서 신규 가입 → 시작하기 버튼 → 메인 진입 여부.

### M-2. OTP 재발송이 `forceResendingToken` 을 사용하지 않음
- 파일: `lib/providers/auth_provider.dart:41`, `lib/screens/auth/otp_input_screen.dart:93-125`
- `resendTokenProvider` 는 codeSent에서 저장되지만 어디서도 read되지 않는다. `_onResend` 는 `startPhoneVerification` 을 다시 호출만 할 뿐 `forceResendingToken` 을 전달하지 않으므로 Firebase 입장에서는 처음 verifyPhoneNumber 호출과 구분되지 않는다.
- 결과: Android에서 reCAPTCHA flow가 다시 뜨거나, `too-many-requests` 가 발생해 spec §4 “재발송 버튼” 의도가 손상됨.
- 조치: `AuthRepository.verifyPhoneNumber`/`startPhoneVerification` 시그니처에 `int? forceResendingToken` 추가하고, `_onResend` 에서 `ref.read(resendTokenProvider)` 를 전달.

### M-3. Auto-verification 경로에서 `authLoadingProvider` 가 `false` 로 복귀하지 않음
- 파일: `lib/providers/auth_provider.dart:65-68`
  ```dart
  verificationCompleted: (PhoneAuthCredential credential) async {
    await repository.signInWithCredential(credential);
    // notifier.state = false 가 없음
  },
  ```
- Android instant verification이 동작하면 OTP 화면 진입 없이 그대로 로그인되지만, `authLoadingProvider` 는 `true` 로 stuck. 이후 다른 화면(특히 OtpInputScreen으로 라우터가 이동했을 때)에서 버튼이 영구 비활성 상태가 될 수 있다.
- 조치: try/finally로 감싸 마지막에 `notifier.state = false` 보장.

---

## 4. Minor / Nit

### m-1. PROGRESS.md를 PR 머지 전에 ✅ 완료로 갱신
- 파일: `docs/PROGRESS.md` (spec_02 행), 비고는 “PR #2 예정”
- `REVIEWER_PROMPT.md` §2.4: “On approval: Update the Spec status in `docs/PROGRESS.md` to `✅ 완료`” — 승인 후 작업이다. 현재 시점에는 `🔄 진행 중` 이 옳다.
- 조치: 이 PR 범위에서 `🔄 진행 중` 으로 되돌리고, 머지 시점 또는 reviewer가 갱신.

### m-2. 테스트 데이터 오타 `해욱대구` → `해운대구`
- 파일: `test/models/user_model_test.dart` (toJson 케이스, 부산광역시 sigungu)
- 단순 오타지만 한국어 행정구역 일치성을 검증하는 모델 테스트에 들어 있으면 인지부조화를 만든다.

### m-3. `createProfile` 에 spec에 없는 `gender: ''` / preferred* 빈 배열 저장
- 파일: `lib/repositories/auth_repository.dart:73-77`
- spec §5 본문에 등장하지 않는 필드(특히 `gender`)를 빈 문자열로 미리 채우는 건 04_db_schema에 맞췄다는 의도로 보이지만, 빈 문자열은 이후 spec_07 마이페이지 / spec_03 추천 로직에서 “미입력” 과 “명시적 빈” 을 구분 못 하게 만든다. 04_db_schema 에서 nullable 또는 enum string 인지 재확인 필요. 가능하면 `null` 또는 필드 자체를 생략(merge:false 새 문서이므로 문제 없음)하는 것이 안전.

---

## 5. 추가 관찰 (정보)

- 라우터 `redirect` 가 프로필 유무를 판단하지 못하므로 ProfileSetupScreen / MainScreen 양쪽이 각자 `userProfileProvider` 를 watch하면서 redirect를 책임진다. 이는 동작은 하지만 “두 화면이 동시에 책임” 구조라 향후 spec_08 navigation 도입 시 경합 위험이 있다. 라우터 redirect에 profile 체크를 위임(예: `userProfileSyncProvider` 같은 캐시된 boolean)을 도입하는 리팩토링을 spec_08 작업에서 함께 검토 권장.
- `_AuthRefresh` 는 `Stream<User?>` 를 듣지만 dispose 시점이 Provider 재구성과 일치하므로 Riverpod의 `StreamProvider<User?>` 를 그대로 쓰는 패턴(예: `GoRouter.refreshListenable: GoRouterRefreshStream(stream)`)으로 단순화 가능. (Nit)
- `pubspec.lock` 도 같이 커밋된 점 양호.
- `flutter analyze` 0 / 8 tests 통과는 신뢰하지만, 위 Blocker B-1, B-2와 Major M-1은 정적 분석으로 잡히지 않는 결함이라 “0 warnings”가 “기능 정상”을 의미하지 않음을 다시 강조한다.

---

## 6. 머지 권고

- B-1, B-2, M-1, M-2, M-3 모두 수정 후 다음 푸시에서 재리뷰.
- 재리뷰 시 PR 본문에 Android emulator(또는 실기) 화면 캡처/녹화 첨부 권장:
  1. `+82-1012345678` 형태로 verifyPhoneNumber 성공
  2. 6자리 OTP 입력 후 메인 진입
  3. 프로필 입력 후 시작하기 → JobListScreen 도달 (loop 없음)
  4. 앱 재실행 시 자동 로그인

이상.
