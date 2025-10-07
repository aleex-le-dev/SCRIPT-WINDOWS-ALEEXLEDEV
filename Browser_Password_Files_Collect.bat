@echo off
chcp 65001 >nul

rem Elevation en administrateur des l'ouverture du script
net session >nul 2>&1
if %errorlevel% neq 0 (
  powershell -Command "Start-Process '%~f0' -Verb RunAs"
  exit /b
)

set "WBPV=%~dp0WebBrowserPassView.exe"
if exist "%WBPV%" (
  rem Lancer l'outil (deja admin)
  start "" "%WBPV%"
) else (
  echo WebBrowserPassView non detecte a cote du script.
  echo Placez "WebBrowserPassView.exe" dans le meme dossier puis relancez.
)

pause
exit /b 0
