# Dispatch Gadget PoCs

This folder contains the PoCs of Native BHI performed with dispatch gadgets.

- `./1stage-common_timer_del-of_css`: PoC with dispatch gadget `common_timer_del`
and disclosure gadget `of_css`, via the 1-stage chaining strategy.
- `./1stage-m_show-of_css`: PoC with dispatch gadget `m_show`
and disclosure gadget `of_css`, via the 1-stage chaining strategy.
- `./2stage-m_show-of_css`: PoC with dispatch gadget `m_show`
and disclosure gadget `of_css`, via the 2-stage chaining strategy.

## Tested environments

- Intel(R) Core(TM) i9-13900K CPU (Raptor Lake)

## Creating the test setup

Install dependencies:

``` bash
cd ../poc-common
./install_dependencies.sh
```

We tested the PoCs with the kernel config available in `./kernel`. To build and
install the kernel:

``` bash
cd ../dispatch-gadgets/kernel
./build_kernel.sh
```

Reboot into the new kernel. Note: you have to disable secure boot.

## Testing the PoCs

Please change the directory to one of the PoCs and execute `run.sh`:

``` bash
sudo ./run.sh
```
