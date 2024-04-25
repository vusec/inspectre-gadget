"""
Entrypoint for the analysis component. The analyzer is responsible of:
1. Loading the target binary
2. Running the scanner to find potential transmission
3. Run analysis passes on each gadget
4. Collect and output results
"""

from collections import OrderedDict
import os
import yaml
import pickle
import angr
import csv
import uuid
import claripy.ast.base
from collections.abc import MutableMapping

from .scanner.scanner import Scanner
from .analysis import transmissionAnalysis, baseControlAnalysis, branchControlAnalysis, pathAnalysis, requirementsAnalysis, rangeAnalysis, bitsAnalysis, tfpAnalysis
from .shared.logger import *
from .shared.transmission import *
from .shared.config import *
from .shared.utils import report_error
from .asmprinter.asmprinter import *


l = get_logger("MAIN")
l_verbose = get_logger("MAIN_VERBOSE")

def flatten_dict(dictionary, parent_key='', separator='_'):
    """
    Transform a hierarchy of nested objects into a flat dictionary.
    """
    items = []
    for key, value in dictionary.items():
        new_key = parent_key + separator + key if parent_key else key
        if isinstance(value, MutableMapping):
            items.extend(flatten_dict(value, new_key, separator=separator).items())
        else:
            items.append((new_key, value))
    return dict(items)


def load_config(config_file):
    """
    Read the YAML configuration.
    """
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
    """
    Load angr project from a pickle, or create one if it does not exist.
    """
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
    """
    Output to a CSV, trying to preserve column order if the file is not empty.
    """

    # Read the CSV file to see if there are already existing entries.
    Path(os.path.dirname(csv_filename)).mkdir(parents=True, exist_ok=True)
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

        l_verbose.info(f"Missing keys: {set(existing_keys) - set(new_keys)}")
        l_verbose.info(f"New keys: {set(new_keys) - set(existing_keys)}")

        keys = existing_keys if len(existing_keys) > 0 else new_keys
        writer = csv.DictWriter(outfile, fieldnames = keys, delimiter=';')
        if len(existing_keys) == 0:
            writer.writeheader()
        writer.writerows(flatten_dicts)


def analyse_gadget(proj, gadget_address, name, config, csv_filename, tfp_csv_filename, asm_folder):
    """
    Run the scanner from a single entrypoint and analyze the potential transmissions
    found at symbolic-execution time.
    """

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
        l.info(f"Analyzing {t.transmission.expr}...")
        t.uuid = str(uuid.uuid4())
        t.name = name
        t.address = gadget_address
        baseControlAnalysis.analyse(t)
        pathAnalysis.analyse(t)
        requirementsAnalysis.analyse(t)

        try:
            rangeAnalysis.analyse(t)
        except Exception as e:
            # TODO: In very few instances, our range analysis fails. Instead of
            # interrupting the analysis right away, we want to continue to
            # the next gadget. There are many reasons why the range analysis
            # can fail, and some of them might be fixed.
            # However, since the number of errors we encountered is very low,
            # this has not been deemed to be a priority for now.
            l.critical("Range analysis error: bailing out")
            report_error(e, where="range_analysis", start_addr=hex(gadget_address), error_type="RANGE")
            continue

        bitsAnalysis.analyse(t)
        branchControlAnalysis.analyse(t)

        # Remove the dependency graph before printing.
        t.properties["deps"] = None
        l_verbose.info(t)

        if asm_folder != "":
            output_gadget_to_file(t, proj, asm_folder)
            l.info(f"Dumped annotated ASM to {asm_folder}")
        if csv_filename != "":
            append_to_csv(csv_filename, [t])
            l.info(f"Dumped properties to {csv_filename}")

    # Step 4. Analyze tainted function pointers.
    if global_config["TaintedFunctionPointers"]:
        l.info(f"--------------- ANALYZING TFPs ------------------")
        all_tfps = []
        for c in s.calls:
            all_tfps.extend(tfpAnalysis.analyse(c))

        if all_tfps: l.info(f"Extracted {len(all_tfps)} tfps.")

        for tfp in all_tfps:
            tfp.uuid = str(uuid.uuid4())
            tfp.name = name
            tfp.address = gadget_address
            pathAnalysis.analyse_tfp(tfp)
            requirementsAnalysis.analyse_tfp(tfp)

            try:
                rangeAnalysis.analyse_tfp(tfp)
            except Exception as e:
                # TODO: In very few instances, our range analysis fails. Instead of
                # interrupting the analysis right away, we want to continue to
                # the next gadget. There are many reasons why the range analysis
                # can fail, and some of them might be fixed.
                # However, since the number of errors we encountered is very low,
                # this has not been deemed to be a priority for now.
                l.critical("Range analysis error: bailing out")
                report_error(e, where="range_analysis", start_addr=hex(gadget_address), error_type="TFP RANGE")
                continue

            l_verbose.info(tfp)

            if asm_folder != "":
                output_tfp_to_file(tfp, proj, asm_folder)
                l.info(f"Dumped annotated ASM to {asm_folder}")
            if tfp_csv_filename != "":
                append_to_csv(tfp_csv_filename, [tfp])
                l.info(f"Dumped CSV to {tfp_csv_filename}")

def run(binary, config_file, base_address, gadgets, cache_project, csv_filename="", tfp_csv_filename="", asm_folder="", symbol_binary=""):
    """
    Run the analyzer on a binary.
    """

    # Simplify how symbols get printed.
    claripy.ast.base._unique_names = False

    config = load_config(config_file)

    if global_config["LogLevel"] == 0:
        disable_logging()
    elif global_config["LogLevel"] == 1:
        disable_logging(keep_main=True)

    # Prepare angr project.
    l.info("Loading angr project...")
    proj   = load_angr_project(binary, base_address, cache_project)

    if symbol_binary:
        l.info("Loading symbol binary...")
        symbol_proj = load_angr_project(symbol_binary, base_address, cache_project)

        proj.loader.all_objects[0]._symbol_cache = symbol_proj.loader.all_objects[0]._symbol_cache
        proj.loader.all_objects[0].symbols = symbol_proj.loader.all_objects[0].symbols
        proj.loader.all_objects[0]._symbols_by_name = symbol_proj.loader.all_objects[0]._symbols_by_name
        del symbol_proj

    # Run the Analyzer.
    # TODO: Parallelize.
    for g in gadgets:
        analyse_gadget(proj, g[0], g[1], config, csv_filename, tfp_csv_filename, asm_folder)
