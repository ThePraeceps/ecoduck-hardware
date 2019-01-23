#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

LOGFILE=/usbreq.log
dmesg | grep "USB DWC2 REQ 80 06 03" > $LOGFILE
WLENGTHS=`awk '$9!="0000" { print $10 }' $LOGFILE`
TOTAL=0
COUNTER=0
for i in $WLENGTHS; do
    if [ "$i" = "00ff" ]; then
        let COUNTER=COUNTER+1
    fi
    let TOTAL=TOTAL+1
    #echo wLength: $i
done
#echo $COUNTER
if [ $TOTAL -eq 0 ]; then
    echo Unknown
    exit
fi
#echo $COUNTER
if [ $COUNTER -eq 0 ]; then
    echo "MacOs" >> $LOGFILE
#elif [ $COUNTER -eq $TOTAL ]; then
#    echo Linux
else
     echo Other
#    echo Windows
fi

modprobe -r g_ether
modprobe libcomposite

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
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # Version 1.0.0
echo 0x0200 > bcdUSB # USB 2.0


# Creating English Locale
mkdir -p strings/0x409
echo "1337696969" > strings/0x409/serialnumber
echo "Team 404" > strings/0x409/manufacturer
echo "Economical Duck" > strings/0x409/product

echo "Setting up functionality"
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

echo "Linking functionality"
ln -s functions/mass_storage.$N configs/c.$C/
ln -s functions/hid.$N configs/c.$C/

echo "Enabling gadget"
ls /sys/class/udc > UDC