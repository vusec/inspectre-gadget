set -e

rm -rf linux-6.6-rc4

# wget https://github.com/torvalds/linux/archive/refs/tags/v6.6-rc4.tar.gz
tar -xvf v6.6-rc4.tar.gz
cd linux-6.6-rc4

git apply ../fineibt_vm_support.patch

make CC=clang-16 defconfig

echo "CONFIG_FINEIBT=y" >> .config
echo "CONFIG_CFI_CLANG=y" >> .config
echo "CONFIG_CFI_PERMISSIVE=n" >> .config
echo "CONFIG_READABLE_ASM=n" >> .config
echo "CONFIG_CONFIGFS_FS=y" >> .config
echo "CONFIG_SECURITYFS=y" >> .config

echo "CONFIG_NVME_TARGET=n" >> .config
echo "CONFIG_NETCONSOLE_DYNAMIC=n" >> .config
echo "CONFIG_OCFS2_FS=n" >> .config

yes "" | make CC=clang-16 oldconfig
yes "" | make CC=clang-16 -j`nproc`
