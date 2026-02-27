@echo off
setlocal EnableExtensions EnableDelayedExpansion
if defined MSYSTEM ("%ComSpec%" /c "%~f0" & exit /b)
if not defined CMDCMDLINE ("%ComSpec%" /c "%~f0" & exit /b)
chcp 65001 >nul
color 0B

REM === AUTO-ELEVATION EN ADMINISTRATEUR ===
if %errorlevel% neq 0 (
    echo Ce script requiert des privileges administrateur.
    echo Demande d'elevation en cours...
    exit /b
)

set /a total_tools=0
set "t[1]=---:OUTILS PRINCIPAUX"
set "t[3]=winget_manager:Mises a jour d'applications~Mettre a jour vos logiciels via Winget"
set "t[4]=context_menu:Menu contextuel Windows 11~Classic/Modern"
set "t[5]=disk_manager:Formatteur de Disque (DISKPART)~Formater un disque de facon securisee"
set "t[6]=sys_browser_passwords:Export mots de passe web~Extracteur de pass (Nirsoft)"
set "t[7]=---:VERIFICATIONS SYSTEME"
set "t[8]=sys_sfc:SFC (Scannow)~Reparation avancee des fichiers systeme Windows"
set "t[9]=sys_dism_check:DISM Check~Verification securisee de l'integrite de l'image Windows"
set "t[10]=sys_dism_restore:DISM Restore~Reparation critique de l'image Windows via Windows Update"
set "t[11]=sys_chkdsk:CHKDSK~Analyse complete des erreurs sur tous les disques"
set "t[14]=sys_temp_cleanup:Nettoyage complet (Temp/Cache)~Suppression massive des fichiers inutiles"
set "t[15]=sys_registry_cleanup:Nettoyage du Registre~Optimisation rapide et suppression des entrees mortes"
set "t[16]=---:DISQUE DUR"
set "t[17]=sys_bitlocker_check:Verificateur BitLocker~Verifiez l'etat de chiffrement de vos partitions"
set "t[18]=---:OUTILS RESEAU"
set "t[19]=sys_ipconfig:ipconfig /all~Affichage de la configuration detaillee des cartes reseau"
set "t[30]=sys_unlock_notes:Recuperation de Compte bloque~Instructions pour reprendre controle sans mot de passe"
set "t[31]=---:MATERIEL"

if not exist "favoris.txt" (
    echo dns_manager>favoris.txt
    echo winget_manager>>favoris.txt
    echo context_menu>>favoris.txt
    echo disk_manager>>favoris.txt
    echo sys_browser_passwords>>favoris.txt
)

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

    set "toggle_target=!main_target[%toggle_idx%]!"
    if not "!toggle_target!"=="none" call :ToggleFav "!toggle_target!"
    goto menu_principal
)

set /a v_idx=fav_idx+1

if "!main_choice!"=="!v_idx!" goto system_tools

set "target=!main_target[%main_choice%]!"
if defined target and not "!target!"=="none" goto !target!
goto menu_principal

REM ===================================================================
REM                    GESTIONNAIRE DNS CLOUDFLARE
REM ===================================================================
:dns_manager
set "opts=Affichage de la configuration actuelle;[--- CLOUDFLARE ---];DNS Cloudflare (1.1.1.1);[--- GOOGLE ---];DNS Google (8.8.8.8);[--- REINITIALISATION ---];Restauration des DNS par defaut (DHCP)"
call :DynamicMenu "GESTIONNAIRE DNS" "%opts%"
set "dns_choice=%errorlevel%"

if "%dns_choice%"=="1" goto show_dns_config
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
echo Sauvegarde creee dans dns_backups
echo.

echo Configuration des DNS Cloudflare IPv4...

echo Configuration des DNS Cloudflare IPv6...

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
echo Sauvegarde creee dans dns_backups
echo.

echo Configuration des DNS Google IPv4...

echo Configuration des DNS Google IPv6...

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

echo Restauration des DNS automatiques IPv6...

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
echo.
echo Configuration DNS IPv6:
echo.
pause
goto dns_manager

