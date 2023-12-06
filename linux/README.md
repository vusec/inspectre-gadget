# Linux Kernel Experiment

1. Follow `input/README.md` to create a kernel dump and generate the
list of all interesting entrypoints
2. Run `run-parallel.sh <VMLINUX> input/<LIST> <N_JOBS>` and wait for it to finish
    * This will create an `out` folder with all the output files
    * You can check the status by listing `out/finished.txt` or use `scripts/check-status.sh`
3. From withing the `out/` folder, use `scripts/merge_gadgets.csv`
    * This will produce two CSVs: `all-gadgets.csv` and `all-tfps.csv`
4. Run the reasoner `python ../../analyzer/reasoner/reasoner.py all-gadgets.csv all-gadgets-reasoned.csv`
5. Inspect the results
    * e.g. `sqlite3 :memory: -cmd '.mode csv' -cmd '.separator ;' -cmd '.import all-gadgets-reasoned.csv gadgets' -cmd '.mode table' -cmd '.output output.txt' < ../../queries/exploitable_list.sql` and
    inspect `output.txt`
