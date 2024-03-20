#!/bin/bash
# Install dependencies to build kernel
sudo apt install build-essential libncurses-dev bison flex libssl-dev libelf-dev zstd liblz4-tool

# Required for FineIBT testing
sudo apt install gcc-9

# Required for FineIBT testing
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 16

rm llvm.sh
