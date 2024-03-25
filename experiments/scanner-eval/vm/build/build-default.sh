set -e

make defconfig

echo "CONFIG_CONFIGFS_FS=y" >> .config
echo "CONFIG_SECURITYFS=y" >> .config

make olddefconfig

make -j`nproc`

