#!/bin/sh
KERN_IMAGE="./linux-6.6-rc4/arch/x86/boot/bzImage"
KERN_RFS="./stretch.img"
KERN_FLAGS="root=/dev/sda rw single console=ttyS0 nokaslr"

taskset -c 0,1 qemu-system-x86_64 \
  -kernel $KERN_IMAGE \
  -drive file=$KERN_RFS,index=0,media=disk,format=raw \
  -nographic \
  -append "$KERN_FLAGS" \
  -m 4096 \
  -smp 1 \
  --enable-kvm \
  -cpu host \
  -s -S
