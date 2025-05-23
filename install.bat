@echo off
setlocal EnableDelayedExpansion

:: ===============================
:: Step 0 - Disclaimer and Backup Check
:: ===============================
echo IMPORTANT: This tool will help you to update the already existing Lua save files on your console.
echo Make sure to backup everything before starting ^!
echo:
echo There is a chance that you corrupt your Lua save file and lose access to the Lua exploit. 
echo You have been warned^! Use this tool at your own risk.
echo:

:BACKUP_CHECK
set "BACKUP_CONFIRMED="
echo I read the disclaimer and backed up my data:
echo 1. True
echo 2. False
set /p "BACKUP_CONFIRMED=Enter the number of your selection: "

if "%BACKUP_CONFIRMED%"=="1" (
    echo Backup confirmed. Proceeding...
    echo:
) else if "%BACKUP_CONFIRMED%"=="2" (
    echo ERROR: You must backup your data before proceeding. Exiting...
    pause
    exit /b
) else (
    echo Invalid selection. Please enter 1 or 2.
    echo.
    goto BACKUP_CHECK
)

:: ===============================
:: Step 1 - Check for lftp
:: ===============================
echo Welcome to the LFTP checker script!
echo:

REM Set expected lftp path
set "LFTP_FOLDER=lftp"
set "LFTP_EXE=%cd%\%LFTP_FOLDER%\bin\lftp.exe"

REM Check if lftp.exe exists
if exist "!LFTP_EXE!" (
    echo lftp found at !LFTP_EXE!
) else (
    echo lftp not found. Downloading and extracting...

    REM Set download URL and output ZIP file name
    set "LFTP_URL=https://lftp.nwgat.ninja/lftp-4.7.7/lftp-4.7.7.win64-openssl.zip"
    set "ZIP_NAME=lftp.zip"

    REM Download ZIP using PowerShell
    powershell -Command "Invoke-WebRequest -Uri '!LFTP_URL!' -OutFile '!ZIP_NAME!'"

    REM Extract ZIP using PowerShell
    powershell -Command "Expand-Archive -Path '!ZIP_NAME!' -DestinationPath './lftp' -Force"

    REM Delete ZIP after extraction
    if exist "!ZIP_NAME!" (
        del /f /q "!ZIP_NAME!"
        echo Deleted ZIP file: !ZIP_NAME!
    )

    echo:
    echo Download and extraction completed.

    REM Check again if lftp.exe is now available
    if exist "!LFTP_EXE!" (
        echo lftp successfully extracted to !LFTP_FOLDER!\bin\lftp.exe
    ) else (
        echo ERROR: lftp.exe not found after extraction.
        pause
        exit /b
    )
    echo:
)

:: ===============================
:: Step 2 - Ask for IP address
:: ===============================
:ASK_IP
set "PS5_IP="
set /p "PS5_IP=Enter the IP address of your PS5 (e.g. 192.168.0.123): "

:: PowerShell regex pattern for IPv4 validation
set "IPV4_REGEX=^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"

:: Validate IP using PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "if ('%PS5_IP%' -match '%IPV4_REGEX%') { exit 0 } else { exit 1 }"
if errorlevel 1 (
    echo Invalid IP address format. Please try again.
    goto ASK_IP
)

echo IP address accepted: %PS5_IP%
echo:

:: ===============================
:: Step 3 - Ask for FTP Port
:: ===============================
:ASK_FTP_PORT
set "PS5_FTP_PORT="
set /p "PS5_FTP_PORT=Please enter the FTP port number of your PS5 (etaHEN uses 1337 by default): "

:: PowerShell regex pattern for numbers only (one or more digits)
set "NUMBER_REGEX=^[0-9]+$"

:: Validate FTP port using PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "if ('%PS5_FTP_PORT%' -match '%NUMBER_REGEX%') { exit 0 } else { exit 1 }"
if errorlevel 1 (
    echo Invalid port number. Please enter only numbers.
    goto ASK_FTP_PORT
)

echo FTP port accepted: %PS5_FTP_PORT%
echo:

:: ===============================
:: Step 4 - Loader selection
:: ===============================
echo Checking and resetting the 'lua_save' folder...
if exist "lua_save" (
    rmdir /s /q "lua_save"
    echo Deleted the 'lua_save' folder.
) else (
    echo The 'lua_save' folder does not exist.
)
mkdir "lua_save"
echo Created the 'lua_save' folder.
echo:

:ASK_LOADER
set "CHOICE="
echo Please select which implementation of the Lua loader you would like to use:
echo 1. itsPLK (recommended)
echo 2. shahrilnet
set /p "CHOICE=Enter the number of your selection (1 or 2): "

