#!/bin/usr/env python3
import os,signal,io
from time import sleep
from subprocess import Popen, PIPE, check_output

def write_report(report, path):
	# Writes packet to given path
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

def network_test(path):
	# ping 192.168.10.1 (The pi)
	write_report(b'\x00\x00\x13\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x0C\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x11\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x0A\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x2c\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x1E\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x26\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x37\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x1E\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x23\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x1F\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x37\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x1E\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x27\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x37\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x1E\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x28\x00\x00\x00\x00\x00',path)
	write_report(b'\x00\x00\x00\x00\x00\x00\x00\x00',path)

	targetip=get_last_lease()
	nmapresults=check_output("/usr/bin/nmap -A " + targetip)
	print(nmapresults)

def wait_till_disconnect():
	# Loops till electrical tests fails
	print("Waiting for device removal")
	while(electrical_test("/dev/hidg0",1)):
		sleep(3)
	print("Disconnected!")


def timeout_handler():
	# Helper function for electrical_test
	raise Execption("Timeout")

def electrical_test(path, timeout):
	# Checks for a led HID packet from the host - proves target is connected, then resets capslock if it is on
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

def get_last_lease():
	fd = io.open("/var/lib/misc/dnsmasq.leases", "r")
	firstline = fd.readline()
	columns=firstline.split(" ")
	print("Found target IP: " + columns[2])
	return columns[2]




# Ensures simple gadget is selected
__location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))
os.system("echo \"\" > /sys/kernel/config/usb_gadget/ecoduck-win/UDC 2>/dev/null")
os.system("echo \"\" > /sys/kernel/config/usb_gadget/ecoduck-other/UDC 2>/dev/null")
os.system("echo \"\" > /sys/kernel/config/usb_gadget/ecoduck-simple/UDC 2>/dev/null")
os.system("ls /sys/class/udc > /sys/kernel/config/usb_gadget/ecoduck-simple/UDC 2>/dev/null")
print("Waiting for connection...")
while(1):
	if(electrical_test("/dev/hidg0", 1)):
		print("Device connected to target")
		# OS Fingerprinting
		detectedos = check_output(__location__+"/fingerprint-host.sh").decode()[:-1]
		if "Windows" == detectedos:
			os.system("echo \"\" >  /sys/kernel/config/usb_gadget/ecoduck-simple/UDC")
			os.system("ls /sys/class/udc > /sys/kernel/config/usb_gadget/ecoduck-win/UDC")
		else:
			os.system("echo \"\" >  /sys/kernel/config/usb_gadget/ecoduck-simple/UDC")
			os.system("ls /sys/class/udc > /sys/kernel/config/usb_gadget/ecoduck-other/UDC")
		path=check_output("/bin/ls /dev/hidg*",shell=True).decode()[:-1]
		print("HID Path is: " + path)
		print("Target OS is: " + detectedos)
		sleep(2)
		dummy_payload(path)
		network_test(path)
		print("Payload completed")
		# Switch back to simple gadget
		if "Windows" == detectedos:
			os.system("echo \"\" > /sys/kernel/config/usb_gadget/ecoduck-win/UDC")
		else:
			os.system("echo \"\" > /sys/kernel/config/usb_gadget/ecoduck-other/UDC")
		os.system("ls /sys/class/udc > /sys/kernel/config/usb_gadget/ecoduck-simple/UDC")
		sleep(2)
		wait_till_disconnect()

