import sys
import os
import json
import subprocess
import io

# Windows 환경에서 인코딩 문제 방지를 위해 stdout/stderr 인코딩을 UTF-8로 설정
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

# 1. Gemini CLI로부터 입력 데이터 읽기
try:
    input_data = json.load(sys.stdin)
except Exception as e:
    sys.stderr.write(f"Error parsing input JSON: {str(e)}\n")
    sys.stdout.write(json.dumps({}))
    sys.exit(0)

# Gemini CLI BeforeTool Hook 사양에 맞춘 필드 추출
tool_name = input_data.get("tool_name")
tool_input = input_data.get("tool_input", {})
command = tool_input.get("command", "")

# 2. 도구가 'run_shell_command'이고, 명령어에 'git commit' 또는 'git push'가 포함된 경우 검증
# (사용자 요청: 새 커밋 생성/수정 시마다 호출)
target_commands = ["git commit", "git push"]
should_verify = any(tc in command.lower() for tc in target_commands)

if should_verify:
    sys.stderr.write(f"🚀 [BeforeTool Hook] {command} 감지! 로컬 빌드 무결성 검증을 시작합니다...\n")
    
    verify_script = "/home/dudxo13/Projects/SilverWorker/General/verify_local.sh"

    try:
        # bash를 통해 검증 스크립트 실행
        result = subprocess.run(
            ["bash", verify_script],
            capture_output=True,
            text=True,
            encoding='utf-8'
        )

        if result.returncode == 0:
            sys.stderr.write("✅ 로컬 빌드 검증 통과! 계속 진행합니다.\n")
            sys.stdout.write(json.dumps({}))
        else:
            sys.stderr.write("❌ 로컬 빌드 검증 실패! 명령 실행이 차단되었습니다.\n")
            sys.stderr.write(result.stdout + "\n")
            sys.stderr.write(result.stderr + "\n")
            # abort: True를 반환하여 실제 도구 실행을 중단시킴
            sys.stdout.write(json.dumps({
                "abort": True,
                "error": "Local verification (verify_local.sh) failed. Please fix issues before committing/pushing."
            }))
            
    except Exception as e:
        sys.stderr.write(f"⚠️ 검증 스크립트 실행 중 오류 발생: {str(e)}\n")
        sys.stdout.write(json.dumps({"abort": True, "error": f"Internal hook error: {str(e)}"}))
else:
    # 해당 명령어가 아니면 아무 작업 없이 허용
    sys.stdout.write(json.dumps({}))
