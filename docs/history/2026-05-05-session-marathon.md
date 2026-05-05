# Session History — 2026-05-05 Marathon Session

## 개요
- **구현자**: OpenCode (Sisyphus)
- **리뷰어**: Claude, Gemini
- **세션 시간**: 2026-05-05 15:00 ~ 18:00 (약 3시간)

---

## 완료 Spec

| Spec | PR | 내용 | 테스트 | 리뷰 |
|---|---|---|---|---|
| spec_04 | #4 | 공고 목록 UI (JobCard, FilterBar, JobListScreen) + UI 시스템 정렬 | 33/33 | Claude 2 round, Gemini 2 round |
| spec_05 | #5 | 공고 상세 (SafetyCurationSection, JobDetailScreen) + formattedSalary | 44/44 | Claude 2 round, Gemini 2 round |
| spec_06 | #6 | 지원 기능 (ApplicationFormScreen, ApplicationResultScreen) + 오터치 방어 | 51/51 | Claude 3 round, Gemini 3 round |
| notify | - | Discord 알림 시스템 (3 agents) | - | 1회 리뷰 |

## 주요 성과

### 1. UI 시스템 정립
- `AppTextStyles`: 14pt 하한, headline/title/body/caption/sectionTitle/button
- `AppColors`: WCAG AA 대비율, primary/text/background/intensity/status 토큰화
- `JobModel.formattedSalary`: 시급/일급/월급 통합 getter (코드 중복 제거)

### 2. 아키텍처 개선
- `JobFilter.copyWith`: sentinel 패턴으로 nullable null 설정 가능
- `ApplicationRepository`: `runTransaction` + 결정적 doc ID로 race condition 해결
- `sealed class ApplicationException`: 타입 안전 예외 처리

### 3. 테스트 커버리지
- Day 4: 22건 신규 (JobCard 10 + FilterBar 7 + JobListScreen 5)
- Day 5: 11건 신규 (SafetyCuration 4 + JobDetailScreen 7)
- Day 6: 7건 신규 (ApplicationForm 5 + ApplicationResult 2)
- **총 51건 → 0 issues, all passed**

### 4. DevOps
- Discord notify 시스템: OpenCode/Claude/Gemini hooks
- `verify_local.sh`: 6단계 CI (pub get → format → analyze → test → pages → graphify)
- Graphify 지식 그래프: 334 nodes, 406 edges, 35 communities

## 발견된 주요 이슈 및 해결

| 이슈 | PR | 해결 |
|---|---|---|
| 시급/일급 "만원" 표기 오류 | #4 B-1 | NumberFormat + 분기 처리 |
| 12pt 폰트 하한 위반 | #4 M-1 | caption 14pt 통일 |
| main.dart GoRouter 미연결 | #4 | MaterialApp.router() 수정 |
| 지원하기 버튼 무반응 | #5 M-1 | SnackBar → 실제 라우팅 |
| _formatSalary 중복 | #5 m-1 | JobModel.formattedSalary |
| Race condition (중복 지원) | #6 M-2 | runTransaction + doc ID |
| _checkAlreadyApplied 자동 저장 | #6 B-1 | hasApplied() 분리 |
| OpenCode Stop 미지원 | notify | PreToolUse(Bash) + rate limit |
| .claude/settings.json 중복 발동 | notify | OpenCode가 claude config도 읽는 문제 파악 |

## 남은 Spec
- Day 9: 마이페이지 (spec_07)
- Day 10: 네비게이션 (spec_08)
- Day 11: UI 시스템 마무리 (spec_09)
- Day 12: 테스트 기준 (spec_10)
