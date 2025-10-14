"""
The Analysis Pipeline is responsible of:
1. Identify unique gadgets from found gadgets
2. Run analysis passes on each gadget
3. Output the gadgets
"""

import angr
import uuid
import os
import csv
from collections.abc import MutableMapping

from . import transmissionAnalysis, tfpAnalysis, halfGadgetAnalysis, secretDependentBranchAnalysis
from . import baseControlAnalysis, branchControlAnalysis, pathAnalysis, requirementsAnalysis, rangeAnalysis, bitsAnalysis, tfpAnalysis
from ..asmprinter.asmprinter import *
from ..shared.logger import *
from ..shared.transmission import *
from ..shared.halfGadget import HalfGadget
from ..shared.secretDependentBranch import SecretDependentBranch
from ..shared.utils import report_error
from ..shared.config import global_config


l = get_logger("AnalysisMAIN")
l_verbose = get_logger("Analysis")


class AnalysisPipeline:
    """
    Analyzes potential gadgets found by the scanner and outputs the final
    gadgets to the configured destinations.
    """

    # Name of the entrypoint to analyze (given by user)
    name: str
    # Entrypoint address
    gadget_address: int
    gadget_symbol: str
    proj: angr.Project
    # Output configurations
    asm_folder: str
    csv_filename: str
    tfp_csv_filename: str
    half_gadget_filename: str

    # Stats
    n_found_transmissions: int
    n_final_transmissions: int
    n_found_tainted_function_pointers: int
    n_final_tainted_function_pointers: int
    n_found_half_gadgets: int
    n_final_half_gadgets: int
    n_found_secret_dependent_branches: int
    n_final_secret_dependent_branches: int

    def __init__(self, name, gadget_address, proj, asm_folder, csv_filename, tfp_csv_filename, half_gadget_filename):
        self.name = name
        self.gadget_address = gadget_address
        self.proj = proj

        symbol = self.proj.loader.find_symbol(self.gadget_address, fuzzy=True)
        self.gadget_symbol = symbol.name if symbol else ""

        self.asm_folder = asm_folder
        self.csv_filename = csv_filename
        self.tfp_csv_filename = tfp_csv_filename
        self.half_gadget_filename = half_gadget_filename

        self.n_found_transmissions = 0
        self.n_final_transmissions = 0
        self.n_found_tainted_function_pointers = 0
        self.n_final_tainted_function_pointers = 0
        self.n_found_half_gadgets = 0
        self.n_final_half_gadgets = 0
        self.n_found_secret_dependent_branches = 0
        self.n_final_secret_dependent_branches = 0

    def analyze_transmission(self, potential_t: TransmissionExpr):

        self.n_found_transmissions += 1
        transmissions = transmissionAnalysis.get_transmissions(potential_t)

        for t in transmissions:
            l.info(f"Analyzing TRANS @{hex(t.pc)}: {truncate_str(t.transmission.expr)}")
            t.uuid = str(uuid.uuid4())
            t.name = self.name
            t.address = self.gadget_address
            pc_symbol = self.proj.loader.find_symbol(t.pc, fuzzy=True)
            t.pc_symbol = pc_symbol.name if pc_symbol else ""
            t.address_symbol = self.gadget_symbol
            baseControlAnalysis.analyse(t)
            pathAnalysis.analyse(t)
            requirementsAnalysis.analyse(t)

            try:
                rangeAnalysis.analyse(t)
            except Exception as e:
                if global_config['CrashOnExceptions']:
                    raise e
                # TODO: In very few instances, our range analysis fails. Instead of
                # interrupting the analysis right away, we want to continue to
                # the next gadget. There are many reasons why the range analysis
                # can fail, and some of them might be fixed.
                # However, since the number of errors we encountered is very low,
                # this has not been deemed to be a priority for now.
                l.critical("Range analysis error: bailing out")
                report_error(e, where="range_analysis", start_addr=hex(
                    self.gadget_address), error_type="RANGE")
                continue

            bitsAnalysis.analyse(t)
            branchControlAnalysis.analyse(t)

            # Remove the dependency graph before printing.
            t.properties["deps"] = None

            self.n_final_transmissions += 1
            l_verbose.info(t)

            if self.asm_folder != "":
                output_gadget_to_file(t, self.proj, self.asm_folder)
                l.info(f"Dumped annotated ASM to {self.asm_folder}")
            if self.csv_filename != "":
                append_to_csv(self.csv_filename, [t])
                l.info(f"Dumped properties to {self.csv_filename}")

    def analyze_tainted_function_pointer(self, t: TaintedFunctionPointer):

        self.n_found_tainted_function_pointers += 1
        tainted_function_pointers = tfpAnalysis.analyse(t)

        for tfp in tainted_function_pointers:
            l.info(f"Analyzing TFP @{hex(tfp.pc)}: {truncate_str(tfp.expr)}")
            tfp.uuid = str(uuid.uuid4())
            tfp.name = self.name
            tfp.address = self.gadget_address
            pc_symbol = self.proj.loader.find_symbol(tfp.pc, fuzzy=True)
            tfp.pc_symbol = pc_symbol.name if pc_symbol else ""
            tfp.address_symbol = self.gadget_symbol
            pathAnalysis.analyse_tfp(tfp)
            requirementsAnalysis.analyse_tfp(tfp)

            try:
                rangeAnalysis.analyse_tfp(tfp)
            except Exception as e:
                if global_config['CrashOnExceptions']:
                    raise e
                # TODO: In very few instances, our range analysis fails. Instead of
                # interrupting the analysis right away, we want to continue to
                # the next gadget. There are many reasons why the range analysis
                # can fail, and some of them might be fixed.
                # However, since the number of errors we encountered is very low,
                # this has not been deemed to be a priority for now.
                l.critical("Range analysis error: bailing out")
                report_error(e, where="range_analysis", start_addr=hex(
                    self.gadget_address), error_type="TFP RANGE")
                continue

            self.n_final_tainted_function_pointers += 1
            l_verbose.info(tfp)

            if self.asm_folder != "":
                output_tfp_to_file(tfp, self.proj, self.asm_folder)
                l.info(f"Dumped annotated ASM to {self.asm_folder}")
            if self.tfp_csv_filename != "":
                append_to_csv(self.tfp_csv_filename, [tfp])
                l.info(f"Dumped CSV to {self.tfp_csv_filename}")

    def analyze_half_gadget(self, gadget: HalfGadget):
        self.n_found_half_gadgets += 1
        gadgets = halfGadgetAnalysis.analyse(gadget)

        for g in gadgets:
            l.info(f"Analyzing half-spectre @{hex(g.pc)}: {truncate_str(g.loaded.expr)}")
            g.uuid = str(uuid.uuid4())
            g.name = self.name
            g.address = self.gadget_address
            pathAnalysis.analyse_half_gadget(g)
            requirementsAnalysis.analyse_half_gadget(g)

            try:
                rangeAnalysis.analyse_half_gadget(g)
            except Exception as e:
                if global_config['CrashOnExceptions']:
                    raise e
                # TODO: In very few instances, our range analysis fails. Instead of
                # interrupting the analysis right away, we want to continue to
                # the next gadget. There are many reasons why the range analysis
                # can fail, and some of them might be fixed.
                # However, since the number of errors we encountered is very low,
                # this has not been deemed to be a priority for now.
                l.critical("Range analysis error: bailing out")
                report_error(e, where="range_analysis", start_addr=hex(
                    self.gadget_address), error_type="HALF GADGET RANGE")

            self.n_final_half_gadgets += 1
            l_verbose.info(g)

            if self.asm_folder != "":
                output_half_gadget_to_file(g, self.proj, self.asm_folder)
                l.info(f"Dumped annotated ASM to {self.asm_folder}")
            if self.half_gadget_filename != "":
                append_to_csv(self.half_gadget_filename, [g])
                l.info(f"Dumped CSV to {self.half_gadget_filename}")

    def analyze_secret_dependent_branch(self, s: SecretDependentBranch):

        self.n_found_secret_dependent_branches += 1
        secret_dependent_branches = secretDependentBranchAnalysis.get_secret_dependent_branches(
            s)

        for sdb in secret_dependent_branches:
            l.info(
                f"Analyzing SDB   @{hex(sdb.pc)}: {truncate_str(sdb.sdb_expr)} <> {truncate_str(sdb.cmp_value.expr)}")
            sdb.uuid = str(uuid.uuid4())
            sdb.name = self.name
            sdb.address = self.gadget_address
            pc_symbol = self.proj.loader.find_symbol(sdb.pc, fuzzy=True)
            sdb.pc_symbol = pc_symbol.name if pc_symbol else ""
            sdb.address_symbol = self.gadget_symbol
            baseControlAnalysis.analyse_secret_dependent_branch(sdb)
            pathAnalysis.analyse(sdb)
            requirementsAnalysis.analyse_secret_dependent_branch(sdb)

            try:
                rangeAnalysis.analyze_secret_dependent_branch(sdb)
            except Exception as e:
                # TODO: In very few instances, our range analysis fails. Instead of
                # interrupting the analysis right away, we want to continue to
                # the next gadget. There are many reasons why the range analysis
                # can fail, and some of them might be fixed.
                # However, since the number of errors we encountered is very low,
                # this has not been deemed to be a priority for now.
                l.critical("Range analysis error: bailing out")
                report_error(e, where="range_analysis", start_addr=hex(
                    self.gadget_address), error_type="RANGE")
                continue

            bitsAnalysis.analyse(sdb)
            branchControlAnalysis.analyse(sdb)

            # Remove the dependency graph before printing.
            sdb.properties["deps"] = None

            self.n_final_secret_dependent_branches += 1
            l_verbose.info(sdb)

            if self.asm_folder != "":
                output_secret_dependent_branch_to_file(
                    sdb, self.proj, self.asm_folder)
                l.info(f"Dumped annotated ASM to {self.asm_folder}")
            if self.csv_filename != "":
                append_to_csv(self.csv_filename, [sdb])
            l.info(f"Dumped properties to {self.csv_filename}")


def flatten_dict(dictionary, parent_key='', separator='_'):
    """
    Transform a hierarchy of nested objects into a flat dictionary.
    """
    items = []
    for key, value in dictionary.items():
        new_key = parent_key + separator + key if parent_key else key
        if isinstance(value, MutableMapping):
            items.extend(flatten_dict(value, new_key,
                         separator=separator).items())
        else:
            items.append((new_key, value))
    return dict(items)


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
        writer = csv.DictWriter(outfile, fieldnames=keys, delimiter=';')
        if len(existing_keys) == 0:
            writer.writeheader()
        writer.writerows(flatten_dicts)
