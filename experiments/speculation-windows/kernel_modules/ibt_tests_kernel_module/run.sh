#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
   echo "Please run as root"
   exit 1
fi

make CC=clang-16

rmmod ibt_testing_module || true
dmesg -C
insmod ibt_testing_module.ko || (dmesg && false)
dmesg
