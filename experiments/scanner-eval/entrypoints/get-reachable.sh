#!/usr/bin/env bash
set -eux

# Download Syzkaller coverage report.
cd /entrypoints
wget https://storage.googleapis.com/syzbot-assets/bfa0eab76177/ci-qemu-upstream-8a749fd1.html

# Extract the list of reached functions.
./get_reached_functions.sh ci-qemu-upstream.html > linux-6.6-rc4/reachable_functions.txt
