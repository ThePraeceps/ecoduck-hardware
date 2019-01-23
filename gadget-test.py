#!/bin/usr/env python3
import io

f = io.open("/dev/hidg0", "rb")
f.read(8)
print("plugged")