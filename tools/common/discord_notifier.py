import os
import sys
import json
from pathlib import Path
from datetime import datetime

try:
    import requests
except ImportError:
    requests = None

try:
    from dotenv import load_dotenv
except ImportError:
    load_dotenv = None

sys.stdout.reconfigure(encoding='utf-8')

_env_path = Path(__file__).parent.parent / 'config' / '.env'
if load_dotenv and _env_path.exists():
    load_dotenv(dotenv_path=_env_path)


class DiscordNotifier:
    def __init__(self, webhook_url=None):
        self.webhook_url = webhook_url or os.getenv('DISCORD_WEBHOOK_URL')

    def send(self, message, agent_name='SilverWorker'):
        if not self.webhook_url:
            print(
                '❌ DISCORD_WEBHOOK_URL not set. '
                'Add it to tools/config/.env or set as environment variable.'
            )
            return False
        return self._send_webhook(message, agent_name)

    def _send_webhook(self, message, agent_name):
        if requests is None:
            print('❌ "requests" package not installed. Run: pip install requests')
            return False

        payload = {
            'content': f'🔔 **[{agent_name}]**\n{message}',
        }
        try:
            response = requests.post(
                self.webhook_url, json=payload, timeout=10
            )
            if response.status_code in (200, 204):
                print(f'✅ Discord notification sent: {agent_name}')
                return True
            else:
                print(f'❌ Discord webhook failed: HTTP {response.status_code}')
                return False
        except Exception as e:
            print(f'❌ Discord webhook error: {e}')
            return False


if __name__ == '__main__':
    notifier = DiscordNotifier()
    notifier.send('SilverWorker notify system test.', agent_name='TestBot')
