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
apt update
apt upgrade

echo "Making File System"
# Making USB Mass Storage File System
dd if=/dev/zero of=/ecoduck.img bs=1024 count=524288
mkdosfs /ecoduck.img


# Installing required packages
echo "Installing required packages"
apt install openvswitch-switch, git, dnsmasq
# Create OVS bridge for gadgets and DHCP
echo "Creating OVS bridge for gadgets"
ovs-vsctl add-br bridge

# Configuring Packages
echo "Configuring packages"
cat templates/interface.tmpl > /etc/network/interfaces
cat templates/wpa_supplicant.conf.tmpl > /etc/wpa_supplicant/wpa_supplicant.conf
cat templates/dnsmasq.conf.tmpl > /etc/dnsmasq.conf

echo "Attempting to automatically patch kernel for finger printing"
bash patch-kernel.sh

# ToDo: AP Setup?
# ToDo: Add EDS to rc.local

echo "Rebooting"

reboot