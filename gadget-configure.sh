#!/bin/bash

# Currently OSX supports Mass Storage + Serial but *not* RNDIS (at least not 10.12 anyway)
# Windows 10 and Linux seem to support everything
# Windows 8, 7 and below are untested

if [ ! -d /sys/kernel/config/usb_gadget ]; then
        modprobe libcomposite
fi

if [ -d /sys/kernel/config/usb_gadget/g1 ]; then
        exit 0
fi

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi


MAC_RNDIS_HOST="42:61:64:55:53:42"
MAC_RNDIS_CLIENT="42:61:64:55:53:43"

MAC_ECM_HOST="44:61:64:55:53:42"
MAC_ECM_CLIENT="44:61:64:55:53:43"

N="usb0"
C=1
FILE=/ecoduck.img

cd /sys/kernel/config/usb_gadget/

# Simple Gadget for OS Enumeration
# ----------------------------------------------------------------------
mkdir ecoduck-simple && cd ecoduck-simple


# Add basic information

echo 0x1d6b > idVendor # Linux Foundation
echo 0x4010 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # Version 1.0.0
echo 0x0200 > bcdUSB # USB 2.0


# Creating English Locale
mkdir -p strings/0x409
echo "1337696969" > strings/0x409/serialnumber
echo "Team 404" > strings/0x409/manufacturer
echo "Economical Duck - Simple" > strings/0x409/product

mkdir -p functions/hid.$N
mkdir -p functions/mass_storage.$N

echo 1 > functions/hid.$N/protocol
echo 1 > functions/hid.$N/subclass
echo 8 > functions/hid.$N/report_length
echo -ne \\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0 > functions/hid.$N/report_desc

echo 1 > functions/mass_storage.$N/stall
echo 0 > functions/mass_storage.$N/lun.0/cdrom
echo 0 > functions/mass_storage.$N/lun.0/ro
echo 0 > functions/mass_storage.$N/lun.0/nofua
echo $FILE > functions/mass_storage.$N/lun.0/file

mkdir -p configs/c.$C/strings/0x409

echo 250 > configs/c.$C/MaxPower 

echo "Linking functionality"
ln -s functions/hid.$N configs/c.$C/
ln -s functions/mass_storage.$N configs/c.$C/

cd ..

# Complex Gadget for Windows
# ----------------------------------------------------------------------

mkdir ecoduck-win && cd ecoduck-win

echo "0x0200" > bcdUSB
echo "0x00" > bDeviceClass
echo "0x00" > bDeviceSubClass
echo "0x3066" > bcdDevice
echo 0x1d6b > idVendor
echo 0x0129 > idProduct

# Windows extensions to force config

echo "1" > os_desc/use
echo "0xcd" > os_desc/b_vendor_code
echo "MSFT100" > os_desc/qw_sign

mkdir strings/0x409
echo "1337696969" > strings/0x409/serialnumber
echo "Team 404" > strings/0x409/manufacturer
echo "Economical Duck - Windows" > strings/0x409/product



mkdir configs/c.1
mkdir configs/c.1/strings/0x409
echo "HID+Mass Storage+RNDIS" > configs/c.1/strings/0x409/configuration

mkdir functions/rndis.$N # Flippin' Windows
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


echo "RNDIS" > functions/rndis.$N/os_desc/interface.rndis/compatible_id
echo "5162001" > functions/rndis.$N/os_desc/interface.rndis/sub_compatible_id

echo $MAC_RNDIS_HOST > functions/rndis.$N/host_addr
echo $MAC_RNDIS_CLIENT > functions/rndis.$N/dev_addr

# Set up the rndis device only first

ln -s functions/rndis.$N configs/c.1

# Tell Windows to use config #2

ln -s configs/c.1 os_desc

ln -s functions/mass_storage.$N configs/c.$C/
ln -s functions/hid.$N configs/c.$C/

cd ..


# Complex Gadget for MacOS/Linux
# ----------------------------------------------------------------------

mkdir ecoduck-other && cd ecoduck-other

echo "0x0200" > bcdUSB
echo "0x3066" > bcdDevice
echo "0x00" > bDeviceClass
echo "0x00" > bDeviceSubClass

echo 0x1d6b > idVendor # Linux Foundation
echo 0x4010 > idProduct # Multifunction Composite Gadget


mkdir strings/0x409
echo "1337696969" > strings/0x409/serialnumber
echo "Team 404" > strings/0x409/manufacturer
echo "Economical Duck - Other" > strings/0x409/product



mkdir configs/c.1
mkdir configs/c.1/strings/0x409
echo "HID+Mass Storage+ECM" > configs/c.1/strings/0x409/configuration

mkdir -p functions/ecm.$N # Flippin' Windows
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

echo $MAC_ECM_HOST > functions/ecm.usb0/host_addr
echo $MAC_ECM_CLIENT > functions/ecm.usb0/dev_addr


ln -s functions/ecm.$N configs/c.1
ln -s functions/mass_storage.$N configs/c.$C/
ln -s functions/hid.$N configs/c.$C/

cd ..


service dnsmasq start

ls /sys/class/udc > ecoduck-simple/UDC
echo "" > ecoduck-simple/UDC

ls /sys/class/udc > ecoduck-win/UDC
echo "" > ecoduck-win/UDC

ls /sys/class/udc > ecoduck-other/UDC
echo "" > ecoduck-other/UDC

ls /sys/class/udc > ecoduck-simple/UDC


# echo "Waiting for connection"
# bash /home/pi/ecoduck-hardware/electrical-test.sh

# OS="$(bash /home/pi/ecoduck-hardware/fingerprint-host.sh)"
# echo $OS


# echo "" > ecoduck-simple/UDC
# if [ "$OS" != "Windows" ]; then
# 	echo "Other"
# 	ls /sys/class/udc > ecoduck-other/UDC
# else 
# 	echo "Windows"
# 	ls /sys/class/udc > ecoduck-win/UDC
# fi