import argparse
import pandas as pd
import numpy as np

# Number of bits of the secret that are used in the transmission.
# E.g.     BASE + (SECRET & 0xf) has 4 inferable bits
#          BASE + (SECRET ^ SECRET) has 0 inferable bits
MIN_INFERABLE_BITS = 1

MIN_BASE_WINDOW = 0
MIN_SECRET_ADDRESS_WINDOW = 0xffff

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

MAX_ENTROPY = 16

with_branches = False

def is_in_range(n, min, max):
    if min <= max:
        return n >= min and n <= max
    else:
        return n >= min or n <= max

def is_overlapping(x_min, x_max, y_min, y_max):
    return x_max >= y_min and y_max >= x_min

def calc_base_size(t: pd.Series):
    if t['base_control'] == 'BaseControlType.NO_BASE' or pd.isna(t['base_expr']):
        return 0

    assert(t['base_expr'].startswith('<BV'))
    return int(t['base_expr'].split(' ')[0].replace('<BV',''))

def calc_transmitted_secret_size(t: pd.Series):
    assert(t['transmitted_secret_expr'].startswith('<BV'))
    return int(t['transmitted_secret_expr'].split(' ')[0].replace('<BV',''))


def get_pc_as_number(t: pd.Series):
    return str(int(t['pc'], 16))

# ----------------- Basic checks

def is_secret_inferable(t : pd.Series):
    """
    Check if the transmission is able to transmit a significant portion of
    the secret.
    """
    return t['inferable_bits_n_inferable_bits'] >= MIN_INFERABLE_BITS

def has_valid_base(t : pd.Series):
    """
    Check if the base can point to a valid address
    """
    base_min = t[f'base_range{"" if not with_branches else "_w_branches"}_min']
    base_max = t[f'base_range{"" if not with_branches else "_w_branches"}_max']

    for r in MAPPED_REGIONS:
        if base_min <= base_max:
            if is_overlapping(base_min, base_max, r[0], r[1]):
                return True
        elif is_overlapping(0, base_max, r[0], r[1]) or (
               is_overlapping(base_min, (2 ** t['base_size']) - 1, r[0], r[1])):
                return True

    return False

def has_valid_secret_address(t : pd.Series):
    """
    Check if the secret address can be adjusted to a valid address and the
    attacker has enough control over it.
    """
    if t[f'secret_address_control'] != 'ControlType.CONTROLLED':
        return False

    if t[f'secret_address_range{"" if not with_branches else "_w_branches"}_window'] < MIN_SECRET_ADDRESS_WINDOW:
        return False

    addr_min = t[f'secret_address_range{"" if not with_branches else "_w_branches"}_min']
    addr_max = t[f'secret_address_range{"" if not with_branches else "_w_branches"}_max']

    if addr_min <= addr_max:
        if addr_min > VALID_ADDRESS_MAX or addr_max < VALID_ADDRESS_MIN:
            return False
    else:
        if addr_min > VALID_ADDRESS_MAX and addr_max < VALID_ADDRESS_MIN:
            return False

    return True

def is_cmove_independent_from_secret(t: pd.Series):
    return t['cmove_control_type'] == 'BranchControlType.BRANCH_INDEPENDENT_FROM_SECRET'

def has_no_speculation_stop(t : pd.Series):
    return t['contains_spec_stop'] == False

# ----------------- Imperfect gadget checks

def is_secret_below_cache_granularity(t : pd.Series):
    """
    Check if there is at least one byte of the secret that is being transmitted
    above cache line granularity.
    If not, we need to apply the sliding technique.
    """
    return t['inferable_bits_spread_low'] < CACHE_SHIFT and t['inferable_bits_spread_high'] < (CACHE_SHIFT + 8)

def is_secret_entropy_high(t : pd.Series):
    """
    Check if the number of bits of the secret that are alive in the transmission
    is too high. This can happen e.g. when a gadget lacks the "masking" step
    that is generally required for a perfect gadget.
    """
    secret_entropy = min(t['inferable_bits_spread_total'], t['inferable_bits_n_inferable_bits'])
    return secret_entropy > MAX_ENTROPY

