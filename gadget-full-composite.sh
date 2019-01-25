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

ID_VENDOR="0x1d6b"
ID_PRODUCT="0x0129"
SERIAL="$(grep Serial /proc/cpuinfo | sed 's/Serial\s*: 0000\(\w*\)/\1/')"
MAC="$(echo ${SERIAL} | sed 's/\(\w\w\)/:\1/g' | cut -b 2-)"
MAC_HOST="12$(echo ${MAC} | cut -b 3-)"
MAC_DEV="02$(echo ${MAC} | cut -b 3-)"

N="usb0"
C=1
FILE=/ecoduck.img

cd /sys/kernel/config/usb_gadget/

mkdir ecoduck
cd ecoduck

echo "0x0200" > bcdUSB
echo "0x00" > bDeviceClass
echo "0x00" > bDeviceSubClass
echo "0x3066" > bcdDevice
echo $ID_VENDOR > idVendor
echo $ID_PRODUCT > idProduct

# Windows extensions to force config

echo "1" > os_desc/use
echo "0xcd" > os_desc/b_vendor_code
echo "MSFT100" > os_desc/qw_sign

mkdir strings/0x409
echo "1337696969" > strings/0x409/serialnumber
echo "Team 404" > strings/0x409/manufacturer
echo "Economical Duck" > strings/0x409/product


# Config #1 for OSX / Linux

mkdir configs/c.1
mkdir configs/c.1/strings/0x409
echo "CDC 2xACM+Mass Storage+RNDIS" > configs/c.1/strings/0x409/configuration

mkdir functions/rndis.usb0 # Flippin' Windows
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


echo "RNDIS" > functions/rndis.usb0/os_desc/interface.rndis/compatible_id
echo "5162001" > functions/rndis.usb0/os_desc/interface.rndis/sub_compatible_id

echo $MAC_HOST > functions/rndis.usb0/host_addr
echo $MAC_DEV > functions/rndis.usb0/dev_addr

# Set up the rndis device only first

ln -s functions/rndis.usb0 configs/c.1

# Tell Windows to use config #2

ln -s configs/c.1 os_desc

ln -s functions/mass_storage.$N configs/c.$C/
ln -s functions/hid.$N configs/c.$C/


echo "20980000.usb" > UDC
