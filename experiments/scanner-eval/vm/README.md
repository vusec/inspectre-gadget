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
./create-image.sh
```

After this, an empty rootfs will be created.

## 2. Build the kernel

Build the selected Linux kernel. Adjust the path in `run_vm.sh` and
`dbg.sh` accordingly.


To build v6.6-rc4 we use (see `build-default.sh`):

``` bash
wget https://github.com/torvalds/linux/archive/refs/tags/v6.6-rc4.tar.gz
tar -xvf v6.6-rc4.tar.gz
cd linux-6.6-rc4

make defconfig
make -j`nproc`
```


## 3. Test the VM is up and running

### Run the VM

Simply use the `./run-vm.sh` script.
The default password is `root`.

### How to exit the VM

1. `CTRL+A` followed by `c`
2. `q` + `enter`

## 4. Create a memory dump

1. Run the VM (`./run-vm.sh`)
2. `CTRL+A` followed by `c`
3. `dump-guest-memory -p dump_6.6-rc4-default`

or you can use `python3 dump-memory.py <FILENAME>` to do it programmatically.

## 5. FineIBT

FineIBT is not supported in QEMU, however, we can apply a small patch
such that FineIBT is still selected in the VM and correctly instrumented.
You also have to enable FineIBT in the config and build with clang (>= 16).
Please refer to the previous sections on how to create a memory dump.

Build with FineIBT:

``` bash
git apply ../fineibt_vm_support.patch

./scripts/config --set-val CONFIG_FINEIBT y
./scripts/config --set-val CONFIG_CFI_CLANG y

make CC=clang-16 defconfig
make CC=clang-16 -j`nproc`
```

Or use `build-fineibt.sh`.
