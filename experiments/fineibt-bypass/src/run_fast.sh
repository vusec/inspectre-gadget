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
echo "uuid_string: ${UUID_STRING}"

UNIX_POLL=`cat /proc/kallsyms | grep -w unix_poll | awk '{print $1}'`
echo "unix_poll: ${UNIX_POLL}"


taskset -c 2 ./main -t ${UUID_STRING} -f -u ${UNIX_POLL} -p $PHYS_MAP
