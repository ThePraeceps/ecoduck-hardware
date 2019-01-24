#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

function write_report {
    echo -ne $1 > /dev/hidg0
}
write_report "\0\0\x39\0\0\0\0\0"
write_report "\0\0\0\0\0\0\0\0"
head -c 1 /dev/hidg0 > /dev/null
write_report "\0\0\x39\0\0\0\0\0"
write_report "\0\0\0\0\0\0\0\0"
echo "Connected!"