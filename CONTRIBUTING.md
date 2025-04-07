# Contributing to InSpectreGadget

Before you send pull requests, you should:

1. Make sure your code is properly **formatted**

```bash
pip install autopep8
python3 -m autopep8 --ignore E302 --recursive --in-place analyzer
```

2. Update the **testsuite**: ideally, each corner-case should have a
   corresponding test in the `test/test-cases` folder.

   - Create a new folder in `test/test-cases`, add a `gadget.S` and a `Makefile` (see other testcases)
   - Run `bash test-single.sh <YOUR_NEW_TESTCASE> --update` to generate the reference output
   - Run `bash test-all.sh` to check that the rest has not changed
   - If some output is expected to changed, make sure to also run `test-single.sh --update` on the corresponding testcase

3. Update **documentation**: you should change the `.md` files in the `docs/*` folder and regenerate with `cd docs && make html && cp -r build/* .`
