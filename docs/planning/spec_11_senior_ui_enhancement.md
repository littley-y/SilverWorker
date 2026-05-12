# spec_11 — 시니어 특화 UI/UX 고도화

> 대상 Day: Day 13  
> 상태: 🔄 진행 중  
> 의존성: spec_09_ui_system (완료)

---

## 1. 목적

사업계획서의 **"시니어 특화 UI/UX 및 무결점 디자인"** 항목 중 MVP에서 제외되었던 기능을 보완합니다.

- **마스코트 캐릭터**: 앱 내 안내를 돕는 친근한 캐릭터 위젯 추가
- **동적 폰트 크기**: 사용자가 직접 폰트 크기를 조절할 수 있는 설정 기능
- **설정 화면**: UI/UX 관련 사용자 설정을 관리하는 전용 화면

---

## 2. 기능 요구사항 (P0)

### P0-1: 마스코트 캐릭터 위젯 (MascotWidget)

**UI-11-01**: `MascotWidget` 공통 위젯을 생성합니다.
- `lib/widgets/mascot_widget.dart`
- 크기: 기본 80×80dp, `size` 파라미터로 조절 가능
- `Image.asset('assets/mascot/silver_bunny.png')` 사용
- `fit: BoxFit.contain`
- 투명 배경 처리
- 애니메이션(선택): `AnimatedScale` 또는 `AnimatedOpacity`로 부드러운 등장/퇴장

**UI-11-02**: 마스코트 배치 위치
- `JobListScreen`: 상단 필터 영역 옆 또는 빈 상태(Empty State) 화면 중앙
- `MyPageScreen`: 프로필 카드 상단 우측
- `SettingsScreen`: 상단 타이틀 옆

**UI-11-03**: 마스코트 에셋
- `assets/mascot/silver_bunny.png` (임시 placeholder)
- `pubspec.yaml` 에 `assets/mascot/` 등록
- 실제 캐릭터 디자인 완료 시 파일 교체

### P0-2: 동적 폰트 크기 조절 (FontSizeNotifier)

**UI-11-04**: `FontSizeNotifier` Riverpod StateNotifier 생성
- `lib/providers/font_size_provider.dart`
- 상태: `double fontScale` (기본값 1.0, 범위 0.8 ~ 1.4)
- `SharedPreferences`로 설정 영구 저장
- `setFontScale(double value)` 메서드

**UI-11-05**: `AppTextStyles` 동적 적용
- `lib/constants/app_text_styles.dart` 수정
- 기존 고정 `fontSize` → `fontSize * fontScale` 적용
- `AppTextStyles.of(BuildContext context, WidgetRef ref)` 또는 `Consumer` 패턴 사용
- 모든 화면의 `TextStyle`이 자동으로 스케일링되도록 통합

**UI-11-06**: 최소/최대 폰트 제한
- 최소: 14pt (caption, scale 0.8 시 11.2pt → 12pt 하한 적용)
- 최대: 24pt (headline, scale 1.4 시 33.6pt → 32pt 상한 적용)
- `max()` / `min()`으로 하한/상한 보장

### P0-3: 설정 화면 (SettingsScreen)

**UI-11-07**: `SettingsScreen` 생성
- `lib/screens/settings/settings_screen.dart`
- 상단: "설정" 타이틀 + 마스코트
- 섹션 1: "글자 크기" — `Slider` 위젯 (0.8 ~ 1.4)
  - 좌측 레이블: "작게", 우측 레이블: "크게"
  - 현재 값 표시: "100%", "120%" 등
  - 슬라이더 변경 시 실시간 미리보기 (아래 샘플 문구)
- 섹션 2: "화면 모드" — 고대비 모드 ON/OFF 토글 (기존 AppColors 활용)
- 섹션 3: "앱 정보" — 버전, 빌드 정보

**UI-11-08**: 설정 화면 진입점
- `MyPageScreen` 메뉴 리스트에 "설정" 메뉴 추가 (마지막 항목, 톱니바퀴 아이콘)
- `go_router` 경로: `/settings`
- `app_router.dart`에 `GoRoute` 등록

### P0-4: MyPage 메뉴 확장

**UI-11-09**: 기존 MyPage 메뉴 리스트에 "설정" 항목 추가
- 아이콘: `Icons.settings`
- 라벨: "설정"
- 탭 시: `context.push('/settings')`

---

## 3. 구현 체크리스트 (DoD)

- [ ] `MascotWidget` 구현 및 3개 화면 적용
- [ ] `FontSizeNotifier` 구현 + SharedPreferences 저장
- [ ] `AppTextStyles` 동적 스케일링 적용
- [ ] `SettingsScreen` 구현 (Slider + 미리보기)
- [ ] `MyPageScreen`에 "설정" 메뉴 추가
- [ ] `go_router`에 `/settings` 경로 추가
- [ ] `assets/mascot/` 디렉토리 생성 + placeholder 이미지 추가
- [ ] `pubspec.yaml` 에 assets 등록
- [ ] `flutter analyze` 0경고
- [ ] `flutter test` 신규 테스트 5건 이상 추가, 전체 통과
- [ ] `docs/PROGRESS.md` 업데이트

---

## 4. 테스트 케이스

| ID | 시나리오 | 기대 결과 |
|---|---|---|
| TC-11-01 | MascotWidget 렌더링 | 80×80dp 이미지가 정상 표시 |
| TC-11-02 | FontSizeNotifier 초기값 | SharedPreferences 미설정 시 1.0 반환 |
| TC-11-03 | 폰트 스케일 1.2 적용 | headline 24pt → 28.8pt 렌더링 |
| TC-11-04 | SettingsScreen Slider 이동 | 값 변경 시 폰트 미리보기 실시간 반영 |
| TC-11-05 | MyPage 설정 메뉴 탭 | SettingsScreen으로 정상 이동 |
| TC-11-06 | 폰트 하한 보장 | scale 0.5 설정 시 caption 12pt 하한 적용 |
| TC-11-07 | 폰트 상한 보장 | scale 2.0 설정 시 headline 32pt 상한 적용 |

---

## 5. 파일 목록

### 신규 파일
- `lib/widgets/mascot_widget.dart`
- `lib/providers/font_size_provider.dart`
- `lib/screens/settings/settings_screen.dart`
- `test/widgets/mascot_widget_test.dart`
- `test/providers/font_size_provider_test.dart`
- `test/widgets/settings_screen_test.dart`
- `assets/mascot/silver_bunny.png` (placeholder)

### 수정 파일
- `lib/constants/app_text_styles.dart`
- `lib/screens/mypage/my_page_screen.dart`
- `lib/router/app_router.dart`
- `pubspec.yaml`
