set -e


wget https://github.com/torvalds/linux/archive/refs/tags/v6.6-rc4.tar.gz
tar -xvf v6.6-rc4.tar.gz
cd linux-6.6-rc4

make defconfig

echo "CONFIG_CONFIGFS_FS=y" >> .config
echo "CONFIG_SECURITYFS=y" >> .config

make olddefconfig

make -j`nproc`

cd ..
wget https://raw.githubusercontent.com/google/syzkaller/master/tools/create-image.sh -O create-image.sh
chmod +x create-image.sh
./create-image.sh -d bullseye

KERN_IMAGE="./linux-6.6-rc4/arch/x86/boot/bzImage"
KERN_RFS="./bullseye.img"
KERN_FLAGS="root=/dev/sda rw single console=ttyS0 nokaslr"

sudo qemu-system-x86_64 \
  -kernel $KERN_IMAGE \
  -drive file=$KERN_RFS,index=0,media=disk,format=raw \
  -nographic \
  -append "$KERN_FLAGS" \
  -m 2G \
  -smp 2 \
