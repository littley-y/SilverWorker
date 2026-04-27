"""
Claude Code SessionStart / SubagentStart hook - injects General folder context.

- SessionStart: detects role from cwd (user manually opened a worktree)
- SubagentStart: detects role from subagent_type in stdin JSON (Agent tool)

Outputs loaded docs to stdout so Claude receives them as context.
"""
import json
import os
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

DOCS = Path("docs")

EMPTY_MARKER = "세션 요약 정보가 제공되지 않았습니다"

ROLE_DOCS = {
    "orchestrator": [
        "history",
        "planning/overview/03_mvp_specs.md",
        "PROGRESS.md",
    ],
}

CWD_MAP = {
    "SilverWorkerNow": "orchestrator",
}

def read_file(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except Exception:
        return ""

def latest_meaningful_md(directory: Path) -> Path | None:
    """Return the most recent .md that isn't an empty session-summary."""
    files = sorted(directory.glob("*.md"), key=lambda f: f.name, reverse=True)
    for f in files:
        # Skip auto-generated empty summaries
        if "session-summary" in f.name:
            continue
        content = read_file(f)
        if content.strip() and EMPTY_MARKER not in content:
            return f
    # Fallback: any non-empty file
    for f in files:
        content = read_file(f)
        if content.strip() and EMPTY_MARKER not in content:
            return f
    return None

def load_docs(role: str) -> list[str]:
    targets = ROLE_DOCS.get(role, ROLE_DOCS["orchestrator"])
    sections = []
    for target in targets:
        path = DOCS / target
        if path.is_dir():
            latest = latest_meaningful_md(path)
            if latest:
                label = path.name
                sections.append(f"=== [{label}] {latest.name} ===\n{read_file(latest)}")
        elif path.is_file():
            content = read_file(path)
            if content.strip():
                sections.append(f"=== {path.name} ===\n{content}")
    return sections

def main():
    role = None
    try:
        data = json.loads(sys.stdin.read())
        agent_type = data.get("subagent_type") or data.get("tool_input", {}).get("subagent_type")
        if agent_type:
            role = agent_type
    except Exception:
        pass

    if not role:
        role = CWD_MAP.get(Path(os.getcwd()).name, "orchestrator")

    sections = load_docs(role)
    if sections:
        print("\n\n".join(sections))

if __name__ == "__main__":
    main()
