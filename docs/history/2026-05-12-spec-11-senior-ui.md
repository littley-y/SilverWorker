# 2026-05-12 — spec_11 시니어 특화 UI/UX 고도화

> Day 13 작업

---

## 1. 사업계획서 수정 PDF 생성

- 기술 스택을 기존 React Native + NestJS → **Flutter + Firebase BaaS**로 수정
- 수정된 PDF: `docs/제품_및_서비스_개발_부문_사업계획서_6080은빛일자리_수정.pdf`

---

## 2. spec_11 스펙 문서 작성

- `docs/planning/spec_11_senior_ui_enhancement.md` 신규 작성
- P0: MascotWidget, FontSizeNotifier, SettingsScreen
- P1: 화면 모드(고대비) 토글 (2차 구현으로 조정)

---

## 3. 구현 내역

### 신규 파일
- `lib/widgets/mascot_widget.dart` — 80dp 기본, TweenAnimationBuilder 등장 애니메이션, error fallback
- `lib/providers/font_size_provider.dart` — SharedPreferences 영구 저장, 0.86~1.33 범위
- `lib/screens/settings/settings_screen.dart` — Slider + 실시간 미리보기 + 설정 초기화
- `test/widgets/mascot_widget_test.dart` — 4건
- `test/providers/font_size_provider_test.dart` — 7건
- `test/widgets/settings_screen_test.dart` — 4건 (MediaQuery.textScaler 검증 포함)

### 수정 파일
- `lib/main.dart` — MaterialApp.builder + MediaQuery.textScaler 오버라이드
- `lib/router/app_router.dart` — `/settings` 경로 추가
- `lib/screens/mypage/my_page_screen.dart` — 설정 메뉴 + 마스코트 배치
- `lib/screens/job/job_list_screen.dart` — AppBar + EmptyState 마스코트 배치
- `pubspec.yaml` — `assets/mascot/` 등록

---

## 4. PR #10 리뷰 및 수정

### Round 1 (Claude)
| ID | 내용 | 처리 |
|------|------|------|
| B-1 | MediaQuery.textScaler 동작 안 함 | MaterialApp.builder로 이동 |
| M-2 | JobList/MyPage 마스코트 누락 | 3곳 배치 완료 |
| M-3 | 화면 모드 토글 P0로 명시 | spec P1로 강등 |
| M-1 | 폰트 스케일 실제 적용 테스트 부재 | MediaQuery.textScaler 검증 테스트 추가 |
| m-1 | AnimatedScale no-op | TweenAnimationBuilder로 교체 |
| m-2 | PR 번호 불일치 (pr11→pr10) | 파일 rename |
| m-3 | double 동등 비교 | epsilon 비교 적용 |
| n-1 | SettingsScreen 타이틀 중복 | "앱 설정" 제거 |

### Round 2 (Claude)
| ID | 내용 | 처리 |
|------|------|------|
| N-1 | ValueKey로 인한 Navigator 재생성 | ValueKey 제거 |
| U-1 | MyApp builder 와이어링 미검증 | UncontrolledProviderScope 테스트 추가 |
| U-2 | caption 12pt/headline 32pt 미보장 | minScale 0.86, maxScale 1.33 조정 |

---

## 5. 품질 지표

| 항목 | 결과 |
|------|------|
| `flutter analyze` | 0경고 |
| `flutter test` | 113/113 통과 |
| `verify_local.sh` | 6/6 통과 |

---

## 6. 다음 단계

- PR #10 Round 2 승인 대기 중
- 승인 시 master 머지