def is_max_secret_too_high(t : pd.Series, only_independent: bool = False):
    """
    Check if the maximum value of the secret would make the transmission fall
    outside of the address space (therefore inhibiting the signal that the
    attacker wants to retrieve).
    """

    if t[f'has_valid_base'] == False:
        # This check is redundant without a valid base
        return False

    if only_independent:
        base_min = t[f'independent_base_range{"" if not with_branches else "_w_branches"}_min']
        base_max = t[f'independent_base_range{"" if not with_branches else "_w_branches"}_max']
    else:
        base_min = t[f'base_range{"" if not with_branches else "_w_branches"}_min']
        base_max = t[f'base_range{"" if not with_branches else "_w_branches"}_max']

    secret_min = t[f'transmitted_secret_range{"" if not with_branches else "_w_branches"}_min']
    secret_max = t[f'transmitted_secret_range{"" if not with_branches else "_w_branches"}_max']

    # Get the transmitted secret maximum.
    if secret_min <= secret_max:
        valid_secret_max = secret_max
    else:
        valid_secret_max = (2 ** t['transmitted_secret_size']) - 1

    for r in MAPPED_REGIONS:

        if base_min <= base_max:
            valid_min = max(base_min, r[0])
        else:
            # If we are here, we have a range that wraps around.
            if r[0] < base_max or r[0] > base_min:
                # Case 1: VALID_ADDRESS_MIN is inside the range: use that.
                valid_min = r[0]
            else:
                # Case 2: VALID_ADDRESS_MIN is outside the range - between
                # base_max and base_min -. so first valid value is base_min
                valid_min = base_min

        if valid_min + valid_secret_max <= r[1]:
            return False

    return True

def base_has_direct_secret_dependency(t: pd.Series):
    return t['base_control_type'] == 'BaseControlType.BASE_DEPENDS_ON_SECRET_ADDR'

def base_has_indirect_secret_dependency(t: pd.Series):
    return t['base_control_type'] == 'BaseControlType.BASE_INDIRECTLY_DEPENDS_ON_SECRET_ADDR'

def is_base_uncontrolled(t : pd.Series):
    return t['base_control'] != 'ControlType.CONTROLLED'

def is_branch_dependent_from_secret(t: pd.Series):
    return t['branch_control_type'] == 'BranchControlType.BRANCH_DEPENDS_ON_SECRET_ADDRESS' or t['branch_control_type'] == 'BranchControlType.BRANCH_DEPENDS_ON_SECRET_VALUE'

def is_branch_dependent_from_uncontrolled(t: pd.Series):
    return t['branch_control_type'] == 'BranchControlType.BRANCH_DEPENDS_ON_UNCONTROLLED'

# ----------------- Transformations

def _has_valid_independent_base(t : pd.Series):
    """
    Check if the independent part of the base can point to a valid address
    """
    base_min = t[f'independent_base_range{"" if not with_branches else "_w_branches"}_min']
    base_max = t[f'independent_base_range{"" if not with_branches else "_w_branches"}_max']

    for r in MAPPED_REGIONS:
        if base_min <= base_max:
            if is_overlapping(base_min, base_max, r[0], r[1]):
                return True
        elif is_overlapping(0, base_max, r[0], r[1]) or (
               is_overlapping(base_min, (2 ** t['independent_base_size']) - 1, r[0], r[1])):
                return True

    return False

def transform_partial_control_into_aliasing(t : pd.Series):
    """
    In some cases, the amount of control we have on the base independently
    from the secret address might be too small. In these cases, we must treat
    the transmission as having a strong dependency with the secret address, even
    if the ast has some independently controllable components.

    Take the following example:
    ```
    rdi[31:0] + rsi + LOAD32[rsi + 0x28]
    ```

    Where`rdi[31:0] + rsi` is the transmission base. In this case, the base
    technically can be controlled independently from the secret, but the
    amount of control we have is limited (32 bits of RDI).
    """

    if _has_valid_independent_base(t):
        return t['base_control_type']

    if not pd.isna(t['indirect_dependent_base_expr']):
        return 'BaseControlType.BASE_INDIRECTLY_DEPENDS_ON_SECRET_ADDR'

    if not pd.isna(t['direct_dependent_base_expr']):
        return 'BaseControlType.BASE_DEPENDS_ON_SECRET_ADDR'

    return t['base_control_type']

