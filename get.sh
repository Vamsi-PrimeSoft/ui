#!/bin/bash

# Enable debugging
set -x

# Define your variables
LOCAL_DOWNLOAD_PATH="/var/go"
SFTP_USER="ubuntu"
SFTP_HOST="172.16.7.120"
SFTP_REMOTE_PATH="/home/ubuntu"

echo "Checking for .zip files in the remote path: ${SFTP_REMOTE_PATH}"

# Get the list of .zip files from the remote server and clean the output
REMOTE_LIST=$(sftp -o StrictHostKeyChecking=no -i "${LOCAL_DOWNLOAD_PATH}/.ssh/id_rsa" "${SFTP_USER}@${SFTP_HOST}" <<EOF
cd "${SFTP_REMOTE_PATH}"
ls -t *.zip
bye
EOF
)

# Disable debugging temporarily
set +x

# Print raw output from the sftp command
echo "Raw output from sftp command:"
echo "${REMOTE_LIST}"

# Clean the output to remove sftp command prompts and extract only filenames
CLEANED_LIST=$(echo "${REMOTE_LIST}" | sed -n '/.zip$/p' | sed 's/^\s*\([^ ]\+\.zip\)$/\1/')

# Print the cleaned list of .zip files
echo "Cleaned list of .zip files:"
echo "${CLEANED_LIST}"

# Extract the latest .zip file from the cleaned list
LATEST_FILE=$(echo "${CLEANED_LIST}" | head -n 1)

# Print the extracted file name
echo "Extracted latest file: ${LATEST_FILE}"

# Check if LATEST_FILE is not empty
if [ -z "$LATEST_FILE" ]; then
  echo "No .zip files found in the remote directory."
  exit 1
fi

echo "Latest file: $LATEST_FILE"

# Enable debugging for downloading the file
set -x

# Download the latest .zip file
sftp -o StrictHostKeyChecking=no -i "${LOCAL_DOWNLOAD_PATH}/.ssh/id_rsa" "${SFTP_USER}@${SFTP_HOST}" <<EOF
cd "${SFTP_REMOTE_PATH}"
lcd "${LOCAL_DOWNLOAD_PATH}"
get "${LATEST_FILE}"
bye
EOF

# Disable debugging
set +x

echo "Download complete."
