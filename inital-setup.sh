#!/bin/bash
# Enable LibComposite

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

modprobe dwc2
modprobe libcomposite

echo "dtoverlay=dwc2" >> /boot/config
echo "dwc2" >> /etc/modules
echo "libcomposite" >> /etc/modules

echo "Updating system"
sudo BRANCH=next rpi-update

echo "Making File System"
# Making USB Mass Storage File System
dd if=/dev/zero of=/ecoduck.img bs=1024 count=524288
mkdosfs /ecoduck.img

cat templates/interface.tmpl > /etc/network/interfaces
cat templates/wpa_supplicant.conf.tmpl > /etc/wpa_supplicant/wpa_supplicant.conf


bash configure.sh

reboot