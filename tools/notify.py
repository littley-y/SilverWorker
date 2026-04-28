import sys
import os
from pathlib import Path

# Add current dir to path for common module
sys.path.append(str(Path(__file__).parent.absolute()))

from common.discord_notifier import DiscordNotifier

# 에이전트 역할별 설정
AGENT_CONFIGS = {
    "Planning": {"icon": "📋", "label": "기획 (Planning)"},
    "Design":   {"icon": "🎨", "label": "디자인 (Design/UI)"},
    "Dev":      {"icon": "⚙️", "label": "핵심 개발 (Core Dev)"},
    "DevOps":   {"icon": "🚀", "label": "플랫폼 & DevOps"},
    "QA":       {"icon": "✅", "label": "품질 보증 (QA/Testing)"},
    "System":   {"icon": "🤖", "label": "시스템 (System)"}
}

def send_notification(agent_key, message):
    notifier = DiscordNotifier()
    
    # 설정 가져오기 (기본값은 System)
    config = AGENT_CONFIGS.get(agent_key, AGENT_CONFIGS["System"])
    icon = config["icon"]
    label = config["label"]

    formatted_message = (
        f"**[ {icon} {label} ]**\n"
        f"━━━━━━━━━━━━━━━━━━━━━━━━\n"
        f"**상태**: 작업 완료 ✅\n"
        f"**내용**: {message}\n"
        f"━━━━━━━━━━━━━━━━━━━━━━━━\n"
        f"*Must Go Out Alarm Project Service*"
    )

    success = notifier.send(
        message=formatted_message,
        agent_name=f"SilverWorkerAlarm"
    )

    if success:
        print(f"✅ Successfully sent notification for {label}")
    else:
        print(f"❌ Failed to send notification for {label}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 notify.py <agent_key> <message>")
        print("Available keys: Planning, Design, Dev, DevOps, QA, System")
    else:
        send_notification(sys.argv[1], sys.argv[2])
