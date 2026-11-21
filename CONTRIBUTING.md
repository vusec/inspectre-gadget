# Contributing to InSpectre Gadget

So, you want to chase some more Spectres?

## TL;DR

Before opening a PR

```bash
ruff format .       # format
ruff check --fix .  # lint and apply safe fixes
ruff check .        # everything else here needs to be addressed manually
pytest [-n num_of_cores] # run testsuite
```

If the tests fail, see section on tests (and add your own as well!).

## Setup

You should be able to install dev dependencies with:

```sh
# Install dev dependencies (pytest, ruff, ...)
pip install -e ".[dev]"
```

e2e tests also require `objdump` and other basic command-line tools.

We strongly suggest to add formatting on autosave on your editor.
For VSCode, this worked for me:

```json
{
    "[python]": {
        "editor.defaultFormatter": "charliermarsh.ruff",
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.fixAll.ruff": "explicit",
            "source.organizeImports.ruff": "explicit"
        }
    },
    "[toml]": {
        "editor.formatOnSave": false
    }
}
```

## Formatting

We use `ruff` for linting and formatting. This is how you use it (run all 3):

```bash
ruff format .       # format
ruff check --fix .  # lint and apply safe fixes
ruff check .        # everything else here needs to be addressed manually
```

## Testing

We have two types of tests:
* **unit tests**: test that specific internal functions do what they're supposed to
* **end-to-end tests (slow)**: run the full InSpectre Gadget pipeline on small assembly snippets and check that the output matches what we expect

You can run the full testsuite with `pytest [-n num_of_cores]`.

### Unit Tests

These are standard python unittest, see `tests/unit`.
If you have functions or modules that do something nasty that has corner cases which are not straightforward from the code, it's good to add a small test here.

You can run unit tests with `pytest -m "not e2e" [-n num_of_cores]`.

### End2End Tests

Ideally, each new analysis/transmitter you add should have corresponding tests in the `tests/end2end` folder.

To add one:
   - Create a new folder in `tests/end2end/cases`, add a `gadget.S` and a `Makefile` (see other testcases)
   - Run `bash test-single.sh <YOUR_NEW_TESTCASE> --update` to generate the reference output

You can run the e2e tests with `pytest -m e2e [-n num_of_cores]` (it might take minutes).
   - If outputs of previous tests are expected to change, make sure to also run `test-single.sh --update` on the corresponding testcase (or `pytest -m e2e --update-reference-output` to update all of them -- be careful with this!)

## Documentation

If what you did is useful to others (and it probably is if you want to upstream it) then add some documentation for it!

Documentation is stored in `.md` files in the `docs/*` folder.
You can regenerate the docs locally with:

```bash
pip install -e ".[docs]"  # if you haven't already
cd docs
make html                 # output goes to docs/build/html
```

Then open `docs/build/html/index.html` in your browser.

The API reference (`docs/generated/`) is produced automatically by `autosummary` from the docstrings, so there's no need to edit it by hand.
If pages look stale after renaming or removing things, start fresh with `make clean html`.

Before opening a PR, it's a good idea to build the same way the CI does, which turns warnings into errors:

```bash
sphinx-build -W --keep-going -b html docs docs/build/html
```

Build outputs (`docs/build/`, `docs/generated/`) are git-ignored: don't commit them.
