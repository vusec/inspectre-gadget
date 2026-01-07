#!/bin/sh
KERN_IMAGE=$1
KERN_RFS="./bullseye.img"
KERN_FLAGS="root=/dev/sda rw single console=ttyS0 nokaslr mitigations=off" # nospectre_v1 spectre_v2=retpoline spec_rstack_overflow=off"

taskset -c 0 qemu-system-x86_64 \
  -kernel $KERN_IMAGE \
  -drive file=$KERN_RFS,index=0,media=disk,format=raw \
  -nographic \
  -append "$KERN_FLAGS" \
  -m 4096 \
  -smp 1 \
  --enable-kvm \
  -cpu host \
  -s

  # -trace enable=exec_tb,file=trace.out \
  # -d cpu,nochain -D trace.out\
  # -trace enable=exec_tb,file=trace.out \
  # -d nochain,trace:exec_tb -D trace.out\

  #   -singlestep
  # trace-event exec_tb on
  # info trace-events exec_tb

