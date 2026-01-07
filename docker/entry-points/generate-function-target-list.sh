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

cp all_text_symbols.csv targets.csv
