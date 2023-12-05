#!/usr/bin/python3

from collections import OrderedDict
import os
import yaml
import argparse
import pickle
import angr
import csv
import uuid
import claripy.ast.base
from collections.abc import MutableMapping

from scanner.scanner import Scanner
from analysis import transmissionAnalysis, baseControlAnalysis, branchControlAnalysis, pathAnalysis, requirementsAnalysis, rangeAnalysis, bitsAnalysis, tfpAnalysis
from shared.logger import *
from shared.transmission import *
from shared.config import *
from shared.utils import report_error
from asmprinter.asmprinter import *


l = get_logger("MAIN")

def flatten_dict(dictionary, parent_key='', separator='_'):
    items = []
    for key, value in dictionary.items():
        new_key = parent_key + separator + key if parent_key else key
        if isinstance(value, MutableMapping):
            items.extend(flatten_dict(value, new_key, separator=separator).items())
        else:
            items.append((new_key, value))
    return dict(items)

def parse_gadget_list(filename):
    file = open(filename, "r")
    data = list(csv.reader(file, delimiter=","))
    file.close()

    if len(data[0]) != 2:
        l.critical("Invalid CSV: gadgets should be in the form of <hex_address>,<name")
        exit(-1)

    return data


def remove_memory_sections(proj: angr.Project):
    # We always remove remove the writeable segments to prevent
    # initialized concrete values (zeros) while they should be symbolic.

    # Get the start addresses of segments to remove
    start_addresses = []

    for segment in proj.loader.main_object.segments:
        if segment.is_writable:
            start_addresses.append(segment.min_addr)

    # Remove segment backers
    # TODO: Uncertain if this method works for all binaries
    for addr in start_addresses:
        for start, backer in proj.loader.memory._backers:
            if addr >= start and addr < backer.max_addr:
                backer.remove_backer(addr)
                break


def load_config(config_file):
    if config_file:
        with open(config_file, "r") as f:
            config = yaml.safe_load(f)
        if not ('controlled_registers' in config or 'controlled_stack' in config):
            l.critical("Invalid config file!")
    else:
        l.info("No config provided, using default config")
        config = {'controlled_registers': ['rax', 'rbx', 'rdi', 'rsi', 'rdx',
                                           'rcx', 'r8', 'r9', 'r10', 'r11',
                                           'r12', 'r13', 'r14', 'r15']}

    init_config(config)
    return config


def load_angr_project(binary_file: str, base_address, use_pickle) -> angr.Project:
    if use_pickle:
        pickle_file = binary_file + '.angr'

        try:
            f = open(pickle_file, "rb")
            proj = pickle.load(f)
        except:
            proj = angr.Project(
                binary_file, auto_load_libs=False, main_opts={"base_addr": base_address})
            f = open(pickle_file, "wb")
            pickle.dump(proj, f)
            f.close()
    else:
        proj = angr.Project(
            binary_file, auto_load_libs=False, main_opts={"base_addr": base_address})

    return proj


def append_to_csv(csv_filename, transmissions):
    # Read the CSV file to see if there are already existing entries.
    existing_keys = []
    try:
        if os.stat(csv_filename).st_size > 0:
            o = open(csv_filename, "r")
            line = o.readline()
            existing_keys = line.replace('\n', '').split(';')
            # l.info(f"Got columns from existing file: {existing_keys}")
            o.close()
    except:
        existing_keys = []


    # Append transmissions to the csv.
    with open(csv_filename, "a+") as outfile:
        flatten_dicts = []
        new_keys = set()

        for t in transmissions:
            if isinstance(t, Transmission):
                t.properties["deps"] = None
            new_d = flatten_dict(t.to_dict())
            flatten_dicts.append(new_d)
            new_keys = (list(new_d.keys()))

        l.info(f"Missing keys: {set(existing_keys) - set(new_keys)}")
        l.info(f"New keys: {set(new_keys) - set(existing_keys)}")

        keys = existing_keys if len(existing_keys) > 0 else new_keys
        writer = csv.DictWriter(outfile, fieldnames = keys, delimiter=';')
        if len(existing_keys) == 0:
            writer.writeheader()
        writer.writerows(flatten_dicts)


