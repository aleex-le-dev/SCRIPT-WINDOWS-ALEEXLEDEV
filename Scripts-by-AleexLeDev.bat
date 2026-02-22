@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM === AUTO-ELEVATION EN ADMINISTRATEUR ===
REM Changement de methode pour compatibilite Mode Sans Echec (net session depend du service Serveur qui est arrete en Safe Mode)
fsutil dirty query %systemdrive% >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo Cette boite a script doit etre lancee en mode administrateur.
    echo Demande des droits en cours...
    powershell.exe -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

REM === DETECTION ET NETTOYAGE AUTO MODE SANS ECHEC ===
reg query "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Option" /v OptionValue >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo ======================================================
    echo           MODE SANS ECHEC DETECTE
    echo ======================================================
    echo.
    echo Le script a detecte que vous etes en Mode Sans Echec.
    echo Suppression automatique du flag 'SafeBoot' pour que
    echo le prochain redemarrage se fasse en MODE NORMAL.
    echo.
    
    bcdedit /deletevalue {current} safeboot >nul 2>&1
    bcdedit /deletevalue {current} safebootalternateshell >nul 2>&1
    
    echo [OK] Configuration appliquee !
    echo Vous pouvez continuer vos operations.
    echo Au prochain redemarrage, Windows reviendra a la normale.
    echo.
    echo Appuyez sur une touche pour acceder au menu...
    pause >nul
)

cd /d "%~dp0"
title Boite a Scripts Windows - By ALEEXLEDEV (v2.4)
color 0B

REM === INITIALISATION BASE DE DONNEES SCRIPTS ===
set "t1_n=SFC (Reparation fichiers)" & set "t1_l=sys_sfc"
set "t2_n=DISM (Reparation image)" & set "t2_l=sys_dism_menu"
set "t3_n=CHKDSK (Erreurs disque)" & set "t3_l=sys_chkdsk"
set "t4_n=Nettoyage Disque/Temp" & set "t4_l=sys_clean_options"
set "t5_n=Nettoyage Registre" & set "t5_l=sys_registry_cleanup"
set "t6_n=Reparer Spouleur" & set "t6_l=repair_spooler"
set "t7_n=Reparer Windows Update" & set "t7_l=sys_windows_update_hub"
set "t8_n=Point de Restauration" & set "t8_l=create_restore_point"
set "t9_n=Gestionnaire DNS" & set "t9_l=dns_manager"
set "t10_n=Mots de passe Wi-Fi" & set "t10_l=sys_wifi_passwords"
set "t11_n=Outils Reseau (Infos/Fix)" & set "t11_l=sys_network_hub"
set "t12_n=Test Connexion (Ping/DNS)" & set "t12_l=sys_ping_test"
set "t13_n=Recherche FTP (Dorks)" & set "t13_l=ftp_search"
set "t14_n=Formatage DISKPART" & set "t14_l=disk_manager"
set "t15_n=Sante Disques (SMART)" & set "t15_l=sys_smart_check"
set "t16_n=Dossiers Volumineux" & set "t16_l=sys_large_files"
set "t17_n=Gestion BitLocker" & set "t17_l=sys_bitlocker_check"
set "t18_n=Batterie ^& RAM" & set "t18_l=sys_hardware_diag"
set "t19_n=Gestion des Drivers" & set "t19_l=sys_drivers"
set "t20_n=Ecran Tactile" & set "t20_l=touch_screen_manager"
set "t21_n=Installation Logiciels" & set "t21_l=install_softwares"
set "t22_n=Mise a Jour Apps (Winget)" & set "t22_l=winget_manager"
set "t23_n=Reset MDP (Utilman)" & set "t23_l=utilman_guide"
set "t24_n=Cle de Produit Win" & set "t24_l=get_win_key"
set "t25_n=Super Administrateur" & set "t25_l=manage_super_admin"
set "t26_n=Menu Win11 Classique" & set "t26_l=context_menu"
set "t27_n=Raccourcis ^& God Mode" & set "t27_l=sys_shortcuts_hub"
set "t28_n=S'approprier (TakeOwn)" & set "t28_l=sys_take_ownership"
set "t29_n=Vitesse Menus" & set "t29_l=sys_menu_showdelay"
set "t30_n=Rapport WinSAT/Systeme" & set "t30_l=menu_reports_key"
set "t31_n=Demarrage ^& Mode Sans Echec" & set "t31_l=menu_boot_safe"
set "max_tools=31"

REM === CHARGEMENT DES FAVORIS ===
set "fav_file=favoris.dat"
if not exist "%fav_file%" (
    echo t14> "%fav_file%"
    echo t21>> "%fav_file%"
    echo t22>> "%fav_file%"
)


:menu_principal
cls
color 0B

REM Nettoyage des anciennes variables boutons
for /f "tokens=1 delims==" %%v in ('set btn_ 2^>nul') do set "%%v="

echo ======================================================
echo     BOITE A SCRIPTS WINDOWS - By ALEEXLEDEV v2.4
echo ======================================================
echo.
echo   ---- [*] FAVORIS ACTUELS ----
set "f_count=0"
for /f "usebackq delims=" %%F in ("%fav_file%") do (
    set /a f_count+=1
    set "f_id=%%F"
    set "f_name=!%%F_n!"
    set "f_label=!%%F_l!"
    echo     [F!f_count!] !f_name!
    set "btn_!f_count!=!f_label!"
)
if %f_count%==0 echo     (Aucun favori selectionne)
echo.
echo     [F] GERER MES FAVORIS
echo.
echo   ---- [+] MAINTENANCE ^& REPARATION ----
echo     [1] SFC / DISM / CHKDSK
echo     [2] Nettoyage (Fichiers, Registre)
echo     [3] Reparer Windows Update ^& Spouleur
echo     [4] Point de Restauration
echo.
echo   ---- [i] INTERNET ^& LOGICIELS ----
echo     [5] DNS ^& Mots de Passe Wi-Fi
echo     [6] Outils ^& Test Reseau
echo     [7] Recherche FTP (Google Dorks)
echo.
echo   ---- [d] DISQUES ^& MATERIEL ----
echo     [8] Sante Disques, Batterie ^& RAM
echo     [9] Dossiers Volumineux ^& BitLocker
echo     [10] Drivers ^& Ecran Tactile
echo.
echo   ---- [s] SYSTEME ^& PERSO ----
echo     [11] Mot de Passe Session ^& Super Admin
echo     [12] Cle Produit ^& Rapports WinSAT
echo     [13] Menu Win11, God Mode ^& Clic-Droit
echo     [14] Demarrage ^& Mode Sans Echec
echo.
echo ======================================================
echo     [0] QUITTER LE SCRIPT
echo ======================================================
set /p main_choice=Votre choix : 

if /i "%main_choice%"=="F" goto manage_favs

REM Gestion des favoris (F1, F2...)
if /i "%main_choice:~0,1%"=="F" (
    set "target_num=%main_choice:~1%"
    for /f "delims=" %%L in ("btn_!target_num!") do (
        if defined %%L (
            set "target_label=!%%L!"
            goto !target_label!
        )
    )
)

if "%main_choice%"=="1" goto menu_maint_diag
if "%main_choice%"=="2" goto sys_clean_options
if "%main_choice%"=="3" goto sys_repair_hub
if "%main_choice%"=="4" goto create_restore_point

if "%main_choice%"=="5" goto menu_internet_wifi
if "%main_choice%"=="6" goto sys_network_hub
if "%main_choice%"=="7" goto ftp_search

if "%main_choice%"=="8" goto sys_hardware_diag
if "%main_choice%"=="9" goto menu_disk_adv
if "%main_choice%"=="10" goto menu_drivers_touch

if "%main_choice%"=="11" goto menu_security_admin
if "%main_choice%"=="12" goto menu_reports_key
if "%main_choice%"=="13" goto menu_tweak_perso
if "%main_choice%"=="14" goto menu_boot_safe

if "%main_choice%"=="0" goto exit_script
echo Choix invalide.
pause
goto menu_principal

:menu_maint_diag
cls
echo ======================================================
echo            DIAGNOSTIC ^& INTEGRITE
echo ======================================================
echo  [1] SFC /scannow
echo  [2] DISM (Check/Restore)
echo  [3] CHKDSK
echo.
echo  [0] Retour
set /p md_choice=Choix: 
if "%md_choice%"=="1" goto sys_sfc
if "%md_choice%"=="2" goto sys_dism_menu
if "%md_choice%"=="3" goto sys_chkdsk
if "%md_choice%"=="0" goto menu_principal
goto menu_maint_diag

:sys_repair_hub
cls
echo ======================================================
echo             REPARATION SERVICES
echo ======================================================
echo  [1] Windows Update (Assistant/Reset)
echo  [2] Spouleur d'Impression
echo.
echo  [0] Retour
set /p rh_choice=Choix: 
if "%rh_choice%"=="1" goto sys_windows_update_hub
if "%rh_choice%"=="2" goto repair_spooler
if "%rh_choice%"=="0" goto menu_principal
goto sys_repair_hub

