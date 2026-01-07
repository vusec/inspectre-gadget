#!/usr/bin/env python3
from pathlib import Path
import shutil
import multiprocessing as mp
import csv
import tqdm
import argparse
import subprocess

arg_parser = argparse.ArgumentParser(
    description='Run InSpectreGadget in parallel')
arg_parser.add_argument('path', help='Path of the "inspectre" python script')
arg_parser.add_argument('binary', help='Path of the binary to analyze')
arg_parser.add_argument('entrypoints', help='Path of the entrypoints list')
arg_parser.add_argument('-c', '--config', type=str,
                        required=True, help='Which configuration file to use')
arg_parser.add_argument('-o', '--out', type=str,
                        required=True, help='Where to store all the output')
arg_parser.add_argument('-t', '--timeout', type=int,
                        required=True, help='Max seconds per entrypoint')
arg_parser.add_argument('-j', '--jobs', type=int,
                        required=True, help='How many parallel jobs')
arg_parser.add_argument('-s', '--symbol-binary', type=str,
                        required=False, help='Binary with function symbols')


args = arg_parser.parse_args()

# Arguments.
inspectre = args.path
binary = args.binary
entrypoints_file = args.entrypoints
config = args.config
out_folder = args.out
jobs = args.jobs
gadget_folder = out_folder + "/gadgets"
tfp_folder = out_folder + "/tfps"
log_folder = out_folder + "/logs"
asm_folder = out_folder + "/asm"
symbol_binary = args.symbol_binary

# Prepare output folder.
# Remove old out.
outpath = Path(out_folder)
if outpath.exists() and outpath.is_dir():
    shutil.rmtree(outpath)
# Create new out.
outpath.mkdir(parents=True, exist_ok=True)
Path(tfp_folder).mkdir(parents=True, exist_ok=True)
Path(log_folder).mkdir(parents=True, exist_ok=True)
Path(asm_folder).mkdir(parents=True, exist_ok=True)
# Touch fail.txt.
open('fail.txt', 'a').close()

# Read entrypoints.
f = open(entrypoints_file)
reader = csv.DictReader(f, delimiter=',')
entrypoints = []
for r in reader:
    entrypoints.append(r)
f.close()

# Run in parallel on every entrypoint.


def run(gadget, with_timeout=True):
    name = gadget['name']
    address = gadget['address']

    logfile = open(f"{log_folder}/out_{name}-{address}.log", "w")
    gadgetfile = f"{gadget_folder}/{name}-{address}.csv"
    tfpfile = f"{tfp_folder}/{name}-{address}.csv"

    cmd = []
    if with_timeout:
        cmd += ["timeout", str(args.timeout)]

    cmd += ["python3", inspectre, "analyze",
            "--config", config,
            "--cache-project",
            "--asm", asm_folder,
            "--output", gadgetfile,
            "--tfp-output", tfpfile,
            "--address", address,
            "--name", name,
            binary]

    # optional args
    if symbol_binary:
        cmd += ['--symbol-binary', symbol_binary]

    # print(' '.join(cmd))
    res = subprocess.run([' '.join(cmd)], shell=True,
                         stdout=logfile, stderr=logfile, check=False)
    logfile.write(f"Exited with code {res.returncode}")
    logfile.close()

    with open(out_folder + "/finished.txt", "a") as f:
        finished = f"addr: {address}    name: {name} "
        # print(finished)
        f.write(finished)


pool = mp.Pool(processes=jobs)

print(
    f"Running inspectre analyze {binary} with {jobs} parallel jobs (output will be saved in {out_folder})")

run(entrypoints[0], with_timeout=False)
for _ in tqdm.tqdm(pool.imap_unordered(run, entrypoints[1:]), total=len(entrypoints)-1):
    pass
