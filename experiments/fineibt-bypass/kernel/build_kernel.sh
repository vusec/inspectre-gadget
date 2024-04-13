#!/bin/bash
set -e
# Download source
wget https://github.com/torvalds/linux/archive/refs/tags/v6.6-rc4.tar.gz
tar -xvf v6.6-rc4.tar.gz

# We copy the config
cd linux-6.6-rc4
cp ../config .config

# Apply the patch required for PoC
patch -p1 < ../fineibt_poc.patch

make CC=clang-16 olddefconfig

# Build and install
make CC=clang-16 -j `nproc`
sudo make modules_install -j `nproc`
sudo make install -j `nproc`

gdb vmlinux -batch -ex 'x/1i uuid_string + 324'

echo "Please verify that the instruction at uuid_string + 324 is equal to movzx  ebx,BYTE PTR [r8+rbx*1]"
echo "This is the transmission location: a different load instruction will break the PoC!"

echo "Please reboot into the kernel: linux-6.6.0-rc4-fineibt-poc"
