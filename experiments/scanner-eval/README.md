# Scanner Evaluation

This folder contains all the code used to run the evaluation of InSpectre Gadget
on Linux kernel version 6.6-rc4.

## TL;DR

```sh
./run.sh
```

This will build a docker container (`inspectre_container`) and run the full
evaluation (`/scripts/run-eval.sh`) inside it.

The result is stored in the `results` folder, in particular:
- `stats.txt` contains the results of the queries used in the paper
- `figs` contains the cumulative distributions showed in the paper
- `gadgets.db` is the gadget database

## Step-by-step

While our evaluation has been performed on the Linux Kernel, any binary
can be analyzed by InSpectre Gadget, given a list of entrypoints.
The evaluation script performs 4 main tasks, each of which is described in a
separate `README` file. You can refer to the content of the `Dockerfile`
for the exact commands.

### 1. Create a VM dump

`vm/README.md` explains how to create the `vmlinux` binary analyzed by
InSpectreGadget and a memory dump from a running Linux VM, which is used to
find call and jump targets after the kernel's startup hotpatches.

### 2. Extract Entrypoints

`entrypoints/README.md` explains how to extract a list of all indirect call and
indirect jump targets from a kernel dump. These will be used as entrypoints
of the analysis.

> **NOTE:**  If you want to reuse our targets, you can skip this step and
> use the lists provided in `entrypoints/linux-6.6-rc4/`.

### 3. Run the Scanner

`scanner/README.md` explains how to run the scanner on the Linux kernel
with parallel jobs and merge the results.

### 4. Analyze results

`analysis/README.md` explains how to generate the gadget database and run the
queries that were reported in the paper.
