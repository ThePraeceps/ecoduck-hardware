#!/bin/bash

HOSTMAC="48:6f:73:74:50:43"
CLIENTMAC="42:61:64:55:53:42"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "Making File System"
# Making USB Mass Storage File System
# dd if=/dev/zero of=/ecoduck.img bs=1024 count=524288
# mkdosfs /ecoduck.img

echo "Mounting mass storage on Pi"
FILE=/ecoduck.img
mkdir -p /mnt/ecoduck
mount -o loop,rw, -t vfat $FILE /mnt/ecoduck

echo "Creating gadget"
# Create gadget
cd /sys/kernel/config/usb_gadget/
mkdir ecoduck && cd ecoduck


# Add basic information

echo 0x04b3 > idVendor # Linux Foundation
echo 0x4010 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # Version 1.0.0
echo 0x0200 > bcdUSB # USB 2.0
echo "0x02" > bDeviceClass # Needs to be 0x00 for Mass Storage
echo "0x00" > bDeviceSubClass


# Creating English Locale
mkdir -p strings/0x409
echo "1337696969" > strings/0x409/serialnumber
echo "Team 404" > strings/0x409/manufacturer
echo "Economical Duck" > strings/0x409/product

echo "Setting up functionality"
N="usb0"


mkdir -p functions/rndis.$N
echo $CLIENTMAC > functions/rndis.$N/dev_addr
echo $HOSTMAC > functions/rndis.$N/host_addr
echo "RNDIS" > functions/rndis.$N/os_desc/interface.rndis/compatible_id
echo "5162001" > functions/rndis.$N/os_desc/interface.rndis/sub_compatible_id

echo "1" > os_desc/use
echo "0xcd" > os_desc/b_vendor_code
echo "MSFT100" > os_desc/qw_sign



C=1
mkdir -p configs/c.$C/strings/0x409
echo "Windows Configuration" > configs/c.$C/strings/0x409/configuration
echo 250 > configs/c.$C/MaxPower 
echo "0x80" > configs/c.$C/bmAttributes

echo "Linking functionality"

ln -s functions/rndis.$N configs/c.$C/
ln -s configs/c.$C os_desc

echo "Enabling gadget"
ls /sys/class/udc > UDC