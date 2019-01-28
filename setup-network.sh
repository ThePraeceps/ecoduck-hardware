#!/bin/bash
ovs-vsctl list port usb0
retVal=$?
if [ $retVal -eq 0 ]; then
        ovs-vsctl del-port usb0
fi

sudo ovs-vsctl list port usb1
retVal=$?
if [ $retVal -eq 0 ]; then
        ovs-vsctl del-port usb1
fi
