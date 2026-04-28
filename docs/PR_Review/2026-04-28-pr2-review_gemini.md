# PR #2 Review — Gemini

**Date**: 2026-04-28
**PR**: #2
**Target Spec**: `docs/planning/spec_02_auth.md`
**Reviewer**: Gemini
**Status**: ❌ CHANGES_REQUESTED

---

## 1. Summary

The implementation of the Firebase Phone Auth flow and profile registration screen mostly adheres to `spec_02_auth.md`. The overall architecture using `go_router` and Riverpod is sound. However, there are significant data errors in the administrative district data and missing features in the auth resend logic that must be addressed before merging.

---

## 2. Review Details

### 🚨 Major Issues (Must Fix)

#### 2.1. Critical Typos in Address Data
In `lib/constants/address_data.dart`, several administrative districts have typos. This is critical because users in these areas will not be able to find or select their correct residence.
- **부산광역시**: `해욱대구` → `해운대구`
- **인천광역시**: `부개구` → `부평구` (Note: `부개동` exists, but it's part of `부평구`)
- **충청남도**: `볼령시` → `보령시`
- **전라남도**: `핫남군` → `해남군`

#### 2.2. Missing Resend Token Logic
The `resendTokenProvider` is defined in `auth_provider.dart` but is never passed back to `AuthRepository.verifyPhoneNumber`.
- **Impact**: When a user clicks "Resend", the app starts a completely new verification session instead of using the force-resend mechanism. This can lead to SMS delivery failures or higher costs/rate-limiting issues.
- **Fix**: Update `AuthRepository.verifyPhoneNumber` to accept an optional `int? forceResendingToken` and pass it to the Firebase API.

#### 2.3. OTP Input UX Regressions
The custom OTP implementation in `OtpInputScreen.dart` lacks standard UX features:
- **No Paste Support**: Users cannot paste a 6-digit code copied from their SMS app.
- **Incomplete Backspace Handling**: If a field is empty, pressing backspace should move the focus to the previous field. The current `_onDigitChanged` only triggers when the value *changes*, which doesn't capture backspace on an empty field.
- **Recommendation**: Consider using a proven package like `pin_code_fields` or implement `RawKeyboardListener`/`onKeyEvent` to handle backspaces properly.

#### 2.4. MainScreen Error State
In `lib/screens/main/main_screen.dart`, if `userProfileProvider` fails, it shows a static error message:
```dart
error: (_, __) => const Scaffold(
  body: Center(child: Text('프로필을 불러오는 중 오류가 발생했습니다.')),
),
```
- **Impact**: If a network error occurs, the user is stuck on this screen with no way to retry other than restarting the app.
- **Fix**: Add a "Retry" button that calls `ref.invalidate(userProfileProvider)`.

---

### ⚠️ Minor Issues / Nits

#### 3.1. Strict Phone Number Validation
The current validation only checks for 10-11 digits. In Korea, mobile numbers always start with `010`.
- **Suggestion**: Add a check `digits.startsWith('010')` to `PhoneInputScreen._isValid` to prevent invalid entries early.

#### 3.2. Firestore Field Consistency
`spec_02_auth.md` §5 mentions fields like `gender`, `physicalConditions`, etc., being part of the user document. While `AuthRepository.createProfile` initializes them to empty values, ensuring they are documented as "Future expansion" in the code would be helpful for maintainability.

---

## 3. Spec Compliance Check

| Requirement | Status | Note |
|---|---|---|
| Phone Auth Flow | ✅ Pass | Verification -> OTP -> Sign-in works as intended. |
| Automatic Redirect | ✅ Pass | `go_router` redirect handles auth state changes. |
| Profile Registration | ✅ Pass | Name, Sido/Sigungu, Career summary implemented. |
| Firestore Schema | ✅ Pass | Matches `04_db_schema.md` requirements. |
| Address Data Coverage | ❌ Fail | Critical typos discovered in `address_data.dart`. |

---

## 4. Assessment

**Verdict**: ❌ Changes Requested

Please fix the typos in the address data and implement the resend token logic. Improving the OTP UX and adding a retry button to the main screen is also highly recommended for a production-ready MVP.
