import argparse
import pandas as pd
import numpy as np
from io import StringIO
import csv


from warnings import simplefilter
simplefilter(action="ignore", category=pd.errors.PerformanceWarning)

MIN_REG_CONTROL_WINDOW = 0xffff

VALID_ADDRESS_MAX = 0xffffffff9fffffff
VALID_ADDRESS_MIN = 0xffff800000000000

MAPPED_REGIONS = [
    (0xffffffff81000000, 0xffffffff84000000),
    (0xffff888000000000, 0xffffc87fffffffff)
]

CANONICAL_REGIONS = [
    (0x0000000000000000, 0x00007fffffffffff),
    (0xffff800000000000, 0xffffffff9fffffff)
]

CACHE_SHIFT = 6
PAGE_SHIFT = 12
ADDRESS_BIT_LEN = 64

with_branches = False

def is_in_range(n, min, max):
    if min <= max:
        return n >= min and n <= max
    else:
        return n >= min or n <= max

def is_overlapping(x_min, x_max, y_min, y_max):
    return x_max >= y_min and y_max >= x_min


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

    if t[f"{reg}_control_type"] in ["TFPRegisterControlType.INDIRECTLY_DEPENDS_ON_TFP_EXPR", "TFPRegisterControlType.DEPENDS_ON_TFP_EXPR"]:
        return False

    # Workaround: Check if load-chain is not controlled:
    # For example: <BV64 LOAD [  LOAD_64[<BV64 0x32880 + gs>]  + (0#32 .. 0xffffffff & rdi[31:0]) ]
    if "gs" in t[f"{reg}_controlled_expr"]:
        return False

    # Check the range
    reg_min = t[f'{reg}_controlled_range{"" if not with_branches else "_with_branches"}_min']
    reg_max = t[f'{reg}_controlled_range{"" if not with_branches else "_with_branches"}_max']
    reg_window = t[f'{reg}_controlled_range{"" if not with_branches else "_with_branches"}_window']

    if reg_window < MIN_REG_CONTROL_WINDOW:
        return False

    for r in MAPPED_REGIONS:
        if reg_min <= reg_max:
            if not is_overlapping(reg_min, reg_max, r[0], r[1]):
                return False
        elif not (is_overlapping(0, reg_max, r[0], r[1]) or
                  is_overlapping(reg_min, (2 ** t[f'{reg}_size']) - 1, r[0], r[1])):
            return False

    return True

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

            if t[f'{reg}_controlled_sufficiently{"" if not with_branches else "_w_branches"}']:
                controlled.append(reg)

    # Indirect controlled registers (2 || 3)
    if reg_type & 2:
        for reg in get_x86_registers():
            if t['reg'] == reg:
                continue

            controlled += t[f'{reg}_controlled_sufficiently_indirect{"" if not with_branches else "_w_branches"}']

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

            controlled += t[f'{reg}_controlled_fully_indirect{"" if not with_branches else "_w_branches"}']

    return controlled, len(controlled)

def get_tfp_control(t: pd.Series):

    reg = t['reg']

    if reg in get_x86_registers():
        controlled_sufficiently = t[f'{reg}_controlled_sufficiently{"" if not with_branches else "_w_branches"}']
        controlled_fully = t[f'{reg}_controlled_fully{"" if not with_branches else "_w_branches"}']

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

    if not t[f'control_sufficiently{"" if not with_branches else "_w_branches"}']:
        fail_reasons.append(
            f'is_tfp_controlled_sufficiently{"" if not with_branches else "_w_branches"}')
        exploitable = False

    controlled = eval(t['controlled'])

    if t['reg'] in controlled:
        if len(controlled) == 1:
            fail_reasons.append(
                f'has_extra_controlled_registers{"" if not with_branches else "_w_branches"}')
            exploitable = False
    else:
        if len(controlled) == 0:
            fail_reasons.append(
                f'has_extra_controlled_registers{"" if not with_branches else "_w_branches"}')
            exploitable = False

    return exploitable, fail_reasons


def add_extra_info(df):

    for reg in get_x86_registers():
        df[f'{reg}_controlled_sufficiently{"" if not with_branches else "_w_branches"}'] = df.apply(
            is_register_sufficiently_controlled, axis=1, args=(reg,))
        df[f'{reg}_controlled_sufficiently_indirect{"" if not with_branches else "_w_branches"}'] = df.apply(
            get_indirect_offsets_sufficiently_controlled, axis=1, args=(reg,))

    for reg in get_x86_registers():
        df[f'{reg}_controlled_fully{"" if not with_branches else "_w_branches"}'] = df.apply(
            is_register_fully_controlled, axis=1, args=(reg,))
        df[f'{reg}_controlled_fully_indirect{"" if not with_branches else "_w_branches"}'] = df.apply(
            get_indirect_offsets_fully_controlled, axis=1, args=(reg,))

    # Direct controlled registers (0)
    df[[f'controlled_sufficiently{"" if not with_branches else "_w_branches"}',
       f'n_controlled_sufficiently{"" if not with_branches else "_w_branches"}']] = df.apply(get_sufficiently_controlled_registers, axis=1, args=(1,), result_type="expand")
    df[[f'controlled_fully{"" if not with_branches else "_w_branches"}',
       f'n_controlled_fully{"" if not with_branches else "_w_branches"}']] = df.apply(get_fully_controlled_registers, axis=1, args=(1,), result_type='expand')

    # Indirect controlled registers (1)
    df[[f'controlled_sufficiently_indirect{"" if not with_branches else "_w_branches"}',
       f'n_controlled_sufficiently_indirect{"" if not with_branches else "_w_branches"}']] = df.apply(get_sufficiently_controlled_registers, axis=1, args=(2,), result_type="expand")
    df[[f'controlled_fully_indirect{"" if not with_branches else "_w_branches"}',
       f'n_controlled_fully_indirect{"" if not with_branches else "_w_branches"}']] = df.apply(get_fully_controlled_registers, axis=1, args=(2,), result_type='expand')

    # All controlled registers (2)
    df[[f'controlled_sufficiently_all{"" if not with_branches else "_w_branches"}',
       f'n_controlled_sufficiently_all{"" if not with_branches else "_w_branches"}']] = df.apply(get_sufficiently_controlled_registers, axis=1, args=(3,), result_type="expand")
    df[[f'controlled_fully_all{"" if not with_branches else "_w_branches"}',
       f'n_controlled_fully_all{"" if not with_branches else "_w_branches"}']] = df.apply(get_fully_controlled_registers, axis=1, args=(3,), result_type='expand')

    df[[f'control_sufficiently{"" if not with_branches else "_w_branches"}',
        f'control_fully{"" if not with_branches else "_w_branches"}'
        ]] = df.apply(get_tfp_control, axis=1, result_type="expand")


