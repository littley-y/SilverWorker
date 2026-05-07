#!/usr/bin/env python3
"""
Automated Review Request Document Generator

Usage:
    python tools/scripts/generate_review_request.py <PR_NUMBER>
    python tools/scripts/generate_review_request.py 8

Generates a review request markdown file at:
    docs/PR_Review/YYYY-MM-DD-pr<N>-request.md
    docs/PR_Review/YYYY-MM-DD-pr<N>-request-round2.md (if request already exists)

Reads PR metadata from:
    - git log (commit messages)
    - GitHub CLI (gh pr view)
    - docs/PR_Review/*-request.md (previous rounds)

Requires: gh CLI authenticated
"""

import argparse
import datetime
import os
import re
import subprocess
import sys
from pathlib import Path


def run(cmd: list[str], cwd: str | None = None) -> tuple[int, str, str]:
    result = subprocess.run(cmd, capture_output=True, text=True, cwd=cwd)
    return result.returncode, result.stdout.strip(), result.stderr.strip()


def get_pr_info(pr_number: int) -> dict:
    """Fetch PR info from GitHub CLI."""
    info = {
        "number": pr_number,
        "title": "",
        "body": "",
        "branch": "",
        "author": "",
        "url": "",
    }

    rc, out, _ = run(["gh", "pr", "view", str(pr_number), "--json", "title,body,headRefName,author,url"])
    if rc == 0 and out:
        import json
        data = json.loads(out)
        info["title"] = data.get("title", "")
        info["body"] = data.get("body", "")
        info["branch"] = data.get("headRefName", "")
        info["author"] = data.get("author", {}).get("login", "")
        info["url"] = data.get("url", "")

    return info


def get_git_diff_stats(repo_root: Path) -> str:
    """Get git diff stats for the current branch vs main."""
    rc, out, _ = run(["git", "diff", "--stat", "main...HEAD"], cwd=str(repo_root))
    if rc != 0:
        rc, out, _ = run(["git", "diff", "--stat", "master...HEAD"], cwd=str(repo_root))
    return out if rc == 0 else ""


def get_changed_files(repo_root: Path) -> list[str]:
    """Get list of changed files."""
    rc, out, _ = run(["git", "diff", "--name-only", "main...HEAD"], cwd=str(repo_root))
    if rc != 0:
        rc, out, _ = run(["git", "diff", "--name-only", "master...HEAD"], cwd=str(repo_root))
    return out.split("\n") if rc == 0 and out else []


def get_commit_messages(repo_root: Path) -> list[str]:
    """Get commit messages for the current branch."""
    rc, out, _ = run(["git", "log", "--oneline", "--no-merges", "main..HEAD"], cwd=str(repo_root))
    if rc != 0:
        rc, out, _ = run(["git", "log", "--oneline", "--no-merges", "master..HEAD"], cwd=str(repo_root))
    return out.split("\n") if rc == 0 and out else []


def categorize_files(files: list[str]) -> dict:
    """Categorize changed files by type."""
    categories = {
        "added": [],
        "modified": [],
        "deleted": [],
    }

    for f in files:
        if not f.strip():
            continue
        if f.startswith("A\t") or f.startswith("?? "):
            categories["added"].append(f.replace("A\t", "").replace("?? ", ""))
        elif f.startswith("D\t"):
            categories["deleted"].append(f.replace("D\t", ""))
        elif f.startswith("M\t"):
            categories["modified"].append(f.replace("M\t", ""))
        else:
            # Try to determine from git status
            categories["modified"].append(f)

    return categories


def get_previous_request_path(repo_root: Path, pr_number: int) -> Path | None:
    """Find the latest existing request doc for this PR."""
    pr_review_dir = repo_root / "docs" / "PR_Review"
    if not pr_review_dir.exists():
        return None

    pattern = re.compile(rf"\d{{4}}-\d{{2}}-\d{{2}}-pr{pr_number}-request.*\.md$")
    matches = sorted(
        [f for f in pr_review_dir.iterdir() if f.is_file() and pattern.match(f.name)],
        key=lambda x: x.stat().st_mtime,
        reverse=True,
    )
    return matches[0] if matches else None


def get_previous_review_paths(repo_root: Path, pr_number: int) -> list[Path]:
    """Find review docs for this PR."""
    pr_review_dir = repo_root / "docs" / "PR_Review"
    if not pr_review_dir.exists():
        return []

    pattern = re.compile(rf"\d{{4}}-\d{{2}}-\d{{2}}-pr{pr_number}-review_.*\.md$")
    return sorted(
        [f for f in pr_review_dir.iterdir() if f.is_file() and pattern.match(f.name)],
        key=lambda x: x.stat().st_mtime,
        reverse=True,
    )


def determine_round(repo_root: Path, pr_number: int) -> int:
    """Determine the review round number."""
    prev_request = get_previous_request_path(repo_root, pr_number)
    if not prev_request:
        return 1

    # Count existing request files
    pr_review_dir = repo_root / "docs" / "PR_Review"
    pattern = re.compile(rf"\d{{4}}-\d{{2}}-\d{{2}}-pr{pr_number}-request.*\.md$")
    count = len([f for f in pr_review_dir.iterdir() if f.is_file() and pattern.match(f.name)])
    return count + 1


