import sys
import os
import json
import glob
import io

# Windows 환경에서 이모지 출력을 위해 stdout/stderr 인코딩을 UTF-8로 설정
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

def get_role():
    cwd = os.getcwd().lower()
    if "design" in cwd: return "design"
    if "devops" in cwd: return "devops"
    if "dev" in cwd: return "dev"
    if "planning" in cwd: return "planning"
    if "qa" in cwd: return "qa"
    return "orchestrator"

def read_file(path):
    if os.path.exists(path):
        try:
            with open(path, 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            return f"Error reading {path}: {str(e)}"
    return ""

role = get_role()
root_path = "/home/dudxo13/Projects/SilverWorker"
general_path = os.path.join(root_path, "General")

context = f"--- [SHARED CONTEXT: {role.upper()}] ---\n"
context += f"This context is automatically injected by the SessionStart hook from {general_path}.\n\n"

# 0. Master Guide (AGENTS.md)
context += "## 🗺️ MASTER GUIDE (AGENTS.md)\n"
agents_content = read_file(os.path.join(root_path, "AGENTS.md"))
if agents_content:
    context += f"{agents_content}\n\n"

# 1. Global Planning Files
planning_files = ["final_blueprint.md", "specs_v1.1_db_presets.md", "test_cases.md"]
context += "## 📋 GLOBAL PLANNING & SPECS\n"
for pf in planning_files:
    p_path = os.path.join(general_path, "planning", pf)
    content = read_file(p_path)
    if content:
        context += f"### {pf}\n{content}\n\n"

# 2. Role-specific History (Latest 3 files)
context += f"## 📜 {role.upper()} HISTORY\n"
history_dir = os.path.join(general_path, role, "history")
if os.path.exists(history_dir):
    h_files = sorted(glob.glob(os.path.join(history_dir, "*.md")), reverse=True)[:3]
    if h_files:
        for hf in h_files:
            context += f"### {os.path.basename(hf)}\n{read_file(hf)}\n\n"
    else:
        context += "No history found.\n\n"

# 3. Active Error Logs
context += "## ⚠️ ACTIVE ERROR LOGS\n"
error_dir = os.path.join(general_path, "ERROR")
if os.path.exists(error_dir):
    e_files = glob.glob(os.path.join(error_dir, "*.md"))
    if e_files:
        for ef in e_files:
            context += f"### {os.path.basename(ef)}\n{read_file(ef)}\n\n"
    else:
        context += "No active errors reported.\n\n"

output = {
    "hookSpecificOutput": {
        "additionalContext": context
    }
}
sys.stdout.write(json.dumps(output, ensure_ascii=False))
