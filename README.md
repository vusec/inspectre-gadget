![](./docs/img/inspectre-gadget-circle.png)

# InSpectre Gadget

This is the official repository for the InSpectre Gadget tool.

This code has been developed as part of our ["InSpectre Gadget" paper](https://download.vusec.net/papers/inspectre_sec24.pdf) (accepted
at 33rd USENIX Security Symposium 2024).

**Disclaimer**

This tool is a research project still under development. It should not be
considered a production-grade tool by any means.

## Description

InSpectre Gadget is a tool for inspecting potential Spectre disclosure gadgets
and performing exploitability analysis.

Documentation can be found at [https://vusec.github.io/inspectre-gadget](https://vusec.github.io/inspectre-gadget).

## Usage

A typical workflow might look something like this:

```sh
# Run the analyzer on a binary to find transmissions.
mkdir out
inspectre analyze <BINARY> --address-list <CSV> --config config_all.yaml --output out/gadgets.csv --tfp-output output/tfp.csv --asm out/asm

# Evaluate exploitability.
inspectre reason gadgets.csv gadgets-reasoned.csv

# Import the CSV in a database and query the results.
# You can use any DB, this is just an example with sqlite3.
sqlite3 :memory: -cmd '.mode csv' -cmd '.separator ;' -cmd '.import gadgets-reasoned.csv gadgets' -cmd '.mode table' < queries/exploitable_list.sql

# Manually inspect interesting candidates.
inspectre show <UUID>
```

## Demo

![](docs/img/inspectre.gif)

## Evaluation and PoCs

The code for all the experiments reported in the paper (including PoCs)
can be found under the `experiments/` folder.

`experiments/scanner-eval` shows how we ran InSpectre Gadget on the Linux kernel.
