@echo off
chcp 65001 >nul
color 0A

echo ===============================================
echo   Extraction des mots de passe Wi-Fi enregistres
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
>"%OUTPUT%" echo Mots de passe Wi-Fi exportes - %date% %time%
>>"%OUTPUT%" echo ===============================================

echo Detection des profils Wi-Fi...
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
		echo SSID: !ssid! ^| MDP: !pwd!
		>>"%OUTPUT%" echo SSID: !ssid! ^| MDP: !pwd!
		set found=1
	)
)

echo.
if %found%==0 (
	echo Aucun profil Wi-Fi trouve ou sortie non reconnue.
	>>"%OUTPUT%" echo Aucun profil Wi-Fi trouve.
) else (
	echo Rapport enregistre: "%OUTPUT%"
)

echo.
pause
