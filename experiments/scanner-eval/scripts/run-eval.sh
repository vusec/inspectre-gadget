#!/bin/bash

set -e

LINUX_FOLDER=/vm/linux-6.6-rc4

# -------------------------- Stage 1. Create VMs -------------------------------
cd /vm

# Finish setting up the rootfs (from syzkaller create-img script).
echo " [+] Mouting rootfs"
mount -o loop bullseye.img /mnt/chroot
cp -a chroot/. /mnt/chroot/.
umount /mnt/chroot

# Since the Linux kernel patches spurious `endbr` instructions at boot time,
# we need to create a dump of a booted Linux Kernel.
echo " [+] Generating dump for default config"
./run-vm.sh bzImage-default &
sleep 40 && python3 dump-memory.py dump_6.6-rc4-default

# Do the same for the FineIBT build.
echo " [+] Generating dump for FineIBT config"
./run-vm.sh bzImage-fineibt &
sleep 40 && python3 dump-memory.py dump_6.6-rc4-fineibt

# # --------------------- Stage 2. Extract Entrypoints ---------------------------

# echo " [+] Generating entrypoint lists"
cd /entrypoints

# ./generate-lists.sh
# ./get-reachable.sh

rm -rf /results/*
cp -r /entrypoints/linux-6.6-rc4/ /results/entrypoints


# ------------------------- Stage 3. Run Scanner -------------------------------
cd /scanner
mkdir out

echo " [+] Running scanner on call targets"
# Start the analyzer with 20 parallel jobs.
./run-parallel.sh /vm/vmlinux-default /entrypoints/linux-6.6-rc4/endbr_call_target_6.6-rc4-default.txt 20
# Merge all results.
cd out && python3 /analysis/merge_gadgets.py && cd ..
# Rename folder.
mv fail.txt out
mv out call_targets

echo " [+] Running scanner on jump targets"
# Start the analyzer with 20 parallel jobs.
./run-parallel.sh /vm/vmlinux-fineibt /entrypoints/linux-6.6-rc4/endbr_jump_target_6.6-rc4-fineibt.txt 20

# Merge all results.
cd out && python3 /analysis/merge_gadgets.py && cd ..

# Rename folder.
mv fail.txt out
mv out jump_targets

# Move everything to the results folder.
mv call_targets /results
mv jump_targets /results

# ---------------------- Stage 4. Analyzer Results -----------------------------
cd /results/jump_targets && /inspectre/inspectre reason all-gadgets.csv all-gadgets-reasoned.csv
cd /results/call_targets && /inspectre/inspectre reason all-gadgets.csv all-gadgets-reasoned.csv

# Move the lists we used to a `lists/` folder.
cd /results
mkdir lists
cp /entrypoints/linux-6.6-rc4/all_text_symbols_6.6-rc4-fineibt.txt lists/
cp /entrypoints/linux-6.6-rc4/all_text_symbols_6.6-rc4-default.txt lists/
cp /entrypoints/linux-6.6-rc4/reachable_functions_6.6-rc4.txt lists/

# Run the script to create a sqlite3 database.
/analysis/build-db.sh
/analysis/run-queries.sh
python3 /analysis/generate-figures.py
mkdir -p /results/figs
mv ./*.pdf /results/figs/
