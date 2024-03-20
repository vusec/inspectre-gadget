#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
   echo "Please run as root"
   exit 1
fi

PHYS_MAP=0

if [ $# -eq 1 ]
  then
    PHYS_MAP=$1
fi

make OS=LINUX_v6_6_RC4_UBUNTU ARCH=INTEL_13_GEN -B

UUID_STRING=`cat /proc/kallsyms | grep -w uuid_string | awk '{print $1}'`

echo "uid_string: ${UUID_STRING}"


taskset -c 0 ./main -t $UUID_STRING -p $PHYS_MAP
