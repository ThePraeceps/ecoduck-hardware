#!/bin/usr/env python3
import os
from time import sleep
import signal



def timeout_handler():
	raise Execption("Timeout")

def electrical_test(path, timeout):
	signal.signal(signal.SIGALRM, timeout_handler)
	signal.alarm(timeout)
	try:
		write_report(b'\x00\x00\x39\x00\x00\x00\x00\x00',"/dev/hidg0")
		write_report(b'\x00\x00\x00\x00\x00\x00\x00\x00',"/dev/hidg0")
		fd = os.open(path, os.O_RDWR)
		state=os.read(fd,4)
		os.close(fd)
		if(state == b'\x02'):
			write_report(b'\x00\x00\x39\x00\x00\x00\x00\x00',"/dev/hidg0")
			write_report(b'\x00\x00\x00\x00\x00\x00\x00\x00',"/dev/hidg0")
			fd = os.open(path, os.O_RDWR)
			state=os.read(fd,4)
			os.close(fd)
	except:
		return False
	signal.alarm(0)
	return True

def write_report(report, path):
	fd = os.open(path, os.O_RDWR)
	os.write(fd, report)
	os.close(fd)

while(1):
	if(read_caps("/dev/hidg0", 2)):
		print("Connected")
	else:
		print("Not connected")
	sleep(1)



