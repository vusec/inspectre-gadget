# Examples

## Tests

The `tests` folder contains two sets of tests:

- `test-cases/`: simple assembly snippets that can be used
  to test the behavior of the scanner in specific situations. You can find the
  reference output for these cases in the `ref/` folder.
- `unit-tests.`: unit tests for internal modules

For both, we provide a simple `./run-all.sh` script.

## Linux Kernel Experiment

In the `experiments/linux` folder you can find the scripts we used to run InSpectre Gadget
against the Linux Kernel.

You can find more details about how to run the Linux Kernel experiment in `linux/README.md`.
