#!/usr/bin/env bash
set -eux

# Download Syzkaller coverage report.
cd /entrypoints
wget https://storage.googleapis.com/syzkaller/cover/ci-qemu-upstream.html

# Extract the list of reached functions.
./get_reached_functions.sh ci-qemu-upstream.html > linux-6.6-rc4/reachable_functions.txt