# ----------------- Techniques to overcome gadget imperfections

def can_perform_sliding(t : pd.Series):
    """
    Check if we have enough control over the least significant bits of the
    base. If we can adjust these bits, and are able to make the transmission
    happen at a page boundary, we can observe a signal even if the secret
    bits are below cache-line granularity
    """
    if t[f'base_control'] != 'ControlType.CONTROLLED':
        return False

    return t[f'independent_base_range{"" if not with_branches else "_w_branches"}_stride'] <= 2**t['inferable_bits_spread_low'] and t[f'independent_base_range{"" if not with_branches else "_w_branches"}_window'] >= 4096

def can_perform_known_prefix(t : pd.Series):
    """
    If we can adjust the secret address with enough precision and independently
    from the base, we can adjust the transmission to first read some known
    bytes before the secret, and then increasing the secret address until
    we reach the secret.
    """
    if t[f'secret_address_control'] != 'ControlType.CONTROLLED':
        return False

    # TODO: should we check the secret address window also?
    return  t[f'secret_address_range{"" if not with_branches else "_w_branches"}_stride'] <= MAX_ENTROPY and t[f'secret_address_range{"" if not with_branches else "_w_branches"}_stride'] <= MAX_ENTROPY

def can_adjust_base(t : pd.Series):
    """
    Check if we have enough control of the base to overflow the transmission
    address in case the secret is too high.
    """
    if t[f'base_control'] != 'ControlType.CONTROLLED':
        return False

    base_controllable_window = t[f'independent_base_range{"" if not with_branches else "_w_branches"}_window']
    secret_max = t[f'transmitted_secret_range{"" if not with_branches else "_w_branches"}_max']


    for r in MAPPED_REGIONS:
        # We assume the attacker can subtract the window from a valid address.
        # it is an approximation, but good enough
        valid_min = r[0] - base_controllable_window if r[0] > base_controllable_window else 0

        # First see if we can simple take a low base
        if valid_min + secret_max <= r[1]:
            return True

        # If not, check if we can overflow
        if base_controllable_window > r[0] and (
           secret_max + base_controllable_window - (2 ** ADDRESS_BIT_LEN) >= r[0]):
            return True

    return False


def can_ignore_direct_dependency(t : pd.Series):
    """
    For gadgets where the base address depends on the secret address, check if
    we need to modify the base independently from the secret.
    If not, we can safely ignore the dependency between the base and the secret
    address.
    """
    if _has_valid_independent_base(t):
        return True
    else:
        return not (is_secret_below_cache_granularity(t) or is_max_secret_too_high(t, only_independent=True))

def perform_training(t: pd.Series):
    return True

def perform_out_of_place_training(t: pd.Series):
    return True

def leak_secret_near_valid_base(t: pd.Series):
    return True

# ----------------- Evaluation

basic_checks = [is_secret_inferable,
                has_valid_base,
                has_valid_secret_address,
                is_cmove_independent_from_secret,
                has_no_speculation_stop
                ]

transformations = [transform_partial_control_into_aliasing]

advanced_checks = [
                    {'problem': is_secret_below_cache_granularity, 'solution': can_perform_sliding},
                    {'problem': is_secret_entropy_high, 'solution': can_perform_known_prefix},
                    {'problem': is_max_secret_too_high, 'solution': can_adjust_base},
                    {'problem': base_has_indirect_secret_dependency, 'solution': leak_secret_near_valid_base},
                    {'problem': base_has_direct_secret_dependency, 'solution': can_ignore_direct_dependency},
                    {'problem': is_branch_dependent_from_secret, 'solution': perform_training},
                    {'problem': is_branch_dependent_from_uncontrolled, 'solution': perform_out_of_place_training},
                  ]


