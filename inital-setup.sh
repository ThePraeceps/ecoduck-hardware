#!/bin/bash
# Enable LibComposite
path=$(realpath $0)
dir=$(dirname $0)
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi
getopts ":r" opt;
case $opt in
	r)
		run=1
		;;
	\?)
		run=0
		;;
esac
echo $run
if [[ $run -ne 1 ]]; then
echo "First run"
modprobe dwc2
modprobe libcomposite

echo "dtoverlay=dwc2" >> /boot/config.txt
echo "dwc2" >> /etc/modules
echo "libcomposite" >> /etc/modules

echo "Updating system"
sudo BRANCH=next rpi-update
apt update
apt upgrade -y

echo "Making File System"
# Making USB Mass Storage File System
dd if=/dev/zero of=/ecoduck.img bs=1024 count=524288
mkdosfs /ecoduck.img


# Installing required packages
echo "Installing required packages"
apt install -y openvswitch-switch git dnsmasq bison flex bc libssl-dev
# Create OVS bridge for gadgets and DHCP
echo "Creating OVS bridge for gadgets"
ovs-vsctl add-br bridge
ovs-vsctl add-port bridge usb0
ovs-vsctl add-port bridge usb1
cd "$dir"
# Configuring Packages
echo "Configuring packages"
cat templates/interface.tmpl > /etc/network/interfaces
cat templates/wpa_supplicant.conf.tmpl > /etc/wpa_supplicant/wpa_supplicant.conf
cat templates/dnsmasq.conf.tmpl > /etc/dnsmasq.conf

cp /etc/rc.local templates/rc.local.bak
cp templates/rc.local-reboot.tmpl /etc/rc.local
sed -i -e "s|PATH_TO_SCRIPT|$path|g" /etc/rc.local

else
echo "Second run"
echo "Attempting to automatically patch kernel for finger printing"
cd "$dir"
bash patch-kernel.sh

# ToDo: AP Setup?
cd "$dir"

cp templates/rc.local.bak /etc/rc.local

fi

echo "Rebooting"

reboot