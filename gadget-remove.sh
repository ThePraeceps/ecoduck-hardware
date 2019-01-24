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

rm configs/c.*/*.$N
rmdir configs/c.*/strings/*
rmdir configs/c.*
rmdir functions/*
rmdir strings/*
cd ..
rmdir ecoduck

echo "Gadget removed"