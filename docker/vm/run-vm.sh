#!/bin/sh
# Usage: run-vm.sh <BZIMAGE>

KERN_IMAGE=$1
KERN_RFS="./bookworm.img"
KERN_FLAGS="console=ttyS0 root=/dev/sda net.ifnames=0 rw nokaslr mitigations=off"

qemu-system-x86_64 \
    -kernel $KERN_IMAGE \
    -drive file=$KERN_RFS,index=0,media=disk,format=raw \
    -nographic \
    -append "$KERN_FLAGS" \
    -m 128 \
    -smp 1 \
    -net user,hostfwd=tcp::7777-:22 -net nic \
    -netdev tap,id=tap0 -device e1000,netdev=tap0 \
    --enable-kvm \
    -cpu host \
    -pidfile vm.pid \
    -qmp unix:qmp.sock,server=on,wait=off
