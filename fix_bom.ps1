$file = 'c:\Users\Alex\Documents\DEV\GITHUB\SCRIPT-WINDOWS-ALEEXLEDEV\Scripts-by-AleexLeDev.bat'
$bytes = [System.IO.File]::ReadAllBytes($file)

# Verifier BOM UTF-8 (EF BB BF)
if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    Write-Host 'BOM UTF-8 detecte - Suppression...' -ForegroundColor Yellow
    $noBom = $bytes[3..($bytes.Length - 1)]
    [System.IO.File]::WriteAllBytes($file, $noBom)
    Write-Host '[OK] BOM supprime. Le fichier commence maintenant par : ' -ForegroundColor Green -NoNewline
    $first3 = [System.Text.Encoding]::ASCII.GetString($bytes[3..5])
    Write-Host $first3
} else {
    Write-Host 'Pas de BOM detecte. Le fichier est propre.' -ForegroundColor Green
    $hex = $bytes[0].ToString('X2') + ' ' + $bytes[1].ToString('X2') + ' ' + $bytes[2].ToString('X2')
    Write-Host "Premiers octets : $hex"
}
