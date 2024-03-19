#!/bin/bash

set -e

cd /vm
mount -o loop bullseye.img /mnt/chroot
cp -a chroot/. /mnt/chroot/.
umount /mnt/chroot

/bin/bash
# ./run-vm.sh

# # --------------------- Stage 2. Extract Entrypoints ---------------------------
# COPY entrypoints /entrypoints
# WORKDIR /entrypoints

# # Next we extract the endbr targets, all text symbols, and distinguish between
# # jump and call targets.

# # get all text symbols
# RUN echo "address,name" > all_text_symbols_6.6-rc4-default.txt && \
#     nm vmlinux | grep -e " t " -e " T " | awk '{print "0x"$1 "," $3}' >> \
#     all_text_symbols_6.6-rc4-default.txt

# # extract endbr addresses from memory dump
# RUN echo "address" > endbr_addresses_6.6-rc4-default.txt && \
#     objdump -M intel -D dump_6.6-rc4-default --start-address=0xffffffff81000000 | \
#     grep endbr64 | awk '{print "0x"$1}' | sed 's/.$//' | sort -u >> \
#     endbr_addresses_6.6-rc4-default.txt

# # filter call-targets
# RUN python3 filter_addresses.py call-targets endbr_addresses_6.6-rc4-default.txt all_text_symbols_6.6-rc4-default.txt > endbr_call_target_6.6-rc4-default.txt

# # filter jump-targets
# RUN python3 filter_addresses.py jump-targets endbr_addresses_6.6-rc4-default.txt all_text_symbols_6.6-rc4-default.txt > endbr_jump_target_6.6-rc4-default.txt

# # ------------------------- Stage 3. Run Scanner -------------------------------
# COPY scanner /scanner
# COPY scanner /scanner
# COPY scanner /scanner
# WORKDIR /scanner

# # ---------------------- Stage 4. Analyzer Results -----------------------------
# COPY analysis /analysis
# WORKDIR /analysis
