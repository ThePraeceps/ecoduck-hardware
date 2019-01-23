#!/bin/usr/env python3
import os

while(1):
	os.system("head -c 1 /dev/hidg0")
	print("Packet Recieved")