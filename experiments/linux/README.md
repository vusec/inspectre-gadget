# Linux Kernel Experiment

Instructions for reproducing the experiments on the Linux Kernel.

## 1. Create a kernel dump

Follow the instructions inside `input/README.md` to create a kernel dump and generate the list of all interesting entrypoints.

## 2. Collect gadgets

Since the current implementation of InSpectre Gadget does not support parallel
execution, we created a quick & dirty script to parallelize the analysis.

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

## 3. Run the reasoner

Run the reasoner on `call_targets/all-gadgets.csv` and `jump_targets/all-gadgets.csv`.

```sh
cd call_targets && $INSPECTRE_ROOT/inspectre reason all-gadgets.csv all-gadgets-reasoned.csv && cd ..
cd jump_targets && $INSPECTRE_ROOT/inspectre reason all-gadgets.csv all-gadgets-reasoned.csv && cd ..
```

## 4. Import results

Now you can import `call_targets/all-gadgets-reasoned.csv` and `jump_targets/all-gadgets-reasoned.csv` in a database of your choice.

We created a script for SQLITE3.

```sh

# Move the lists we used to a `lists/` folder.
mkdir lists
cp input/linux-6.6-rc4/all_text_symbols_6.6-rc4-fineibt.txt lists/
cp input/linux-6.6-rc4/all_text_symbols_6.6-rc4-default.txt lists/
cp input/linux-6.6-rc4/reachable_functions_6.6-rc4.txt lists/

# Run the script to create a sqlite3 database and print some stats.
scripts/run-queries.sh
```

You will find the newly created database in `gadgets.db`.
