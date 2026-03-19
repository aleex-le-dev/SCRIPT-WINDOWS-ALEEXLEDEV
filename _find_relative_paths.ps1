param()
$file = 'c:\Users\Alex\Documents\DEV\GITHUB\SCRIPT-WINDOWS-ALEEXLEDEV\Scripts-by-AleexLeDev.bat'
$lines = [System.IO.File]::ReadAllLines($file)

# Trouver les occurrences du chemin relatif "favoris.txt"
$pattern = '"favoris.txt"'
$results = @()
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match [regex]::Escape($pattern)) {
        $results += [PSCustomObject]@{ Line = $i+1; Content = $lines[$i].Substring(0, [Math]::Min(120, $lines[$i].Length)) }
    }
}

Write-Host "Occurrences du chemin relatif favoris.txt :"
$results | ForEach-Object { Write-Host ("  L" + $_.Line + ": " + $_.Content) }
Write-Host ""
Write-Host "Total : $($results.Count) occurrences"
