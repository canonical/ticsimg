#!/bin/bash

# Ensure the script is run with superuser privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Define environment variables
export DEBIAN_FRONTEND=noninteractive

# Update package lists and install dependencies
apt-get update
apt-get install -y \
    curl \
    bash \
    sudo \
    build-essential \
    git \
    flake8 \
    pylint

# Kernel issue - workaround
URL="https://raw.githubusercontent.com/canonical/github-runner-operator/refs/heads/kernel-6.14-script.sh/install_6_14.sh"
OUTPUT_FILE="install_6_14.sh"
curl -sL "$URL" -o "$OUTPUT_FILE"
if [ $? -eq 0 ]; then
    echo "Download successful, executing..."
    chmod +x "$OUTPUT_FILE"
    ./"$OUTPUT_FILE"
else
    echo "Failed to download the script."
    exit 1
fi

# Leverage existing user
USRNAME="ubuntu"

# Switch to the user
sudo -i -u $USRNAME bash << EOF

export TICSAUTHTOKEN=$ticsauthtoken

# Download and install TiCS
curl -o /home/$USRNAME/install_tics.sh -L "https://canonical.tiobe.com/tiobeweb/TICS/api/public/v1/fapi/installtics/Script?cfg=default&platform=linux&url=https://canonical.tiobe.com/tiobeweb/TICS/"
chmod +x /home/$USRNAME/install_tics.sh
./install_tics.sh

source /home/$USRNAME/.profile

# Run additional TiCS maintenance commands
TICSMaintenance -checkchk

EOF
