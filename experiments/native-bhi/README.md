# Native BHI POC - cgroup_seqfile_show

This folder contains Native BHI PoC cgroup_seqfile_show.

## Tested environments

- Intel(R) Core(TM) i9-13900K CPU (Raptor Lake)


## Creating the test setup

Install dependencies

``` bash
cd ../poc-common
./install_dependencies.sh
```

Build and install the kernel:

``` bash
cd kernel
./build_kernel.sh
```

Reboot into new kernel. Note: you have to disable secure boot.

## Testing the PoC

First test the PoC without finding the huge-page to verify
the PoC is working:

``` bash
cd src
sudo ./run.sh -p
```

Test the leakage rate:

``` bash
cd src
sudo ./run.sh test_rate
```

Test and time the shadow leak:

``` bash
cd src
time sudo ./run.sh test_rate
```

Note: Please re-run the PoC a few times and reboot once. The leakage
rates can differ across boots and runs.
