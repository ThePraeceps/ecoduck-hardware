# ecoduck-hardware
The repository for scripts relating to hardware setup for the economical duck.

## initial-setup.sh
Sets up the modules required for USB OTG gadgets on a fresh installation of Raspbian Stretch

## gadget-configure.sh
Sets up three gadgets on a configured device, one for fingerprinting, another for windows, and one for linux/mac

## gadget-remove.sh
Disables all gadgets from configured device and removes their configuration files

## patch-kernel.sh
Generates a modifed dwc2.ko with USB sniffing based on the current kernel version

## fingerprint-host.sh
Returns the name of

## gadget-test.py
Opens terminal, prints "Hello World", pings the Pi and runs nmap on the last IP to request a DHCP lease. To be replaced with EDS.

## Templates folder
Contains the configuration files for the device
