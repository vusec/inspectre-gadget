# Disclosure - FineIBT Analysis and bypass

This folder contains the POC of the FineIBT bypass using the gadget `unix_poll`.

## Tested environments

The PoC is tested on the following Intel CPU:

- Intel(R) Core(TM) i9-13900K CPU (Raptor Lake)

We used Linux kernel v6.6-rc4.

## Creating the test setup

Install dependencies

``` bash
cd ../poc-common
./install_dependencies.sh
```

Build the kernel. This command will apply the required patch for the PoC
and build a kernel with the tested kernel configuration.

``` bash
cd kernel
./build_kernel.sh
```

Reboot into new kernel. Note: you have to disable secure boot.

## Testing FineIBT Bypass PoC (unix_poll)

First, install the kernel module:

``` bash
cd kernel_modules/patch_kernel_module
sudo ./run.sh
```

To test the leakage rate:

``` bash
cd src
sudo ./run_fast.sh
```

To test the full PoC, including the collision finding phase.
Note that the collision-finding phase can take up-to 5 minutes

``` bash
cd src
sudo ./run.sh
```

Note: Please re-run the PoC a few times and reboot once. The leakage
rates can differ across boots and runs.
