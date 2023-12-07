# InSpectre Gadget

This is the official repository for the InSpectre Gadget tool.

The code has been developed as part of our "InSpectre Gadget" paper, which is
currently under submission. Access is limited to interested parties for now.

**Disclaimer**

This tool is a research project still under development. It should not be
considered a production-grade tool by any means.

## Description

InSpectre Gadget is a tool for inspecting potential Spectre disclosure gadgets
and performing exploitability analysis.

Given a binary and a list of speculation entrypoints,
InSpectre Gadget will explore a configurable amount of basic blocks for each entrypoint
and output a CSV with a list of all the transmission gadgets found, along
with a set of properties that can be used to reason about exploitability.

A separate component, the "reasoner", is used to reason about exploitability.
This component models advanced exploitation techniques and their requirements as
queries on the CSV.

## Usage

### Installation

Just install python3, clone the repo and `pip3 install -r requirements.txt`.

Our test script uses [batcat](https://github.com/sharkdp/bat).

### Workflow

A typical workflow might look something like this:

```sh
# Run the analyzer on a binary from a specified address.
mkdir out
inspectre analyze <BINARY> --address <HEX_ADDRESS> --config config_all.yaml --output out/gadgets.csv --asm out/asm

# Evaluate exploitability.
inspectre reason gadgets.csv gadgets-reasoned.csv

# Import the CSV in a database and query the results.
# You can use any DB, this is just an example with sqlite3.
sqlite3 :memory: -cmd '.mode csv' -cmd '.separator ;' -cmd '.import gadgets-reasoned.csv gadgets' -cmd '.mode table' < experiments/queries/exploitable_list.sql

# Manually inspect interesting candidates.
inspectre show <UUID>
```

![](inspectre.gif)

The complete list of flags can be found by invoking `analyzer/main.py --help`:

### Output

The CSV output of the analyzer is just a "flattened" version of the Transmission
object, which can be found in `analyzer/shared/transmission.py`.

**:warning: Our CSV outputs typically use SEMICOLON as a separator**

Some useful terminology when inspecting the tool's output:

- **Components**: `base`, `secret_address`, `secret_val` and `transmitted_secret` are
  referred to as the "components" of a transmission. Refer to the paper for a
  formal definition of what these components are.
- **Requirements**: For each gadget and for each component, we provide
  a list of registers and memory locations that the attacker needs to control
  in order to exploit it. This means that we can initially consider all registers
  controlled, and later refine the search by looking at each gadget's requirements.
- **TFPs**: short for "Tainted Function Pointers", referred to as "dispatch gadgets"
  in the paper
- **Aliases**: During symbolic execution, our memory model creates a new symbolic
  variable for each symbolic load. If two symbolic loads are bound to alias in memory
  (e.g. `LOAD64[rax] and LOAD32[rax+1]`) we create alias constrain for the loaded values.
- **Constraints**: During symbolic execution, we record two types of constraints:
  - "hard" constraints (or simply `constraints`), generated by CMOVEs and
    Sign-Extensions. In these cases, we split the state in two and we attach
    a hard constraint to the child state. These constraints cannot be bypassed.
  - "soft" constraints (or `branches`), generated by branch instructions. These
    constraints can be bypassed with speculation.

```
TODO: Generate a complete description of the columns somewhere.
```

### Configuration

A YAML file can be provided to the tool with the `--config` flag.
The config defines which registers and stack locations are controlled by the
user.

Note that, since our tool lists which registers and memory locations are
really needed for each gadget, our approach is to mark everything as
controlled, and apply filters later on the CSV.

Some other configurations that can be tweaked are:

- **STLForwarding**: When enabled, the scanner will forward stored values to subsequent loads to the same address
- **DistributeShifts**: When enabled, left-shift expressions like `(rax + rbx) << 8` will be treated as `(rax << 8) + (rbx << 8)` during range and control analysis.
- **TaintedFunctionPointers**: When enabled, the scanner will scan also for TaintedFunctionPointers (a.k.a dispatch gadgets)

## Experiments

### Tests

The `tests` folder contains some samples that can be used
to test the behavior of the scanner in specific situations.

You can run all tests with `cd tests && ./run-all.sh`.

### Linux Kernel Experiment

In the `experiments/linux` folder you can find the scripts we used to run InSpectre gadget
against the Linux Kernel.

You can find more details about how to run the Linux Kernel experiment in `linux/README.md`.

## Internals

Out tool is based on the [ANGR](https://github.com/angr/angr) symbolic
execution engine.

You can find more details about the tool internals in `analyzer/README.md`.

## License

TBD
