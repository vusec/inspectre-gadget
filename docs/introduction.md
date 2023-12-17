# Introduction

InSpectre Gadget is a program analysis tool that can be used to inspect potential
Spectre disclosure gadgets and perform technique-aware exploitability analysis.

You can read more about the general problem and our approach in particular in
our [paper]() (currently under submission).

## Motivation

Whenever there is a chain of loads that can be executed in a speculative window,
we might be able to leak memory through a side-channel.

However, not all double-loads are created equal.

This tool finds potential Spectre gadgets and classifies them based on properties
like where can we leak from, where can we place our reload buffer, etc.

## How it works

InSpectre gadget is an [ANGR](https://angr.io)-based tool written in Python.

<!-- The tool takes as input a binary and a list of **speculation entrypoints** and
outputs a list of **transmissions**, i.e. symbolic expressions associated to
a given location in the program, enriched with a set of properties that can
be used by the analyst to filter out or prioritize gadgets. -->

Given a binary and a list of speculation entrypoints,
InSpectre Gadget will explore a configurable amount of basic blocks for each entrypoint
and output a CSV with a list of all the transmission gadgets it found.

By default, all registers and stack locations are considered attacker-controlled,
and each gadget can later be filtered by the registers and memory that it actually requires.

A separate component, the "reasoner", is used to reason about exploitability.
This component models advanced exploitation techniques and their requirements as
queries on the CSV.

## License

TBD
