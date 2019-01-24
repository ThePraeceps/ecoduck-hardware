#!/bin/usr/env python3
import os
from time import sleep
from subprocess import Popen, PIPE

def write_report(report):
	fd = os.open("/dev/hidg0", os.O_RDWR)
	os.write(fd, report)
	os.close(fd)

def popen_timeout(command, timeout):
    p = Popen(command, stdout=PIPE, stderr=PIPE)
    for t in range(timeout):
        sleep(1)
        if p.poll() is not None:
            return True
    p.kill()
    return False

def wait_till_disconnect():
	while(popen_timeout("./electrical-test.sh", 5)):
		sleep(3)
	print("Disconnected!")

while(1):
	os.system("head -c 1 /dev/hidg0 > /dev/null")
	if(popen_timeout("./electrical-test.sh", 1):
		print("Target conneceted")
		write_report(b'\x80\x00\x15\x00\x00\x00\x00\x00')
		write_report(b'\x00\x00\x00\x00\x00\x00\x00\x00')
		sleep(1)
		write_report(b'\x00\x00\x06\x00\x00\x00\x00\x00')
		write_report(b'\x00\x00\x10\x00\x00\x00\x00\x00')
		write_report(b'\x00\x00\x07\x00\x00\x00\x00\x00')
		write_report(b'\x00\x00\x28\x00\x00\x00\x00\x00')
		write_report(b'\x00\x00\x00\x00\x00\x00\x00\x00')
		sleep(2)
		write_report(b'\x00\x00\x08\x00\x00\x00\x00\x00')
		write_report(b'\x00\x00\x06\x00\x00\x00\x00\x00')
		write_report(b'\x00\x00\x0b\x00\x00\x00\x00\x00')
		write_report(b'\x00\x00\x12\x00\x00\x00\x00\x00')
		write_report(b'\x00\x00\x2c\x00\x00\x00\x00\x00')

		write_report(b'\x00\x00\x34\x00\x00\x00\x00\x00')
		# H (press shift and H)

		write_report(b'\x20\x00\x0b\x00\x00\x00\x00\x00')

		# e
		write_report(b'\x00\x00\x08\x00\x00\x00\x00\x00')

		# ll
		write_report(b'\x00\x00\x0f\x00\x00\x00\x00\x00')
		write_report(b'\x00\x00\x00\x00\x00\x00\x00\x00')
		write_report(b'\x00\x00\x0f\x00\x00\x00\x00\x00')

		# o
		write_report(b'\x00\x00\x12\x00\x00\x00\x00\x00')

		# SPACE
		write_report(b'\x00\x00\x2c\x00\x00\x00\x00\x00')

		# W (press shift and W)
		write_report(b'\x20\x00\x1a\x00\x00\x00\x00\x00')

		# o
		write_report(b'\x00\x00\x12\x00\x00\x00\x00\x00')

		# r
		write_report(b'\x00\x00\x15\x00\x00\x00\x00\x00')

		# l
		write_report(b'\x00\x00\x0f\x00\x00\x00\x00\x00')

		# d
		write_report(b'\x00\x00\x07\x00\x00\x00\x00\x00')

		# ! (press shift and 1)
		write_report(b'\x20\x00\x1e\x00\x00\x00\x00\x00')

		write_report(b'\x00\x00\x34\x00\x00\x00\x00\x00')

		write_report(b'\x00\x00\x28\x00\x00\x00\x00\x00')

		# Release al keys
		write_report(b'\x00\x00\x00\x00\x00\x00\x00\x00')
		print("Payload completed")
		wait_till_disconnect()
