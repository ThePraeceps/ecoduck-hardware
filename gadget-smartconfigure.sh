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

echo 1 > functions/hid.$N/protocol
echo 1 > functions/hid.$N/subclass
echo 8 > functions/hid.$N/report_length
echo -ne \\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0 > functions/hid.$N/report_desc


C=1
mkdir -p configs/c.$C/strings/0x409

echo 250 > configs/c.$C/MaxPower 

echo "Linking functionality"
ln -s functions/hid.$N configs/c.$C/

echo "Enabling gadget"
ls /sys/class/udc > UDC

echo "Waiting for connection"
bash /home/pi/ecoduck-hardware/electrical-test.sh

echo "Identifying OS"
OS="$(bash /home/pi/ecoduck-hardware/fingerprint-host.sh)"
HOST="48:6f:73:74:50:43"
SELF0="42:61:64:55:53:42"
SELF1="42:61:64:55:53:43"

echo "Setting up mass storage"
mkdir -p functions/mass_storage.$N

echo 1 > functions/mass_storage.$N/stall
echo 0 > functions/mass_storage.$N/lun.0/cdrom
echo 0 > functions/mass_storage.$N/lun.0/ro
echo 0 > functions/mass_storage.$N/lun.0/nofua
echo $FILE > functions/mass_storage.$N/lun.0/file

echo "Setting up Networking"
if [ "$OS" != "MacOS" ]; then
	echo "Not Mac"
	# Config 1: RNDIS
	C=2
	mkdir -p configs/c.$C/strings/0x409
	echo "0x80" > configs/c.$C/bmAttributes
	echo 250 > configs/c.$C/MaxPower
	echo "Config 1: RNDIS network" > configs/c.$C/strings/0x409/configuration

	echo "1" > os_desc/use
	echo "0xcd" > os_desc/b_vendor_code
	echo "MSFT100" > os_desc/qw_sign

	mkdir -p functions/rndis.$N
	echo $SELF0 > functions/rndis.$N/dev_addr
	echo $HOST > functions/rndis.$N/host_addr
	echo "RNDIS" > functions/rndis.$N/os_desc/interface.rndis/compatible_id
	echo "5162001" > functions/rndis.$N/os_desc/interface.rndis/sub_compatible_id
fi
C=3
# Config 2: CDC ECM
mkdir -p configs/c.$C/strings/0x409
echo "Config 2: ECM network" > configs/c.2/strings/0x409/configuration
echo 250 > configs/c.$C/MaxPower

mkdir -p functions/ecm.$N
# first byte of address must be even
echo $HOST > functions/ecm.$N/host_addr
echo $SELF1 > functions/ecm.$N/dev_addr

# Create the CDC ACM function
mkdir -p functions/acm.gs0

# Link everything and bind the USB device
if [ "$OS" != "MacOs" ]; then
	ln -s configs/c.2 os_desc
	ln -s functions/rndis.usb0 configs/c.2
fi

ln -s functions/ecm.usb0 configs/c.3
ln -s functions/acm.gs0 configs/c.3
ln -s functions/mass_storage.$N configs/c.1/

echo "" > UDC
ls /sys/class/udc > UDC

echo "Running payload"
python3 /home/pi/ecoduck-hardware/gadget-test.py