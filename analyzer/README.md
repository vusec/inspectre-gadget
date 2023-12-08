# InSpectre Gadget

Modelling exploitability for Spectre disclosure gadgets.

## Motivation

Whenever there's a chain of loads that can be executed in a speculative window,
we might be able to leak memory through a side-channel.

However, not all double-loads are created equal.

This tool finds potential Spectre gadgets and classifies them based on properties
like where can we leak from, where can we place our reload buffer, etc.

## How it works

The tool takes as input a binary and a list of attacker-controlled registers and stack locations.

It outputs a list of **transmissions**, i.e. symbolic expressions associated to a given location in the program, enriched with a set of properties that can be used by the analyst to filter out or prioritize gadgets.

## Design

Internally, the gadget analysis is divided into different steps:

- Step 0: the binary is loaded into an **angr project** and all non-writable memory is removed.
- Step 1: the **Scanner** performs symbolic execution on the code for a limited number of basic blocks and returns a list of symbolic expression that have been classified as potential transmissions.
- Step 2: the **Transmission Analyzer** extracts a list of transmissions from the symbolic expressions found by the scanner, identifying a _base_ and _secret_ for each of them.
- Step 3: a series of analysis are run on each transmission:
  - A **Base Control** analysis tries to understand if the base can be independently controlled from the secret and secret address.
  - A **Path** analysis recovers the visited branches and the resulting constraints.
  - A **Requirements** analysis lists which registers and memory locations need to be controlled by the attacker.
  - A **Range** analysis tries to identify the range of the secret, the secret address and the transmission base.

### Scanner

The scanner performs symbolic execution and records:

- every load
- every store
- every branch

For each **store**, we save the address and value.

For each **load**, we create a new symbol and set it as the result of the load.
The newly created symbol is tagged with a `LoadAnnotation`, which can be one
of the following:

- `MaybeAttacker` -> value loaded from a constant address
- `Secret` -> value loaded from an attacker-controlled address
- `Transmission` -> load of a secret-dependent address

We also check if the address aliases with any other previous store or load,
and in this case, we save the corresponding constraint.

For each **branch**, we save the PC and constraints in a list.

We also completely disable concretization.

At the end of its execution, the Scanner reports a list of potential transmissions,
i.e. instructions that are known to leak the argument (only loads and stores are
supported for now) and have a secret-dependent argument.

### TransmissionAnalysis

Once we have a list of potential transmissions from the scanner, we analyze them
to identify clearly what secret is being transmitted and possibly if there's
a _transmission base_ (e.g. flush-reload buffer).

First, the expression is **canonicalized**, i.e. reduced to a known form:

- `claripy.simplify()` is applied, to covert subtractions into sums and distribute \* and / over +
- expressions containing ` if-then-else` statements (e.g. CMOVs) are split into equivalent expressions with associated constraints (e.g. `if a>0 then b else c` is split into `b (condition a>0)` and `c (condition a <=0)`)
- concats are reduced to shifts
- `<<` are distributed over `+`

Then, we divide the final expression into sum members and, for each, we check if they
contain a potential secret (e.g. a value loaded from an attacker-controlled address).
If so, we create a `Transmission` object with that member as the transmitted secret and everything else as the base.