def run(in_csv, out_csv):
    global with_branches

    integer_cols = []

    for reg in get_x86_registers():
        for with_branches in [False, True]:
            integer_cols.append(
                f'{reg}_range{"" if not with_branches else "_with_branches"}_min')
            integer_cols.append(
                f'{reg}_range{"" if not with_branches else "_with_branches"}_max')
            integer_cols.append(
                f'{reg}_range{"" if not with_branches else "_with_branches"}_window')
            integer_cols.append(
                f'{reg}_range{"" if not with_branches else "_with_branches"}_stride')
            # integer_cols.append(f'{reg}_range{"" if not with_branches else "_with_branches"}_and_mask')
            # integer_cols.append(f'{reg}_range{"" if not with_branches else "_with_branches"}_or_mask')
            integer_cols.append(
                f'{reg}_controlled_range{"" if not with_branches else "_with_branches"}_min')
            integer_cols.append(
                f'{reg}_controlled_range{"" if not with_branches else "_with_branches"}_max')
            integer_cols.append(
                f'{reg}_controlled_range{"" if not with_branches else "_with_branches"}_window')
            integer_cols.append(
                f'{reg}_controlled_range{"" if not with_branches else "_with_branches"}_stride')
            # integer_cols.append(f'{reg}_controlled_range{"" if not with_branches else "_with_branches"}_and_mask')
            # integer_cols.append(f'{reg}_controlled_range{"" if not with_branches else "_with_branches"}_or_mask')

    # Replace 'None' with 0
    # TODO: Hack, we should adjust the analyzer output.
    file = open(in_csv, 'r')
    data = file.read()
    file.close()

    df_header = pd.read_csv(StringIO(data), delimiter=';')
    types_dict = {
        col: 'UInt64' if col in integer_cols else df_header[col].dtype.name for col in df_header}

    # Fixes bug before commit "[ranges] Bail out if stride overflows at infer-isolated"
    # "40c486caa400901239e0c6e5b12544da59879c8e" (inspectre-gadget)
    for reg in get_x86_registers():
        for with_branches in [False, True]:
            values = list(
                df_header[f'{reg}_range{"" if not with_branches else "_with_branches"}_stride'].unique())
            values += list(
                df_header[f'{reg}_controlled_range{"" if not with_branches else "_with_branches"}_stride'].unique())

            for v in values:
                try:
                    np.uint64(v)
                except OverflowError as e:
                    print(
                        f"OverflowError for stride {reg}, replacing '{v}' by '1'")
                    data = data.replace(v, '1')

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

    print(
        f"   [+] Found {len(df[df['exploitable'] == True])} exploitable TFPs!")
    print(f"   [+] Found {len(df[df['n_controlled_sufficiently'] >= 1]['pc'].unique())} (unique PCs) TFPs with at least one sufficiently controlled register!")
    print(f"   [+] Found {len(df[df['n_controlled_sufficiently'] >= 1]['address'].unique())} (unique entry point) TFPs with at least one sufficiently controlled register!")

    # --------------------------------------------------------------------------
    # Add results of exploitability analysis considering branches.
    print("[-] Enriching with extra info including branch constraints...")
    with_branches = True

    add_extra_info(df)

    print("[-] Performing exploitability analysis with branches...")

    df[['exploitable_w_branches', 'fail_reasons_w_branches']] = df.apply(
        is_exploitable, axis=1, result_type="expand")

    print(
        f"   [+] Found {len(df[df['exploitable_w_branches'] == True])} exploitable TFPs with branches!")
    print(f"   [+] Found {len(df[df['n_controlled_sufficiently_w_branches'] >= 1]['pc'].unique())} (unique PCs) TFPs with at least one sufficiently controlled register!")
    print(f"   [+] Found {len(df[df['n_controlled_sufficiently_w_branches'] >= 1]['address'].unique())} (unique entry point) TFPs with at least one sufficiently controlled register!")

    # Save to new file.
    print(f"[-] Saving to {out_csv}")

    df.to_csv(out_csv, sep=';', index=False)

    print("[-] Done!")
