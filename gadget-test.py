#!/bin/usr/env python3
import os,signal
from time import sleep
from subprocess import Popen, PIPE, check_output
def write_report(report, path):
	fd = os.open(path, os.O_RDWR)
	os.write(fd, report)
	os.close(fd)


def dummy_payload(path):
	write_report(b'\x80\x00\x15\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x00\x00\x00\x00\x00\x00',path)
	sleep(1)
	write_report(b'\x00\x00\x06\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x10\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x07\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x28\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x00\x00\x00\x00\x00\x00',path)
	sleep(2)
	write_report(b'\x00\x00\x08\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x06\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x0b\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x12\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x2c\x00\x00\x00\x00\x00',path)

	write_report(b'\x00\x00\x34\x00\x00\x00\x00\x00',path)
	# H (press shift and H)

	write_report(b'\x20\x00\x0b\x00\x00\x00\x00\x00',path)

	# e
	write_report(b'\x00\x00\x08\x00\x00\x00\x00\x00',path)

	# ll
	write_report(b'\x00\x00\x0f\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x00\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x0f\x00\x00\x00\x00\x00',path)

	# o
	write_report(b'\x00\x00\x12\x00\x00\x00\x00\x00',path)

	# SPACE
	write_report(b'\x00\x00\x2c\x00\x00\x00\x00\x00',path)

	# W (press shift and W)
	write_report(b'\x20\x00\x1a\x00\x00\x00\x00\x00',path)

	# o
	write_report(b'\x00\x00\x12\x00\x00\x00\x00\x00',path)

	# r
	write_report(b'\x00\x00\x15\x00\x00\x00\x00\x00',path)

	# l
	write_report(b'\x00\x00\x0f\x00\x00\x00\x00\x00',path)

	# d
	write_report(b'\x00\x00\x07\x00\x00\x00\x00\x00',path)

	# ! (press shift and 1)
	write_report(b'\x20\x00\x1e\x00\x00\x00\x00\x00',path)

	write_report(b'\x00\x00\x34\x00\x00\x00\x00\x00',path)

	write_report(b'\x00\x00\x28\x00\x00\x00\x00\x00',path)

	# Release al keys
	write_report(b'\x00\x00\x00\x00\x00\x00\x00\x00',path)


def wait_till_disconnect():
	while(electrical_test("/dev/hidg0"),1):
		sleep(3)
	print("Disconnected!")


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




# Ensures simple gadget is selected
__location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))
os.system("echo \"\" > /sys/kernel/config/usb_gadget/ecoduck-win/UDC 2>/dev/null")
os.system("echo \"\" > /sys/kernel/config/usb_gadget/ecoduck-other/UDC 2>/dev/null")
os.system("echo \"\" > /sys/kernel/config/usb_gadget/ecoduck-simple/UDC 2>/dev/null")
os.system("ls /sys/class/udc > /sys/kernel/config/usb_gadget/ecoduck-simple/UDC 2>/dev/null")

while(1):
	if(electrical_test("/dev/hidg0", 1)):
		# OS Fingerprinting
		detectedos = check_output(__location__+"/fingerprint-host.sh").decode()[:-1]
		if "Windows" == detectedos:
			print("Windows detected")
			os.system("echo \"\" >  /sys/kernel/config/usb_gadget/ecoduck-simple/UDC")
			os.system("ls /sys/class/udc > /sys/kernel/config/usb_gadget/ecoduck-win/UDC")
		else:
			print("Other")
			os.system("echo \"\" >  /sys/kernel/config/usb_gadget/ecoduck-simple/UDC")
			os.system("ls /sys/class/udc > /sys/kernel/config/usb_gadget/ecoduck-other/UDC")

		path=check_output("/bin/ls /dev/hidg*",shell=True).decode()[:-1]
		print(path)
		print("Target is: " + detectedos)
		print("Target conneceted")
		sleep(2)
		dummy_payload(path)
		
		print("Payload completed")
		# Switch back to simple gadget
		if "Windows" == detectedos:
			os.system("echo \"\" > /sys/kernel/config/usb_gadget/ecoduck-win/UDC")
		else:
			os.system("echo \"\" > /sys/kernel/config/usb_gadget/ecoduck-other/UDC")
		os.system("ls /sys/class/udc > /sys/kernel/config/usb_gadget/ecoduck-simple/UDC")
		wait_till_disconnect()

