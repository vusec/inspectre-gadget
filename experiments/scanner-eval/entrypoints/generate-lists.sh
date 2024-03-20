#!/usr/bin/env bash
set -eux

cd /entrypoints

mv linux-6.6-rc4 expected
mkdir -p linux-6.6-rc4
cd linux-6.6-rc4

# First, we extract the endbr targets, all text symbols, and distinguish between
# jump and call targets.

# get all text symbols
echo "address,name" > all_text_symbols_6.6-rc4-default.txt && \
    nm /vm/vmlinux-default | grep -e " t " -e " T " | awk '{print "0x"$1 "," $3}' >> \
    all_text_symbols_6.6-rc4-default.txt
# extract endbr addresses from memory dump
echo "address" > endbr_addresses_6.6-rc4-default.txt && \
    objdump -M intel -D /vm/dump_6.6-rc4-default --start-address=0xffffffff81000000 | \
    grep endbr64 | awk '{print "0x"$1}' | sed 's/.$//' | sort -u >> \
    endbr_addresses_6.6-rc4-default.txt
# filter call-targets
python3 ../filter_addresses.py call-targets endbr_addresses_6.6-rc4-default.txt all_text_symbols_6.6-rc4-default.txt > endbr_call_target_6.6-rc4-default.txt
# filter jump-targets
python3 ../filter_addresses.py jump-targets endbr_addresses_6.6-rc4-default.txt all_text_symbols_6.6-rc4-default.txt > endbr_jump_target_6.6-rc4-default.txt



# We do the same for the FineIBT build.
# get all CFI text symbols
echo "address,name" > all_text_symbols_cfi_6.6-rc4-fineibt.txt && \
     nm /vm/vmlinux-fineibt | grep "__cfi_" | grep -e " t " -e " T " | \
     awk '{print "0x"$1 "," $3}' >> all_text_symbols_cfi_6.6-rc4-fineibt.txt

# extract endbr addresses from memory dump
echo "address" > endbr_addresses_6.6-rc4-fineibt.txt && \
     objdump -M intel -D /vm/dump_6.6-rc4-fineibt --start-address=0xffffffff81000000 | \
     grep endbr64 | awk '{print "0x"$1}' | sed 's/.$//' | sort -u >> \
     endbr_addresses_6.6-rc4-fineibt.txt

# filter call-targets
python3 ../filter_addresses.py call-targets endbr_addresses_6.6-rc4-fineibt.txt all_text_symbols_cfi_6.6-rc4-fineibt.txt > endbr_call_target_6.6-rc4-fineibt.txt

# filter jump-targets
python3 ../filter_addresses.py jump-targets endbr_addresses_6.6-rc4-fineibt.txt all_text_symbols_cfi_6.6-rc4-fineibt.txt > endbr_jump_target_6.6-rc4-fineibt.txt

