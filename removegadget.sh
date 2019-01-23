#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi
"Removing gadget"

cd /sys/kernel/config/usb_gadget/ecoduck

echo "" > UDC

rm configs/c.$C/*
rmdir configs/c.$C/strings/*
rmdir configs/c.$C
rmdir functions/*
rmdir strings/*
cd ..
rmdir ecoduck

echo "Gadget removed"