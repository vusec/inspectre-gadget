#
# Prepare the environment for eval.
#
FROM ubuntu:24.04 AS base

# -----------------------------------------------------------------------------
# Packages
# -----------------------------------------------------------------------------
RUN apt update && \
    apt install -y build-essential libncurses-dev bison flex libssl-dev \
    libelf-dev zstd qemu-system-x86 debootstrap wget bc sudo python3-pip \
    openssh-client git sqlite3 vim linux-headers-$(uname -r) gdb

# Graph drawing dependencies.
# RUN pip3 install pandas matplotlib numpy cycler scienceplots tqdm argparse --break-system-packages
# RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/Amsterdam apt-get -y install texlive-latex-extra texlive-fonts-recommended dvipng cm-super


# -----------------------------------------------------------------------------
# VM Setup
# -----------------------------------------------------------------------------

COPY vm/create-image.sh /vm/create-image.sh
WORKDIR /vm
# Reuse syzkaller scripts to easily create a rootfs.
RUN ./create-image.sh -d bookworm

# Python dependencies
COPY inspectre/requirements.txt /inspectre/requirements.txt

RUN pip3 install -r /inspectre/requirements.txt --break-system-packages
RUN pip3 install qemu.qmp tqdm --break-system-packages

# -----------------------------------------------------------------------------
# Copy local directories
# -----------------------------------------------------------------------------

# Copy required folders
COPY vm /vm
COPY inspectre /inspectre
COPY scanner /scanner
COPY scripts /scripts
COPY analysis /analysis
COPY entry-points /entry-points

