echo off
REM Script "menu" - Modifie la valeur MenuShowDelay pour accélérer l'ouverture des menus (Windows 11)
REM Usage: Exécuter le script. Aucune élévation requise (HKCU). Redémarre Explorer pour appliquer le changement.

setlocal enabledelayedexpansion

REM Définir la valeur cible
set "TARGET_VALUE=10"

REM Écrire dans le registre (HKCU\Control Panel\Desktop\MenuShowDelay)
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "%TARGET_VALUE%" /f >nul 2>&1
if errorlevel 1 (
  echo Echec lors de la modification du registre.
  exit /b 1
)

REM Redémarrer l'Explorateur Windows pour appliquer immédiatement
taskkill /f /im explorer.exe >nul 2>&1
start "" explorer.exe >nul 2>&1

echo MenuShowDelay defini a %TARGET_VALUE% et Explorer redemarre.
endlocal
exit /b 0