def is_exploitable(t : pd.Series):
    exploitable = True

    fail_reasons = []
    required_solutions = []

    for b in basic_checks:
        if not b(t):
            exploitable = False
            fail_reasons.append(b.__name__)

    for c in advanced_checks:
        if t[f'{c["problem"].__name__}{"" if not with_branches else "_w_branches"}']:

            if t[f'{c["solution"].__name__}{"" if not with_branches else "_w_branches"}']:
                required_solutions.append(c['solution'].__name__)
            else:
                exploitable = False
                fail_reasons.append(c['problem'].__name__.replace('is_',''))

    return exploitable, required_solutions if exploitable else [], fail_reasons

def main(in_csv, out_csv):
    global with_branches

    df = pd.read_csv(in_csv, delimiter=';')
    df = df.replace(to_replace=['None'], value=0)

    integer_cols = ['base_range_max',
                    'base_range_min',
                    'base_range_stride',
                    'base_range_window',
                    # 'base_size',
                    'inferable_bits_n_inferable_bits',
                    'inferable_bits_spread_high',
                    'inferable_bits_spread_low',
                    'inferable_bits_spread_total',
                    'secret_address_range_stride',
                    'secret_address_range_max',
                    'secret_address_range_min',
                    'secret_address_range_window',
                    'transmitted_secret_range_max',
                    'transmitted_secret_range_min',
                    # 'transmitted_secret_size',
                    'base_range_w_branches_max',
                    'base_range_w_branches_min',
                    'base_range_w_branches_stride',
                    'base_range_w_branches_window',
                    'independent_base_range_w_branches_max',
                    'independent_base_range_w_branches_min',
                    'independent_base_range_w_branches_stride',
                    'independent_base_range_w_branches_window',
                    'secret_address_range_w_branches_stride',
                    'secret_address_range_w_branches_max',
                    'secret_address_range_w_branches_min',
                    'secret_address_range_w_branches_window',
                    'transmitted_secret_range_w_branches_max',
                    'transmitted_secret_range_w_branches_min'
                    ]

    # Transform columns.
    for i in integer_cols:
        df[i] = df[i].fillna(0)
        df[i] = df[i].astype('float64', errors='ignore')

    df['base_size'] = df.apply(calc_base_size, axis=1)
    df['transmitted_secret_size'] = df.apply(calc_transmitted_secret_size, axis=1)
    df['pc_as_int'] = df.apply(get_pc_as_number, axis=1)

    # Add results of exploitability analysis.
    print("[-] Doing exploitability analysis...")
    with_branches = False
    for b in basic_checks:
        df[b.__name__] = df.apply(b, axis=1)

    for transformation in transformations:
        df['base_control_type'] = df.apply(transformation, axis=1)

    for c in advanced_checks:
        df[c['problem'].__name__] = df.apply(c['problem'], axis=1)
        df[c['solution'].__name__] = df.apply(c['solution'], axis=1)

    df[['exploitable', 'required_solutions', 'fail_reasons']] = df.apply(is_exploitable, axis=1, result_type="expand")

    # Add results of exploitability analysis considering branches.
    print("[-] Doing exploitability analysis including branch constraints...")
    with_branches = True
    for b in basic_checks:
        df[b.__name__ + '_w_branches'] = df.apply(b, axis=1)

    for transformation in transformations:
        df['base_control_type'] = df.apply(transformation, axis=1)

    for c in advanced_checks:
        df[c['problem'].__name__ + '_w_branches'] = df.apply(c['problem'], axis=1)
        df[c['solution'].__name__ + '_w_branches'] = df.apply(c['solution'], axis=1)

    df[['exploitable_w_branches', 'required_solutions_w_branches',
        'fail_reasons_w_branches']] = df.apply(is_exploitable, axis=1, result_type="expand")

    # Save to new file.
    df.to_csv(out_csv, sep=';', index=False)

    print("[-] Done!")


# ----------------- Main

if __name__ == '__main__':

    arg_parser = argparse.ArgumentParser(description='Reason over the exploitability of InSpectre Gadget transmissions.')

    arg_parser.add_argument('csv_in')
    arg_parser.add_argument('csv_out')
    args = arg_parser.parse_args()

    main(args.csv_in, args.csv_out)
