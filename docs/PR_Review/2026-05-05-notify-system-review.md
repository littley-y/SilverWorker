# Review — Notify System 재활성화 및 Agent Hooks 구성

- **작업자**: OpenCode (Sisyphus)
- **날짜**: 2026-05-05
- **대상**: `tools/notify.py`, `tools/common/discord_notifier.py`, `tools/scripts/notify_hook.sh`, `tools/scripts/notify_review_hook.sh`, `.opencode/hooks.json`, `.claude/settings.json`, `.gemini/settings.json`
- **커밋**: `f082201` (master 직접 푸시)

---

## 개요

MustGoOut 프로젝트에서 사용하던 Discord 알림 시스템을 SilverWorker로 이식하고, 3개 AI 에이전트(OpenCode, Claude, Gemini)의 hooks에 연결하여 작업 완료 시 Discord 채널로 알림이 발송되도록 구성.

---

## 변경 파일

### 신규 (4)

| 파일 | 설명 |
|---|---|
| `tools/common/__init__.py` | Python 패키지 초기화 |
| `tools/common/discord_notifier.py` | Discord Webhook 알림 모듈 (MustGoOut에서 이식·간소화) |
| `tools/scripts/notify_hook.sh` | OpenCode용 알림 래퍼 (60초 rate limit) |
| `tools/scripts/notify_review_hook.sh` | Claude/Gemini 리뷰어용 알림 래퍼 (5분 이내 리뷰 파일 감지) |

### 수정 (4)

| 파일 | 변경 내용 |
|---|---|
| `tools/notify.py` | MustGoOut 참조 제거, SilverWorker 에이전트 키(opencode/claude/gemini/system)로 변경 |
| `.opencode/hooks.json` | `PreToolUse`(Bash) → `notify_hook.sh opencode` 추가 |
| `.claude/settings.json` | `Stop` → `notify_review_hook.sh claude` 추가 |
| `.gemini/settings.json` | `Stop` → `notify_review_hook.sh gemini` 추가 |

---

## 아키텍처

```
                    Discord Webhook
                         ▲
                         │
            ┌────────────┼────────────┐
            │            │            │
       notify.py    notify.py    notify.py
            ▲            ▲            ▲
            │            │            │
    notify_hook.sh  review_hook  review_hook
            ▲            ▲            ▲
            │            │            │
        OpenCode      Claude       Gemini
     PreToolUse(Bash)   Stop         Stop
     (60s rate limit)  (5min find)  (5min find)
```

---

## 알림 발송 조건

| 에이전트 | 트리거 | 조건 | 메시지 |
|---|---|---|---|
| **OpenCode** | `PreToolUse`(Bash) | 60초당 최대 1회 | "구현 작업이 완료되었습니다" |
| **Claude** | `Stop` | `docs/PR_Review/*.md` 5분 이내 수정 | "리뷰가 완료되었습니다" |
| **Gemini** | `Stop` | `docs/PR_Review/*.md` 5분 이내 수정 | "리뷰가 완료되었습니다" |

---

## 설계 결정

### 1. OpenCode: `Stop` 대신 `PreToolUse`(Bash) + Rate Limit
- OpenCode의 `Stop` 이벤트 미지원 확인 → `PreToolUse`(Bash)로 우회
- 매 쉘 커맨드마다 발송되는 문제 → `/tmp/silverworker_notify_opencode.stamp` 파일로 60초 rate limit 적용

### 2. Claude/Gemini: `Stop` + `find -mmin`
- `PostToolUse`(Bash)는 너무 빈번 → `Stop` 이벤트로 변경
- `git diff`/`ls-files`는 과거 PR의 미커밋 리뷰 파일까지 감지 → `find -mmin -5`로 최근 5분 파일만 감지

### 3. `.env` 분리
- `DISCORD_WEBHOOK_URL`은 `tools/config/.env`에서 로드 (`.gitignore` 등록)
- `python-dotenv` 미설치 시 환경변수 폴백

---

## 테스트 결과

| 테스트 | 결과 |
|---|---|
| `notify.py opencode` 직접 호출 | ✅ Discord 알림 수신 |
| `notify_review_hook.sh` (새 리뷰 파일) | ✅ Discord 알림 수신 |
| `notify_review_hook.sh` (기존 파일만) | ✅ 조용히 종료 |
| `notify_hook.sh` 1차 호출 | ✅ Discord 알림 수신 |
| `notify_hook.sh` 2차 호출 (60초 이내) | ✅ 무시 (rate limit) |

---

## 주의사항

1. **`DISCORD_WEBHOOK_URL` 필수**: `tools/config/.env`에 Webhook URL이 설정되어 있어야 실제 알림 발송됨 (현재 설정 완료)
2. **Python 의존성**: `requests`, `python-dotenv` 필요 (`pip install requests python-dotenv`)
3. **Rate limit stamp 파일**: `/tmp/silverworker_notify_*.stamp` — 서버 재부팅 시 초기화됨 (의도된 동작)
