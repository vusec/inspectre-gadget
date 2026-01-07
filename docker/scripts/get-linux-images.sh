#!/bin/bash
# -----------------------------------------------------------------------------
# Retreive the linux images
# -----------------------------------------------------------------------------

set -e

WORK_DIR="${WORK_DIR:-/work-dir}"

mkdir -p $WORK_DIR/images

if [ ! -f $WORK_DIR/images/vmlinuz ] || [ ! -f $WORK_DIR/images/vmlinux ] || [ ! -f $WORK_DIR/images/vmlinux-dbg ]; then

    # Hard-coded URL for now
    # echo "Running pre-configured version Ubuntu 5.15.0-153-generic"
    # LINUX_DEB_URL=http://nl.archive.ubuntu.com/ubuntu/pool/main/l/linux-signed/linux-image-5.15.0-153-generic_5.15.0-153.163_amd64.deb
    # LINUX_DDEB_URL=http://ddebs.ubuntu.com/pool/main/l/linux/linux-image-unsigned-5.15.0-153-generic-dbgsym_5.15.0-153.163_amd64.ddeb
    # LINUX_HEADERS_URL=http://nl.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-5.15.0-153-generic_5.15.0-153.163_amd64.deb


    # echo "Running pre-configured version Ubuntu 6.8.0-88-generic"
    # LINUX_DEB_URL=http://nl.archive.ubuntu.com/ubuntu/pool/main/l/linux-signed/linux-image-6.8.0-88-generic_6.8.0-88.89_amd64.deb
    # LINUX_DDEB_URL=http://ddebs.ubuntu.com/pool/main/l/linux/linux-image-unsigned-6.8.0-88-generic-dbgsym_6.8.0-88.89_amd64.ddeb
    # LINUX_HEADERS_URL=http://nl.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-6.8.0-88-generic_6.8.0-88.89_amd64.deb

    echo "Running pre-configured version Ubuntu 6.14.0-34"
    LINUX_DEB_URL=http://nl.archive.ubuntu.com/ubuntu/pool/main/l/linux-signed-hwe-6.14/linux-image-6.14.0-34-generic_6.14.0-34.34%7e24.04.1_amd64.deb
    LINUX_DDEB_URL=http://ddebs.ubuntu.com/pool/main/l/linux-hwe-6.14/linux-image-unsigned-6.14.0-34-generic-dbgsym_6.14.0-34.34%7e24.04.1_amd64.ddeb
    LINUX_HEADERS_URL=http://nl.archive.ubuntu.com/ubuntu/pool/main/l/linux-hwe-6.14/linux-headers-6.14.0-34-generic_6.14.0-34.34%7e24.04.1_amd64.deb

    cd $WORK_DIR/images

    echo $LINUX_DEB_URL > url.txt
    echo $LINUX_DDEB_URL >> url.txt

    # Download and extract vmlinuz and vmlinux
    FILE_NAME=$(basename $LINUX_DEB_URL)
    wget $LINUX_DEB_URL -O $FILE_NAME
    dpkg-deb --fsys-tarfile $FILE_NAME | tar Ox --wildcards  './boot/vmlinuz-*' > vmlinuz
    /usr/src/linux-headers-$(uname -r)/scripts/extract-vmlinux vmlinuz > vmlinux

    # Download and extract vmlinux debug file
    FILE_NAME=$(basename $LINUX_DDEB_URL)
    wget $LINUX_DDEB_URL -O $FILE_NAME
    dpkg-deb --fsys-tarfile $FILE_NAME | tar Ox --wildcards  './usr/lib/debug/boot/vmlinux-*' > vmlinux-dbg

else
    echo "[+] [CACHED] Resuing linux images from work directory"
fi
