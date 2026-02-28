Clear-Host
$WarningPreference = 'SilentlyContinue'
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "         DIAGNOSTIC ET INVENTAIRE SYSTEME COMPLET" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Recolte des informations en cours, veuillez patienter..." -ForegroundColor Yellow
Write-Host ""
$os = Get-CimInstance Win32_OperatingSystem
Write-Host "--- INFORMATIONS SYSTEME ---" -ForegroundColor Green
Write-Host "Nom de l'ordinateur  : $($env:COMPUTERNAME)"
Write-Host "Systeme d'exploitation: $($os.Caption) ($($os.OSArchitecture))"
Write-Host "Version (Build)      : $($os.Version)"
Write-Host "Dernier demarrage    : $($os.LastBootUpTime)"
Write-Host ""
$cpu = Get-CimInstance Win32_Processor
$bios = Get-CimInstance Win32_BIOS
$ram = Get-CimInstance Win32_ComputerSystem
$gpu = Get-CimInstance Win32_VideoController
$pm = @(Get-CimInstance Win32_PhysicalMemory)
$typeInt = if ($pm.Count -gt 0) {$pm[0].SMBIOSMemoryType} else {0}
$memTypes = @{ 20='DDR'; 21='DDR2'; 22='DDR2 FB-DIMM'; 24='DDR3'; 26='DDR4'; 34='DDR5' }
$ramType = if ($memTypes.ContainsKey($typeInt)) { $memTypes[$typeInt] } else { 'Type Inconnu' }
Write-Host "--- MATERIEL ---" -ForegroundColor Green
Write-Host "Fabricant / Modele   : $($ram.Manufacturer) / $($ram.Model)"
Write-Host "Processeur (CPU)     : $($cpu.Name)"
Write-Host "Memoire (RAM)        : $([math]::Round($ram.TotalPhysicalMemory / 1GB, 2)) Go ($ramType)"
Write-Host "Carte graphique (GPU): $($gpu.Name)"
Write-Host "Version du BIOS      : $($bios.SMBIOSBIOSVersion)"
Write-Host ""
Write-Host "--- LECTEURS DE DISQUE ---" -ForegroundColor Green
Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {
    $total = [math]::Round($_.Size / 1GB, 2)
    $free = [math]::Round($_.FreeSpace / 1GB, 2)
    $percent = 0; if ($total -gt 0) { $percent = [math]::Round(($free / $total) * 100, 2) }
    Write-Host "Lecteur $($_.DeviceID) - $free Go libres sur $total Go ($percent% libres)" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "--- RESEAU (Interfaces actives) ---" -ForegroundColor Green
Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object {
    $ip = (Get-NetIPAddress -InterfaceIndex $_.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress
    Write-Host "Interface: $($_.Name) ($($_.InterfaceDescription))"
    Write-Host "  Adresse IP : $ip"
    Write-Host "  Statut     : $($_.Status) ($($_.LinkSpeed))"
}
Write-Host ""
Write-Host "--- SECURITE (TPM) ---" -ForegroundColor Green
try {
    $tpm = Get-Tpm
    if ($tpm.TpmPresent) { Write-Host "Module TPM present et active : Oui (Pret: $($tpm.TpmReady))" }
    else { Write-Host "Module TPM non present ou desactive dans le BIOS." -ForegroundColor Yellow }
} catch { Write-Host "Impossible de verifier l'etat du TPM." -ForegroundColor Red }
Write-Host ""
Write-Host "Diagnostic termine." -ForegroundColor White
Start-Sleep -Seconds 1
