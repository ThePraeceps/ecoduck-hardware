#!/bin/usr/env python3
import os

while:
	os.system("head -c 1 /dev/hidg0")
	print("Packet Recieved")