#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

dir=$(dirname $0)
patchloc=$(readlink -f "${dir}/templates/gadget.patch")
apt install -y bison flex bc libssl-dev

version="$(uname -r | awk -F '.' '{ print $1 }')"
patchlevel="$(uname -r | awk -F '.' '{ print $2 }')"
branch="rpi-$version.$patchlevel.y"
echo "Identifed branch from kernel version: $branch"
echo "Cloning idetnified branch"
cd /root/
git clone --depth=1 --branch "$branch" https://github.com/raspberrypi/linux
if [ $? -ne 0 ]; then
    echo "Git command failed, possible network error or branch detection failed"
    exit
fi

echo "Compiling kernel"
cd linux
KERNEL=kernel
make bcmrpi_defconfig
make oldconfig
make prepare
make scripts
echo "Attempting to patching dwc2"
cd drivers/usb/dwc2
patch -i -f "$patchloc"
if [ $? -ne 0 ]; then
    echo "Patched failed, kernel version potentially incompatible"
    exit
fi
cd /root/linux
make M=drivers/usb/dwc2 CONFIG_USB_DWC2=m
if [ $? -ne 0 ]; then
    echo "Make command failed, kernel version potentially incompatible"
    exit
fi

cd drivers/usb/dwc2
cd "$dir"
mkdir -p kernel-patch
cd kernel-patch
cp /root/linux/drivers/usb/dwc2/dwc2.ko ./dwc2-patched.ko
cp "/lib/modules/$(uname -r)/kernel/drivers/usb/dwc2/dwc2.ko" "./dwc2-original.ko"
cp "./dwc2-patched.ko" "/lib/modules/$(uname -r)/kernel/drivers/usb/dwc2/dwc2.ko"