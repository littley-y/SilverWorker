"""
Claude Code PostToolUse hook - Discord notification on agent completion.
Called with: python hook_agent_notify.py
Reads hook JSON context from stdin.
"""
import json
import sys
import subprocess
from pathlib import Path

AGENT_KEY_MAP = {
    "dev": "Dev",
    "design": "Design",
    "devops": "DevOps",
    "qa": "QA",
    "orchestrator": "System",
}

def main():
    try:
        data = json.loads(sys.stdin.read())
    except Exception:
        data = {}

    tool_input = data.get("tool_input", {})
    agent_type = tool_input.get("subagent_type") or "System"
    agent_key = AGENT_KEY_MAP.get(agent_type, "System")
    message = f"✅ {agent_key} 에이전트 작업 완료"

    notify_script = Path(__file__).parent.parent / "notify.py"
    subprocess.run(
        [sys.executable, str(notify_script), agent_key, message],
        cwd=str(notify_script.parent),
    )

if __name__ == "__main__":
    main()
