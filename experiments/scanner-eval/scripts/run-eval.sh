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
sleep 100 && python3 dump-memory.py dump_6.6-rc4-default

# Do the same for the FineIBT build.
echo " [+] Generating dump for FineIBT config"
./run-vm.sh bzImage-fineibt &
sleep 100 && python3 dump-memory.py dump_6.6-rc4-fineibt


# --------------------- Stage 2. Extract Entrypoints ---------------------------
echo " [+] Generating entrypoint lists"
cd /entrypoints

mv linux-6.6-rc4 expected
mkdir -p linux-6.6-rc4

# Use FineIBT and ENDBR instrumentation to identify the address of all indirect
# jump and call targets of the kernel.
./generate-lists.sh
# Identify which ones are reachable from userspace by parsing the Syzkaller report.
./get-reachable.sh

rm -rf /results/*
cp -r /entrypoints/linux-6.6-rc4/ /results/entrypoints

# ------------------------- Stage 3. Run Scanner -------------------------------
cd /scanner
mkdir out

echo " [+] Running scanner on call targets"
# Start the analyzer with 20 parallel jobs.
python3 run-parallel.py /inspectre/inspectre /vm/vmlinux-default /entrypoints/linux-6.6-rc4/endbr_call_target_6.6-rc4-default.txt -c config_all.yaml -o out -t360 -j20
# Merge all results.
cd out && python3 /analysis/merge_gadgets.py && cd ..
# Move to results folder.
mv fail.txt out
mv out /results/call_targets

echo " [+] Running scanner on jump targets"
# Start the analyzer with 20 parallel jobs.
python3 run-parallel.py /inspectre/inspectre /vm/vmlinux-fineibt /entrypoints/linux-6.6-rc4/endbr_jump_target_6.6-rc4-fineibt.txt -c config_all.yaml -o out -t360 -j20
# Merge all results.
cd out && python3 /analysis/merge_gadgets.py && cd ..
# Move to results folder.
mv fail.txt out
mv out /results/jump_targets

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
