@echo on
setlocal enabledelayedexpansion
set "_lf_path=C:\temp"
set "LF_PS=test.ps1"
>  "!LF_PS!" echo $path = '!_lf_path!'
>> "!LF_PS!" echo $base = $path.TrimEnd('\')
>> "!LF_PS!" echo $leaf = Split-Path $base -Leaf
>> "!LF_PS!" echo if (-not $leaf) { $leaf = $base }
>> "!LF_PS!" echo $leaf = $leaf -replace '[:\\/:*?"^<^>^|]', ''
>> "!LF_PS!" echo $stamp = Get-Date -Format 'yyyyMMdd_HHmm'
>> "!LF_PS!" echo $out = Join-Path $env:USERPROFILE "Desktop\Liste_${leaf}_${stamp}.txt"
>> "!LF_PS!" echo Write-Host "  [~] Scan en cours..." -ForegroundColor Cyan
>> "!LF_PS!" echo function Show-Tree {
>> "!LF_PS!" echo     param($p, $pre = '')
>> "!LF_PS!" echo     $ch = @(Get-ChildItem -LiteralPath $p -Directory -ErrorAction SilentlyContinue ^| Sort-Object Name)
>> "!LF_PS!" echo     for ($i = 0; $i -lt $ch.Count; $i++) {
>> "!LF_PS!" echo         $last = ($i -eq $ch.Count - 1)
>> "!LF_PS!" echo         $conn = if ($last) { '\-- ' } else { '+-- ' }
>> "!LF_PS!" echo         $next = if ($last) { $pre + '    ' } else { $pre + '^|   ' }
>> "!LF_PS!" echo         $script:lines += $pre + $conn + $ch[$i].Name
>> "!LF_PS!" echo         Show-Tree -p $ch[$i].FullName -pre $next
>> "!LF_PS!" echo     }
>> "!LF_PS!" echo }
>> "!LF_PS!" echo $script:lines = @()
>> "!LF_PS!" echo $sep = '=' * 70
>> "!LF_PS!" echo $header  = @()
>> "!LF_PS!" echo $header += $sep
>> "!LF_PS!" echo $header += "  Dossier : $path"
>> "!LF_PS!" echo $header += "  Date    : $(Get-Date -Format 'dd/MM/yyyy HH:mm')"
>> "!LF_PS!" echo $header += $sep
>> "!LF_PS!" echo $header += ""
>> "!LF_PS!" echo $rootLabel = if ($leaf) { $leaf } else { $base }
>> "!LF_PS!" echo $script:lines += $rootLabel + "\"
>> "!LF_PS!" echo Show-Tree -p $path
>> "!LF_PS!" echo $total = ($script:lines ^| Where-Object { $_ -match '\+--^|\\--' }).Count
>> "!LF_PS!" echo $header[2] = "  Sous-dossiers : $total"
>> "!LF_PS!" echo $all = $header + $script:lines + @('', $sep)
>> "!LF_PS!" echo $all ^| ForEach-Object { Write-Host $_ }
>> "!LF_PS!" echo $all ^| Out-File -FilePath $out -Encoding UTF8
>> "!LF_PS!" echo Write-Host ""
>> "!LF_PS!" echo Write-Host "  [OK] Exporte : $out" -ForegroundColor Green
>> "!LF_PS!" echo Start-Sleep -Seconds 1
>> "!LF_PS!" echo Invoke-Item $out

type "!LF_PS!"
exit /b 0
