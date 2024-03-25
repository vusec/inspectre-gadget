set -e

git apply ../fineibt_vm_support.patch

make CC=clang-16 defconfig

echo "CONFIG_FINEIBT=y" >> .config
echo "CONFIG_CFI_CLANG=y" >> .config
echo "CONFIG_CONFIGFS_FS=y" >> .config
echo "CONFIG_SECURITYFS=y" >> .config

yes "n" | make CC=clang-16 oldconfig
make CC=clang-16 -j`nproc`
