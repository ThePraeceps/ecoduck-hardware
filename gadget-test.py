#!/bin/usr/env python3
import usb.core
import usb.util

usbs = usb.core.find()
for item in usbs:
	for i in item:
		for e in i:
			print e.bEndpointAddress