:menu_internet_wifi
cls
echo ======================================================
echo              CONNEXION ^& WI-FI
echo ======================================================
echo  [1] Gestionnaire DNS
echo  [2] Mots de passe Wi-Fi
echo.
echo  [0] Retour
set /p iw_choice=Choix: 
if "%iw_choice%"=="1" goto dns_manager
if "%iw_choice%"=="2" goto sys_wifi_passwords
if "%iw_choice%"=="0" goto menu_principal
goto menu_internet_wifi

:menu_disk_adv
cls
echo ======================================================
echo             STOCKAGE AVANCE
echo ======================================================
echo  [1] Analyse fichiers volumineux
echo  [2] Gestion BitLocker
echo.
echo  [0] Retour
set /p da_choice=Choix: 
if "%da_choice%"=="1" goto sys_large_files
if "%da_choice%"=="2" goto sys_bitlocker_check
if "%da_choice%"=="0" goto menu_principal
goto menu_disk_adv

:menu_drivers_touch
cls
echo ======================================================
echo             PILOTES ^& MATERIEL
echo ======================================================
echo  [1] Gestionnaire de Pilotes (Drivers)
echo  [2] Gestion Ecran Tactile
echo.
echo  [0] Retour
set /p dt_choice=Choix: 
if "%dt_choice%"=="1" goto sys_drivers
if "%dt_choice%"=="2" goto touch_screen_manager
if "%dt_choice%"=="0" goto menu_principal
goto menu_drivers_touch

:menu_security_admin
cls
echo ======================================================
echo             SECURITE ^& COMPTES
echo ======================================================
echo  [1] Reset Mot de Passe (Utilman)
echo  [2] Gestion Super Admin
echo.
echo  [0] Retour
set /p sa_choice=Choix: 
if "%sa_choice%"=="1" goto utilman_guide
if "%sa_choice%"=="2" goto manage_super_admin
if "%sa_choice%"=="0" goto menu_principal
goto menu_security_admin

:menu_reports_key
cls
echo ======================================================
echo             CLE ^& PERFORMANCES
echo ======================================================
echo  [1] Recuperer Cle Windows
echo  [2] Rapport WinSAT / Systeme
echo.
echo  [0] Retour
set /p rk_choice=Choix: 
if "%rk_choice%"=="1" goto get_win_key
if "%rk_choice%"=="2" goto sys_perf_report_hub
if "%rk_choice%"=="0" goto menu_principal
goto menu_reports_key

:menu_tweak_perso
cls
echo ======================================================
echo             TWEAKS ^& PERSO
echo ======================================================
echo  [1] Menu Windows 11
echo  [2] Raccourcis ^& God Mode
echo  [3] Take Ownership (Clic-droit)
echo  [4] Acceleration Menus
echo.
echo  [0] Retour
set /p tp_choice=Choix: 
if "%tp_choice%"=="1" goto context_menu
if "%tp_choice%"=="2" goto sys_shortcuts_hub
if "%tp_choice%"=="3" goto sys_take_ownership
if "%tp_choice%"=="4" goto sys_menu_showdelay
if "%tp_choice%"=="0" goto menu_principal
goto menu_tweak_perso



REM ===================================================================
REM                    GESTIONNAIRE DNS (GOOGLE / CLOUDFLARE)
REM ===================================================================
:dns_manager
cls
color 0B
echo ================================================
echo     GESTIONNAIRE DNS (GOOGLE / CLOUDFLARE)
echo ================================================
echo.
echo   [1] DNS Google (8.8.8.8 / 8.8.4.4)
echo   [2] DNS Cloudflare (1.1.1.1 / 1.0.0.1)
echo   [3] Restauration des DNS par defaut
echo   [4] Affichage de la configuration actuelle
echo.
echo   [0] Retour au menu principal
echo.
echo ================================================
set /p dns_choice=Choisissez une option: 

if "%dns_choice%"=="1" goto install_google_full
if "%dns_choice%"=="2" goto install_cloudflare_full
if "%dns_choice%"=="3" goto restore_dns
if "%dns_choice%"=="4" goto show_dns_config
if "%dns_choice%"=="0" goto menu_principal
echo Option invalide.
pause
goto dns_manager

:install_google_full
cls
echo ================================================
echo     INSTALLATION DNS GOOGLE (IPv4 + IPv6)
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
netsh interface ip set dns "%interface%" static 8.8.8.8
netsh interface ip add dns "%interface%" 8.8.4.4 index=2

echo Configuration des DNS Google IPv6...
netsh interface ipv6 set dns "%interface%" static 2001:4860:4860::8888
netsh interface ipv6 add dns "%interface%" 2001:4860:4860::8844 index=2

echo Vidage du cache DNS...
ipconfig /flushdns

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
set "fallback_interface="
for /f "skip=3 tokens=1,2,3*" %%a in ('netsh interface show interface') do (
    if /i "%%b"=="Connecté" set "interface=%%d" & goto :interface_found
    if /i "%%b"=="Connected" set "interface=%%d" & goto :interface_found
    if /i "%%c"=="Dédié" if not defined fallback_interface set "fallback_interface=%%d"
    if /i "%%c"=="Dedicated" if not defined fallback_interface set "fallback_interface=%%d"
)
if not defined interface set "interface=%fallback_interface%"
:interface_found
if defined interface (
    set "interface=%interface: =%"
    set "interface=%interface:"=%"
)
goto :eof

REM ===================================================================
REM                   WINGET - Mises à jour des application windows
REM ===================================================================
@echo off
title Gestionnaire Winget + Pilotes
color 0A

:winget_manager
cls
echo ================================================
echo     Mises a jour des apps Windows
echo ================================================
echo.

where winget >nul 2>nul
if errorlevel 1 (
    echo ERREUR: Winget n'est pas installe sur ce systeme.
    echo Veuillez l'installer depuis le Microsoft Store.
    pause
    goto menu_principal
)

echo.
echo   [1] Mettre a jour une application (liste et choix)
echo   [2] Mettre a jour toutes les applications
echo   [3] Voir les application facultatives (Windows Update)
echo.
echo   [0] Retour au menu principal
echo.
set /p winget_choice=Choisissez une option: 

if "%winget_choice%"=="1" goto update_single
if "%winget_choice%"=="2" goto update_all
if "%winget_choice%"=="3" goto check_drivers
if "%winget_choice%"=="0" goto menu_principal
echo Option invalide.
pause
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

:check_drivers
cls
echo ================================================
echo     VERIFICATION DES PILOTES DISPONIBLES
echo ================================================
echo.
echo Ouverture de Windows Update - Mises a jour facultatives...
echo.
start ms-settings:windowsupdate-optionalupdates

echo.
echo Windows Update a ete ouvert.
echo Les pilotes disponibles s'affichent dans "Mises a jour facultatives".
echo.
pause
goto winget_manager

REM =================================================================
REM                    MENU CONTEXTUEL WINDOWS 11
REM =================================================================
:context_menu
cls
color 0E
echo ========================================================
echo    Menu contextuel classique - Windows 11
echo ========================================================
echo.
echo   [1] Activer le menu contextuel classique (recommande)
echo   [2] Restaurer le menu contextuel moderne de Windows 11
echo.
echo   [0] Retour au menu principal
echo.
set /p ctx_choice=Votre choix: 

if "%ctx_choice%"=="1" goto activate_classic
if "%ctx_choice%"=="2" goto restore_modern
if "%ctx_choice%"=="0" goto system_tools
echo Choix invalide.
pause
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
echo.
echo =============================================================
echo.

(echo list disk) | diskpart

echo.
echo =============================================================
echo.
echo ATTENTION : Le formatage effacera TOUTES les donnees !
echo.
echo Entrez le numero du disque a formater (ou 'Q' pour quitter) :
set /p disk_num=Numero du disque: 

if /i "%disk_num%"=="Q" goto menu_principal

echo %disk_num%| findstr.exe /r "^[0-9][0-9]*$" >nul
if %errorLevel% neq 0 (
    echo.
    echo ❌ Erreur : Veuillez entrer un numero valide !
    timeout /t 1 >nul
    goto disk_manager
)

:disk_format_choice
cls
echo.
echo =============================================================
echo               CHOIX DU SYSTEME DE FICHIERS
echo =============================================================
echo.
echo Disque selectionne : DISQUE %disk_num%
echo.
echo Choisissez le format de formatage :
echo.
echo   [1] NTFS      (Recommande pour Windows, fichiers volumineux)
echo   [2] FAT32     (Compatible multi-plateformes, max 4 GB/fichier)
echo   [3] exFAT     (Compatible multi-plateformes, fichiers volumineux)
echo   [4] ReFS      (Systeme de fichiers resilient Windows Server)
echo.
echo   [0] Retour au menu principal
echo.
set /p format_choice=Votre choix: 

