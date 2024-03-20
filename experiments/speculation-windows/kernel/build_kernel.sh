#!/bin/bash
set -e
# Download source
wget https://github.com/torvalds/linux/archive/refs/tags/v6.6-rc4.tar.gz
tar -xvf v6.6-rc4.tar.gz

wget https://kernel.ubuntu.com/mainline/v6.6-rc4/amd64/linux-headers-6.6.0-060600rc4-generic_6.6.0-060600rc4.202310012130_amd64.deb
dpkg-deb --fsys-tarfile linux-headers-6.6.0-060600rc4-generic_6.6.0-060600rc4.202310012130_amd64.deb | tar Ox --wildcards './usr/src/*/.config' > config_ubuntu

# We copy the config
cd linux-6.6-rc4
cp ../config_ubuntu .config

## Adjust the config

scripts/config --set-val CONFIG_LOCALVERSION '"-fineibt"'
# Enable FineIBT
scripts/config -e CONFIG_FINEIBT
scripts/config -e CONFIG_CFI_CLANG

# Disable modules signing
scripts/config -d SECURITY_LOCKDOWN_LSM -d MODULE_SIG -d MODULE_SIG_ALL
# Enable MSR \ CPUID
scripts/config -e CONFIG_X86_MSR -e CONFIG_X86_CPUID
# Disable ubuntu specific
scripts/config -d CONFIG_SYSTEM_REVOCATION_KEYS -d CONFIG_SYSTEM_TRUSTED_KEYS
# IBT (Enabled on default Linux)
scripts/config -e CONFIG_X86_KERNEL_IBT
# Disable debug build
scripts/config -d CONFIG_ATH11K_DEBUGFS
scripts/config -d CONFIG_RTW89_DEBUG
scripts/config -d CONFIG_RTW89_DEBUGMSG
scripts/config -d CONFIG_RTW89_DEBUGFS
scripts/config -d CONFIG_WWAN_DEBUGFS
scripts/config -d CONFIG_AMD_PMF_DEBUG
scripts/config -d CONFIG_DEBUG_INFO_DWARF5

scripts/config --undefine GDB_SCRIPTS
scripts/config --undefine DEBUG_INFO
scripts/config --undefine DEBUG_INFO_SPLIT
scripts/config --undefine DEBUG_INFO_REDUCED
scripts/config --undefine DEBUG_INFO_COMPRESSED
scripts/config --set-val  DEBUG_INFO_NONE y
scripts/config --set-val  DEBUG_INFO_DWARF5 n

make CC=clang-16 olddefconfig

make CC=clang-16  -j `nproc`
sudo modules_install -j `nproc`
sudo install -j `nproc`

echo "Please reboot into the kernel: linux-6.6.0-rc4-fineibt"
