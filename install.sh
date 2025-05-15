#!/bin/bash

echo "Welcome to the LFTP checker script!"

# Set folder and executable path
LFTP_FOLDER="lftp"
LFTP_EXE="$PWD/$LFTP_FOLDER/bin/lftp.exe"
ZIP_NAME="lftp.zip"
LFTP_URL="https://lftp.nwgat.ninja/lftp-4.7.7/lftp-4.7.7.win64-openssl.zip"

# Check if lftp.exe already exists
if [[ -f "$LFTP_EXE" ]]; then
    echo "lftp found at $LFTP_EXE"
else
    echo "lftp not found. Downloading and extracting..."

    # Download using curl or wget
    if command -v curl >/dev/null 2>&1; then
        curl -L "$LFTP_URL" -o "$ZIP_NAME"
    elif command -v wget >/dev/null 2>&1; then
        wget "$LFTP_URL" -O "$ZIP_NAME"
    else
        echo "ERROR: curl or wget is required to download files."
        exit 1
    fi

    # Extract ZIP file (requires unzip)
    if command -v unzip >/dev/null 2>&1; then
        mkdir -p "$LFTP_FOLDER"
        unzip -q "$ZIP_NAME" -d "$LFTP_FOLDER"
    else
        echo "ERROR: unzip command not found. Install it and try again."
        exit 1
    fi

    # Delete the ZIP file
    rm -f "$ZIP_NAME"
    echo "Deleted ZIP file: $ZIP_NAME"

    # Confirm lftp.exe exists
    if [[ -f "$LFTP_EXE" ]]; then
        echo "lftp successfully extracted to $LFTP_FOLDER/bin/lftp.exe"
    else
        echo "ERROR: lftp.exe not found after extraction."
    fi
fi
