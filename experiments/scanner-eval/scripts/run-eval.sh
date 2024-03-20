#!/bin/bash

set -e

LINUX_FOLDER=/vm/linux-6.6-rc4

# -------------------------- Stage 1. Create VMs -------------------------------
cd /vm

# Finish setting up the img (from syzkaller create-img script).
echo " [+] Mouting rootfs"
mount -o loop bullseye.img /mnt/chroot
cp -a chroot/. /mnt/chroot/.
umount /mnt/chroot

# Since the Linux kernel patches spurious `endbr` instructions at boot time,
# we need to create a dump of a booted Linux Kernel.
echo " [+] Generating dump for default config"
echo " • Running QEMU"
./run-vm.sh &
echo " • Dumping memory"
sleep 40 && python3 dump-memory.py dump_6.6-rc4-default
cp $LINUX_FOLDER/vmlinux vmlinux-default

# FineIBT is not supported in QEMU, however, we apply a small patch such that
# FineIBT is still selected in the VM and correctly instrumented.

echo " [+] Generating dump for FineIBT config"
echo " • Recompiling kernel with FineIBT"
./build-fineibt.sh
echo " • Running QEMU"
cd /vm
./run-vm.sh &
echo " • Dumping memory"
sleep 40 && python3 dump-memory.py dump_6.6-rc4-fineibt
cp $LINUX_FOLDER/vmlinux vmlinux-fineibt

/bin/bash

# --------------------- Stage 2. Extract Entrypoints ---------------------------

# echo " [+] Generating entrypoint lists"
# cd /entrypoints
# ./generate-lists.sh
# ./get-reachable.sh


# # ------------------------- Stage 3. Run Scanner -------------------------------
# cd /scanner
# mkdir out

# echo " [+] Running scanner on call targets"
# # Start the analyzer with 20 parallel jobs.
# ./run-parallel.sh /vm/vmlinux-default /entrypoints/linux-6.6-rc4/endbr_call_target_6.6-rc4-default.txt 20
# # Merge all results.
# cd out && python ../scripts/merge_gadgets.py && cd ..
# # Rename folder.
# mv fail.txt out
# mv out call_targets

# echo " [+] Running scanner on jump targets"
# # Start the analyzer with 20 parallel jobs.
# ./run-parallel.sh /vm/vmlinux-fineibt /entrypoints/linux-6.6-rc4/endbr_jump_target_6.6-rc4-fineibt.txt 20

# # Merge all results.
# cd out && python ../scripts/merge_gadgets.py && cd ..

# # Rename folder.
# mv fail.txt out
# mv out jump_targets

# # ---------------------- Stage 4. Analyzer Results -----------------------------
# COPY analysis /analysis
# WORKDIR /analysis
