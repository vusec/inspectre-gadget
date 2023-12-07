# Input

This folder contains the documentation on how to create the input used by
InSpectre Gadget. In this example we focus on performing the analysis
on the Linux kernel, however, InSpectre Gadget should be able to analyze any
binary code.


## 1: Building the kernel

The first step is to build a Linux kernel, we build v6.6-rc4.

``` bash
wget https://github.com/torvalds/linux/archive/refs/tags/v6.6-rc4.tar.gz
tar -xvf v6.6-rc4.tar.gz
cd linux-6.6-rc4

make defconfig
make -j 32
```

## 2: Create a memory dump

Since the Linux kernel patches spurious `endbr` on boot time, we need
to create a dump of a booted Linux Kernel. Follow the steps in the VM folder
to create a memory dump.

## 3: Extract the endbr targets

Next we extract the `endbr` targets, all text symbols, and differentiate between
the jump and call targets.

``` bash
# get all text symbols
echo "address,name" > all_text_symbols_6.6-rc4-default.txt && nm vmlinux | grep -e " t " -e " T " | awk '{print "0x"$1 "," $3}' >> all_text_symbols_6.6-rc4-default.txt

# extract endbr addresses from memory dump
echo "address" > endbr_addresses_6.6-rc4-default.txt && objdump -M intel -D dump_6.6-rc4-default --start-address=0xffffffff81000000 | grep endbr64 | awk '{print "0x"$1}' | sed 's/.$//' | sort -u >> endbr_addresses_6.6-rc4-default.txt

# filter call-targets
python3 filter_addresses.py call-targets endbr_addresses_6.6-rc4-default.txt all_text_symbols_6.6-rc4-default.txt > endbr_call_target_6.6-rc4-default.txt

# filter jump-targets
python3 filter_addresses.py jump-targets endbr_addresses_6.6-rc4-default.txt all_text_symbols_6.6-rc4-default.txt > endbr_jump_target_6.6-rc4-default.txt
```

## 3: Extract the endbr targets for FineIBT

Jump targets are of particular interest in the case if FineIBT is enabled (see
paper). Therefore, we extract the targets again for a Linux kernel with FineIBT
enabled.

FineIBT is not supported in QEMU, however, we apply a small patch
such that FineIBT is still selected in the VM and correctly instrumented.
You also have to enable FineIBT in the config and build with clang (>= 16).
Please refer to the 'VM' section on how to create a memory dump.

Build with FineIBT:

``` bash
git apply ../fineibt_vm_support.patch

./scripts/config --set-val CONFIG_FINEIBT y
./scripts/config --set-val CONFIG_CFI_CLANG y

make CC=clang-16 defconfig
make -j 32
```

Since CFI creates an `__cfi_` symbol for each function, and these are only
used for call instructions, we can do more accurate filtering for jump targets.
Namely, we assume every `endbr` instruction not at an `__cfi_`  symbol
a jump target. To filter:

``` bash
# get all CFI text symbols
echo "address,name" > all_text_symbols_cfi_6.6-rc4-fineibt.txt && nm vmlinux | grep "__cfi_" | grep -e " t " -e " T " | awk '{print "0x"$1 "," $3}' >> all_text_symbols_cfi_6.6-rc4-fineibt.txt

# extract endbr addresses from memory dump
echo "address" > endbr_addresses_6.6-rc4-fineibt.txt && objdump -M intel -D dump_6.6-rc4-fineibt --start-address=0xffffffff81000000 | grep endbr64 | awk '{print "0x"$1}' | sed 's/.$//' | sort -u >> endbr_addresses_6.6-rc4-fineibt.txt

# filter call-targets
python3 filter_addresses.py call-targets endbr_addresses_6.6-rc4-fineibt.txt all_text_symbols_cfi_6.6-rc4-fineibt.txt > endbr_call_target_6.6-rc4-fineibt.txt

# filter jump-targets
python3 filter_addresses.py jump-targets endbr_addresses_6.6-rc4-fineibt.txt all_text_symbols_cfi_6.6-rc4-fineibt.txt > endbr_jump_target_6.6-rc4-fineibt.txt
```
