#!/bin/bash
set -e
# Download source
wget https://github.com/torvalds/linux/archive/refs/tags/v6.6-rc4.tar.gz
tar -xvf v6.6-rc4.tar.gz

# We copy the config
cd linux-6.6-rc4
cp ../config_ubuntu .config

make olddefconfig

# Build and install
make -j `nproc`
sudo make modules_install -j `nproc`
sudo make install -j `nproc`

echo "Please reboot into the kernel: linux-6.6.0-rc4"
