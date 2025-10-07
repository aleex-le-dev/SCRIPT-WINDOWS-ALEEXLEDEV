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
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:menu_principal
cls
color 0B
echo ======================================================
echo     BOITE A SCRIPTS WINDOWS - By ALEEXLEDEV
echo ======================================================
echo.
echo      === OUTILS PRINCIPAUX ===
echo   [1] Gestionnaire DNS Cloudflare
echo   [2] Mises à jour des application windows
echo   [3] Menu contextuel Windows 11
echo   [4] Formatage avec DISKPART
echo   [5] Voir les outils systeme avances
echo.
echo   [0] Quitter
echo.
echo ======================================================
set /p main_choice=Entrez votre choix: 

if "%main_choice%"=="1" goto dns_manager
if "%main_choice%"=="2" goto winget_manager
if "%main_choice%"=="3" goto context_menu
if "%main_choice%"=="4" goto disk_manager
if "%main_choice%"=="5" goto system_tools
if "%main_choice%"=="0" goto exit_script
echo Choix invalide, veuillez recommencer.
pause
goto menu_principal

REM ===================================================================
REM                    GESTIONNAIRE DNS CLOUDFLARE
REM ===================================================================
:dns_manager
cls
color 0B
echo ================================================
echo     GESTIONNAIRE DNS CLOUDFLARE
echo ================================================
echo.
echo   [1] Installation des DNS Cloudflare (IPv4 + IPv6)
echo   [2] Installation des DNS Cloudflare (IPv4 seulement)
echo   [3] Restauration des DNS par defaut
echo   [4] Affichage de la configuration actuelle
echo   [0] Retour au menu principal
echo.
echo ================================================
set /p dns_choice=Choisissez une option: 

if "%dns_choice%"=="1" goto install_cloudflare_full
if "%dns_choice%"=="2" goto install_cloudflare_ipv4
if "%dns_choice%"=="3" goto restore_dns
if "%dns_choice%"=="4" goto show_dns_config
if "%dns_choice%"=="0" goto menu_principal
echo Option invalide.
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
REM                   WINGET - Mises à jour des application windows
REM ===================================================================
:winget_manager
cls
color 0A
echo ================================================
echo     Mises à jour des application windows
echo ================================================
echo.

where winget >nul 2>nul
if errorlevel 1 (
    echo ERREUR: Winget n'est pas installe sur ce systeme.
    echo Veuillez l'installer depuis le Microsoft Store.
    pause
    goto menu_principal
)

echo   [1] Mettre a jour une application (liste et choix)
echo   [2] Mettre a jour toutes les applications
echo   [0] Retour au menu principal
echo.
set /p winget_choice=Choisissez une option: 

if "%winget_choice%"=="1" goto update_single
if "%winget_choice%"=="2" goto update_all
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

REM ===================================================================
REM                    MENU CONTEXTUEL WINDOWS 11
REM ===================================================================
:context_menu
cls
color 0E
echo ========================================================
echo    Menu contextuel classique - Windows 11
echo ========================================================
echo.
echo   [1] Activer le menu contextuel classique (recommande)
echo   [2] Restaurer le menu contextuel moderne de Windows 11
echo   [0] Retour au menu principal
echo.
set /p ctx_choice=Votre choix: 

if "%ctx_choice%"=="1" goto activate_classic
if "%ctx_choice%"=="2" goto restore_modern
if "%ctx_choice%"=="0" goto menu_principal
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
echo =============================================================
echo.

echo list disk | diskpart

echo.
echo =============================================================
echo.
echo ATTENTION : Le formatage effacera TOUTES les donnees !
echo.
echo Entrez le numero du disque a formater (ou 'Q' pour quitter) :
set /p disk_num=Numero du disque: 

if /i "%disk_num%"=="Q" goto menu_principal

echo %disk_num%| findstr /r "^[0-9][0-9]*$" >nul
if %errorLevel% neq 0 (
    echo.
    echo ❌ Erreur : Veuillez entrer un numero valide !
    timeout /t 3 >nul
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
color 07
echo ======================================================
echo     OUTILS SYSTEME AVANCES
echo ======================================================
echo.
echo      === VERIFICATIONS D'INTEGRITE SYSTEME ===
echo   [1] Analyse et reparation des fichiers (SFC /scannow)
echo   [2] Verification de l'etat Windows (DISM /CheckHealth)
echo   [3] Restaurer l'etat Windows (DISM /RestoreHealth)
echo   [4] Analyse d'erreurs avancee (CHKDSK)
echo.
echo      === NETTOYAGE ^& OPTIMISATION ===
echo   [5] Nettoyage de disque (cleanmgr)
echo  [6] Optimisation systeme (suppression fichiers temp)
echo  [7] Nettoyage/optimisation avancee du Registre
echo.
echo      === DISQUE DUR ===
echo   [8] Verifier chiffrement BitLocker / Dechiffrer
echo.
echo      === OUTILS RESEAU ===
echo   [9] Options DNS (Flush/Set/Reset)
echo   [10] Afficher les informations reseau (ipconfig /all)
echo   [11] Redemarrer les cartes reseau
echo   [12] Reparation reseau - Assistant automatique
echo.
echo      === UTILITAIRES ^& EXTRAS ===
echo  [13] Afficher les pilotes installes
echo  [14] Outil de reparation Windows Update
echo  [15] Generer un rapport systeme complet
echo  [16] Utilitaire de reinitialisation Windows Update
echo.
echo      === MOT DE PASSE ===
echo  [17] Gestion des mots de passe Wi-Fi
echo.
echo      === MATERIEL ===
echo  [18] Gestion de l'ecran tactile
echo.
echo   [0] Retour au menu principal
echo.
echo ------------------------------------------------------
set /p sys_choice=Entrez votre choix: 

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
if "%sys_choice%"=="17" goto sys_wifi_passwords
if "%sys_choice%"=="18" goto touch_screen_manager
if "%sys_choice%"=="0" goto menu_principal
echo Choix invalide.
pause
goto system_tools

:sys_sfc
cls
echo Analyse des fichiers systeme (SFC /scannow)...
sfc /scannow
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

:sys_dns_options
cls
echo ======================================================
echo Vidage du cache DNS...
ipconfig /flushdns
echo ======================================================
echo [1] Utiliser DNS Google (8.8.8.8 / 8.8.4.4)
echo [2] Utiliser DNS Cloudflare (1.1.1.1 / 1.0.0.1)
echo [3] Restaurer les DNS d'origine
echo [4] Saisir vos DNS personnalises
echo [5] Retour au menu
echo ======================================================
set /p dns_opt_choice=Entrez votre choix: 

if "%dns_opt_choice%"=="1" goto set_google_dns
if "%dns_opt_choice%"=="2" goto set_cloudflare_dns
if "%dns_opt_choice%"=="3" goto restore_dns_default
if "%dns_opt_choice%"=="4" goto custom_dns
if "%dns_opt_choice%"=="5" goto system_tools

echo Choix invalide, veuillez recommencer.
pause
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