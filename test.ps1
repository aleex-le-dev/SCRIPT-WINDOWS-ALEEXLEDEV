$path = 'C:\temp'
$base = $path.TrimEnd('\')
$leaf = Split-Path $base -Leaf
if (-not $leaf) { $leaf = $base }
$leaf = $leaf -replace '[:\\/:*?"^<^>^|]', ''
$stamp = Get-Date -Format 'yyyyMMdd_HHmm'
$out = Join-Path $env:USERPROFILE "Desktop\Liste_${leaf}_${stamp}.txt"
Write-Host "  [~] Scan en cours..." -ForegroundColor Cyan
function Show-Tree {
    param($p, $pre = '')
    $ch = @(Get-ChildItem -LiteralPath $p -Directory -ErrorAction SilentlyContinue | Sort-Object Name)
    for ($i = 0; $i -lt $ch.Count; $i++) {
        $last = ($i -eq $ch.Count - 1)
        $conn = if ($last) { '\-- ' } else { '+-- ' }
        $next = if ($last) { $pre + '    ' } else { $pre + '|   ' }
        $script:lines += $pre + $conn + $ch[$i].Name
        Show-Tree -p $ch[$i].FullName -pre $next
    }
}
$script:lines = @()
$sep = '=' * 70
$header  = @()
$header += $sep
$header += "  Dossier : $path"
$header += "  Date    : $(Get-Date -Format 'dd/MM/yyyy HH:mm')"
$header += $sep
$header += ""
$rootLabel = if ($leaf) { $leaf } else { $base }
$script:lines += $rootLabel + "\"
Show-Tree -p $path
$total = ($script:lines | Where-Object { $_ -match '\+--|\\--' }).Count
$header[2] = "  Sous-dossiers : $total"
$all = $header + $script:lines + @('', $sep)
$all | ForEach-Object { Write-Host $_ }
$all | Out-File -FilePath $out -Encoding UTF8
Write-Host ""
Write-Host "  [OK] Exporte : $out" -ForegroundColor Green
Start-Sleep -Seconds 1
Invoke-Item $out
