$lines = Get-Content 'c:/Users/Alex/Documents/DEV/GITHUB/SCRIPT-WINDOWS-ALEEXLEDEV/Scripts-by-AleexLeDev.bat' -Encoding UTF8

Write-Host "=== :DynamicMenu PS code (F key handling) ==="
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '^:DynamicMenu') {
        for ($j = $i; $j -le [Math]::Min($i+80, $lines.Length-1); $j++) {
            Write-Host ("{0}: {1}" -f ($j+1), $lines[$j])
            if ($j -gt $i+5 -and $lines[$j] -match '^:[a-z]') { break }
        }; break
    }
}

Write-Host ""
Write-Host "=== cyber_ip_grabber entry + cyber_grabber_methods current state ==="
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '^:cyber_ip_grabber') {
        for ($j = $i; $j -le [Math]::Min($i+75, $lines.Length-1); $j++) {
            Write-Host ("{0}: {1}" -f ($j+1), $lines[$j])
            if ($j -gt $i+5 -and $lines[$j] -match '^:gm_dns') { break }
        }; break
    }
}
