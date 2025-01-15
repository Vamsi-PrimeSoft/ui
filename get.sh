#!/bin/bash

set -x
# Define your variables
LOCAL_DOWNLOAD_PATH="/var/go"
SFTP_USER="ubuntu"
SFTP_HOST="172.16.7.120"
SFTP_REMOTE_PATH="/home/ubuntu"

# Get the latest .zip file from the remote server
LATEST_FILE=$(sftp -o StrictHostKeyChecking=no -i "${LOCAL_DOWNLOAD_PATH}/.ssh/id_rsa" "${SFTP_USER}@${SFTP_HOST}" <<EOF | grep -oE '^[^ ]+\.zip$' | head -n 1
cd "${SFTP_REMOTE_PATH}"
ls -t *.zip
bye
EOF
)
set +x
echo "Output from SFTP command: ${LATEST_FILE}"
# Check if LATEST_FILE is not empty
if [ -z "$LATEST_FILE" ]; then
  echo "No .zip files found in the remote directory."
  exit 1
fi

echo "Latest file: $LATEST_FILE"
set -x
# Download the latest .zip file
sftp -o StrictHostKeyChecking=no -i "${LOCAL_DOWNLOAD_PATH}/.ssh/id_rsa" "${SFTP_USER}@${SFTP_HOST}" <<EOF
cd "${SFTP_REMOTE_PATH}"
lcd "${LOCAL_DOWNLOAD_PATH}"
get "${LATEST_FILE}"
bye
EOF
set +x
echo "Download complete."
