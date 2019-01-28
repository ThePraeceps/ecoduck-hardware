#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

N="usb0"
C=1

echo "Disabling gadgets"
cd /sys/kernel/config/usb_gadget

echo "" > ecoduck-simple/UDC
echo "" > ecoduck-win/UDC
echo "" > ecoduck-other/UDC

echo "Removing simple gadget"
cd ecoduck-simple

rm configs/c.*/*.$N
rmdir configs/c.*/strings/*
rmdir configs/c.*
rmdir functions/*
rmdir strings/*
cd ..

echo "Removing windows gadget"
cd ecoduck-win

rm configs/c.*/*.$N
rm os_desc/c.*
rmdir configs/c.*/strings/*
rmdir configs/c.*
rmdir functions/*
rmdir strings/*
cd ..

echo "Removing other OS gadget"
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

echo "Script complete"