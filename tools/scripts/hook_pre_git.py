"""
Claude Code PreToolUse hook - guards git write operations.

Rules:
  1. git push origin master/main from a role worktree → blocked (use PR flow)
     Exception: orchestrator (SilverWorkerNow/) may push directly to master
  2. git commit/push/merge/rebase → requires verify_local.ps1 to pass first
     - verify runs in the target worktree (parsed from 'cd <path> &&' prefix)

Reads tool_input JSON from stdin.
Exit code 2 + JSON output = block the tool use.
"""
import json
import os
import re
import subprocess
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
sys.stderr.reconfigure(encoding="utf-8")

REPO_DIRS = [
    Path("/home/dudxo13/Projects/SilverWorker"),
    Path("/mnt/e/Projects/SilverWorker"),
]

# Git commands that modify the repo / remote
BLOCKED_PREFIXES = (
    "git commit",
    "git push",
    "git merge",
    "git rebase",
)

PROTECTED_BRANCHES = ("master", "main")

def is_repo_root(working_dir: str) -> bool:
    """working_dir가 프로젝트 루트인지 확인."""
    try:
        resolved = Path(working_dir).resolve()
        return any(resolved == d.resolve() for d in REPO_DIRS)
    except Exception:
        return False

def is_direct_master_push(command: str) -> bool:
    """git push origin master/main 형태의 직접 푸시 감지."""
    subcommands = re.split(r"&&|;", command)
    for sub in subcommands:
        sub = sub.strip().lower()
        for branch in PROTECTED_BRANCHES:
            if re.search(rf'\bgit\s+push\b.*\b{branch}\b', sub):
                return True
    return False

def is_write_git_command(command: str) -> bool:
    # Split on && and ; to check each subcommand in a chain
    subcommands = re.split(r"&&|;", command)
    return any(
        sub.strip().lower().startswith(prefix)
        for sub in subcommands
        for prefix in BLOCKED_PREFIXES
    )

def extract_working_dir(command: str) -> str:
    """cd 'path' && 또는 cd "path" && 패턴에서 경로를 추출. 없으면 현재 cwd 반환."""
    match = re.match(r'^cd\s+"([^"]+)"\s*&&', command.strip())
    if match:
        return match.group(1)
    match = re.match(r"^cd\s+'([^']+)'\s*&&", command.strip())
    if match:
        return match.group(1)
    match = re.match(r'^cd\s+(\S+)\s*&&', command.strip())
    if match:
        return match.group(1)
    return os.getcwd()

def run_verify(working_dir: str) -> tuple[bool, str]:
    verify_script = Path(working_dir) / "tools" / "verify_local.sh"
    result = subprocess.run(
        ["bash", str(verify_script), working_dir],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    output = result.stdout + result.stderr
    return result.returncode == 0, output

def block(reason: str):
    print(json.dumps({"decision": "block", "reason": reason}, ensure_ascii=False))
    sys.exit(2)

def main():
    try:
        data = json.loads(sys.stdin.read())
    except Exception:
        sys.exit(0)

    command = data.get("tool_input", {}).get("command", "")
    if not is_write_git_command(command):
        sys.exit(0)

    working_dir = extract_working_dir(command)

    # Rule 1: master/main 직접 푸시 차단
    if is_direct_master_push(command) and not is_repo_root(working_dir):
        block(
            "master/main 직접 푸시는 금지입니다 (PR Flow 사용).\n"
            "feature 브랜치에 푸시한 후 PR을 생성하세요.\n"
            "예: git push origin feat/spec-02-auth && gh pr create --base master"
        )

    print(f"[hook] git 쓰기 작업 감지: {command.splitlines()[0]}", file=sys.stderr)
    print(f"[hook] verify_local.sh 실행 중... (repo: {working_dir})", file=sys.stderr)

    passed, output = run_verify(working_dir)
    if passed:
        sys.exit(0)

    block(
        f"verify_local.sh 실패 — git 작업이 차단됐습니다.\n\n{output}\n\n"
        "문제를 수정한 후 다시 시도하세요."
    )

if __name__ == "__main__":
    main()
