"""
Entrypoint for the analysis component. The analyzer is responsible of:
1. Loading the target binary
2. Running the scanner to find potential gadgets
3. Run analyzer on each gadget (if not done during scanning)
"""

import yaml
import pickle
import angr
import claripy.ast.base
from cle import Symbol

from .scanner.scanner import Scanner
from .analysis.pipeline import AnalysisPipeline
from .shared.logger import *
from .shared.config import *
from .asmprinter.asmprinter import *


l = get_logger("MAIN")
l_verbose = get_logger("MAIN_VERBOSE")


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


def analyse_gadget(proj, gadget_address, name, csv_filename, tfp_csv_filename, asm_folder, half_gadget_filename):
    """
    Run the scanner from a single entrypoint and analyze the potential transmissions
    found at symbolic-execution time.
    """

    # Step 1. Initialize the analyzer
    analysis_pipeline = AnalysisPipeline(name=name, gadget_address=gadget_address, proj=proj,
                                         asm_folder=asm_folder, csv_filename=csv_filename,
                                         tfp_csv_filename=tfp_csv_filename,
                                         half_gadget_filename=half_gadget_filename)

    # Step 2. Analyze the code snippet with angr.
    l.info(f"Analyzing gadget at address {hex(gadget_address)}...")
    s = Scanner(analysis_pipeline=analysis_pipeline)
    s.run(proj, gadget_address)

    if global_config['TransmissionGadgets']:
        l.info(f"Found {len(s.transmissions)} potential transmissions.")
    if global_config['TaintedFunctionPointers']:
        l.info(f"Found {len(s.calls)} potential tainted function pointers.")
    if global_config['HalfSpectre']:
        l.info(f"Found {len(s.half_gadgets)} potential half-spectre gadgets.")
    if global_config['SecretDependentBranches']:
        l.info(
            f"Found {len(s.secretDependentBranches)} potential secret dependent branches.")

    # Step 3. Analyze found gadgets (if not analyzed during scanning)
    if not global_config['AnalyzeDuringScanning']:

        for t in s.transmissions:
            analysis_pipeline.analyze_transmission(t)

        for tfp in s.calls:
            analysis_pipeline.analyze_tainted_function_pointer(tfp)

        for half in s.half_gadgets:
            analysis_pipeline.analyze_half_gadget(half)

    if global_config['TransmissionGadgets']:
        l.info(
            f"Outputted {analysis_pipeline.n_final_transmissions} transmissions.")
    if global_config['TaintedFunctionPointers']:
        l.info(
            f"Outputted {analysis_pipeline.n_final_tainted_function_pointers} tainted function pointers.")
    if global_config['HalfSpectre']:
        l.info(
            f"Outputted {analysis_pipeline.n_final_half_gadgets} half-spectre gadgets.")
    if global_config['SecretDependentBranches']:
        l.info(
            f"Outputted {analysis_pipeline.n_final_secret_dependent_branches} secret dependent branches.")


def run(binary, config_file, base_address, gadgets, cache_project, csv_filename="", tfp_csv_filename="", asm_folder="", symbol_binary="", half_gadget_filename=""):
    """
    Run the analyzer on a binary.
    """

    # Simplify how symbols get printed.
    claripy.ast.base._unique_names = False

    load_config(config_file)

    if global_config["LogLevel"] == 0:
        disable_logging()
    elif global_config["LogLevel"] == 1:
        disable_logging(keep_main=True)

    # Prepare angr project.
    l.info("Loading angr project...")
    proj = load_angr_project(binary, base_address, cache_project)

    if symbol_binary:
        l.info("Loading symbol binary...")
        symbol_proj = load_angr_project(
            symbol_binary, base_address, cache_project)

        proj.loader.all_objects[0].symbols = symbol_proj.loader.all_objects[0].symbols
        proj.loader.all_objects[0]._symbols_by_name = symbol_proj.loader.all_objects[0]._symbols_by_name

        # This works for the Linux kernel binary, not tested on other inputs
        # Adding the symbols to the text object ensures that fuzzy search
        # using proj.loader.find_symbol() works
        text_obj = proj.loader.find_object_containing(base_address)

        if text_obj:
            for symbol in symbol_proj.loader.all_objects[0].symbols:
                if symbol.rebased_addr < text_obj.min_addr or\
                        symbol.rebased_addr > text_obj.max_addr:
                    continue

                relative_addr = symbol.relative_addr - \
                    text_obj.mapped_base + symbol.owner.mapped_base
                new_symbol = Symbol(owner=text_obj, name=symbol.name,
                                    relative_addr=relative_addr, size=symbol.size,
                                    sym_type=symbol._type)
                new_symbol.resolved = symbol.resolved
                new_symbol.resolvedby = symbol.resolvedby

                text_obj.symbols.add(new_symbol)

        del symbol_proj

    # Run the Analyzer.
    # TODO: Parallelize.
    for g in gadgets:
        analyse_gadget(proj, g[0], g[1], csv_filename,
                       tfp_csv_filename, asm_folder, half_gadget_filename)
