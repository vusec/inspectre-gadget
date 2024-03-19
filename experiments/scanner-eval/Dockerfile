FROM ubuntu:22.04 AS base

RUN apt-get update && \
    apt-get install -y build-essential libncurses-dev bison flex libssl-dev \
    libelf-dev zstd qemu-system-x86 debootstrap wget bc sudo python3-pip \
    openssh-client kmod util-linux

COPY inspectre /inspectre
RUN pip3 install -r inspectre/requirements.txt


# --------------------------- Stage 1. Dump VM ---------------------------------
# The first step is to build a Linux kernel, we build v6.6-rc4.
COPY vm /vm
WORKDIR /vm
RUN wget https://github.com/torvalds/linux/archive/refs/tags/v6.6-rc4.tar.gz
RUN tar -xvf v6.6-rc4.tar.gz

WORKDIR /vm/linux-6.6-rc4
RUN make defconfig
RUN make -j`nproc`

# Since the Linux kernel patches spurious `endbr` instructions at boot time,
# we need to create a dump of a booted Linux Kernel.

# First, we reuse syzkaller scripts to easily create a rootfs.
WORKDIR /vm
RUN chmod +x create-image.sh
RUN ./create-image.sh -a x86_64 -s 4096

COPY entrypoints /entrypoints
COPY scanner /scanner
COPY analysis /analysis
COPY scripts /scripts