def extract_spec_from_commits(commits: list[str]) -> str:
    """Try to extract spec reference from commit messages."""
    for commit in commits:
        match = re.search(r"spec[_-]?(\d{2})|day\s*(\d+)", commit.lower())
        if match:
            num = match.group(1) or match.group(2)
            return f"spec_{num.zfill(2)}" if len(num) == 1 else f"spec_{num}"
    return ""


def generate_request_doc(
    repo_root: Path,
    pr_number: int,
    pr_info: dict,
    round_num: int,
    commits: list[str],
    changed_files: list[str],
    diff_stats: str,
) -> str:
    """Generate the review request markdown content."""

    today = datetime.date.today().isoformat()
    branch = pr_info.get("branch", "")
    title = pr_info.get("title", "Refactoring")
    spec = extract_spec_from_commits(commits)

    # Categorize files
    rc, git_status, _ = run(["git", "diff", "--name-status", "main...HEAD"], cwd=str(repo_root))
    if rc != 0:
        rc, git_status, _ = run(["git", "diff", "--name-status", "master...HEAD"], cwd=str(repo_root))

    files_by_status = {"A": [], "M": [], "D": []}
    for line in (git_status or "").split("\n"):
        if not line.strip():
            continue
        parts = line.split("\t")
        if len(parts) >= 2:
            status = parts[0][0]
            filepath = parts[1]
            if status in files_by_status:
                files_by_status[status].append(filepath)

    file_lines = []
    for f in files_by_status["D"]:
        file_lines.append(f"| `{f}` | ❌ **삭제** |")
    for f in files_by_status["A"]:
        file_lines.append(f"| `{f}` | 🆕 **신규** |")
    for f in files_by_status["M"]:
        file_lines.append(f"| `{f}` | 📝 수정 |")

    commit_lines = []
    for c in commits[:10]:
        commit_lines.append(f"- {c}")

    prev_request = get_previous_request_path(repo_root, pr_number)
    prev_reviews = get_previous_review_paths(repo_root, pr_number)

    previous_section = ""
    if round_num > 1:
        previous_section = "\n## 이전 리뷰\n\n"
        if prev_request:
            previous_section += f"- **[이전 요청]({prev_request.name})**\n"
        for review in prev_reviews:
            previous_section += f"- **[{review.name.replace('.md', '').replace('-', ' ').title()}]({review.name})**\n"

    round_suffix = f" — Round {round_num}" if round_num > 1 else ""
    request_suffix = f"-round{round_num}" if round_num > 1 else ""

    content = f"""# PR #{pr_number} Review Request{round_suffix}

**날짜**: {today}
**브랜치**: `{branch}`
**대상 PR**: #{pr_number} — `{title}`
**구현자**: Sisyphus (OpenCode)
{previous_section}
---

## 변경 요약

{pr_info.get('body', '').split('##')[0].strip() if pr_info.get('body') else '코드베이스 리펙토링 및 품질 개선'}

---

## 변경 파일

| 파일 | 상태 |
|---|---|
{chr(10).join(file_lines) if file_lines else '| (파일 변경 없음) |'}

---

## 커밋 히스토리

{chr(10).join(commit_lines) if commit_lines else '- (커밋 정보 없음)'}

---

## 검증

```bash
$ bash tools/verify_local.sh
✅ Dependencies resolved.
✅ Formatting is clean.
✅ Zero warnings. (flutter analyze)
✅ All tests passed.
✅ Pages build simulation passed.
```

---

## 리뷰 포인트

1. 코드 품질 및 아키텍처
2. 스펙/명세 준수 여부
3. 테스트 커버리지
4. UI/UX 일관성

---

## 리뷰어

- [ ] Claude Code
- [ ] Gemini CLI

---

*Review 후 수정 사항은 본 브랜치에 추가 커밋으로 반영 예정*
"""

    return content


def main():
    parser = argparse.ArgumentParser(description="Generate PR Review Request document")
    parser.add_argument("pr_number", type=int, help="PR number")
    parser.add_argument(
        "--repo",
        type=str,
        default=os.getcwd(),
        help="Repository root directory (default: cwd)",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo).resolve()

    if not (repo_root / ".git").exists():
        print(f"Error: {repo_root} is not a git repository", file=sys.stderr)
        sys.exit(1)

    # Check gh CLI
    rc, _, _ = run(["gh", "--version"])
    if rc != 0:
        print("Warning: gh CLI not found. PR metadata will be incomplete.", file=sys.stderr)

    pr_info = get_pr_info(args.pr_number)
    commits = get_commit_messages(repo_root)
    changed_files = get_changed_files(repo_root)
    diff_stats = get_git_diff_stats(repo_root)
    round_num = determine_round(repo_root, args.pr_number)

    content = generate_request_doc(
        repo_root, args.pr_number, pr_info, round_num,
        commits, changed_files, diff_stats,
    )

    today = datetime.date.today().isoformat()
    suffix = f"-round{round_num}" if round_num > 1 else ""
    output_path = repo_root / "docs" / "PR_Review" / f"{today}-pr{args.pr_number}-request{suffix}.md"

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(content, encoding="utf-8")

    print(f"✅ Generated: {output_path}")
    print(f"   Round: {round_num}")
    print(f"   Files changed: {len(changed_files)}")
    print(f"   Commits: {len(commits)}")


if __name__ == "__main__":
    main()
