chcp 65001
set MaxonInstallMX1bat="%~dp0MaxonInstall_wMX1.bat"


cd "C:\Program Files\Maxon\Tools>"

:: log into mx1 if we're not already
start mx1.exe user login -u "your_maxon_username" -p "your_maxon_password"
timeout /T 20


:: Run the MX1 install script to install redshift
cmd /c %MaxonInstallMX1bat% com.redshift3d.redshift


:: Clean Up
cd c:\
timeout /T 20
rd /s /q %WorkingDir%
