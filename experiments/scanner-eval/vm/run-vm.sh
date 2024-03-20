#!/bin/sh
KERN_IMAGE="./linux-6.6-rc4/arch/x86/boot/bzImage"
KERN_RFS="./bullseye.img"
KERN_FLAGS="root=/dev/sda rw single console=ttyS0 nokaslr"

qemu-system-x86_64 \
    -m 2G \
    -smp 2 \
    -kernel linux-6.6-rc4/arch/x86/boot/bzImage \
    -append "console=ttyS0 root=/dev/sda earlyprintk=serial net.ifnames=0" \
    -drive file=bullseye.img,format=raw \
    -net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 \
    -net nic,model=e1000 \
    -enable-kvm \
    -nographic \
    -pidfile vm.pid


