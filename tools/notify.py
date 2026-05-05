#!/usr/bin/env python3
"""SilverWorker Discord notification script.

Usage:
    python3 tools/notify.py <agent_key> <message>

Agent keys:
    opencode  - OpenCode (implementer)
    claude    - Claude (reviewer)
    gemini    - Gemini (reviewer)
    system    - System notification
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from common.discord_notifier import DiscordNotifier

AGENT_CONFIGS = {
    'opencode': {'icon': '⚙️', 'label': 'OpenCode (Implementer)'},
    'claude':   {'icon': '🔍', 'label': 'Claude (Reviewer)'},
    'gemini':   {'icon': '🔎', 'label': 'Gemini (Reviewer)'},
    'system':   {'icon': '🤖', 'label': 'System'},
}


def send_notification(agent_key, message):
    notifier = DiscordNotifier()

    config = AGENT_CONFIGS.get(agent_key, AGENT_CONFIGS['system'])
    icon = config['icon']
    label = config['label']

    formatted_message = (
        f'**[ {icon} {label} ]**\n'
        f'━━━━━━━━━━━━━━━━━━━━━━━━\n'
        f'**상태**: 작업 완료 ✅\n'
        f'**내용**: {message}\n'
        f'━━━━━━━━━━━━━━━━━━━━━━━━\n'
        f'*SilverWorkerNow Project*'
    )

    success = notifier.send(
        message=formatted_message,
        agent_name='SilverWorkerAlarm',
    )

    if success:
        print(f'✅ Notification sent for {label}')
    else:
        print(f'❌ Failed to send notification for {label}')


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Usage: python3 tools/notify.py <agent_key> <message>')
        print('Available keys: opencode, claude, gemini, system')
        sys.exit(1)
    send_notification(sys.argv[1], sys.argv[2])
