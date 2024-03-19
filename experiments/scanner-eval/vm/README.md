# VM setup
This document describes how to setup a VM with a custom build kernel and
to create a dump of the memory.

## Requirements

- User must be in  the `kvm` group and `/dev/kvm` should be present
- `sudo apt-get install build-essential libncurses-dev bison flex libssl-dev libelf-dev zstd qemu-system-x86 debootstrap wget bc`

## 1. Create a rootfs

We reuse [syzkaller](https://github.com/google/syzkaller) scripts to easily create a rootfs using the following commands:

``` bash
wget https://raw.githubusercontent.com/google/syzkaller/master/tools/create-image.sh -O create-image.sh
chmod +x create-image.sh
./create-image.sh -a x86_64 -s 4096
```

After this, an empty rootfs will be created.

## 2. Build the kernel

Build the selected Linux kernel. Adjust the path in `run_vm.sh` and
`dbg.sh` accordingly.


To build v6.6-rc4 we use:

``` bash
wget https://github.com/torvalds/linux/archive/refs/tags/v6.6-rc4.tar.gz
tar -xvf v6.6-rc4.tar.gz
cd linux-6.6-rc4

make defconfig
make -j`nproc`
```


## 3. Test the VM is up and running

### Run the VM

Simply use the `./run_vm.sh` script
The default password is `root`

### How to exit the VM

1. `CTRL+A` followed by `c`
2. `q` + `enter`

## 4. Create a memory dump

1. Run the VM (`./run_vm.sh`)
2. `CTRL+A` followed by `c`
3. `dump-guest-memory -p dump_6.6-rc4-default`
