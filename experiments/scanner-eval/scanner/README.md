# Running the Scanner

This document describes how to run the scanner on the Linux kernel given a
list of entrypoints.

## 1. Prerequisites

InSpectre Gadget requires a list of entrypoints as input.
We show an example of how to run the scanner on all indirect targets of the
Linux kernel version 6.6-rc4.

We assume you followed the procedure described in the `entrypoints/` folder
to create such list.
You can also use your own list of entrypoints and adjust the instructions
accordingly.

## 2. Collect gadgets

We created a quick & dirty script to parallelize the analysis.

The basic idea is to run `run-parallel.sh <VMLINUX> <LIST> <N_JOBS>` and wait for it to finish.

### Call Targets

```sh
# Start the analyzer with 20 parallel jobs.
./run-parallel.sh vmlinux-6.6-rc4_ibt input/linux-6.6-rc4/endbr_call_target_6.6-rc4-default.txt 20

# Check the status (will show percentage of completion).
watch 'scripts/check-status.sh input/linux-6.6-rc4/endbr_call_target_6.6-rc4-default.txt'

# ... once the status scripts indicates 100.0% ...

# Merge all results.
cd out && python ../scripts/merge_gadgets.py && cd ..

# Rename folder.
mv fail.txt out
mv out call_targets
```

### Jump Targets

```sh
# Start the analyzer with 20 parallel jobs.
./run-parallel.sh vmlinux-6.6-rc4_fineibt input/linux-6.6-rc4/endbr_jump_target_6.6-rc4-fineibt.txt 20

# Check the status (will show percentage of completion).
watch 'scripts/check-status.sh input/linux-6.6-rc4/endbr_jump_target_6.6-rc4-fineibt.txt'

# ... once the status scripts indicates 100.0% ...

# Merge all results.
cd out && python ../scripts/merge_gadgets.py && cd ..

# Rename folder.
mv fail.txt out
mv out jump_targets
```
