#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
   echo "Please run as root"
   exit 1
fi

echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

make ARCH=INTEL_13_GEN OS=LINUX_v6_6_RC4_UBUNTU -B

SYS_TABLE=`cat /proc/kallsyms | grep " sys_call_table" | cut -d ' ' -f 1 | tail -c 5`
OF_CSS=`cat /proc/kallsyms | grep -w of_css | awk '{print $1}'`

echo "sys_call_table: ${SYS_TABLE}"
echo "of_css: ${OF_CSS}"


taskset -c 2 ./main -t $OF_CSS -o 0x$SYS_TABLE
