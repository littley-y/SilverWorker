import sys
import os
import json
from datetime import datetime
import io

# Windows 환경에서 인코딩 문제 방지를 위해 stdout/stderr 인코딩을 UTF-8로 설정
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

# 1. Input 데이터 읽기 (Gemini CLI가 전달한 세션 요약 등)
try:
    input_data = json.load(sys.stdin)
except:
    input_data = {}

role = get_role()
general_path = "/home/dudxo13/Projects/SilverWorker/General"
history_dir = os.path.join(general_path, role, "history")

# 2. 히스토리 폴더 보장
if not os.path.exists(history_dir):
    os.makedirs(history_dir)

# 3. 파일명 및 내용 생성
today = datetime.now().strftime("%Y-%m-%d")
filename = f"{today}-session-summary.md"
filepath = os.path.join(history_dir, filename)

# 세션 요약 정보 추출 (CLI가 제공하는 정보에 따라 다를 수 있음)
summary_content = input_data.get("sessionSummary", "세션 요약 정보가 제공되지 않았습니다.")
tokens_used = input_data.get("tokensUsed", "N/A")

content = f"""# Session Summary: {today}
- **Role**: {role.upper()}
- **Time**: {datetime.now().strftime("%H:%M:%S")}
- **Context**: {os.getcwd()}

## 🚀 Session Actions & Results
{summary_content}

---
*Auto-recorded by SessionEnd Hook (Tokens used: {tokens_used})*
"""

# 4. 파일 쓰기 (기존 파일이 있으면 아래에 추가)
with open(filepath, 'a', encoding='utf-8') as f:
    f.write("\n\n" + content)

# 5. 결과 반환 (필수)
sys.stdout.write(json.dumps({}))
