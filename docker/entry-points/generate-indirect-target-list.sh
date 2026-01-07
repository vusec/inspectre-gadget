#!/usr/bin/env bash
set -e

WORK_DIR="${WORK_DIR:-/work-dir}"
RESULTS_FOLDER="${RESULTS_FOLDER:-/results}"

OUT_FOLDER=${WORK_DIR}/entry-points

mkdir -p $OUT_FOLDER

# First, we extract the endbr targets, all text symbols, and distinguish between
# jump and call targets.

cd $OUT_FOLDER

# get all text symbols
echo "address,name" > all_text_symbols.csv && \
    nm $WORK_DIR/images/vmlinux-dbg | grep -e " t " -e " T " | awk '{print "0x"$1 "," $3}' >> \
    all_text_symbols.csv

# extract endbr addresses from memory dump
echo "address" > endbr_addresses.txt && \
    objdump -M intel -D $WORK_DIR/images/dump_vmlinux --start-address=0xffffffff81000000 | \
    grep endbr64 | awk '{print "0x"$1}' | sed 's/.$//' | sort -u >> \
    endbr_addresses.txt

echo "address,name" >> endbr_call_target.csv
grep -f endbr_addresses.txt all_text_symbols.csv > endbr_call_target.csv

awk -F, '{print $1}' all_text_symbols.csv > /tmp/all_text_symbols_addr.txt
echo "address,name" >> endbr_jump_target.csv
grep -f /tmp/all_text_symbols_addr.txt endbr_addresses.txt | awk '{print $1",jump_target"}' >> endbr_jump_target.csv

cat endbr_call_target.csv endbr_jump_target.csv > targets.csv
