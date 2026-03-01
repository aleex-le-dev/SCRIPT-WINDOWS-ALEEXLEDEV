$c = Get-Content 'payload_temp.txt' -Raw
$c = $c -replace '\[System\.Convert\]::FromHexString\([^)]*\)', '$null'
Set-Content "regex_fixed.ps1" -Value $c