if "%CHOICE%"=="1" (
    echo Cloning itsPLK's loader...
    git clone https://github.com/itsPLK/ps5_lua_loader.git lua_save
    if exist "lua_save\savedata" (
        set "LOADER=itsPLK"
        echo itsPLK's loader cloned successfully into 'lua_save'.
    ) else (
        echo ERROR: Failed to clone itsPLK's loader. Please check your internet connection and Git installation.
        pause
        exit /b
    )
) else if "%CHOICE%"=="2" (
    echo Cloning shahrilnet's loader...
    git clone https://github.com/shahrilnet/remote_lua_loader.git lua_save
    if exist "lua_save\savedata" (
        set "LOADER=shahrilnet"
        echo shahrilnet's loader cloned successfully into 'lua_save'.
    ) else (
        echo ERROR: Failed to clone shahrilnet's loader. Please check your internet connection and Git installation.
        pause
        exit /b
    )
) else (
    echo Invalid selection. Please enter 1 or 2.
    echo.
    goto ASK_LOADER
)
echo:

:: ===============================
:: Done - Summary
:: ===============================
echo:
echo Your selections:
echo - PS5 IP: %PS5_IP%
echo - PS5 FTP Port: %PS5_FTP_PORT%
echo - Lua Loader: %LOADER%
echo:

:: ===============================
:: Step 5 - Connect to PS5 and list /data
:: ===============================

echo Connecting to FTP server, please wait...
echo.

:: Use a temporary file to capture output and detect failure
set "FTP_LOG=ftp_temp_log.txt"
del /f /q "%FTP_LOG%" >nul 2>&1

"%LFTP_EXE%" -u PS5, ftp://%PS5_IP%:%PS5_FTP_PORT% -e "set ftp:passive-mode on; set net:timeout 2; set net:reconnect-interval-base 1; ls /data; quit" >"%FTP_LOG%" 2>&1

:: Check if the connection was successful
findstr /I /C:"Login failed" /C:"Fatal error" /C:"Connection refused" /C:"timed out" "%FTP_LOG%" >nul
if not errorlevel 1 (
    echo.
    echo [ERROR] FTP connection failed. Details:
    type "%FTP_LOG%"
    echo.
    pause
    del /f /q "%FTP_LOG%" >nul 2>&1
    exit /b
)

echo FTP connection successful!
echo:

:: ===============================
:: Step 6 - Delete and recreate /data/lua-tmp and upload files
:: ===============================
echo Checking and resetting /data/lua-tmp...

"%LFTP_EXE%" -u PS5, ftp://%PS5_IP%:%PS5_FTP_PORT% -e ^
"set ftp:passive-mode on; set net:timeout 2; set net:reconnect-interval-base 1; rm -r /data/lua-tmp; mkdir /data/lua-tmp; cd /data/lua-tmp; mput lua_save/savedata/*; quit"

echo:
echo Folder /data/lua-tmp has been reset and files uploaded.
echo.

del /f /q "%FTP_LOG%" >nul 2>&1

:: ===============================
:: Step 7 - Monitor /mnt/pfs for savedata folder
:: ===============================
echo Monitoring /mnt/pfs for a 'savedata' folder...
echo This may take a few moments. Please wait...

:WAIT_FOR_SAVEDATA
set "PFS_LOG=pfs_temp_log.txt"
del /f /q "%PFS_LOG%" >nul 2>&1

"%LFTP_EXE%" -u PS5, ftp://%PS5_IP%:%PS5_FTP_PORT% -e "set ftp:passive-mode on; set net:timeout 1; set net:reconnect-interval-base 1; ls /mnt/pfs; quit" >"%PFS_LOG%" 2>&1

echo.
echo Current contents of /mnt/pfs:
type "%PFS_LOG%"
echo.

:: Look for any line containing 'savedata'
findstr /I "savedata" "%PFS_LOG%" >nul
if errorlevel 1 (
    REM No savedata folder found, wait and try again
    powershell -Command "Start-Sleep -Milliseconds 100"
    goto WAIT_FOR_SAVEDATA
)

:: At this point we know there's a line containing 'savedata', show it and extract the folder name
echo Found savedata folder:

set "SAVEDATA_FOLDER="

for /f "tokens=* delims=" %%A in ('findstr /I "savedata" "%PFS_LOG%"') do (
    echo %%A
    for %%B in (%%A) do set "SAVEDATA_FOLDER=%%B"
)

:: The last token will be the folder name
setlocal enabledelayedexpansion
echo Savedata folder name: !SAVEDATA_FOLDER!
endlocal & set "SAVEDATA_FOLDER=%SAVEDATA_FOLDER%"
echo.

:: ===============================
:: Step 8 - Update the lua files
:: ===============================
:: Create empty temp file if not exist
if not exist test_write.tmp (
    type nul > test_write.tmp
)

echo Checking if /mnt/pfs/%SAVEDATA_FOLDER% is writable...

:check_writable
"%LFTP_EXE%" -u PS5,ftp://%PS5_IP%:%PS5_FTP_PORT% -e "set ftp:passive-mode on; set net:timeout 1; set net:reconnect-interval-base 1; cd /mnt/pfs/%SAVEDATA_FOLDER%; put test_write.tmp; rm test_write.tmp; quit" >nul 2>&1

if errorlevel 1 (
    echo Folder not writable yet, retrying in 0.1 seconds...
    powershell -Command "Start-Sleep -Milliseconds 100"
    goto check_writable
) else (
    echo Folder is writable, proceeding with upload...
)


pause
