#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi
echo "Removing gadget"

N="usb0"
C=1

cd /sys/kernel/config/usb_gadget/ecoduck

echo "" > UDC

rm configs/c.$C/*.$N
rmdir configs/c.$C/strings/*
rmdir configs/c.$C
rmdir functions/*
rmdir strings/*
cd ..
rmdir ecoduck

echo "Gadget removed"