:get_interface
set "interface="
    if /i "%%b"=="Connecté" (
        set "interface=%%d"
        goto :interface_found
    )
    if /i "%%b"=="Connected" (
        set "interface=%%d"
        goto :interface_found
    )
)
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
if "%ctx_choice%"=="0" goto menu_principal
goto context_menu

:activate_classic
cls
echo.
echo Activation du menu contextuel classique...
echo.
echo Modification du registre terminee.
echo.
echo IMPORTANT : Un redemarrage de l'Explorateur Windows est necessaire.
echo.
set /p restart_explorer=Redemarrer l'Explorateur maintenant ? (O/N): 
if /i "%restart_explorer%"=="O" (
    echo Redemarrage de l'Explorateur Windows...
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
echo Modification du registre terminee.
echo.
set /p restart_explorer=Redemarrer l'Explorateur maintenant ? (O/N): 
if /i "%restart_explorer%"=="O" (
    echo Redemarrage de l'Explorateur Windows...
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
    if !idx! equ %res% set "disk_num=%%D"
    set /a idx+=1
)

if not defined disk_num goto disk_manager




    echo Ã¢ÂÅ’ Erreur : Veuillez entrer un numero valide !

:disk_format_choice
call :DynamicMenu "CHOIX DU SYSTEME DE FICHIERS (DISQUE %disk_num%)" "%opts%"
set "format_choice=%errorlevel%"

if "%format_choice%"=="0" goto menu_principal
if "%format_choice%"=="1" set fs_type=NTFS
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
if "%touch_choice%"=="3" goto touch_enable
if "%touch_choice%"=="0" goto system_tools
goto touch_screen_manager

:touch_restart
cls
echo.
echo === Redemarrage du pilote d'ecran tactile ===
echo.

echo Redemarrage du service TabletInputService...

echo Redemarrage du service HidServ...

echo.
echo Desactivation/Reactivation du peripherique tactile via PowerShell...

echo.
echo Redemarrage du processus dwm.exe (Desktop Window Manager)...

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

echo Desactivation du peripherique tactile...

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

echo Demarrage du service TabletInputService...

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
for /l %%I in (7,1,%total_tools%) do (
    for /f "tokens=1,* delims=:" %%A in ("!t[%%I]!") do (
        if "%%A"=="---" (
            set "opts=!opts!;[--- %%B ---]"
        ) else (
            set "is_fav=0"
            for /f "usebackq tokens=*" %%F in ("favoris.txt") do (if "%%F"=="%%A" set "is_fav=1")
            if "!is_fav!"=="1" (
                set "opts=!opts!;[*] %%B"
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

    set "toggle_target=!sys_target[%toggle_idx%]!"
    call :ToggleFav "!toggle_target!"
    goto system_tools
)

set "target=!sys_target[%sys_choice%]!"
if defined target goto !target!
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
if "%bpv_choice%"=="0" goto system_tools
goto bpv_menu

:EXPORT
rem Telecharger si necessaire
if not exist "%WBPV%" (
  echo.
  echo Telechargement de WebBrowserPassView.exe...
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
)

rem Generer un nom de fichier unique
call :GET_UNIQUE_FILENAME
set "OUTPUT=%UNIQUE_FILE%"

echo.
echo Lancement de WebBrowserPassView...
start "" "%WBPV%"


echo Traitement en cours...



rem Attendre que le processus se termine completement

rem Nettoyage si telecharge
if "%DOWNLOADED%"=="1" (
  echo Nettoyage...
  if exist "%WBPV%" (
  )
)

if exist "%OUTPUT%" (
  echo Termine. Fichier sauvegarde: %OUTPUT%
  echo.
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
)

rem Generer un nom de fichier unique
call :GET_UNIQUE_FILENAME
set "OUTPUT=%UNIQUE_FILE%"

echo.
echo Lancement de WebBrowserPassView...
start "" "%WBPV%"


echo Traitement en cours...



rem Attendre que le processus se termine completement

if not exist "%OUTPUT%" (
  echo ERREUR: Le fichier n'a pas ete cree.
  if "%DOWNLOADED%"=="1" (
    if exist "%WBPV%" (
    )
  )
  pause
  goto bpv_menu
)

echo Fichier sauvegarde: %OUTPUT%
echo.
echo Envoi du fichier par email...


rem Nettoyage si telecharge
if "%DOWNLOADED%"=="1" (
  echo.
  echo Nettoyage...
  if exist "%WBPV%" (
  )
)

echo.
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
if %errorlevel% neq 0 (
    echo.
    echo [X] Operation annulee par l'utilisateur.
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
if %errorlevel% neq 0 (
    echo.
    echo [X] Operation annulee par l'utilisateur.
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
echo.
if %errorlevel% neq 0 (
    echo.
    echo [X] Operation annulee par l'utilisateur.
    goto system_tools
)
echo.
echo Lancement de la restauration, veuillez patienter...
dism /online /cleanup-image /restorehealth
pause
goto system_tools

:sys_ipconfig
cls
echo Affichage des informations reseau...
ipconfig /all
pause
goto system_tools

cls
echo Redemarrage des cartes reseau...
echo Cartes reseau redemarrees.
pause
goto system_tools

cls
echo ================================
echo     Reparation reseau automatique
echo ================================
echo.
echo Etape 1 : Renouvellement de l'adresse IP...
ipconfig /release >nul
ipconfig /renew >nul

ipconfig /flushdns >nul

echo Etape 3 : Reinitialisation des composants reseau...

echo.
echo Les parametres reseau ont ete actualises.
echo Un redemarrage est recommande pour un effet complet.
echo.
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

set count=0
set safe_count=0

echo Analyse du Registre Windows pour les erreurs et problemes de performance...
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

    set "DESKTOP=%%d"
)

    set "DATESTR=%%t"
)

set "SYS=%DESKTOP%\Infos_Systeme_%DATESTR%.txt"
set "NET=%DESKTOP%\Infos_Reseau_%DATESTR%.txt"
set "DRV=%DESKTOP%\Liste_Pilotes_%DATESTR%.txt"

echo Ecriture des informations systeme...

echo Ecriture des informations reseau...

echo Ecriture de la liste des pilotes...

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

echo Arret du service de Chiffrement...

echo Demarrage du service Application Identity...

echo Demarrage du service Windows Update...

echo Demarrage du service BITS...

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

set "SUFFIX=.bak_%RANDOM%"
if exist "%windir%\SoftwareDistribution" (
)
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
)
goto :eof

:startIfExists
sc query "%~1" | findstr /i "STATE" >nul
if not errorlevel 1 (
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


rem Detection simple via findstr si le volume est non chiffre
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
if %errorlevel% neq 0 (
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
    echo SSID: %%A 
    echo MDP : %%B
    echo ------------------------------------------
)
echo.
pause
goto menu_wifi

:wifi_collect
set found=0
	set "ssid=%%I"
	set "ssid=!ssid:~1!"
	if not "!ssid!"=="" (
		set "pwd="
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
    if defined wifi_opts (set "wifi_opts=!wifi_opts!;SSID: %%A | MDP: %%B") else (set "wifi_opts=SSID: %%A | MDP: %%B")
)

call :DynamicMenu "SUPPRIMER UN RESEAU WI-FI" "%wifi_opts%"
set "wifi_res=%errorlevel%"
if "%wifi_res%"=="0" goto menu_wifi

rem Recuperer le SSID selectionne
set /a idx=0
set "TARGET="
    set /a idx+=1
    if !idx! equ %wifi_res% set "TARGET=%%A"
)

if not defined TARGET goto menu_wifi

echo.
echo Suppression du profil: "%TARGET%" ...
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
	>>"%OUTPUT%" echo SSID: %%A ^| MDP: %%B
)
echo Rapport enregistre: "%OUTPUT%"
pause
goto menu_wifi

:wifi_exit
endlocal
goto system_tools

REM ================= Embedded: Gestion des utilisateurs locaux (um_*) =================
:um_menu
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
if not defined UM_ADMIN_GROUP set "UM_ADMIN_GROUP=Administrators"
set "UM_STR_PWD_REQ_EN=Password required"
set "UM_STR_PWD_REQ_FR=Mot de passe requis"

set "opts=Lister les utilisateurs;Ajouter un utilisateur;Supprimer un utilisateur;Gerer les droits (Standard/Admin);Ajouter/Modifier un mot de passe;Supprimer le mot de passe (Auto-login)"
call :DynamicMenu "GESTION UTILISATEURS LOCAUX" "%opts%"
set "um_choice=%errorlevel%"

if "%um_choice%"=="1" goto um_list
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
echo.
pause
goto um_menu

:um_admin
cls
set "user_opts="
set /a u_idx=0
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
    if !errorlevel!==0 (echo '%UADM%' a ete ajoute aux Administrateurs.) else (echo Echec.)
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
goto um_add_check

:um_add_no_pwd

:um_add_check
if not %errorlevel%==0 (
    echo Echec de creation de l'utilisateur.
    pause
    goto um_menu
)

set "ADDADM="
set /p ADDADM="Ajouter '%NEWU%' aux Administrateurs ? (O/N) > "
echo.
echo [OK] Utilisateur cree avec succes.
pause
goto um_menu

:um_del
cls
set "user_opts="
set /a u_idx=0
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

if not %errorlevel%==0 (
    echo [ECHEC] Impossible de supprimer le compte utilisateur '%DELU%'.
    pause
    goto um_menu
)

echo [OK] Utilisateur Windows supprime.
echo.
set "TMP_PS1=%temp%\wipe_profile_%RANDOM%.ps1"

echo param($u, $l) > "%TMP_PS1%"
echo "RAPPORT: Nettoyage et suppression definitive du dossier "+$u ^| Out-File -Encoding UTF8 $l >> "%TMP_PS1%"
echo $f=@('-', '\', '^|', '/') >> "%TMP_PS1%"
echo $i=0 >> "%TMP_PS1%"
echo while(-not $p.HasExited) { >> "%TMP_PS1%"
echo     Write-Host -NoNewline "`r[ $($f[$i]) ] (Journal dispo sur le Bureau) Effacement des fichiers...   " -ForegroundColor Cyan >> "%TMP_PS1%"
echo     $i=($i+1) %% 4 >> "%TMP_PS1%"
echo     Start-Sleep -Milliseconds 150 >> "%TMP_PS1%"
echo } >> "%TMP_PS1%"
echo Write-Host "`r[ OK ] Dossier personnel efface. L'utilisateur a completement disparu.                      " -ForegroundColor Green >> "%TMP_PS1%"

set "LOGFILE=%USERPROFILE%\Desktop\Suppression_Profil_%DELU%.log"

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
    echo Les mots de passe ne correspondent pas.
    pause
    goto um_menu
)
if not %errorlevel%==0 (
    echo Echec de la mise a jour du mot de passe.
    pause
    goto um_menu
)

echo Mot de passe mis a jour.
set /p RFORCE=Exiger le changement au prochain logon ? (O/N) ^> 
if /I not "%RFORCE%"=="O" goto um_reset_end

echo Obligation de changement au prochain logon active.

:um_reset_end
pause
goto um_menu

:um_remove_pwd
cls
set "user_opts="
set /a u_idx=0
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
setlocal
set "m_title=%~1"


set "res=%errorlevel%"
exit /b %res%


:sys_unlock_notes
cls
echo ===============================================
echo ===============================================
echo.
echo 1^) Demarrer sur une cle USB Windows ^(WinRE/WinPE^) puis ouvrir l'invite de commande.
echo.
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
echo.
echo 4^) Remplacer utilman.exe par cmd.exe ^(sauvegarder si besoin avant^):
echo    ^(Optionnel^) Sauvegarde:
echo    Remplacement:
echo    Tapez O ^(Oui^) si demande pour remplacer.
echo.
echo 5^) Redemarrer le PC normalement.
echo.
echo 6^) A l'ecran de connexion, cliquer sur le bouton "Ergonomie" ^(facilites d'acces^):
echo.
echo 7^) Changer le mot de passe du compte desire:
echo    Exemple:
echo.
echo 8^) ^(Recommande^) Restaurer utilman.exe d'origine apres recuperation:
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
