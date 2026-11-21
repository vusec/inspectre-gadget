![](./docs/img/inspectre-gadget-circle.png)

# InSpectre Gadget

[![CI](https://github.com/vusec/inspectre-gadget/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/vusec/inspectre-gadget/actions/workflows/ci.yml?query=branch%3Amain)

This is the official repository for the InSpectre Gadget tool.

This code has been developed as part of our [InSpectre Gadget paper](https://download.vusec.net/papers/inspectre_sec24.pdf).
The code for all the experiments reported in the paper (including PoCs)
can be found at [inspectre-gadget-artifact](https://github.com/vusec/inspectre-gadget-artifact).

**Disclaimer**

This tool is a research project still under development. It should not be
considered a production-grade tool by any means.

## Description

InSpectre Gadget is a tool for inspecting potential Spectre disclosure gadgets
and performing exploitability analysis.

Documentation can be found at [https://vusec.github.io/inspectre-gadget](https://vusec.github.io/inspectre-gadget).

Here's a small demo.

![](docs/img/inspectre.gif)

## Install

Install the tool locally in a virtual environment.

```sh
# Install the tool locally.
python3 -m venv .venv
source .venv/bin/activate
pip3 install -e .
```

If you plan to work on it as a developer, you might want to install dev dependencies (and optionally docs dependencies) as well.

```sh
# Install dev dependencies (pytest, ...)
pip install -e ".[dev]"
# Install dependencies for building docs (sphinx, ...)
pip install -e ".[docs]"
```

## Usage

A typical workflow might look something like this:

```sh
# Run the analyzer on a binary to find transmissions.
mkdir out
inspectre analyze <BINARY> --address-list <CSV> --config examples/configs/config_all.yaml --output out/gadgets.csv --tfp-output output/tfp.csv --asm out/asm

# Evaluate exploitability.
inspectre reason gadgets.csv gadgets-reasoned.csv

# Import the CSV in a database and query the results.
# You can use any DB, this is just an example with sqlite3.
sqlite3 :memory: -cmd '.mode csv' -cmd '.separator ;' -cmd '.import gadgets-reasoned.csv gadgets' -cmd '.mode table' < examples/queries/exploitable_list.sql

# Manually inspect interesting candidates.
inspectre show <UUID>
```

## Run Tests

You can run all tests with `pytest [-n num_of_cores]`.

We have two types of tests:
* **unit tests**: test that specific internal functions do what they're supposed to
    * run with `pytest -m "not e2e"`
* **end-to-end tests (slow)**: run the full InSpectre Gadget pipeline on small assembly snippets and check that the output matches what we expect
    * run with `pytest -m e2e [-n num_of_cores]`
    * the short report should contain instructions on how to check the output of failing tests


