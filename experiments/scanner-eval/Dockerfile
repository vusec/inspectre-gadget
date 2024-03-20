#
# Prepare the environment for eval.
#
FROM ubuntu:23.04 AS base

# Packages.
RUN apt-get update && \
    apt-get install -y build-essential libncurses-dev bison flex libssl-dev \
    libelf-dev zstd qemu-system-x86 debootstrap wget bc sudo python3-pip \
    openssh-client clang-16 git sqlite3

# Python dependencies.
COPY inspectre /inspectre
RUN pip3 install -r inspectre/requirements.txt --break-system-packages
RUN pip3 install qemu.qmp --break-system-packages

# The first step is to build a Linux kernel, we build v6.6-rc4.
COPY vm /vm
WORKDIR /vm
RUN ./build-default.sh

# Since the Linux kernel patches spurious `endbr` instructions at boot time,
# we need to create a dump of a booted Linux Kernel.
# First, we reuse syzkaller scripts to easily create a rootfs.
RUN ./create-image.sh -d bullseye

# Copy all folders.
COPY entrypoints /entrypoints
COPY scanner /scanner
COPY analysis /analysis
COPY scripts /scripts

RUN pip3 install pandas matplotlib numpy cycler scienceplots --break-system-packages
RUN apt-get -y install texlive-latex-extra texlive-fonts-recommended dvipng cm-super
