#!/bin/bash

# assumes a disk image exists here...
FILE=/ecoduck.img
mkdir -p /mnt/ecoduck
mount -o loop,ro,offset=1048576 -t vfat $FILE /mnt/ecoduck
cd /sys/kernel/config/usb_gadget/

mkdir -p ecomass
cd ecomass
#echo '' > UDC

echo 0x1d6b > idVendor # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB # USB2

mkdir -p strings/0x409
echo "fedcba9876543210" > strings/0x409/serialnumber
echo "Inverse Path" > strings/0x409/manufacturer 
echo "USB Armory" > strings/0x409/product 

N="usb0"

mkdir -p functions/hid.$N
mkdir -p functions/mass_storage.$N


echo 1 > functions/mass_storage.$N/stall
echo 0 > functions/mass_storage.$N/lun.0/cdrom
echo 0 > functions/mass_storage.$N/lun.0/ro
echo 0 > functions/mass_storage.$N/lun.0/nofua
echo $FILE > functions/mass_storage.$N/lun.0/file

echo 1 > functions/hid.$N/protocol
echo 1 > functions/hid.$N/subclass
echo 8 > functions/hid.$N/report_length
echo -ne \\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0 > functions/hid.$N/report_desc


C=1
mkdir -p configs/c.$C/strings/0x409

echo 250 > configs/c.$C/MaxPower 

ln -s functions/mass_storage.$N configs/c.$C/
ln -s functions/hid.$N configs/c.$C/

# it took a little while to find out that the i.MX53 uses
# a ChipIdea core and thus "ci_hdrc.0" is the right driver 
#echo ci_hdrc.0 > UDC

# this lists available UDC drivers
ls /sys/class/udc > UDC
