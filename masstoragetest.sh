#!/bin/bash
# Enable LibComposite
modprobe libcomposite

echo "Making File System"
# Making USB Mass Storage File System
dd if=/dev/zero of=/ecoduck.img bs=1024 count=524288
mkdosfs /ecoduck.img

IMAGEFILE=/ecoduck.img

mkdir /mnt/ecoduck
mount -o loop,ro, -t vfat $IMAGEFILE /mnt/ecoduck

echo "Creating gadget"
# Create gadget
cd /sys/kernel/config/usb_gadget/
mkdir ecomass && cd ecomass


# Add basic information

echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x1d6b > idVendor # Linux Foundation
echo 0x0100 > bcdDevice # Version 1.0.0
echo 0x0200 > bcdUSB # USB 2.0

# echo 0x00 > bDeviceClass
# echo 0x00 > bDeviceProtocol
# echo 0x00 > bDeviceSubClass
# echo 0x08 > bMaxPacketSize0

# Create English locale
mkdir strings/0x409

echo "Team 404" > strings/0x409/manufacturer
echo "Economical Duck" > strings/0x409/product
echo "1337696969" > strings/0x409/serialnumber


# Create Mass Storage function
mkdir functions/mass_storage.usb0

echo 1 > functions/mass_storage.usb0/stall
echo 0 > functions/mass_storage.usb0/lun.0/cdrom
echo 0 > functions/mass_storage.usb0/lun.0/ro
echo 0 > functions/mass_storage.usb0/lun.0/nofua
echo $IMAGEFILE > functions/mass_storage.usb0/lun.0/file


# Create configuration
mkdir configs/c.1
mkdir configs/c.1/strings/0x409

# echo 0x80 > configs/c.1/bmAttributes
echo 200 > configs/c.1/MaxPower # 200 mA
echo "Test config" > configs/c.1/strings/0x409/configuration

echo "Starting gadget"
# Link HID function to configuration
ln -s functions/mass_storage.usb0 configs/c.1/

# Enable gadget
ls /sys/class/udc > UDC