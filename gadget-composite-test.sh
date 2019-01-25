#!/bin/bash

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

echo 0x1d6b > idVendor # Linux Foundation
echo 0x0137 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # Version 1.0.0
echo 0x0200 > bcdUSB # USB 2.0


echo 0xEF > bDeviceClass
echo 0x02 > bDeviceSubClass
echo 0x01 > bDeviceProtocol

# Creating English Locale
mkdir -p strings/0x409
echo "1337696969" > strings/0x409/serialnumber
echo "Team 404" > strings/0x409/manufacturer
echo "Economical Duck" > strings/0x409/product

echo "Setting up functionality"

C=1
mkdir -p configs/c.$C/strings/0x409
echo 250 > configs/c.1/MaxPower
echo 0xC0 > configs/c.1/bmAttributes # self powered device
echo 0x80 > configs/c.1/bmAttributes #  USB_OTG_SRP | USB_OTG_HNP
echo 250 > configs/c.$C/MaxPower 

N="usb0"
# RNDIS
mkdir -p functions/rndis.$N
echo "42:63:65:13:34:56" > functions/rndis.$N/host_addr
echo "42:63:65:66:43:21" > functions/rndis.$N/dev_addr

mkdir -p os_desc
echo 1 > os_desc/use
echo 0xbc > os_desc/b_vendor_code
echo MSFT100 > os_desc/qw_sign

mkdir -p functions/rndis.usb0/os_desc/interface.rndis
echo RNDIS > functions/rndis.usb0/os_desc/interface.rndis/compatible_id
echo 5162001 > functions/rndis.usb0/os_desc/interface.rndis/sub_compatible_id

# Mass Storage
mkdir -p functions/mass_storage.$N
echo 1 > functions/mass_storage.$N/stall
echo 0 > functions/mass_storage.$N/lun.0/cdrom
echo 0 > functions/mass_storage.$N/lun.0/ro
echo 0 > functions/mass_storage.$N/lun.0/nofua
echo $FILE > functions/mass_storage.$N/lun.0/file

# HID Device
mkdir -p functions/hid.$N
echo 1 > functions/hid.$N/protocol
echo 1 > functions/hid.$N/subclass
echo 8 > functions/hid.$N/report_length
echo -ne \\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0 > functions/hid.$N/report_desc



echo "Linking functionality"
ln -s functions/rndis.$N configs/c.$C/
ln -s functions/mass_storage.$N configs/c.$C/
ln -s functions/hid.$N configs/c.$C/

echo "Enabling gadget"
ls /sys/class/udc > UDC