#!/bin/bash

# Enable debugging
set -x

# Define your variables
LOCAL_DOWNLOAD_PATH="/var/go"
SFTP_USER="ubuntu"
SFTP_HOST="172.16.7.120"
SFTP_REMOTE_PATH="/home/ubuntu"

# Echo the status
echo "Checking for .zip files in the remote path: ${SFTP_REMOTE_PATH}"

# Get the list of .zip files from the remote server
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

# Print confirmation that download is complete
echo "Download complete for ${LATEST_FILE}"

# Now, proceed with further operations (e.g., extracting and moving the .zip file)
echo "Processing downloaded .zip files..."

# Check if any .zip files exist in /var/go/
if ls /var/go/*.zip 1> /dev/null 2>&1; then
  # Remove the prime-square directory (if necessary)
  sudo rm -rf "/var/www/html/prime-square"

  # Ensure the .zip files exist and then proceed with chown, unzip, and mv
  sudo chown "ubuntu:ubuntu" /var/go/*.zip
  sudo unzip -o /var/go/*.zip -d "/var/www/html"
  sudo mv /var/go/*.zip /home/ubuntu/ui-archive

  echo "Processing completed successfully."
else
  echo "No .zip files found in ${LOCAL_DOWNLOAD_PATH}. Please check the download step."
  exit 1
fi
