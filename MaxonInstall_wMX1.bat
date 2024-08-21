@echo off
chcp 65001

:: Script to install Maxon software titles using the Maxon App's built-in MX1.exe utility
::
:: Assumes that Max App is already installed and a user account is logged in.



:: Get variables from command line
set MaxonPKGtoInstall=%~1
set SpecificVersion=%~2


:: Create working directory and temporary download directory and move to it
set WorkingDir=C:\ProgramData\MaxonInstallers
if not exist %WorkingDir% md %WorkingDir%
set TempDir=%WorkingDir%\%MaxonPKGtoInstall%.DL
if not exist %TempDir% md %TempDir%
cd %TempDir%


:: Use mx1.exe to install the red giant plugins silently
set MX1exe="C:\Program Files\Maxon\Tools\mx1.exe"


:: First, Download the package to the temp dir - 
:: If version number is specified mx1 will grab that version,
:: otherwise mx1 will download the latest available version.
%MX1exe% package download %MaxonPKGtoInstall% %SpecificVersion%





:: Now find out the file extension of the DL

:: Loop through each file in the directory looking for .zip or .exe files
:: We only downloaded one file, so we're just using this hack to get the 
:: file path and extension for the downloaded file.

for %%f in ("%TempDir%\*.*") do (
    :: echo "%%~xf"
	set DLext="%%~xf"
	set DLfile="%%f"
)




:: Based on the file extension - run the installer
if /i %DLext%==".zip" (
    echo "Found a ZIP file: %DLfile%"
	
	:: Move Zip file to working folder and rename
    move "%DLfile%" "%WorkingDir%\%MaxonPKGtoInstall%.zip"

    :: Unzip zip file to temp folder
    tar.exe -xzf "%WorkingDir%\%MaxonPKGtoInstall%.zip" -C "%TempDir%"

    :: Delete the .zip file
    del /q "%WorkingDir%\%MaxonPKGtoInstall%.zip"

    :: Run the scripted installer
    :: Tested to work for Magic Bullet, Pluraleyes, Maxon Studio, Trapcode, and VFX
    cmd.exe /c "%TempDir%\Scripts\install.bat"     
	
) else if /i %DLext%==".exe" (
    REM Above line checks if the file has a .exe extension  
    echo "Found an EXE file: %DLfile%"
	
    REM Run the installer
	if /i "%MaxonPKGtoInstall%"=="com.redshift3d.redshift" (
		REM - Speciall Installer flags for Redshift
	    cmd /c start /wait "Install %MaxonPKGtoInstall%" %DLfile% /S
	) else (
		REM Otherwise use common flags for Maxon ,exe installers
		REM Tested to work for Universe
		cmd /c start /wait "Install %MaxonPKGtoInstall%" %DLfile% --mode unattended --unattendedmodeui none
	)
) else (
	echo "No .zip or .exe files found in DL folder. Cleaning up and exiting."

    REM Clean up temp dir
    cd %WorkingDir%
    timeout /T 10
    rd /s /q %TempDir%

	exit /b 1
)

REM Clean up temp dir
cd %WorkingDir%
timeout /T 20
rd /s /q %TempDir%


echo "Reached end with no errors."
exit /b 0
