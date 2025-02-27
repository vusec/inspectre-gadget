#
# Prepare the environment for eval.
#
FROM ubuntu:22.04 AS base

# Packages.
RUN apt-get update && \
    apt-get install -y build-essential libncurses-dev bison flex libssl-dev \
    libelf-dev zstd qemu-system-x86 debootstrap wget bc sudo python3-pip \
    openssh-client clang-15 git sqlite3 vim fish

# Python dependencies.
COPY inspectre /inspectre
RUN PIP_BREAK_SYSTEM_PACKAGES=1 pip3 install -r inspectre/requirements.txt
RUN PIP_BREAK_SYSTEM_PACKAGES=1 pip3 install qemu.qmp

# Graph drawing dependencies.
RUN PIP_BREAK_SYSTEM_PACKAGES=1 pip3 install pandas matplotlib numpy cycler scienceplots tqdm argparse
RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/Amsterdam apt-get -y install texlive-latex-extra texlive-fonts-recommended dvipng cm-super

COPY vm/build /vm
WORKDIR /vm
# Reuse syzkaller scripts to easily create a rootfs.
RUN ./create-image.sh -d bullseye

# Download kernel v6.6-rc4.
RUN wget https://github.com/torvalds/linux/archive/refs/tags/v6.6-rc4.tar.gz
RUN tar -xvf v6.6-rc4.tar.gz
# Build kernel.
RUN cd linux-6.6-rc4 && ../build-default.sh
RUN cp ./linux-6.6-rc4/arch/x86/boot/bzImage bzImage-default
RUN cp ./linux-6.6-rc4/vmlinux vmlinux-default

# Build kernel with FineIBT.
RUN rm -rf linux-6.6-rc4
RUN tar -xvf v6.6-rc4.tar.gz
RUN cd linux-6.6-rc4 && ../build-fineibt.sh
RUN cp ./linux-6.6-rc4/arch/x86/boot/bzImage bzImage-fineibt
RUN cp ./linux-6.6-rc4/vmlinux vmlinux-fineibt

# Copy all folders.
COPY entrypoints /entrypoints
COPY scanner /scanner
COPY analysis /analysis
COPY scripts /scripts
COPY vm /vm

