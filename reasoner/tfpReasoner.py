import argparse
import pandas as pd
import numpy as np
from io import StringIO
import csv

from . import addressSpace

from warnings import simplefilter
simplefilter(action="ignore", category=pd.errors.PerformanceWarning)

MIN_REG_CONTROL_WINDOW = 0xffff

CACHE_SHIFT = 6
PAGE_SHIFT = 12
ADDRESS_BIT_LEN = 64

with_branches = False


def branch_suffix():
    """
    Suffix of the columns for the current analysis (with or without branches).
    """
    return "" if not with_branches else "_w_branches"


def range_column(prefix, field):
    """
    Name of a range column in the analyzer output, e.g.,
    range_column('rax_controlled', 'min') -> 'rax_controlled_range_with_branches_min'.
    """
    return f'{prefix}_range{"" if not with_branches else "_with_branches"}_{field}'


def is_in_range(n, min, max):
    if min <= max:
        return n >= min and n <= max
    else:
        return n >= min or n <= max


def get_pc_as_number(t: pd.Series):
    return str(int(t['pc'], 16))


def get_x86_registers():
    return ["rax", "rbx", "rcx", "rdx", "rsi",
            "rdi", "rbp", "rsp", "r8", "r9",
            "r10", "r11", "r12", "r13", "r14", "r15"]


def calc_reg_size(t: pd.Series, reg):
    if t[f'{reg}_expr'] == '':
        return 0
    try:
        assert (t[f'{reg}_expr'].startswith('<BV'))
    except:
        return 0
    return int(t[f'{reg}_expr'].split(' ')[0].replace('<BV', ''))


def eval_column_to_dict(t: pd.Series, column):

    lst = eval(t[column])
    assert (type(lst) == dict)

    return lst


# ----------------- Basic checks

def is_register_sufficiently_controlled(t: pd.Series, reg):

    if t[f"{reg}_control"] != "ControlType.CONTROLLED":
        return False

    if t[f"{reg}_control_type"] in [
            "TFPRegisterControlType.INDIRECTLY_DEPENDS_ON_TFP_EXPR",
            "TFPRegisterControlType.DEPENDS_ON_TFP_EXPR"]:
        return False

    # Workaround: Check if load-chain is not controlled:
    # For example:
    #   <BV64 LOAD [  LOAD_64[<BV64 0x32880 + gs>]
    #                 + (0#32 .. 0xffffffff & rdi[31:0]) ]
    if "gs" in t[f"{reg}_controlled_expr"]:
        return False

    # Check the range
    reg_min = t[range_column(f'{reg}_controlled', 'min')]
    reg_max = t[range_column(f'{reg}_controlled', 'max')]
    reg_window = t[range_column(f'{reg}_controlled', 'window')]

    if reg_window < MIN_REG_CONTROL_WINDOW:
        return False

    # Dereferenced registers (see get_indirect_offsets_*) have no size column
    if f'{reg}_size' in t:
        reg_size = t[f'{reg}_size']
    else:
        reg_size = calc_reg_size(t, reg)

    return addressSpace.range_overlaps_regions(reg_min, reg_max, reg_size,
                                               addressSpace.MAPPED_REGIONS)


def is_register_fully_controlled(t: pd.Series, reg):

    if not is_register_sufficiently_controlled(t, reg):
        return False

    # Check the range
    if t[f"{reg}_controlled_range_window"] < (2 ** t[f'{reg}_size']) - 1:
        return False

    return True


def get_indirect_offsets_sufficiently_controlled(t: pd.Series, reg):

    sufficiently_controlled = []

    for r_str, r_dict in t[f'{reg}_reg_dereferenced'].items():
        # add reg as prefix, expected by other functions
        if is_register_sufficiently_controlled(r_dict, r_str):
            sufficiently_controlled.append(r_str)

    return sufficiently_controlled


def get_indirect_offsets_fully_controlled(t: pd.Series, reg):

    sufficiently_controlled = []

    for r_str, r_dict in t[f'{reg}_reg_dereferenced'].items():
        # add reg as prefix, expected by other functions
        r_dict[f'{r_str}_size'] = calc_reg_size(r_dict, r_str)
        if is_register_fully_controlled(r_dict, r_str):
            sufficiently_controlled.append(r_str)

    return sufficiently_controlled


