# Scanner Evaluation

This folder contains all the code use to run the evaluation of the scanner
on Linux kernel version 6.6-rc4.

## TL;DR

```sh
./run.sh
```

This will run the full evaluation in a docker container.

## Step-by-step

While our evaluation has been performed on the Linux Kernel, any binary
can be analyzed by InSpectre Gadget, given a list of entrypoints.
The evaluation scripts performs 4 main steps, each of which is described in a
separate `README` file. You can refer to the content of the `Dockerfile`
for the exact commands.


> **NOTE:**  If you want to reuse our targets, you can skip steps 1. and 2. and
> use the lists provided in `entrypoints/linux-6.6-rc4/`.

### 1. Create a VM dump

`vm/README.md` explains how to create a memory dump from a running Linux VM.

### 2. Extract Entrypoints

`entrypoints/README.md` explains how to extract a list of all indirect call and
indirect jump targets from a kernel dump. These will be used as entrypoints
of the analysis.

### 3. Run the Scanner

`scanner/README.md` explains how to run the scanner on the Linux kernel
with parallel jobs and merge the results.

### 4. Analyze results

`analysis/README.md` explains how to generate the gadget database and run the
queries that were reported in the paper.
