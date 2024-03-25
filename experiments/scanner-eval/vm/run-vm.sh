#!/bin/sh
# Usage: run-vm.sh <BZIMAGE>

KERN_IMAGE=$1
KERN_RFS="./bullseye.img"
KERN_FLAGS="console=ttyS0 root=/dev/sda net.ifnames=0 rw nokaslr"

qemu-system-x86_64 \
    -m 4096 \
    -smp 1 \
    -kernel $KERN_IMAGE \
    -append "$KERN_FLAGS" \
    -drive file=$KERN_RFS,index=0,media=disk,format=raw \
    -nographic \
    -pidfile vm.pid \
    -qmp unix:qmp.sock,server=on,wait=off