if "%format_choice%"=="0" goto menu_principal
if "%format_choice%"=="1" set fs_type=NTFS
if "%format_choice%"=="2" set fs_type=FAT32
if "%format_choice%"=="3" set fs_type=exFAT
if "%format_choice%"=="4" set fs_type=ReFS

if not defined fs_type (
    echo.
    echo ❌ Choix invalide !
    timeout /t 2 >nul
    goto disk_format_choice
)

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
    echo ❌ Operation annulee par l'utilisateur.
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
    echo ✅ Formatage termine avec succes !
    echo.
    echo Le disque %disk_num% a ete :
    echo   - Nettoye completement
    echo   - Partitionne en partition primaire
    echo   - Formate en %fs_type%
    echo   - Une lettre de lecteur lui a ete assignee
    echo.
) else (
    echo.
    echo ❌ Une erreur s'est produite pendant le formatage.
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
cls
color 0D
echo ========================================================
echo         GESTION DU PILOTE D'ECRAN TACTILE
echo ========================================================
echo.
echo   [1] Redemarrer le pilote tactile
echo   [2] Desactiver le pilote tactile
echo   [3] Activer le pilote tactile
echo.
echo   [0] Retour au menu principal
echo.
set /p touch_choice=Votre choix: 

if "%touch_choice%"=="1" goto touch_restart
if "%touch_choice%"=="2" goto touch_disable
if "%touch_choice%"=="3" goto touch_enable
if "%touch_choice%"=="0" goto menu_principal
echo Choix invalide.
pause
goto touch_screen_manager

:touch_restart
cls
echo.
echo === Redemarrage du pilote d'ecran tactile ===
echo.

echo Redemarrage du service TabletInputService...
net stop TabletInputService >nul 2>&1
timeout /t 1 /nobreak >nul
net start TabletInputService >nul 2>&1

echo Redemarrage du service HidServ...
net stop HidServ >nul 2>&1
timeout /t 1 /nobreak >nul
net start HidServ >nul 2>&1

echo.
echo Desactivation/Reactivation du peripherique tactile via PowerShell...
powershell.exe -Command "& { $touchDevices = Get-PnpDevice | Where-Object { ($_.FriendlyName -like '*HID*' -and ($_.FriendlyName -like '*tactile*' -or $_.FriendlyName -like '*touch*')) -or ($_.Class -eq 'HIDClass' -and $_.FriendlyName -like '*ecran*') }; if ($touchDevices) { foreach ($device in $touchDevices) { Write-Host 'Desactivation:' $device.FriendlyName; Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false }; Start-Sleep -Seconds 2; foreach ($device in $touchDevices) { Write-Host 'Reactivation:' $device.FriendlyName; Enable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false } } else { Write-Host 'Aucun peripherique tactile trouve' } }"

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
powershell.exe -Command "& { $touchDevices = Get-PnpDevice | Where-Object { ($_.FriendlyName -like '*HID*' -and ($_.FriendlyName -like '*tactile*' -or $_.FriendlyName -like '*touch*')) -or ($_.Class -eq 'HIDClass' -and $_.FriendlyName -like '*ecran*') }; if ($touchDevices) { foreach ($device in $touchDevices) { Write-Host 'Desactivation:' $device.FriendlyName; Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false } } else { Write-Host 'Aucun peripherique tactile trouve' } }"

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
powershell.exe -Command "& { $touchDevices = Get-PnpDevice | Where-Object { ($_.FriendlyName -like '*HID*' -and ($_.FriendlyName -like '*tactile*' -or $_.FriendlyName -like '*touch*')) -or ($_.Class -eq 'HIDClass' -and $_.FriendlyName -like '*ecran*') }; if ($touchDevices) { foreach ($device in $touchDevices) { Write-Host 'Activation:' $device.FriendlyName; Enable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false } } else { Write-Host 'Aucun peripherique tactile trouve' } }"

echo Demarrage du service TabletInputService...
net start TabletInputService >nul 2>&1

echo.
echo === Pilote tactile active ===
echo.
pause
goto touch_screen_manager

REM ===================================================================
REM                    INSTALLATION LOGICIELS (CHROME / VLC / PDF)
REM ===================================================================
:install_softwares
cls
color 0B
echo ======================================================
echo     INSTALLATION DE LOGICIELS
echo ======================================================
echo.
echo   [1] Google Chrome
echo   [2] Sumatra PDF
echo   [3] VLC Media Player
echo   [4] Installer TOUS les logiciels (Chrome + PDF + VLC)
echo   [5] Pack Office (Telechargement + Install)
echo.
echo   [0] Retour au menu principal
echo.
echo ======================================================
set /p soft_choice=Votre choix: 

if "%soft_choice%"=="1" set "apps=Google.Chrome" & goto install_apps_single
if "%soft_choice%"=="2" set "apps=SumatraPDF.SumatraPDF" & goto install_apps_single
if "%soft_choice%"=="3" set "apps=VideoLAN.VLC" & goto install_apps_single
if "%soft_choice%"=="4" goto install_apps_all
if "%soft_choice%"=="5" goto install_office
if "%soft_choice%"=="0" goto menu_principal
echo Choix invalide.
pause
goto install_softwares

:install_apps_single
cls
echo Installation de %apps% en cours...
winget install -e --id %apps% --accept-source-agreements --accept-package-agreements
echo.
echo Installation terminee.
pause
goto install_softwares

:install_apps_all
cls
echo Installation de TOUS les logiciels en cours...
echo.
echo 1/3 Installation de Google Chrome...
winget install -e --id Google.Chrome --accept-source-agreements --accept-package-agreements
echo.
echo 2/3 Installation de Sumatra PDF...
winget install -e --id SumatraPDF.SumatraPDF --accept-source-agreements --accept-package-agreements
echo.
echo 3/3 Installation de VLC Media Player...
winget install -e --id VideoLAN.VLC --accept-source-agreements --accept-package-agreements
echo.
echo Toutes les installations sont terminees !
pause
goto install_softwares

:install_office
cls
echo ======================================================
echo    TELECHARGEMENT ET INSTALLATION DE MICROSOFT OFFICE
echo ======================================================
echo.
echo Telechargement de l'installateur en cours...
echo Veuillez patienter, cela peut prendre un moment selon votre connexion.
echo.

set "office_installer=%temp%\OfficeSetup.exe"
curl -L -o "%office_installer%" "https://drive.usercontent.google.com/download?id=1wf1eqVkXIM0f0R2963Ee4RKK-a_rgWld&export=download&authuser=0&confirm=t&uuid=941d1835-9870-4115-8baa-5155c2bcbeb8&at=AKSUxGOpxt6HuTVCq4_qMaWEBFoX:1761170678446"

if exist "%office_installer%" (
    echo.
    echo Telechargement reussi. Lancement de l'installation...
    echo.
    start /wait "" "%office_installer%"
    echo.
    echo Installation lancee. Suivez les instructions a l'ecran.
    echo Une fois termine, appuyez sur une touche.
) else (
    echo.
    echo ERREUR : Le telechargement a echoue.
    echo Verifiez votre connexion internet.
)
pause
goto install_softwares

REM ===================================================================
REM               RACCOURCIS BUREAU (ARRET / VEILLE / REDEMARRER)
REM ===================================================================
:shortcuts_manager
cls
color 0E
echo ======================================================
echo     CREATION DE RACCOURCIS BUREAU
echo ======================================================
echo.
echo   [1] Creer raccourci "Arreter"
echo   [2] Creer raccourci "Mettre en veille"
echo   [3] Creer raccourci "Redemarrer"
echo   [4] Creer les 3 raccourcis
echo.
echo   [0] Retour au menu principal
echo.
echo ======================================================
set /p shortcut_choice=Votre choix: 

if "%shortcut_choice%"=="1" goto create_shutdown
if "%shortcut_choice%"=="2" goto create_sleep
if "%shortcut_choice%"=="3" goto create_restart
if "%shortcut_choice%"=="4" goto create_all_shortcuts
if "%shortcut_choice%"=="0" goto system_tools
echo Choix invalide.
pause
goto shortcuts_manager

:create_shutdown
echo.
echo Creation du raccourci ARRET...
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%USERPROFILE%\Desktop\Arret_PC.lnk'); $s.TargetPath = 'shutdown.exe'; $s.Arguments = '/s /t 0'; $s.IconLocation = '%SystemRoot%\system32\shell32.dll,27'; $s.Save()"
echo Raccourci cree sur le Bureau !
pause
goto shortcuts_manager

:create_sleep
echo.
echo Creation du raccourci VEILLE...
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%USERPROFILE%\Desktop\Veille_PC.lnk'); $s.TargetPath = 'rundll32.exe'; $s.Arguments = 'powrprof.dll,SetSuspendState 0,1,0'; $s.IconLocation = '%SystemRoot%\system32\shell32.dll,223'; $s.Save()"
echo Raccourci cree sur le Bureau !
pause
goto shortcuts_manager

:create_restart
echo.
echo Creation du raccourci REDEMARRAGE...
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%USERPROFILE%\Desktop\Redemarrer_PC.lnk'); $s.TargetPath = 'shutdown.exe'; $s.Arguments = '/r /t 0'; $s.IconLocation = '%SystemRoot%\system32\shell32.dll,238'; $s.Save()"
echo Raccourci cree sur le Bureau !
pause
goto shortcuts_manager

:create_all_shortcuts
echo.
echo Creation des 3 raccourcis...
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%USERPROFILE%\Desktop\Arret_PC.lnk'); $s.TargetPath = 'shutdown.exe'; $s.Arguments = '/s /t 0'; $s.IconLocation = '%SystemRoot%\system32\shell32.dll,27'; $s.Save()"
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%USERPROFILE%\Desktop\Veille_PC.lnk'); $s.TargetPath = 'rundll32.exe'; $s.Arguments = 'powrprof.dll,SetSuspendState 0,1,0'; $s.IconLocation = '%SystemRoot%\system32\shell32.dll,223'; $s.Save()"
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%USERPROFILE%\Desktop\Redemarrer_PC.lnk'); $s.TargetPath = 'shutdown.exe'; $s.Arguments = '/r /t 0'; $s.IconLocation = '%SystemRoot%\system32\shell32.dll,238'; $s.Save()"
echo Termine !
pause
goto shortcuts_manager

REM ===================================================================
REM               RECHERCHE FTP / INDEX OF (GOOGLE DORKS)
REM ===================================================================
:ftp_search
cls
color 0D
echo ======================================================
echo     RECHERCHE AVANCEE (Index Of / FTP)
echo ======================================================
echo.
echo   Cet outil utilise des commandes Google (Dorks) pour
echo   trouver des repertoires ouverts (Index Of).
echo.
echo   Que recherchez-vous ?
echo.
echo   [1] Musique (mp3, wav, flac...)
echo   [2] Video (mkv, avi, mp4...)
echo   [3] Documents (Office, PDF, TXT...)
echo   [4] Logiciels / Executables (exe, iso, rar...)
echo   [5] Images (jpg, png...)
echo   [6] Personnalise (choisir l'extension)
echo.
echo   [0] Retour
echo.
echo ======================================================
set /p ftp_type=Votre choix: 

if "%ftp_type%"=="0" goto system_tools
if "%ftp_type%"=="1" goto set_type_music
if "%ftp_type%"=="2" goto set_type_video
if "%ftp_type%"=="3" goto set_type_docs
if "%ftp_type%"=="4" goto set_type_soft
if "%ftp_type%"=="5" goto set_type_img
if "%ftp_type%"=="6" goto ftp_custom_ext
goto ftp_search

:set_type_music
set "file_ext=(mp3|wav|flac|aac|ogg)"
goto ftp_query

:set_type_video
set "file_ext=(mkv|avi|mp4|mov|wmv)"
goto ftp_query

:set_type_docs
set "file_ext=(pdf|txt|doc|docx|xls|xlsx|csv|ppt|pptx|pps|epub|odt)"
goto ftp_query

:set_type_soft
set "file_ext=(exe|iso|rar|zip|apk)"
goto ftp_query

:set_type_img
set "file_ext=(jpg|png|gif|bmp)"
goto ftp_query

:ftp_custom_ext
echo.
set /p user_ext=Entrez l'extension (ex: py, php, bat) : 
set "file_ext=(%user_ext%)"
goto ftp_query

REM ===================================================================
REM                    MOTEUR DE RECHERCHE VIA POWERSHELL
REM ===================================================================
:ftp_query
echo.
echo Entrez le nom du fichier ou votre recherche :
set /p user_query=Recherche : 
if "%user_query%"=="" goto ftp_search

echo.
echo Recherche : %user_query%
echo.
echo Lancement de la recherche Google (Moteur Avance)...

REM Definition du Dork Google
REM On passe les variables a PowerShell via l'environnement pour eviter les problemes avec les caracteres speciaux
set "file_ext=%file_ext%"
set "user_query=%user_query%"

powershell -Command "$ext = $env:file_ext; $query = $env:user_query; $baseUrl = 'https://www.google.com/search?q='; $dork = 'intitle:\"index of\" \"parent directory\" ' + $ext + ' \"' + $query + '\"'; Write-Host 'Requete :' $dork; $url = $baseUrl + [Uri]::EscapeDataString($dork); Start-Process $url"

echo.
echo La page de resultats devrait s'ouvrir dans votre navigateur.
pause
goto ftp_search

REM ===================================================================
REM                    OUTILS SYSTEME AVANCES
REM ===================================================================
:sys_dism_menu
cls
echo ======================================================
echo             OUTILS DISM (IMAGE WINDOWS)
echo ======================================================
echo.
echo   [1] Verification rapide (CheckHealth)
echo   [2] Correction avancee (RestoreHealth)
echo.
echo   [0] Retour
echo.
set /p dism_c=Choix: 
if "%dism_c%"=="1" goto sys_dism_check
if "%dism_c%"=="2" goto sys_dism_restore
if "%dism_c%"=="0" goto menu_maintenance
goto sys_dism_menu

:sys_clean_options
cls
echo ======================================================
echo               NETTOYAGE SYSTEME
echo ======================================================
echo.
echo   [1] Nettoyage de disque Windows (cleanmgr)
echo   [2] Suppression des fichiers temporaires (Script)
echo.
echo   [0] Retour
echo.
set /p clean_c=Choix: 
if "%clean_c%"=="1" goto sys_cleanmgr
if "%clean_c%"=="2" goto sys_temp_cleanup
if "%clean_c%"=="0" goto menu_maintenance
goto sys_clean_options

:sys_windows_update_hub
cls
echo ======================================================
echo            REPARATION WINDOWS UPDATE
echo ======================================================
echo.
echo   [1] Assistant de reparation Windows Update
echo   [2] Reinitialisation complete des composants
echo.
echo   [0] Retour
echo.
set /p wu_c=Choix: 
if "%wu_c%"=="1" goto sys_windows_update
if "%wu_c%"=="2" goto sys_reset_windows_update
if "%wu_c%"=="0" goto menu_maintenance
goto sys_windows_update_hub

:sys_network_hub
cls
echo ======================================================
echo                  OUTILS RESEAU
echo ======================================================
echo.
echo   [1] Afficher les informations IP
echo   [2] Redemarrer les cartes reseau
echo   [3] Reparation reseau automatique
echo.
echo   [0] Retour
echo.
set /p net_h=Choix: 
if "%net_h%"=="1" goto sys_ipconfig
if "%net_h%"=="2" goto sys_restart_network
if "%net_h%"=="3" goto sys_repair_network
if "%net_h%"=="0" goto menu_internet_logiciels
goto sys_network_hub

:sys_hardware_diag
cls
echo ======================================================
echo               HARDWARE ^& DIAGNOSTIC
echo ======================================================
echo.
echo   [1] Rapport de sante Batterie
echo   [2] Diagnostic Memoire (RAM)
echo.
echo   [0] Retour
echo.
set /p hard_c=Choix: 
if "%hard_c%"=="1" goto sys_battery_report
if "%hard_c%"=="2" goto sys_ram_check
if "%hard_c%"=="0" goto menu_disques_materiel
goto sys_hardware_diag

:sys_shortcuts_hub
cls
echo ======================================================
echo            RACCOURCIS ^& PERSONNALISATION
echo ======================================================
echo.
echo   [1] Creer Raccourcis Bureau (Arret/Veille/etc.)
echo   [2] Creer le dossier "God Mode"
echo.
echo   [0] Retour
echo.
set /p short_c=Choix: 
if "%short_c%"=="1" goto shortcuts_manager
if "%short_c%"=="2" goto sys_god_mode
if "%short_c%"=="0" goto menu_systeme_perso
goto sys_shortcuts_hub

:sys_perf_report_hub
cls
echo ======================================================
echo             PERFORMANCES ^& RAPPORTS
echo ======================================================
echo.
echo   [1] Generer un rapport systeme complet
echo   [2] Analyse de performance WinSAT
echo.
echo   [0] Retour
echo.
set /p perf_c=Choix: 
if "%perf_c%"=="1" goto sys_report
if "%perf_c%"=="2" goto sys_winsat
if "%perf_c%"=="0" goto menu_systeme_perso
goto sys_perf_report_hub

:system_tools
goto menu_principal


:sys_sfc
cls
echo Analyse des fichiers systeme (SFC /scannow)...
sfc /scannow
pause
goto system_tools

:sys_winsat
cls
echo ========================================================
echo        ANALYSE DE PERFORMANCE DU PC (WinSAT)
echo ========================================================
echo.
echo ATTENTION : 
echo 1. Cette operation peut prendre plusieurs minutes.
echo 2. Votre ecran clignotera pendant les tests graphiques.
echo 3. VOUS DEVEZ ETRE BRANCHE SUR SECTEUR (sinon erreur).
echo.
echo Appuyez sur une touche pour commencer l'analyse...
pause >nul

echo.
echo Execution des tests en cours...
winsat formal
echo.
echo Analyse terminee. Affichage des resultats...
timeout /t 2 >nul

:winsat_show_results
cls
echo.
echo ========================================================
echo               RESULTATS DE PERFORMANCE
echo ========================================================
echo.
powershell -Command "Get-CimInstance Win32_WinSat | Select-Object @{N='Processeur';E={$_.CPUScore}}, @{N='Memoire RAM';E={$_.MemoryScore}}, @{N='Graphique';E={$_.GraphicsScore}}, @{N='Jeux 3D';E={$_.D3DScore}}, @{N='Disque Dur';E={$_.DiskScore}}, @{N='Score Global';E={$_.WinSPRLevel}} | Format-List"
echo.
echo Note : Les scores sont sur une echelle de 1.0 a 9.9.
echo.
pause
goto system_tools

:sys_menu_showdelay
cls
echo ================================================
echo    Acceleration des menus (MenuShowDelay = 10)
echo ================================================
echo.
set "TARGET_VALUE=10"
echo Modification du registre...
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "%TARGET_VALUE%" /f >nul 2>&1
if errorlevel 1 (
    echo Echec lors de la modification du registre.
    echo.
    pause
    goto system_tools
)

echo Modification reussie.
echo.
echo Redemarrage de l'Explorateur Windows...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
start "" explorer.exe >nul 2>&1

echo.
echo MenuShowDelay defini a %TARGET_VALUE%.
echo L'Explorateur a ete redemarre.
echo.
pause
goto system_tools

:sys_dism_check
cls
echo Verification de l'etat de Windows (DISM /CheckHealth)...
dism /online /cleanup-image /checkhealth
pause
goto system_tools

:sys_dism_restore
cls
echo Restauration de l'etat de Windows (DISM /RestoreHealth)...
dism /online /cleanup-image /restorehealth
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
    shutdown.exe /r /t 5 >nul 2>&1
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

for /f "delims=" %%d in ('powershell.exe -NoProfile -Command ^
  "Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -ne $null } | ForEach-Object { $_.Name + ':' }" 
') do (
    echo.
    echo Analyse du lecteur %%d ...
    chkdsk.exe %%d /f /r /x
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
echo Analyse du Registre en cours (mode optimise)...
set "regTempFile=%TEMP%\reg_uninstall_keys.txt"
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall 2>nul > "%regTempFile%"

for /f "usebackq delims=" %%A in ("%regTempFile%") do (
    set /a count+=1
    set "entries[!count!]=%%A"
)

for /f "delims=" %%B in ('findstr /I "IE40 IE4Data DirectDrawEx DXM_Runtime SchedulingAgent" "%regTempFile%"') do (
    set /a safe_count+=1
    set "safe_entries[!safe_count!]=%%B"
)
if exist "%regTempFile%" del "%regTempFile%"

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

for /f "usebackq delims=" %%d in (`powershell.exe -NoProfile -Command "$env:USERPROFILE + '\Desktop'"`) do (
    set "DESKTOP=%%d"
)

for /f "usebackq delims=" %%t in (`powershell.exe -NoProfile -Command "Get-Date -Format yyyy-MM-dd"`) do (
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
echo [2] Retour au menu
echo.
set /p fixchoice=Choisissez une option: 

if "%fixchoice%"=="1" goto reset_wu_services
if "%fixchoice%"=="2" goto system_tools

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
cls
call :wifi_collect
echo Profils Wi-Fi trouves:
echo.
if %found%==0 (
	echo Aucun profil Wi-Fi trouve ou sortie non reconnue.
) else (
	set /a idx=0
	for /f "tokens=1,2 delims=|" %%A in ('type "%MAPFILE%"') do (
		set /a idx+=1
		echo  [!idx!] SSID: %%A ^| MDP: %%B
	)
)

echo.
echo ===============================================
echo   [1] Supprimer un reseau Wi-Fi
echo   [2] Generer un rapport sur le Bureau
echo   [0] Retour
echo ===============================================
set /p wchoice=Votre choix: 
if "%wchoice%"=="1" goto wifi_display
if "%wchoice%"=="2" goto wifi_report
if "%wchoice%"=="0" goto wifi_exit

echo Choix invalide.
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
cls
echo Profils Wi-Fi trouves:
echo.
if %found%==0 (
	echo Aucun profil Wi-Fi trouve ou sortie non reconnue.
	pause
	goto menu_wifi
)
set /a idx=0
for /f "tokens=1,2 delims=|" %%A in ('type "%MAPFILE%"') do (
	set /a idx+=1
	echo  [!idx!] SSID: %%A ^| MDP: %%B
)

echo.
set /p delidx=Supprimer un profil ? Entrez le numero (0 pour annuler): 
if "%delidx%"=="0" goto menu_wifi

set "_raw=%delidx%"
set "_num=%_raw: =%"
for /f "delims=0123456789" %%X in ("!_num!") do set "_num_invalid=1"
if defined _num_invalid (
	echo Numero invalide.
	pause
	goto menu_wifi
)
set /a _check=%_num% + 0 >nul 2>&1
if errorlevel 1 (
	echo Numero invalide.
	pause
	goto menu_wifi
)
if %_num% lss 1 (
	echo Numero hors plage.
	pause
	goto menu_wifi
)

set /a idx=0
set "TARGET="
for /f "tokens=1,2 delims=|" %%A in ('type "%MAPFILE%"') do (
	set /a idx+=1
	if !idx! EQU %_num% set "TARGET=%%A"
)
if not defined TARGET (
	echo Numero hors plage.
	pause
	goto menu_wifi
)

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

:create_restore_point
cls
color 0B
echo ======================================================
echo    CREATION POINT DE RESTAURATION
echo ======================================================
echo.
echo Voulez-vous creer un point de restauration maintenant ?
echo Cela est recommande AVANT toute modification systeme.
echo.
set /p confirm=Confirmer la creation ? (O/N) : 
if /i not "%confirm%"=="O" goto system_tools

echo.
echo Creation du point de restauration en cours...
echo Veuillez patienter (cela peut prendre quelques secondes)...
echo.
powershell -Command "Checkpoint-Computer -Description 'Sauvegarde Script AleexLeDev' -RestorePointType 'MODIFY_SETTINGS'"
if %errorlevel% neq 0 (
    echo.
    echo [ERREUR] Impossible de creer le point de restauration.
    echo Verifiez que la protection systeme est activee sur le disque C:
) else (
    echo.
    echo [SUCCES] Point de restauration cree avec succes !
)
pause
goto system_tools

:utilman_guide
cls
color 0C
echo ======================================================
echo    REINITIALISATION MDP - UTILMAN (AUTOMATIQUE)
echo ======================================================
echo.
echo  Cet outil remplace utilman.exe par cmd.exe pour
echo  permettre la reinitialisation du mot de passe.
echo.
echo  MODES D'UTILISATION :
echo  ---------------------
echo  [1] Mode MANUEL (Lire le tutoriel texte)
echo  [2] Mode AUTO - OFFLINE (Recommande - Depuis WinRE/USB)
echo  [3] Mode AUTO - ONLINE (Force permissions - Risque)
echo  [4] RESTAURER Utilman d'origine (Annuler le hack)
echo.
echo  [0] Retour
echo.
set /p util_choice=Votre choix: 

if "%util_choice%"=="1" goto utilman_text
if "%util_choice%"=="2" goto utilman_auto_offline
if "%util_choice%"=="3" goto utilman_auto_online
if "%util_choice%"=="4" goto utilman_restore
if "%util_choice%"=="0" goto system_tools
goto utilman_guide

:utilman_text
cls
echo ======================================================
echo    TUTORIEL MANUEL (Lecture seule)
echo ======================================================
echo.
echo 1) Demarrer sur une cle USB Windows ou WinRE.
echo 2) Ouvrir l'invite de commande (Shift + F10).
echo 3) Identifier le disque Windows (ex: Z:).
echo 4) Commandes a taper :
echo    copy Z:\Windows\System32\utilman.exe Z:\Windows\System32\utilman.exe.bak
echo    copy Z:\Windows\System32\cmd.exe Z:\Windows\System32\utilman.exe
echo 5) Redemarrer et cliquer sur l'icone Ergonomie.
echo 6) Taper : net user pseudo nouveau_mdp
echo.
pause
goto utilman_guide

