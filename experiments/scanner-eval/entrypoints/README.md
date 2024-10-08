# Input

This folder contains the documentation on how to create the input used by
InSpectre Gadget. In this example we focus on performing the analysis
on the Linux kernel, however, InSpectre Gadget should be able to analyze any
binary code.

## TL;DR

You can find the pre-built list in the `linux-6.6-rc4` folder.
If you want to regenerate these lists, follow the instructions below.


## 1: Building kernel and create a memory dump

Since the Linux kernel patches spurious `endbr` on boot time, we need
to create a dump of a booted Linux Kernel. Follow the steps in the VM folder
to create a memory dump.

## 2: Extract the endbr targets

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

Refer to the VM folder to see how the kernel is compiled with FineIBT.

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

## 4: Extract the reached function list from Syzkaller

To make an estimation of which targets are reachable
(i.e., can be triggered from userspace through a syscall), we extract
all the reached functions by Syzkaller as part of the syzbot project.

First download the coverage report:

``` bash
wget https://storage.googleapis.com/syzkaller/cover/ci-qemu-upstream-8a749fd1.html
```

Next, extract the list of reached functions by using the script `get_reached_functions.sh`:

``` bash
echo "name" > reachable_functions.txt
./get_reached_functions.sh ci-qemu-upstream.html >> reachable_functions_6.6-rc4.txt
```

The list of reached functions is included in the `linux-6.6-rc4` folder.
