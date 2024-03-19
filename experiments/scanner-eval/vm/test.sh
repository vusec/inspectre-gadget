wget https://github.com/torvalds/linux/archive/refs/tags/v6.6-rc4.tar.gz
tar -xvf v6.6-rc4.tar.gz
cd linux-6.6-rc4

make defconfig
make -j`nproc`

cd ..
wget https://raw.githubusercontent.com/google/syzkaller/master/tools/create-image.sh -O create-image.sh
chmod +x create-image.sh
./create-image.sh


qemu-system-x86_64 -hda bullseye.img \
                     -snapshot -net user,host=10.0.2.10,hostfwd=tcp::10022-:22  \
                     -net nic -nographic -kernel linux-6.6-rc4/arch/x86/boot/bzImage \
                     -append "kvm-intel.nested=1 kvm-intel.unrestricted_guest=1 kvm-intel.ept=1 kvm-intel.flexpriority=1 kvm-intel.vpid=1 kvm-intel.emulate_invalid_guest_state=1 kvm-intel.eptad=1 kvm-intel.enable_shadow_vmcs=1 kvm-intel.pml=1 kvm-intel.enable_apicv=1 console=ttyS0 root=/dev/sda earlyprintk=serial slub_debug=UZ vsyscall=native rodata=n oops=panic panic_on_warn=1 panic=86400 ima_policy=tcb" \
                     -enable-kvm \
                     -pidfile vm_pid \
                      -m 2G \
                      -smp 4 \
                      -cpu host
