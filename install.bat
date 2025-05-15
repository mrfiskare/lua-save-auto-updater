@echo off
setlocal EnableDelayedExpansion

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
    )
    echo:
)

endlocal
pause
