# Disclosure - FineIBT bypass with unix_poll

This folder contains the FineIBT bypass PoC with the gadget
`unix_poll`. The PoC is tested on the i9-13900K with Linux
kernel version 6.6-rc4. Please read the setup instructions in the parent
folder.

## The attack

The reachable dispatch gadget `unix_poll` is used to load
a secret and, subsequently, jump to a single instruction that
transmits the secret with an attacker controlled value as base. For
a more detailed explanation we refer to the enclosed paper.

## Building

Build de PoC:

``` bash
cd unix_poll
make OS=LINUX_v6_6_6_DEFAULT ARCH=INTEL_13_GEN -B
```

This PoC requires SMT contention, to build the SMT contention program:

``` bash
cd ../../contention
make smt_contention -B
```

## Running

Executing the `run.sh` script will first retrieve the address
of `uuid_string`, which contains our transmission instruction (`movzx ebx, BYTE
PTR[r8+rbx]`). Next it will execute the PoC program on core 0.

``` bash
cd unix_poll
sudo ./run.sh
```

Next run the smt_contention on the sibling thread. Please check
the topology (`lscpu --extended`) to make sure it is running on the sibling
of core 0. In our experiments contention option 0 was the most efficient,
but this can differ per uarch.


``` bash
cd ../../contention
taskset -c 1 ./smt_contention 0
```

Note that the KASLR break to retrieve the phys_map start is not
designed to work with SMT contention. Either start the SMT contention
after the initialization, or provide the phys_map start with `./main -p START`
or `./run.sh START`

### Fastening the collision phase

Finding a collision takes around 10 minutes on the tested CPU. To fasten
the collision phase for testing purposes, please use the script `run_fast.sh`. This test
will patch the FineIBT check by replacing the `je` instruction with a
`jmp` before the start of the collision phase. The FineIBT check is restored
after the collision is found.

This option requires to load the `patch_kernel_module`:


``` bash
cd ../../kernel/patch_kernel_module
sudo ./run.sh
```

Run:

``` bash
cd unix_poll
sudo ./run_fast.sh
```

As mentioned above, please first start the user program after starting the
contention, or provide the phys_map start with `./main -p START`
or `./run_fast.sh START`
