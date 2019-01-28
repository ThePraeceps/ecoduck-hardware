#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi
echo "Removing gadget"

N="usb0"
C=1

cd /sys/kernel/config/usb_gadget

echo "" > ecoduck-simple/UDC
echo "" > ecoduck-win/UDC
echo "" > ecoduck-other/UDC

cd ecoduck-simple

rm configs/c.*/*.$N
rmdir configs/c.*/strings/*
rmdir configs/c.*
rmdir functions/*
rmdir strings/*
cd ..

cd ecoduck-win

rm configs/c.*/*.$N
rm os_desc/c.*
rmdir configs/c.*/strings/*
rmdir configs/c.*
rmdir functions/*
rmdir strings/*
cd ..

cd ecoduck-other

rm configs/c.*/*.$N
rmdir configs/c.*/strings/*
rmdir configs/c.*
rmdir functions/*
rmdir strings/*
cd ..

rmdir ecoduck-simple
rmdir ecoduck-win
rmdir ecoduck-other

echo "Gadgets removed"