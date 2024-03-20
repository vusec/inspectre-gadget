#!/bin/bash
set -e 

if [[ $EUID -ne 0 ]]; then
   echo "Please run as root"
   exit 1
fi

make CC=clang-16

rmmod patch_kernel_module || true
dmesg -C
insmod patch_kernel_module.ko
dmesg
