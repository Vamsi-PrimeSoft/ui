#!/bin/bash

# Variables (pass these as arguments to the script)
SFTP_HOST="$1"
SFTP_USER="$2"
SFTP_REMOTE_PATH="$3"
LOCAL_DOWNLOAD_PATH="$4"
PRIVATE_KEY="$5"
GET_FILE="$6"

# Ensure all variables are provided
if [[ -z "$SFTP_HOST" || -z "$SFTP_USER" || -z "$SFTP_REMOTE_PATH" || -z "$LOCAL_DOWNLOAD_PATH" || -z "$PRIVATE_KEY" || -z "$GET_FILE" ]]; then
    echo "Usage: $0 <SFTP_HOST> <SFTP_USER> <SFTP_REMOTE_PATH> <LOCAL_DOWNLOAD_PATH> <PRIVATE_KEY> <GET_FILE>"
    exit 1
fi

# Perform the SFTP operation
sftp -o StrictHostKeyChecking=no -i "$PRIVATE_KEY" "$SFTP_USER@$SFTP_HOST" <<EOF
cd "$SFTP_REMOTE_PATH"
lcd "$LOCAL_DOWNLOAD_PATH"
get $GET_FILE
bye
EOF

if [[ $? -eq 0 ]]; then
    echo "File $GET_FILE successfully downloaded to $LOCAL_DOWNLOAD_PATH"
else
    echo "Failed to download $GET_FILE"
    exit 1
fi
