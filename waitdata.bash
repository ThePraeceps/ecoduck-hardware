#!/bin/bash

function write_report {
    echo -ne $1 > /dev/hidg1
}

cat /dev/hidg1 | echo

# Alphabetical numbers in HEX starting at x4


write_report "\x80\0\x15\0\0\0\0\0"
write_report "\0\0\0\0\0\0\0\0"
sleep 1
write_report "\0\0\x6\0\0\0\0\0"
write_report "\0\0\x10\0\0\0\0\0"
write_report "\0\0\x7\0\0\0\0\0"
write_report "\0\0\x28\0\0\0\0\0"
write_report "\0\0\0\0\0\0\0\0"
sleep 2
write_report "\0\0\x08\0\0\0\0\0"
write_report "\0\0\x06\0\0\0\0\0"
write_report "\0\0\x0b\0\0\0\0\0"
write_report "\0\0\x12\0\0\0\0\0"
write_report "\0\0\x2c\0\0\0\0\0"

write_report "\0\0\x34\0\0\0\0\0"
# H (press shift and H)

write_report "\x20\0\xb\0\0\0\0\0"

# e
write_report "\0\0\x8\0\0\0\0\0"

# ll
write_report "\0\0\xf\0\0\0\0\0"
write_report "\0\0\0\0\0\0\0\0"
write_report "\0\0\xf\0\0\0\0\0"

# o
write_report "\0\0\x12\0\0\0\0\0"

# SPACE
write_report "\0\0\x2c\0\0\0\0\0"

# W (press shift and W)
write_report "\x20\0\x1a\0\0\0\0\0"

# o
write_report "\0\0\x12\0\0\0\0\0"

# r
write_report "\0\0\x15\0\0\0\0\0"

# l
write_report "\0\0\xf\0\0\0\0\0"

# d
write_report "\0\0\x7\0\0\0\0\0"

# ! (press shift and 1)
write_report "\x20\0\x1e\0\0\0\0\0"

write_report "\0\0\x34\0\0\0\0\0"

write_report "\0\0\x28\0\0\0\0\0"

# Release al keys
write_report "\0\0\0\0\0\0\0\0"
