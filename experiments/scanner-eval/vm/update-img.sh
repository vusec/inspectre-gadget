#!/bin/sh
sudo mkdir -p /mnt/chroot
sudo mount -o loop stretch.img /mnt/chroot

sudo cp -r ../src/*  /mnt/chroot/root/

sudo umount /mnt/chroot
