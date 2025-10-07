@echo off
chcp 65001 >nul
color 0A

echo ===============================================
echo   Outil Wi-Fi - Profils et mots de passe
echo ===============================================

echo.
REM Elevation en administrateur si necessaire
net session >nul 2>&1
if %errorlevel% neq 0 (
	powershell -Command "Start-Process '%~f0' -Verb RunAs"
	exit /b
)

setlocal enabledelayedexpansion
set "OUTPUT=%USERPROFILE%\Desktop\Wifi_Mots_de_passe.txt"
set "MAPFILE=%TEMP%\wifi_map_%RANDOM%.txt"

:menu
cls
echo ===============================================
echo   [1] Afficher / supprimer les reseaux Wi-Fi
echo   [2] Generer un rapport sur le Bureau
echo   [0] Quitter
echo ===============================================
set /p choice=Votre choix: 
if "%choice%"=="1" goto action_display
if "%choice%"=="2" goto action_report
if "%choice%"=="0" goto end

echo Choix invalide.
pause
goto menu

:collect
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

:action_display
call :collect
cls
echo Profils Wi-Fi trouves:
echo.
if %found%==0 (
	echo Aucun profil Wi-Fi trouve ou sortie non reconnue.
	pause
	goto menu
)
set /a idx=0
for /f "tokens=1,2 delims=|" %%A in ('type "%MAPFILE%"') do (
	set /a idx+=1
	echo  [!idx!] SSID: %%A ^| MDP: %%B
)

echo.
set /p delidx=Supprimer un profil ? Entrez le numero (0 pour annuler): 
if "%delidx%"=="0" goto menu

REM Validation numerique robuste (integer positif)
set "_raw=%delidx%"
set "_num=%_raw: =%"
for /f "delims=0123456789" %%X in ("!_num!") do set "_num_invalid=1"
if defined _num_invalid (
	echo Numero invalide.
	pause
	goto menu
)
set /a _check=%_num% + 0 >nul 2>&1
if errorlevel 1 (
	echo Numero invalide.
	pause
	goto menu
)
if %_num% lss 1 (
	echo Numero hors plage.
	pause
	goto menu
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
	goto menu
)

echo Suppression du profil: "%TARGET%" ...
netsh wlan delete profile name="%TARGET%"
pause
goto menu

:action_report
call :collect
cls
if %found%==0 (
	echo Aucun profil Wi-Fi trouve. Rapport non cree.
	pause
	goto menu
)
>"%OUTPUT%" echo Mots de passe Wi-Fi exportes - %date% %time%
>>"%OUTPUT%" echo ===============================================
for /f "tokens=1,2 delims=|" %%A in ('type "%MAPFILE%"') do (
	>>"%OUTPUT%" echo SSID: %%A ^| MDP: %%B
)
echo Rapport enregistre: "%OUTPUT%"
pause
goto menu

:end
if exist "%MAPFILE%" del "%MAPFILE%" >nul 2>&1
endlocal
exit /b 0
