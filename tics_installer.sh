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

# Kernel issue - workaround for 6.17.0
if [[ $(uname -r | cut -d '-' -f 1) == "6.17.0" ]]; then
    echo "Kernel 6.17.0 detected."
    apt-get install -y linux-generic-6.14

    ARCH=$(dpkg --print-architecture)
    if [ "$ARCH" = "s390x" ]; then
        # s390x uses zipl; /boot/vmlinuz symlink already points to 6.14 after install
        zipl
    else
        # Pin GRUB to boot the 6.14 kernel instead of the newer HWE kernel
        KERNEL_ENTRY=$(sudo grep -oP "menuentry '\K[^']*6\.14[^']*" /boot/grub/grub.cfg | head -1)
        sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub
        grub-set-default "Advanced options for Ubuntu>${KERNEL_ENTRY}"
        update-grub
    fi

    # Prevent apt upgrade from pulling in a newer HWE kernel
    apt-mark hold linux-generic-hwe-24.04 linux-image-generic-hwe-24.04

    # Suppress misleading "Pending Kernel Upgrade" warnings from needrestart
    sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = 0;/g" /etc/needrestart/needrestart.conf
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