def analyse_gadget(proj, gadget_address, name, config, csv_filename, tfp_csv_filename, asm_folder):
    # Step 1. Analyze the code snippet with angr.
    l.info(f"Analyzing gadget at address {hex(gadget_address)}...")
    s = Scanner()
    s.run(proj, gadget_address, config)
    l.info(f"Found {len(s.transmissions)} potential transmissions.")
    l.info(f"Found {len(s.calls)} tainted function pointers.")

    # Step 2. Identify unique transmissions.
    transmissions = []
    for t in s.transmissions:
        transmissions.extend(transmissionAnalysis.get_transmissions(t))
    l.info(f"Extracted {len(transmissions)} transmissions.")

    # Step 3. Analyze each transmission.
    l.info(f"--------------- ANALYZING TRANSMISSIONS ------------------")
    for t in transmissions:
        t.uuid = str(uuid.uuid4())
        t.name = name
        t.address = gadget_address
        baseControlAnalysis.analyse(t)
        pathAnalysis.analyse(t)
        requirementsAnalysis.analyse(t)
        rangeAnalysis.analyse(t)
        bitsAnalysis.analyse(t)
        branchControlAnalysis.analyse(t)

        # Remove the dependency graph before printing.
        t.properties["deps"] = None
        l.info(t)

        if asm_folder != "":
            output_gadget_to_file(t, proj, name, asm_folder)
        if csv_filename != "":
            append_to_csv(csv_filename, [t])


    # Step 4. Analyze tainted function pointers.
    if global_config["TaintedFunctionPointers"]:
        l.info(f"--------------- ANALYZING TFPs ------------------")
        all_tfps = []
        for c in s.calls:
            all_tfps.extend(tfpAnalysis.analyse(c))
        for tfp in all_tfps:
            tfp.uuid = str(uuid.uuid4())
            tfp.name = name
            tfp.address = gadget_address
            pathAnalysis.analyse_tfp(tfp)
            requirementsAnalysis.analyse_tfp(tfp)
            rangeAnalysis.analyse_tfp(tfp)
            l.info(tfp)

            if asm_folder != "":
                output_tfp_to_file(tfp, proj, name, asm_folder)
            if tfp_csv_filename != "":
                append_to_csv(tfp_csv_filename, [tfp])


def main(binary, cache_project, config_file, base_address, gadgets, csv_filename="", tfp_csv_filename="", asm_folder=""):
    # Simplify how symbols get printed.
    claripy.ast.base._unique_names = False

    # Prepare angr project.
    l.info("Loading angr project...")
    config = load_config(config_file)
    proj   = load_angr_project(binary, base_address, cache_project)

    l.info("Removing non-writable memory...")
    remove_memory_sections(proj)

    if not global_config["EnableLogging"]:
        disable_logging()

    # Run the Analyzer.
    # TODO: Parallelize.
    for g in gadgets:
        analyse_gadget(proj, g[0], g[1], config, csv_filename, tfp_csv_filename, asm_folder)


if __name__ == '__main__':
    arg_parser = argparse.ArgumentParser(description='An analyzer for Spectre gadgets.')

    arg_parser.add_argument('binary')
    arg_parser.add_argument('--cache-project', action='store_true')
    arg_parser.add_argument('--config', type=str, required=True)
    arg_parser.add_argument('--base-address', required=False, default="")
    arg_parser.add_argument('--gadget-address', required=False, default="")
    arg_parser.add_argument('--gadgets-file', required=False, default="")
    # Outputs.
    arg_parser.add_argument('--csv', required=False, default="")
    arg_parser.add_argument('--tfp-csv', required=False, default="")
    arg_parser.add_argument('--asm', required=False, default="")

    args = arg_parser.parse_args()

    gadgets = []

    # Check if we are looking for one or more than one gadget.
    if args.gadgets_file == "" and args.gadget_address == "":
        # No gadget address or gadget file: use default.
        gadgets = [["0x400000", args.binary]]
        print(f"Assuming gadget address: 0x400000")
    elif args.gadgets_file != "" and args.gadget_address != "":
        # Both gadget address and gadget file defined" error.
        print("Use only one between '--gadget-address' (specify only one address) and '--gadget-file' (provide a CSV with a list of addresses)")
        exit()

    elif args.gadget_address != "":
        gadgets = [[args.gadget_address, args.binary]]
    elif args.gadgets_file != "":
        gadgets = parse_gadget_list(args.gadgets_file)

    # Base address is by default the address of the first gadget.
    if args.base_address == "":
        args.base_address = int(gadgets[0][0], 16)
    else:
        args.base_address = int(args.base_address, 16)

    # Call main.
    parsed_gadgets = [[int(x[0], 16), str(x[1]).strip()] for x in gadgets]
    main(args.binary, args.cache_project, args.config, args.base_address, parsed_gadgets, args.csv, args.tfp_csv, args.asm)
