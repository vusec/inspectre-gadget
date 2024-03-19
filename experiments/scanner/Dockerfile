FROM ubuntu:22.04 AS base

RUN apt-get update && \
    apt-get install -y build-essential libncurses-dev bison flex libssl-dev \
    libelf-dev zstd qemu-system-x86 debootstrap wget bc sudo

# --------------------------- Stage 1. Dump VM ---------------------------------
COPY vm /vm

# The first step is to build a Linux kernel, we build v6.6-rc4.
WORKDIR /vm
RUN wget https://github.com/torvalds/linux/archive/refs/tags/v6.6-rc4.tar.gz
RUN tar -xvf v6.6-rc4.tar.gz

WORKDIR /vm/linux-6.6-rc4
RUN make defconfig
RUN make -j`nproc`

# Since the Linux kernel patches spurious `endbr` instructions at boot time,
# we need to create a dump of a booted Linux Kernel.
# RUN usermod -a -G kvm $USER
WORKDIR /vm
RUN wget https://raw.githubusercontent.com/google/syzkaller/master/tools/create-image.sh
RUN chmod +x create-image.sh
RUN ./create-image.sh -a x86_64 -d stretch -s 4096

# # --------------------- Stage 2. Extract Entrypoints ---------------------------
# COPY entrypoints /entrypoints
# WORKDIR /entrypoints

# # Next we extract the endbr targets, all text symbols, and distinguish between
# # jump and call targets.

# # get all text symbols
# RUN echo "address,name" > all_text_symbols_6.6-rc4-default.txt && \
#     nm vmlinux | grep -e " t " -e " T " | awk '{print "0x"$1 "," $3}' >> \
#     all_text_symbols_6.6-rc4-default.txt

# # extract endbr addresses from memory dump
# RUN echo "address" > endbr_addresses_6.6-rc4-default.txt && \
#     objdump -M intel -D dump_6.6-rc4-default --start-address=0xffffffff81000000 | \
#     grep endbr64 | awk '{print "0x"$1}' | sed 's/.$//' | sort -u >> \
#     endbr_addresses_6.6-rc4-default.txt

# # filter call-targets
# RUN python3 filter_addresses.py call-targets endbr_addresses_6.6-rc4-default.txt all_text_symbols_6.6-rc4-default.txt > endbr_call_target_6.6-rc4-default.txt

# # filter jump-targets
# RUN python3 filter_addresses.py jump-targets endbr_addresses_6.6-rc4-default.txt all_text_symbols_6.6-rc4-default.txt > endbr_jump_target_6.6-rc4-default.txt

# # ------------------------- Stage 3. Run Scanner -------------------------------
# COPY scanner /scanner
# COPY scanner /scanner
# COPY scanner /scanner
# WORKDIR /scanner

# # ---------------------- Stage 4. Analyzer Results -----------------------------
# COPY analysis /analysis
# WORKDIR /analysis