def get_sufficiently_controlled_registers(t: pd.Series, reg_type):
    controlled = []

    # Direct controlled registers (1 || 3)
    if reg_type & 1:
        for reg in get_x86_registers():
            if t['reg'] == reg:
                continue

            if t[f'{reg}_controlled_sufficiently{branch_suffix()}']:
                controlled.append(reg)

    # Indirect controlled registers (2 || 3)
    if reg_type & 2:
        for reg in get_x86_registers():
            if t['reg'] == reg:
                continue

            controlled += t[f'{reg}_controlled_sufficiently_indirect{branch_suffix()}']

    return controlled, len(controlled)


def get_fully_controlled_registers(t: pd.Series, reg_type):
    controlled = []

    # Direct controlled registers (1 || 3)
    if reg_type & 1:
        for reg in get_x86_registers():
            if t['reg'] == reg:
                continue

            if t[f'{reg}_controlled_fully']:
                controlled.append(reg)

    # Indirect controlled registers (2 || 3)
    if reg_type & 2:
        for reg in get_x86_registers():
            if t['reg'] == reg:
                continue

            controlled += t[f'{reg}_controlled_fully_indirect{branch_suffix()}']

    return controlled, len(controlled)


def get_tfp_control(t: pd.Series):

    reg = t['reg']

    if reg in get_x86_registers():
        controlled_sufficiently = t[f'{reg}_controlled_sufficiently{branch_suffix()}']
        controlled_fully = t[f'{reg}_controlled_fully{branch_suffix()}']

    else:
        # We might want to add controlled_range for tfp expr to do more
        # fine-grained
        if t[f"control"] != "ControlType.CONTROLLED" or "gs" in t[f"expr"]:
            controlled_sufficiently = False
            controlled_fully = False

        else:
            controlled_sufficiently = True
            controlled_fully = True

    return controlled_sufficiently, controlled_fully


# ----------------- Evaluation

def is_exploitable(t: pd.Series):

    fail_reasons = []
    exploitable = True

    if not t[f'control_sufficiently{branch_suffix()}']:
        fail_reasons.append(
            f'is_tfp_controlled_sufficiently{branch_suffix()}')
        exploitable = False

    return exploitable, fail_reasons


def add_extra_info(df):

    for reg in get_x86_registers():
        df[f'{reg}_controlled_sufficiently{branch_suffix()}'] = df.apply(
            is_register_sufficiently_controlled, axis=1, args=(reg,))
        df[f'{reg}_controlled_sufficiently_indirect{branch_suffix()}'] = df.apply(
            get_indirect_offsets_sufficiently_controlled, axis=1, args=(reg,))

    for reg in get_x86_registers():
        df[f'{reg}_controlled_fully{branch_suffix()}'] = df.apply(
            is_register_fully_controlled, axis=1, args=(reg,))
        df[f'{reg}_controlled_fully_indirect{branch_suffix()}'] = df.apply(
            get_indirect_offsets_fully_controlled, axis=1, args=(reg,))

    # Direct controlled registers (0)
    df[[f'controlled_sufficiently{branch_suffix()}',
        f'n_controlled_sufficiently{branch_suffix()}']] = df.apply(
            get_sufficiently_controlled_registers, axis=1, args=(1,),
            result_type="expand")
    df[[f'controlled_fully{branch_suffix()}',
        f'n_controlled_fully{branch_suffix()}']] = df.apply(
            get_fully_controlled_registers, axis=1, args=(1,),
            result_type='expand')

    # Indirect controlled registers (1)
    df[[f'controlled_sufficiently_indirect{branch_suffix()}',
        f'n_controlled_sufficiently_indirect{branch_suffix()}']] = df.apply(
            get_sufficiently_controlled_registers, axis=1, args=(2,),
            result_type="expand")
    df[[f'controlled_fully_indirect{branch_suffix()}',
        f'n_controlled_fully_indirect{branch_suffix()}']] = df.apply(
            get_fully_controlled_registers, axis=1, args=(2,),
            result_type='expand')

    # All controlled registers (2)
    df[[f'controlled_sufficiently_all{branch_suffix()}',
        f'n_controlled_sufficiently_all{branch_suffix()}']] = df.apply(
            get_sufficiently_controlled_registers, axis=1, args=(3,),
            result_type="expand")
    df[[f'controlled_fully_all{branch_suffix()}',
        f'n_controlled_fully_all{branch_suffix()}']] = df.apply(
            get_fully_controlled_registers, axis=1, args=(3,),
            result_type='expand')

    df[[f'control_sufficiently{branch_suffix()}',
        f'control_fully{branch_suffix()}'
        ]] = df.apply(get_tfp_control, axis=1, result_type="expand")


