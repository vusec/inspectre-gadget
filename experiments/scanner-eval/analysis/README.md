# Gadget Analysis

This document describes how to analyze gadgets found by the InSpectre Gadget
scanner.

## 1. Prerequisites

We assume that you ran the scanner following the instructions in the
`entrypoints/` and `scanner/` folder, respectively to generate the input
lists and to generate the gadget's csvs.
You should have an `out` folder with
a `call_targets` folder containing `all-gadgets.csv` and a `jump_targets`
folder with another `all-gadgets.csv`.

You also need a list of:
* all symbols of the default linux build (e.g. `all_text_symbols_6.6-rc4-default.txt`)
* all sybmols of the fineibt build (e.g. `all_text_symbols_6.6-rc4-fineibt.txt`)
* a list of reachable functions, generated e.g. by parsing Syzkaller reports

The `entrypoints/` folder contains instructions on how to generate these from scratch.

## 2. Run the reasoner

Run the reasoner on `call_targets/all-gadgets.csv` and `jump_targets/all-gadgets.csv`.

```sh
cd call_targets && $INSPECTRE_ROOT/inspectre reason all-gadgets.csv all-gadgets-reasoned.csv && cd ..
cd jump_targets && $INSPECTRE_ROOT/inspectre reason all-gadgets.csv all-gadgets-reasoned.csv && cd ..
```

## 3. Create a DB

Now you can import `call_targets/all-gadgets-reasoned.csv` and `jump_targets/all-gadgets-reasoned.csv` in a database of your choice.

We created a script for SQLITE3.

```sh

# Move the lists we used to a `lists/` folder.
mkdir lists
cp ../entrypoints/linux-6.6-rc4/all_text_symbols_6.6-rc4-fineibt.txt lists/
cp ../entrypoints/linux-6.6-rc4/all_text_symbols_6.6-rc4-default.txt lists/
cp ../entrypoints/linux-6.6-rc4/reachable_functions_6.6-rc4.txt lists/

# Run the script to create a sqlite3 database.
./build-db.sh
```

You will find the newly created database in `gadgets.db`.

## 4. Run Queries

The `./run-queries.sh` script will run all the queries we used for
the evaluation and print the results.

## 5. Generate Figures

The `./genrate-figures.py` script will generate all the cumulative ditribution
figures we included in the paper.