:utilman_auto_offline
cls
echo.
echo  MODE AUTOMATIQUE OFFLINE
echo  ------------------------
echo  A utiliser si vous avez demarre sur une cle USB ou WinRE.
echo.
echo  Entrez la lettre du lecteur qui contient Windows
echo  (Attention : En WinRE, C: n'est pas toujours Windows !)
echo.
set /p target_dir=Lettre du lecteur (ex: C, D, E) : 
if "%target_dir%"=="" goto utilman_guide
set "sys32=%target_dir%:\Windows\System32"

if not exist "%sys32%\utilman.exe" (
    echo.
    echo [ERREUR] utilman.exe introuvable sur %target_dir%:
    echo Verifiez la lettre du lecteur (essayez D ou E).
    pause
    goto utilman_auto_offline
)

echo.
echo 1. Sauvegarde de utilman.exe...
copy /y "%sys32%\utilman.exe" "%sys32%\utilman.exe.bak"
if errorlevel 1 (
    echo [ERREUR] Echec de la sauvegarde.
    pause
    goto utilman_guide
)

echo 2. Remplacement par cmd.exe...
copy /y "%sys32%\cmd.exe" "%sys32%\utilman.exe"
if errorlevel 1 (
    echo [ERREUR] Echec du remplacement.
    pause
    goto utilman_guide
)

echo.
echo [SUCCES] Hack applique ! Redemarrez et cliquez sur l'icone Ergonomie.
pause
goto utilman_guide

:utilman_auto_online
cls
echo.
echo  MODE AUTOMATIQUE ONLINE (FORCE)
echo  -------------------------------
echo  Cette methode tente de modifier les fichiers pendant que
echo  Windows est allume. Cela necessite de changer les droits.
echo.
echo  ATTENTION : Windows Defender peut bloquer/restaurer le fichier.
echo.
set /p confirm=Voulez-vous continuer ? (O/N) : 
if /i not "%confirm%"=="O" goto utilman_guide

echo.
echo Creation automatique d'un point de restauration...
powershell -Command "Checkpoint-Computer -Description 'Sauvegarde Avant Hack Utilman' -RestorePointType 'MODIFY_SETTINGS'"
if %errorlevel% neq 0 (
    echo.
    echo [ATTENTION] Impossible de creer le point de restauration.
    echo Voulez-vous quand meme continuer ? (O/N)
    set /p ignore_restore=
    if /i not "!ignore_restore!"=="O" goto utilman_guide
) else (
    echo [OK] Point de restauration cree.
)
echo.

set "sys32=%SystemRoot%\System32"

echo.
echo 1. Prise de possession de utilman.exe...
takeown /f "%sys32%\utilman.exe"
icacls "%sys32%\utilman.exe" /grant Administrators:F

echo.
echo 2. Sauvegarde et Remplacement...
copy /y "%sys32%\utilman.exe" "%sys32%\utilman.exe.bak"
copy /y "%sys32%\cmd.exe" "%sys32%\utilman.exe"

echo.
echo Operation terminee. Verifiez les messages d'erreur ci-dessus.
pause
goto utilman_guide

:utilman_restore
cls
echo.
echo  RESTAURATION ORIGINALE
echo  ----------------------
echo.
set /p target_dir=Lettre du lecteur (Laisser vide pour %SystemDrive:~0,1%) : 
if "%target_dir%"=="" set "target_dir=%SystemDrive:~0,1%"
set "sys32=%target_dir%:\Windows\System32"

if not exist "%sys32%\utilman.exe.bak" (
    echo.
    echo [ERREUR] Sauvegarde .bak introuvable sur %target_dir%:
    pause
    goto utilman_guide
)

echo.
echo Restauration en cours...
copy /y "%sys32%\utilman.exe.bak" "%sys32%\utilman.exe"
if errorlevel 1 (
    echo.
    echo [ACCES REFUSE] Tentative de forcer les droits...
    takeown /f "%sys32%\utilman.exe"
    icacls "%sys32%\utilman.exe" /grant Administrators:F
    copy /y "%sys32%\utilman.exe.bak" "%sys32%\utilman.exe"
)

echo.
echo Restauration terminee.
pause
goto utilman_guide

:manage_super_admin
cls
echo ======================================================
echo    GESTION DU COMPTE SUPER ADMINISTRATEUR
echo ======================================================
echo.
echo Le compte "Super Admin" a tous les privileges (Systeme).
echo UAC desactive, acces total aux fichiers systeme.
echo.
echo   [1] ACTIVER le compte Super Admin
echo   [2] DESACTIVER le compte Super Admin (Cache)
echo.
echo   [0] Retour
echo.
set /p admin_choice=Votre choix: 

if "%admin_choice%"=="1" goto enable_super_admin_exec
if "%admin_choice%"=="2" goto disable_super_admin_exec
if "%admin_choice%"=="0" goto system_tools
goto manage_super_admin

:enable_super_admin_exec
net user administrateur /active:yes
if %errorlevel% equ 0 (
    echo.
    echo [SUCCES] Le compte Super Admin est ACTIF.
    echo Il apparaitra au prochain demarrage ou changement de session.
) else (
    echo.
    echo [ECHEC] Erreur. Etes-vous bien lance en Administrateur ?
)
pause
goto system_tools

:disable_super_admin_exec
net user administrateur /active:no
if %errorlevel% equ 0 (
    echo.
    echo [SUCCES] Le compte Super Admin est DESACTIVE (Cache).
) else (
    echo.
    echo [ECHEC] Erreur lors de la desactivation.
)
pause
goto system_tools

:sys_take_ownership
cls
echo ======================================================
echo    GESTION DU CLIC-DROIT : S'APPROPRIER (TAKE OWNERSHIP)
echo ======================================================
echo.
echo Cette option permet d'ajouter ou de retirer une entree 
echo au menu clic-droit pour s'approprier n'importe quel 
echo fichier ou dossier (utile en cas d'Acces refuse).
echo.
echo   [1] AJOUTER l'option au clic-droit
echo   [2] RETIRER l'option du clic-droit
echo.
echo   [0] Retour
echo.
set /p take_choice=Votre choix : 

if "%take_choice%"=="0" goto system_tools
if "%take_choice%"=="1" goto add_take_ownership
if "%take_choice%"=="2" goto remove_take_ownership
goto sys_take_ownership

:add_take_ownership
echo Modification du registre pour l'ajout...
reg add "HKCR\*\shell\runas" /ve /t REG_SZ /d "S'approprier (Take Ownership)" /f >nul 2>&1
reg add "HKCR\*\shell\runas" /v "NoWorkingDirectory" /t REG_SZ /d "" /f >nul 2>&1
reg add "HKCR\*\shell\runas\command" /ve /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" && icacls \"%%1\" /grant administrators:F" /f >nul 2>&1
reg add "HKCR\*\shell\runas\command" /v "IsolatedCommand" /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" && icacls \"%%1\" /grant administrators:F" /f >nul 2>&1
reg add "HKCR\Directory\shell\runas" /ve /t REG_SZ /d "S'approprier (Take Ownership)" /f >nul 2>&1
reg add "HKCR\Directory\shell\runas" /v "NoWorkingDirectory" /t REG_SZ /d "" /f >nul 2>&1
reg add "HKCR\Directory\shell\runas\command" /ve /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" /r /d y && icacls \"%%1\" /grant administrators:F /t" /f >nul 2>&1
reg add "HKCR\Directory\shell\runas\command" /v "IsolatedCommand" /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" /r /d y && icacls \"%%1\" /grant administrators:F /t" /f >nul 2>&1
echo.
echo [OK] L'option a ete ajoutee au menu contextuel.
pause
goto system_tools

:remove_take_ownership
echo Modification du registre pour la suppression...
reg delete "HKCR\*\shell\runas" /f >nul 2>&1
reg delete "HKCR\Directory\shell\runas" /f >nul 2>&1
echo.
echo [OK] L'option a ete retiree du menu contextuel.
pause
goto system_tools

:sys_god_mode
cls
echo ======================================================
echo    CREATION DU DOSSIER "GOD MODE"
echo ======================================================
echo.
echo Le "God Mode" est un dossier special qui regroupe tous
echo les parametres de Windows au meme endroit.
echo.
set /p confirm_god=Creer le dossier sur le Bureau ? (O/N) : 
if /i not "%confirm_god%"=="O" goto system_tools

mkdir "%USERPROFILE%\Desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}" 2>nul
echo.
echo [SUCCES] Le dossier "GodMode" a ete cree sur votre Bureau.
pause
goto system_tools

:sys_large_files
cls
echo ======================================================
echo    VERIFICATEUR DE DONNEES VOLUMINEUSES
echo ======================================================
echo.
echo  Que voulez-vous analyser sur le disque C: ?
echo.
echo   [1] Les 20 FICHIERS les plus lourds
echo   [2] Les 20 DOSSIERS les plus lourds (Analyse racine)
echo.
echo   [0] Retour
echo.
set /p scan_choice=Votre choix : 

if "%scan_choice%"=="1" goto scan_files
if "%scan_choice%"=="2" goto scan_folders
if "%scan_choice%"=="0" goto system_tools
goto sys_large_files

:scan_files
cls
echo ======================================================
echo    ANALYSE DES FICHIERS LES PLUS LOURDS
echo ======================================================
echo.
echo [INFO] Scan en cours sur C:\...
echo [CONSEIL] Appuyez sur CTRL+C pour annuler la recherche.
echo.
powershell -NoProfile -Command "$fichiers = New-Object System.Collections.Generic.List[PSObject]; Get-ChildItem -Path C:\ -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object { if ($_.Length -gt 100MB) { Write-Host 'Analyse :' $_.FullName -ForegroundColor Gray; $fichiers.Add($_) } }; echo ''; echo '--- TOP 20 DES FICHIERS LES PLUS LOURDS ---'; $fichiers | Sort-Object Length -Descending | Select-Object -First 20 | ForEach-Object { [PSCustomObject]@{ 'Nom' = $_.Name; 'Taille(Go)' = [math]::Round($_.Length / 1GB, 2); 'Chemin' = $_.FullName } } | Format-Table -AutoSize"
echo.
pause
goto system_tools

:scan_folders
cls
echo ======================================================
echo    ANALYSE DES DOSSIERS LES PLUS LOURDS
echo ======================================================
echo.
echo [INFO] Scan en cours sur C:\ (Analyse des dossiers racines)...
echo [CONSEIL] Appuyez sur CTRL+C pour annuler la recherche.
echo.
powershell -NoProfile -Command "$resultats = @(); $dossiers = Get-ChildItem -Path C:\ -Directory -ErrorAction SilentlyContinue; foreach ($d in $dossiers) { Write-Host 'Analyse du dossier :' $d.FullName -ForegroundColor Gray; try { $taille = (Get-ChildItem $d.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum; if ($taille -gt 0) { $obj = [PSCustomObject]@{ 'Nom' = $d.Name; 'Taille(Go)' = [math]::Round($taille / 1GB, 2); 'Chemin' = $d.FullName }; $resultats += $obj } } catch {} }; echo ''; echo '--- TOP 20 DES DOSSIERS LES PLUS LOURDS ---'; $resultats | Sort-Object 'Taille(Go)' -Descending | Select-Object -First 20 | Format-Table -AutoSize"
echo.
pause
goto system_tools

:sys_battery_report
cls
echo ======================================================
echo     ANALYSE DE LA BATTERIE
echo ======================================================
echo.
echo Generation du rapport via powercfg...
set "report_path=%USERPROFILE%\Desktop\battery-report.html"
powercfg /batteryreport /output "%report_path%" >nul

if exist "%report_path%" (
    echo.
    echo Rapport genere : %report_path%
    echo.
    echo Analyse du fichier en cours...
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$c = Get-Content -Path '%report_path%' -Raw; $dPat = '(?:DESIGN CAPACITY|CAPACIT. DE CONCEPTION).*?(\d[\d\s\.,]*)\s*mWh'; $fPat = '(?:FULL CHARGE CAPACITY|CAPACIT. DE RECHARGE COMPL.TE).*?(\d[\d\s\.,]*)\s*mWh'; $cPat = '(?:CYCLE COUNT|NOMBRE DE CYCLES).*?<\/td>\s*<td>\s*(\d+)'; $chemPat = '(?:CHEMISTRY|CHIMIE).*?<\/td>\s*<td>\s*(\w+)'; $d=0; $f=0; if($c -match $dPat){$d=[long]($matches[1] -replace '[^0-9]','')}; if($c -match $fPat){$f=[long]($matches[1] -replace '[^0-9]','')}; if($d -gt 0){$pc=[math]::Round(($f/$d)*100, 2); Write-Host 'Technologie        :' $(if($c -match $chemPat){$matches[1]}else{'Inconnue'}) -ForegroundColor Gray; Write-Host 'Cycles de charge   :' $(if($c -match $cPat){$matches[1]}else{'Non disponible'}) -ForegroundColor Cyan; Write-Host 'Capacite Usine     :' $d 'mWh' -ForegroundColor Gray; Write-Host 'Capacite Actuelle  :' $f 'mWh' -ForegroundColor Gray; Write-Host 'SANTE BATTERIE     :' $pc '%' -ForegroundColor Green} else {Write-Host 'Impossible de trouver les valeurs de capacite dans le rapport.' -ForegroundColor Yellow}"
    echo.
) else (
    echo.
    echo Erreur lors de la generation du rapport.
)

echo.
pause
goto system_tools

:sys_smart_check
cls
echo ======================================================
echo     ETAT DE SANTE DES DISQUES (S.M.A.R.T)
echo ======================================================
echo.
echo Analyse en cours...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PhysicalDisk | Sort-Object DeviceId | ForEach-Object { $d=$_; $s=$d.Size; if($s -gt 1099511627776){$sz=[math]::Round($s/1TB,2).ToString()+' To'}else{$sz=[math]::Round($s/1GB,0).ToString()+' Go'}; $h=$d.HealthStatus; if($h -eq 'Healthy'){$h='Bonne Sante'}elseif($h -eq 'Warning'){$h='ATTENTION'}elseif($h -eq 'Unhealthy'){$h='CRITIQUE'}; $ct=($d | Get-StorageReliabilityCounter -ErrorAction SilentlyContinue); if($ct.Wear -ne $null){$p=100-$ct.Wear; $h=$h+' ('+$p+'%%)'}; $lws=($d | Get-Disk -ErrorAction SilentlyContinue | Get-Partition -ErrorAction SilentlyContinue | Where-Object DriveLetter | Select-Object -ExpandProperty DriveLetter) -join ' '; if($lws){$ltr='['+$lws+']'}else{$ltr='    '}; $t=$d.MediaType; if($d.BusType -eq 'USB'){$t='USB'}elseif($t -eq 'Unspecified'){$t='---'}; Write-Host ('{0,-6} [{1,-3}] {2,-30} ({3}) : {4}' -f $ltr, $t, $d.FriendlyName, $sz, $h) }"

echo.
pause
goto system_tools

:sys_ram_check
cls
echo ======================================================
echo     DIAGNOSTIC MEMOIRE WINDOWS (RAM)
echo ======================================================
echo.
echo L'outil de diagnostic de memoire Windows (mdsched.exe)
echo permet de tester vos barrettes de RAM au demarrage.
echo.
echo Voulez-vous redemarrer maintenant pour lancer le test ?
echo.
echo   [O] OUI - Redemarrer maintenant
echo   [N] NON - Planifier au prochain redemarrage
echo   [A] Annuler
echo.
set /p ram_choice=Votre choix : 
if /i "%ram_choice%"=="O" (
    mdsched.exe /temp on
    goto system_tools
) 
if /i "%ram_choice%"=="N" (
    mdsched.exe
    echo.
    echo Le test a ete planifie pour le prochain demarrage.
    pause
    goto system_tools
)
goto system_tools

:sys_ping_test
cls
echo ======================================================
echo     TEST DE CONNEXION COMPLET (PING / DNS)
echo ======================================================
echo.
echo Ce test va verifier ou se situe le probleme de connexion.
echo.

echo Etape 1 : Verification Carte Reseau (127.0.0.1)...
ping 127.0.0.1 -n 1 >nul
if %errorlevel% neq 0 goto ping_fail_nic
echo [OK] Carte reseau active.
echo.

echo Etape 2 : Verification Passerelle (Box)...
set "gateway="
REM Methode robuste pour trouver la passerelle via route print
for /f "tokens=3" %%g in ('route print 0.0.0.0 ^| findstr "\<0.0.0.0\>"') do set "gateway=%%g"

if not defined gateway (
    echo [!] Impossible de detecter la passerelle par defaut.
    echo     (Vous n'etes peut-etre pas connecte au reseau)
    goto skip_gateway_ping
)

echo Ping de la passerelle detectee (%gateway%)...
ping %gateway% -n 1 >nul
if %errorlevel% neq 0 goto ping_fail_gateway
echo [OK] Connexion a la Box reussie.

:skip_gateway_ping
echo.
echo Etape 3 : Verification Internet (Google 8.8.8.8)...
ping 8.8.8.8 -n 1 >nul
if %errorlevel% neq 0 goto ping_fail_internet
echo [OK] Connexion Internet fonctionnelle.
echo.

echo Etape 4 : Verification DNS (google.com)...
ping google.com -n 1 >nul
if %errorlevel% neq 0 goto ping_fail_dns
echo [OK] DNS fonctionnels.
goto end_ping_success

:ping_fail_nic
echo.
echo [ECHEC] Carte reseau HS ou desactivee.
goto end_ping_test

:ping_fail_gateway
echo.
echo [ECHEC] La Box/Routeur ne repond pas.
echo         Verifiez le cable Ethernet ou la connexion Wi-Fi.
goto end_ping_test

:ping_fail_internet
echo.
echo [ECHEC] Pas d'acces Internet.
echo         La Box repond mais pas Internet (Probleme FAI/Ligne).
goto end_ping_test

:ping_fail_dns
echo.
echo [ECHEC] Probleme DNS !
echo         Vous avez Internet mais ne pouvez pas naviguer.
echo         Changez vos DNS via le Menu Principal [1].
goto end_ping_test

:end_ping_success
echo.
echo [SUCCES] Tout semble fonctionner correctement !

:end_ping_test
echo.
echo ------------------------------------------------------
echo Diagnostic termine.
pause
goto system_tools

REM ===================================================================
REM                    MENU DEPANNAGE & REPARATIONS
REM ===================================================================
:depannage_menu
goto menu_maintenance


:repair_spooler
cls
echo.
echo ======================================================
echo   REPARATION DU SPOULEUR D'IMPRESSION
echo ======================================================
echo.
echo 1. Arret du service Spouleur...
net stop spooler /y
echo.
echo 2. Suppression des fichiers en attente (file d'impression)...
del /F /Q "%systemroot%\System32\spool\PRINTERS\*.*"
echo.
echo 3. Redemarrage du service Spouleur...
net start spooler
echo.
echo Reparation terminee. Essayez d'imprimer a nouveau.
pause
goto depannage_menu

:get_win_key
cls
echo.
echo ======================================================
echo   RECUPERATION CLE PRODUIT WINDOWS
echo ======================================================
echo.
echo Recherche de la cle dans le BIOS/UEFI...
echo.

set "key="
REM Methode PowerShell (plus fiable)
for /f "usebackq delims=" %%I in (`powershell -command "(Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey"`) do set "key=%%I"

if "%key%"=="" (
    REM Fallback methode WMIC standard
    for /f "tokens=2 delims==" %%I in ('wmic path softwarelicensingservice get OA3xOriginalProductKey /value 2^>nul') do set "key=%%I"
)

if "%key%"=="" (
    echo [!] Aucune cle OEM trouvee dans le BIOS.
    echo.
    echo Causes possibles :
    echo  - Windows active par licence numerique (compte Microsoft)
    echo  - Cle Retail non integree a la carte mere
    echo  - PC assemble sans licence pre-installee
) else (
    echo =================================================
    echo CLE TROUVEE : %key%
    echo =================================================
    echo.
    set /p save_key=Voulez-vous enregistrer cette cle sur le Bureau ? (O/N): 
    
    if /i "!save_key!"=="O" (
        echo Cle Windows Recovered: %key% > "%USERPROFILE%\Desktop\Cle_Windows_%computername%.txt"
        echo.
        echo [OK] Fichier enregistre : %USERPROFILE%\Desktop\Cle_Windows_%computername%.txt
    )
)
echo.
pause
goto depannage_menu

:menu_boot_safe
echo.
echo DIAGNOSTIC : Entree dans menu_boot_safe...
timeout /t 1 >nul
cls
echo ======================================================
echo     OPTIONS DE DEMARRAGE AVANCEES
echo ======================================================
echo.
echo   [1] Redemarrer en Mode Sans Echec - Minimal
echo   [2] Redemarrer en Mode Sans Echec - avec Reseau
echo   [3] Redemarrer avec Invite de Commandes - Sans Echec
echo   [4] Redemarrer sur les Options de Recuperation - Menu Bleu
echo       - Pour: UEFI, Restauration config, Reparation auto...
echo.
echo   [5] RETOUR MODE NORMAL - Desactiver Mode Sans Echec
echo       - Utilisez ceci si vous etes bloque en mode sans echec
echo.
echo   [0] Retour
echo.
echo ======================================================
echo   ATTENTION : Les options 1-3 forcent le demarrage.
echo   Pour revenir a la normale, il faudra utiliser l option 5.
echo ======================================================
set "boot_choice="
set /p boot_choice=Votre choix: 

if "%boot_choice%"=="1" goto boot_safe_minimal
if "%boot_choice%"=="2" goto boot_safe_network
if "%boot_choice%"=="3" goto boot_safe_cmd
if "%boot_choice%"=="4" goto boot_recovery
if "%boot_choice%"=="5" goto boot_normal
if "%boot_choice%"=="0" goto depannage_menu

echo Choix invalide.
pause
goto menu_boot_safe

:boot_safe_minimal
echo.
echo Configuration du demarrage en Mode Sans Echec [Minimal]...
echo Application de la commande bcdedit...
C:\Windows\System32\bcdedit.exe /set {current} safeboot minimal
if errorlevel 1 (
    echo.
    echo ERREUR : La commande a echoue. Etes-vous bien Administrateur ?
    pause
    goto boot_troubleshoot
)
echo Configuration reconnue.
goto confirm_reboot

:boot_safe_network
echo.
echo Configuration du demarrage en Mode Sans Echec [Reseau]...
C:\Windows\System32\bcdedit.exe /set {current} safeboot network
if errorlevel 1 (
    echo.
    echo ERREUR : La commande a echoue.
    pause
    goto boot_troubleshoot
)
goto confirm_reboot

:boot_safe_cmd
echo.
echo Configuration du demarrage en Mode Sans Echec [Invite de commandes]...
C:\Windows\System32\bcdedit.exe /set {current} safeboot minimal
C:\Windows\System32\bcdedit.exe /set {current} safebootalternateshell yes
if errorlevel 1 (
    echo.
    echo ERREUR : La commande a echoue.
    pause
    goto boot_troubleshoot
)
goto confirm_reboot

:boot_recovery
echo.
echo Redemarrage vers le menu de recuperation...
echo Le PC va redemarrer dans quelques instants...
timeout /t 3
shutdown /r /o /t 0
exit

:boot_normal
echo.
echo Restauration du demarrage normal...
C:\Windows\System32\bcdedit.exe /deletevalue {current} safeboot
C:\Windows\System32\bcdedit.exe /deletevalue {current} safebootalternateshell >nul 2>&1
echo.
echo Pret a redemarrer en mode normal.

:confirm_reboot
echo.
set /p reboot=Redemarrer l'ordinateur maintenant ? (O/N): 
if /i "%reboot%"=="O" (
    shutdown /r /t 0
) else (
    echo Modifications appliquees pour le prochain redemarrage.
    pause
    goto boot_troubleshoot
)

REM ===================================================================
REM                    SORTIE DU SCRIPT
REM ===================================================================
:manage_favs
cls
color 0E
echo ======================================================
echo             GESTION DES FAVORIS
echo ======================================================
echo.
echo  --- VOS FAVORIS ACTUELS ---
if exist "%fav_file%" (
    for /f "usebackq delims=" %%F in ("%fav_file%") do (
        set "id_raw=%%F"
        set "num_raw=!id_raw:t=!"
        echo    [*] [!num_raw!] !%%F_n!
    )
) else (
    echo    (Aucun favori selectionne)
)
echo.
echo  --- LISTE COMPLETE (Tapez le numero pour Ajouter/Retirer) ---
for /l %%i in (1,1,%max_tools%) do (
    set "status=   "
    if exist "%fav_file%" (
        findstr /x "t%%i" "%fav_file%" >nul && set "status=[*]"
    )
    echo    !status! [%%i] !t%%i_n!
)
echo.
echo  [R] Reinitialiser tous les favoris
echo.
echo  [0] Retour au menu principal
echo.
echo  Votre choix :
set /p fav_choice=

if "%fav_choice%"=="0" goto menu_principal
if /i "%fav_choice%"=="R" del "%fav_file%" & goto menu_principal

REM Verification si c'est un numero valide
echo !fav_choice!| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 goto manage_favs
if !fav_choice! GTR %max_tools% goto manage_favs

set "new_fav=t!fav_choice!"
set "tool_name=!%new_fav%_n!"
set "found_f=0"

REM On cree un fichier temporaire pour filtrer
if exist "%fav_file%" (
    findstr /v /x "!new_fav!" "%fav_file%" > "%fav_file%.tmp"
    for /f %%A in ('findstr /x "!new_fav!" "%fav_file%"') do set "found_f=1"
    
    if !found_f!==1 (
        move /y "%fav_file%.tmp" "%fav_file%" >nul
        echo !tool_name! retire des favoris.
    ) else (
        echo !new_fav!>> "%fav_file%"
        if exist "%fav_file%.tmp" del "%fav_file%.tmp"
        echo !tool_name! ajoute aux favoris.
    )
) else (
    echo !new_fav!> "%fav_file%"
    echo !tool_name! ajoute aux favoris.
)

timeout /t 2 >nul
goto manage_favs

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