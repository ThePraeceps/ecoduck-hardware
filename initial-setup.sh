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
apt install -y openvswitch-switch git dnsmasq bison flex bc libssl-dev screen
# Create OVS bridge for gadgets and DHCP

cd "$dir"
# Configuring Packages
echo "Configuring packages"
cat templates/interfaces.tmpl > /etc/network/interfaces
cat templates/dnsmasq.conf.tmpl > /etc/dnsmasq.conf

cd "$dir"
cp templates/ecoduck-install.tmpl /etc/init.d/ecoduck-install
sed -i -e "s|PATH_TO_SCRIPT|$path|g" /etc/init.d/ecoduck-install
chmod 755 /etc/init.d/ecoduck-install
update-rc.d ecoduck-install defaults

cp templates/getty.override.tty /etc/systemd/system/getty@tty1.service.d/override.conf

else
echo "Second run"
echo "Attempting to automatically patch kernel for finger printing"
cd "$dir"
bash patch-kernel.sh

# ToDo: AP Setup?
echo "Setting up software"

mkdir -p /usr/ecoduck/
cd /usr/ecoduck/
git clone git://www.github.com/ThePraeceps/ecoduck-software.git
cp ecoduck-software/gadget-configure.sh ./
cp ecoduck-software/ecoduck.py ./
cp ecoduck-software/load-payloads.py ./

echo "Setting up boot script"
cd "$dir"
cp templates/ecoduck-init.tmpl /etc/init.d/ecoduck-init
chmod 755 /etc/init.d/ecoduck-init
update-rc.d ecoduck-init defaults




echo "Creating OVS bridge for gadgets"
ovs-vsctl add-br bridge


echo "Setup complete, removing setup from reboot" 
update-rc.d -f ecoduck-install remove
rm -f /etc/init.d/ecoduck-install
rm -f /etc/systemd/system/getty@tty1.service.d/override.conf

fi

echo "Rebooting"

reboot