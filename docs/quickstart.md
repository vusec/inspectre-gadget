# Getting Started

## Installation

Install `python3.11`, clone the repo and `pip3 install -r requirements.txt` in a virtual environment.

```{warning}
 To install python3.11 on newer Ubuntu versions you can check [here](https://askubuntu.com/questions/1512005/python3-11-install-on-ubuntu-24-04).
```

Some of our scripts use [batcat](https://github.com/sharkdp/bat) and `sqlite3`, although
they are not required for the core of the tool (analyzer and reasoner).

## Usage

The basic usage of the tool is to run `inspectre analyze` on a binary to extract
all potential transmissions, and then use `inspectre reason` to mark the exploitable ones.

For the analyzer, the user should provide:

- a **binary**
- a **list of speculation entrypoints**, i.e. a CSV with the format
  `<HEX_ADDRESS>,<ENTRYPOINT_NAME>` (name is used for human-readable output)
- a **config** file in YAML format (described in the dedicated [doc page](./configuration.md))
- the name of the CSV output
- (optionally) a folder where to output the annotated assembly of each gadget

```sh
inspectre analyze <BINARY> --address-list <CSV_FILE> --config <YAML_CONFIG> --output <FILE> --asm <FOLDER>
```

For the reasoner, you only need to provide the CSV produced by the analyzer as input.

A list of all the flags can be found by invoking `inspectre <SUBCOMMAND> --help`.

## Workflow

A typical workflow might look something like this.

```sh
# Find all potential transmissions in the given binary.
mkdir out
inspectre analyze <BINARY> --address-list <CSV_FILE> --config config_all.yaml --output out/gadgets.csv --asm out/asm

# Evaluate exploitability.
inspectre reason out/gadgets.csv out/gadgets-reasoned.csv

# Import the CSV in a database and query the results.
# You can use any DB, this is just an example with sqlite3.
sqlite3 :memory: -cmd '.mode csv' -cmd '.separator ;' -cmd '.import out/gadgets-reasoned.csv gadgets' -cmd '.mode table' < queries/exploitable_list.sql

# Manually inspect interesting candidates.
inspectre show <UUID>
```

## Demo

![](img/inspectre.gif)

## Build Docs

```sh
pip install sphinx myst-parser sphinx_rtd_theme sphinx-rtd-size
cd docs
make html && cp -r _build/* .

# --> open _build/html/index.html in a browser
```
