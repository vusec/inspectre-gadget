# IBT and FineIBT Speculation window tests

This folder contains the IBT and FineIBT speculation window tests.

## Tested environments

The IBT and FineIBT window testing is performed on the following Intel CPUs:

- Intel(R) Core(TM) i7-11800H COU (Rocket Lake)
- Intel(R) Core(TM) i9-12900K CPU (Alder Lake)
- Intel(R) Core(TM) i9-13900K CPU (Raptor Lake)

We used Linux kernel v6.6-rc4.

## Creating the test setup

Install dependencies

``` bash
cd ../poc-common
./install_dependencies.sh
```

Build the kernel:

``` bash
cd kernel
./build_kernel.sh
```

Note: If your architecture is not supported by the Ubuntu config,
creating a config via `make localmodconfig` should also work. The tests should
not be dependent on a kernel version, but we did not test for it either.

Please add 'isolcpus=2,3' to the kernel boot parameters. Replace
2 and 3 with the core you want to test the PoC on and the corresponding
sibling.

Reboot into new kernel. Note: you have to disable secure boot.

## Testing FineIBT Speculation Windows

First, install the kernel module:

``` bash
cd kernel_modules/ibt_tests_kernel_module
sudo ./run.sh
```

To start the test:
Please select two performance sibling cores. We selected for the i9-13900K
and i9-12900K CPUs core 2 and 3 and for the i7-11800H CPU core 2 and 10. Please
adjust the cores in the file `src\targets.h'

The test takes approximately 8 hours. So please run it via a separate session
(e.g., `tmux`).
To run the test (adjust the CPU name):

``` bash
cd src
sudo ./run_test.sh i9-13900K
```

To analyze the results:

``` bash
./analyze_all.sh src/results/

# Filter for fine_ibt results:
./analyze_all.sh src/results/ fineibt

# Filter for ibt results:
./analyze_all.sh src/results/ ibt
```

Our results are included in the folder `results`.
As shown in Table 4 of the paper, we used the following configs for the
different CPUs.

- i7-11800H: C1 (2 outer 5 inner)
- i9-12900K: C2 (1 outer 9 inner)
- i9-13900K: C3 (2 outer 8 inner)
