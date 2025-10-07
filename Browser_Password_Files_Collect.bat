@echo off
chcp 65001 >nul

rem Elevation en administrateur si necessaire (certaines copies peuvent requerir des droits)
net session >nul 2>&1
if %errorlevel% neq 0 (
  powershell -Command "Start-Process '%~f0' -Verb RunAs"
  exit /b
)

setlocal enabledelayedexpansion

rem Dossier de destination sur le Bureau avec horodatage
for /f "usebackq delims=" %%d in (`powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"`) do set TS=%%d
set DEST=%USERPROFILE%\Desktop\Browser_Password_Files_%TS%
if not exist "%DEST%" mkdir "%DEST%" >nul 2>&1
set LOG=%DEST%\collect_log.txt
>"%LOG%" echo Collecte fichiers mots de passe navigateurs - %date% %time%
>>"%LOG%" echo Dossier destination: "%DEST%"
>>"%LOG%" echo ==============================================================

rem Utilitaire de copie via PowerShell pour gerer fichiers verrouilles
set COPYCMD=powershell -NoProfile -Command "Copy-Item -Path 'SRC' -Destination 'DST' -Force -ErrorAction SilentlyContinue"

rem --- Chrome (Chromium) ---
set CHROMED=%LOCALAPPDATA%\Google\Chrome\User Data
set COPIED=0
if exist "%CHROMED%\Local State" (
  set "SRC=%CHROMED%\Local State"
  set "DST=%DEST%\Chrome_Local State"
  set CMD=!COPYCMD:SRC=%SRC%!
  set CMD=!CMD:DST=%DST%!
  !CMD! >nul 2>&1
  >>"%LOG%" echo [OK] Chrome - Local State: "%SRC%" ^> "%DST%"
  echo [OK] Chrome - Local State
  set COPIED=1
) else (
  >>"%LOG%" echo [MISS] Chrome - Local State introuvable
  echo [MISS] Chrome - Local State
)
if exist "%CHROMED%\Default\Login Data" (
  set "SRC=%CHROMED%\Default\Login Data"
  set "DST=%DEST%\Chrome_Login Data"
  set CMD=!COPYCMD:SRC=%SRC%!
  set CMD=!CMD:DST=%DST%!
  !CMD! >nul 2>&1
  >>"%LOG%" echo [OK] Chrome - Login Data: "%SRC%" ^> "%DST%"
  echo [OK] Chrome - Login Data
  set COPIED=1
) else (
  >>"%LOG%" echo [MISS] Chrome - Login Data introuvable
  echo [MISS] Chrome - Login Data
)
if !COPIED! EQU 0 (
  >>"%LOG%" echo [INFO] Aucun fichier Chrome copie
)

rem --- Edge (Chromium) ---
set EDGED=%LOCALAPPDATA%\Microsoft\Edge\User Data
set COPIED=0
if exist "%EDGED%\Local State" (
  set "SRC=%EDGED%\Local State"
  set "DST=%DEST%\Edge_Local State"
  set CMD=!COPYCMD:SRC=%SRC%!
  set CMD=!CMD:DST=%DST%!
  !CMD! >nul 2>&1
  >>"%LOG%" echo [OK] Edge - Local State: "%SRC%" ^> "%DST%"
  echo [OK] Edge - Local State
  set COPIED=1
) else (
  >>"%LOG%" echo [MISS] Edge - Local State introuvable
  echo [MISS] Edge - Local State
)
if exist "%EDGED%\Default\Login Data" (
  set "SRC=%EDGED%\Default\Login Data"
  set "DST=%DEST%\Edge_Login Data"
  set CMD=!COPYCMD:SRC=%SRC%!
  set CMD=!CMD:DST=%DST%!
  !CMD! >nul 2>&1
  >>"%LOG%" echo [OK] Edge - Login Data: "%SRC%" ^> "%DST%"
  echo [OK] Edge - Login Data
  set COPIED=1
) else (
  >>"%LOG%" echo [MISS] Edge - Login Data introuvable
  echo [MISS] Edge - Login Data
)
if !COPIED! EQU 0 (
  >>"%LOG%" echo [INFO] Aucun fichier Edge copie
)

rem --- Firefox (tous profils) ---
set FFPROF=%APPDATA%\Mozilla\Firefox\Profiles
set ANYFF=0
if exist "%FFPROF%" (
  for /d %%P in ("%FFPROF%\*") do (
    set COP2=0
    if exist "%%P\logins.json" (
      set "SRC=%%P\logins.json"
      set "DST=%DEST%\Firefox_%%~nP_logins.json"
      set CMD=!COPYCMD:SRC=%SRC%!
      set CMD=!CMD:DST=%DST%!
      !CMD! >nul 2>&1
      >>"%LOG%" echo [OK] Firefox %%~nP - logins.json: "%SRC%" ^> "%DST%"
      echo [OK] Firefox %%~nP - logins.json
      set COP2=1
      set ANYFF=1
    ) else (
      >>"%LOG%" echo [MISS] Firefox %%~nP - logins.json introuvable
      echo [MISS] Firefox %%~nP - logins.json
    )
    if exist "%%P\key4.db" (
      set "SRC=%%P\key4.db"
      set "DST=%DEST%\Firefox_%%~nP_key4.db"
      set CMD=!COPYCMD:SRC=%SRC%!
      set CMD=!CMD:DST=%DST%!
      !CMD! >nul 2>&1
      >>"%LOG%" echo [OK] Firefox %%~nP - key4.db: "%SRC%" ^> "%DST%"
      echo [OK] Firefox %%~nP - key4.db
      set COP2=1
      set ANYFF=1
    ) else (
      >>"%LOG%" echo [MISS] Firefox %%~nP - key4.db introuvable
      echo [MISS] Firefox %%~nP - key4.db
    )
    if !COP2! EQU 0 (
      >>"%LOG%" echo [INFO] Aucun fichier Firefox copie pour le profil %%~nP
    )
  )
) else (
  >>"%LOG%" echo [MISS] Dossier de profils Firefox introuvable
  echo [MISS] Profils Firefox
)

echo.
echo Fichiers copiees dans le dossier "%DEST%" sur le Bureau

pause
endlocal
