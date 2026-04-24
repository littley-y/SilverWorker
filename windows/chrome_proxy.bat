@echo off
REM Flutter Chrome Launcher Proxy Script
REM 이 스크립트는 Flutter가 Chrome을 띄울 때 강제로 디버깅 락을 해제합니다.

set CHROME_PATH="C:\Program Files\Google\Chrome\Application\chrome.exe"

REM Flutter가 넘겨주는 인자(%*)에 더하여, 연결 실패를 유발하는 샌드박스를 완전히 분쇄합니다.
%CHROME_PATH% --remote-allow-origins=* --disable-web-security --no-sandbox --disable-gpu --disable-software-rasterizer %*
