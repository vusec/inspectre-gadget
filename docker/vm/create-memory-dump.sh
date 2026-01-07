#!/bin/bash
# -----------------------------------------------------------------------------
# Create memory dump of kernel image
# -----------------------------------------------------------------------------

set -e

DIR_WORK="${DIR_WORK:-/work-dir}"

if [ ! -f $DIR_WORK/images/dump_vmlinux ]; then

    echo "[+] Creating memory dump of vmlinux"

    cd /vm

    # Finish setting up the rootfs (from syzkaller create-img script).
    echo "[+] Mouting rootfs"
    if [ ! -f bookworm.img ]; then
        echo "[+] Created symlink to bookworm.img -> bullseye.img"
        ln -s bullseye.img bookworm.img
    fi

    mount -o loop bookworm.img /mnt/chroot

    cp -a chroot/. /mnt/chroot/.
    umount /mnt/chroot

    # Create dump
    ./run-vm.sh $DIR_WORK/images/vmlinuz 2>&1 > /dev/null &
    sleep 10 && python3 dump-memory.py dump_vmlinux
    mv dump_vmlinux $DIR_WORK/images/dump_vmlinux

else
    echo "[+] [CACHED] Resuing vmlinux memory dump from work directory"
fi
