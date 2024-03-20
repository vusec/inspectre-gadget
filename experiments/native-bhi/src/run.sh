#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
   echo "Please run as root"
   exit 1
fi

echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

make ARCH=INTEL_13_GEN OS=LINUX_v6_6_RC4_UBUNTU -B

SYS_TABLE=`cat /proc/kallsyms | grep " sys_call_table" | cut -d ' ' -f 1 | tail -c 5`

echo "sys_call_table: ${SYS_TABLE}"

taskset -c 2 ./main -o 0x$SYS_TABLE $1 $2 $3
