# PR #7 Review Request — Round 2

**날짜**: 2026-05-06
**브랜치**: `feature/day9-mypage`
**대상 PR**: [#7 feat(mypage): implement spec_07 (Day 9)](https://github.com/littley-y/SilverWorker/pull/7)
**대상 스펙**: [`docs/planning/spec_07_mypage.md`](../planning/spec_07_mypage.md)
**구현자**: Sisyphus (OpenCode)

---

## Round 1 → Round 2 수정 내역

### 🟠 Major (3건) — 모두 수정 완료

| 항목 | 위치 | 수정 내용 |
|---|---|---|
| **M-1** | `lib/screens/mypage/my_page_screen.dart` | `FirebaseAuth.instance.signOut()` → `ref.read(authRepositoryProvider).signOut()`으로 변경. `_showLogoutDialog`에 `WidgetRef ref` 인자 추가. 테스트도 mock에 `signOutCallCount` 카운터 추가하여 다이얼로그 → 확인 → `signOut()` 1회 호출 검증. |
| **M-2** | `lib/screens/mypage/my_page_screen.dart` | `user == null` 시 `addPostFrameCallback` + `context.go()` 제거. router redirect에 위임. `profile == null` 시 남은 defense guard에서도 `Scaffold` 중첩 제거, `Center(child: CircularProgressIndicator())`만 반환. |
| **M-3** | `lib/screens/mypage/my_page_screen.dart` | 경력 소개 스타일 `AppTextStyles.sectionTitle.copyWith(fontSize: 16)` → `AppTextStyles.body.copyWith(fontSize: 16)`. 스펙 의도(16pt regular)와 일치. |

### 🟡 Minor (3건) — 모두 수정 완료

| 항목 | 위치 | 수정 내용 |
|---|---|---|
| **m-1** | `test/widgets/my_page_screen_test.dart` | 다이얼로그 검증 `findsNWidgets(3)` → `find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextButton))`로 좁혀 "로그아웃" 액션 버튼만 정확히 카운트. |
| **m-2** | `lib/screens/mypage/application_list_screen.dart` | 날짜 포맷 `'${date.month}월 ${date.day}일'` → `padLeft(2, '0')` 적용. zero-pad 형식(`MM월 DD일`)으로 스펙과 일치. 테스트 assertion도 동기화. |
| **m-3** | `lib/screens/mypage/my_page_screen.dart` | M-2와 함께 해결. `profile == null` 분기에서 Scaffold 중첩 제거. |

### ⚪ Nit (2건) — 모두 수정 완료

| 항목 | 위치 | 수정 내용 |
|---|---|---|
| **n-1** | `test/helpers/test_doubles.dart` (신규) | `test/widgets/my_page_screen_test.dart`와 `test/widgets/application_list_screen_test.dart`의 중복 `_MockUser`를 `test/helpers/test_doubles.dart`로 추출. `MockUser`로 이름 변경(public). 양쪽 테스트 파일 import 업데이트. |
| **n-2** | `test/widgets/my_page_screen_test.dart` | 테스트 이름 `' tapping logout...'` → `'tapping logout...'` leading space 제거. |

---

## 변경 파일 (Round 2)

| 파일 | 변경 유형 | 설명 |
|---|---|---|
| `lib/screens/mypage/my_page_screen.dart` | 수정 | M-1, M-2, M-3 적용 |
| `lib/screens/mypage/application_list_screen.dart` | 수정 | m-2 zero-pad 날짜 포맷 |
| `test/widgets/my_page_screen_test.dart` | 수정 | M-1(signOut 카운터), m-1(descendant finder), n-2(이름), n-1(MockUser import) |
| `test/widgets/application_list_screen_test.dart` | 수정 | m-2(zero-pad assertion), n-1(MockUser import) |
| `test/helpers/test_doubles.dart` | 신규 | n-1 공용 MockUser 추출 |
| `docs/PROGRESS.md` | 수정 | spec_07 상태 → Review Round 2 |
| `docs/history/2026-05-06-day9-mypage.md` | 수정 | 리뷰 및 수정 내역 추가 |

---

## 검증

```bash
$ bash tools/verify_local.sh
✅ Dependencies resolved.
✅ Formatting is clean.
✅ Zero warnings. (flutter analyze)
✅ All tests passed. (62/62)
✅ Pages build simulation passed.
```

---

## Round 2 리뷰 포인트

1. **M-1 검증**: `ref.read(authRepositoryProvider).signOut()` 호출이 실제로 테스트에서 1회만 호출되는지 (`mockRepo.signOutCallCount == 1`)
2. **M-2 검증**: router redirect에 의존하는 구조가 안전한지. `user == null` 제거 후에도 다른 화면들과 일관된 동작인지
3. **M-3 검증**: 경력 소개가 16pt regular(body)로 렌더링되어 가독성이 적절한지
4. **m-1 검증**: `find.descendant`가 다이얼로그 내에서만 "로그아웃" 텍스트를 찾는지
5. **n-1 검증**: `test/helpers/test_doubles.dart` 추출이 다른 테스트 파일들에 영향을 주지 않는지

---

## 머지 가이드

- Major/Minor/Nit 모두 수정 완료
- Gemini는 Round 1에서 이미 승인
- Claude Round 2 승인 시 master 머지 가능

---

*Round 1 리뷰 문서: [`docs/PR_Review/2026-05-06-pr7-review_claude.md`](./2026-05-06-pr7-review_claude.md)*
