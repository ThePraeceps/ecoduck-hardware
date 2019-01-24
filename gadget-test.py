#!/bin/usr/env python3
import os
from time import sleep

def write_report(report):
	fd = os.open("/dev/hidg0", os.O_RDWR)
	os.write(fd, report)
	os.close(fd)

while(1):
	os.system("head -c 1 /dev/hidg0 > /dev/null")
	print("Packet Recieved")
	write_report(b'\x80\0\x15\0\0\0\0\0')
	write_report(b'\0\0\0\0\0\0\0\0')
	sleep(1)
	write_report(b'\0\0\x6\0\0\0\0\0')
	write_report(b'\0\0\x10\0\0\0\0\0')
	write_report(b'\0\0\x7\0\0\0\0\0')
	write_report(b'\0\0\x28\0\0\0\0\0')
	write_report(b'\0\0\0\0\0\0\0\0')
	sleep(2)
	write_report(b'\0\0\x08\0\0\0\0\0')
	write_report(b'\0\0\x06\0\0\0\0\0')
	write_report(b'\0\0\x0b\0\0\0\0\0')
	write_report(b'\0\0\x12\0\0\0\0\0')
	write_report(b'\0\0\x2c\0\0\0\0\0')

	write_report(b'\0\0\x34\0\0\0\0\0')
	# H (press shift and H)

	write_report(b'\x20\0\xb\0\0\0\0\0')

	# e
	write_report(b'\0\0\x8\0\0\0\0\0')

	# ll
	write_report(b'\0\0\xf\0\0\0\0\0')
	write_report(b'\0\0\0\0\0\0\0\0')
	write_report(b'\0\0\xf\0\0\0\0\0')

	# o
	write_report(b'\0\0\x12\0\0\0\0\0')

	# SPACE
	write_report(b'\0\0\x2c\0\0\0\0\0')

	# W (press shift and W)
	write_report(b'\x20\0\x1a\0\0\0\0\0')

	# o
	write_report(b'\0\0\x12\0\0\0\0\0')

	# r
	write_report(b'\0\0\x15\0\0\0\0\0')

	# l
	write_report(b'\0\0\xf\0\0\0\0\0')

	# d
	write_report(b'\0\0\x7\0\0\0\0\0')

	# ! (press shift and 1)
	write_report(b'\x20\0\x1e\0\0\0\0\0')

	write_report(b'\0\0\x34\0\0\0\0\0')

	write_report(b'\0\0\x28\0\0\0\0\0')

	# Release al keys
	write_report(b'\0\0\0\0\0\0\0\0')