def run(in_csv, out_csv):
    global with_branches

    integer_cols = []

    for reg in get_x86_registers():
        for with_branches in [False, True]:
            integer_cols.append(range_column(reg, 'min'))
            integer_cols.append(range_column(reg, 'max'))
            integer_cols.append(range_column(reg, 'window'))
            integer_cols.append(range_column(reg, 'stride'))
            # integer_cols.append(range_column(reg, 'and_mask'))
            # integer_cols.append(range_column(reg, 'or_mask'))
            integer_cols.append(range_column(f'{reg}_controlled', 'min'))
            integer_cols.append(range_column(f'{reg}_controlled', 'max'))
            integer_cols.append(range_column(f'{reg}_controlled', 'window'))
            integer_cols.append(range_column(f'{reg}_controlled', 'stride'))
            # integer_cols.append(range_column(f'{reg}_controlled', 'and_mask'))
            # integer_cols.append(range_column(f'{reg}_controlled', 'or_mask'))

    file = open(in_csv, 'r')
    data = file.read()
    file.close()

    df_header = pd.read_csv(StringIO(data), delimiter=';')
    types_dict = {
        col: 'UInt64' if col in integer_cols else df_header[col].dtype.name
        for col in df_header}

    # Via this method we avoid pandas mixing types
    df = pd.read_csv(StringIO(data), delimiter=';', dtype=types_dict)

    print(f"[-] Imported {len(df)} gadgets")
    if df.empty:
        return

    # Transform columns.
    for i in integer_cols:
        df[i] = df[i].fillna(0)

    df['pc_as_int'] = df.apply(get_pc_as_number, axis=1)

    for reg in get_x86_registers():
        df[f'{reg}_size'] = df.apply(calc_reg_size, axis=1, args=(reg,))
        df[f'{reg}_reg_dereferenced'] = df.apply(
            eval_column_to_dict, axis=1, args=(f'{reg}_reg_dereferenced',))

    # --------------------------------------------------------------------------
    # Add results of exploitability analysis.
    with_branches = False

    print("[-] Enriching with extra info...")
    add_extra_info(df)

    print("[-] Performing exploitability analysis...")

    df[['exploitable', 'fail_reasons']] = df.apply(
        is_exploitable, axis=1, result_type="expand")

    print(f"   [+] Found {len(df[df['exploitable'] == True])} exploitable TFPs!")
    sufficiently = df[df['n_controlled_sufficiently'] >= 1]
    print(f"   [+] Found {len(sufficiently['pc'].unique())} (unique PCs) TFPs with at "
          "least one sufficiently controlled register!")
    print(f"   [+] Found {len(sufficiently['address'].unique())} (unique entry point) "
          "TFPs with at least one sufficiently controlled register!")

    # --------------------------------------------------------------------------
    # Add results of exploitability analysis considering branches.
    print("[-] Enriching with extra info including branch constraints...")
    with_branches = True

    add_extra_info(df)

    print("[-] Performing exploitability analysis with branches...")

    df[['exploitable_w_branches', 'fail_reasons_w_branches']] = df.apply(
        is_exploitable, axis=1, result_type="expand")

    n_exploitable = len(df[df['exploitable_w_branches'] == True])
    print(f"   [+] Found {n_exploitable} exploitable TFPs with branches!")
    sufficiently = df[df['n_controlled_sufficiently_w_branches'] >= 1]
    print(f"   [+] Found {len(sufficiently['pc'].unique())} (unique PCs) TFPs with at "
          "least one sufficiently controlled register!")
    print(f"   [+] Found {len(sufficiently['address'].unique())} (unique entry point) "
          "TFPs with at least one sufficiently controlled register!")

    # Save to new file.
    print(f"[-] Saving to {out_csv}")

    df.to_csv(out_csv, sep=';', index=False)

    print("[-] Done!")
