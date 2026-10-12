import argparse
import ast
import pandas as pd
import numpy as np
from io import StringIO

from . import addressSpace

from warnings import simplefilter
simplefilter(action="ignore", category=pd.errors.PerformanceWarning)

# Number of bits of the secret that are used in the transmission.
# E.g.     BASE + (SECRET & 0xf) has 4 inferable bits
#          BASE + (SECRET ^ SECRET) has 0 inferable bits
MIN_INFERABLE_BITS = 1

MIN_BASE_WINDOW = 0
MIN_SECRET_ADDRESS_WINDOW = 0xffff

MAX_SECRET_WO_ADJUSTING_BASE = ((1 << 30) * 256)  # 256 GB

CACHE_SHIFT = 6
PAGE_SHIFT = 12
ADDRESS_BIT_LEN = 64

MAX_ENTROPY = 16

with_branches = False


def branch_suffix():
    """
    Suffix of the columns for the current analysis (with or without branches).
    """
    return "" if not with_branches else "_w_branches"


def is_in_range(n, min, max):
    if min <= max:
        return n >= min and n <= max
    else:
        return n >= min or n <= max


def calc_base_size(t: pd.Series):
    if t['base_control'] == 'BaseControlType.NO_BASE' or t['base_expr'] == '':
        return 0
    try:
        assert (t['base_expr'].startswith('<BV'))
    except:
        return 0
    return int(t['base_expr'].split(' ')[0].replace('<BV', ''))


def calc_transmitted_secret_size(t: pd.Series):
    assert (t['transmitted_secret_expr'].startswith('<BV'))
    return int(t['transmitted_secret_expr'].split(' ')[0].replace('<BV', ''))


def get_pc_as_number(t: pd.Series):
    return str(int(t['pc'], 16))

# ----------------- Basic checks


def is_secret_inferable(t: pd.Series):
    """
    Check if the transmission is able to transmit a significant portion of
    the secret.
    """
    return t['inferable_bits_n_inferable_bits'] >= MIN_INFERABLE_BITS


def has_valid_base(t: pd.Series):
    """
    Check if the base can point to a valid address
    """
    base_min = t[f'base_range{branch_suffix()}_min']
    base_max = t[f'base_range{branch_suffix()}_max']

    return addressSpace.range_overlaps_regions(base_min, base_max, t['base_size'],
                                               addressSpace.MAPPED_REGIONS)


def has_valid_secret_address(t: pd.Series):
    """
    Check if the secret address can be adjusted to a valid address and the
    attacker has enough control over it.
    """
    if t[f'secret_address_control'] != 'ControlType.CONTROLLED':
        return False

    if t[f'secret_address_range{branch_suffix()}_window'] < MIN_SECRET_ADDRESS_WINDOW:
        return False

    addr_min = t[f'secret_address_range{branch_suffix()}_min']
    addr_max = t[f'secret_address_range{branch_suffix()}_max']

    return addressSpace.range_overlaps_regions(addr_min, addr_max, ADDRESS_BIT_LEN,
                                               addressSpace.VALID_REGIONS)


def is_cmove_independent_from_secret(t: pd.Series):
    return t['cmove_control_type'] == 'BranchControlType.BRANCH_INDEPENDENT_FROM_SECRET'


def has_no_speculation_stop(t: pd.Series):
    return t['contains_spec_stop'] == False

# ----------------- Imperfect gadget checks


def is_secret_below_cache_granularity(t: pd.Series):
    """
    Check if there is at least one byte of the secret that is being transmitted
    above cache line granularity.
    If not, we need to apply the sliding technique.
    """
    return (t['inferable_bits_spread_low'] < CACHE_SHIFT
            and t['inferable_bits_spread_high'] < (CACHE_SHIFT + 8))


def is_secret_entropy_high(t: pd.Series):
    """
    Check if the number of bits of the secret that are alive in the transmission
    is too high. This can happen e.g. when a gadget lacks the "masking" step
    that is generally required for a perfect gadget.
    """
    secret_entropy = min(t['inferable_bits_spread_total'],
                         t['inferable_bits_n_inferable_bits'])
    return secret_entropy > MAX_ENTROPY


def is_max_secret_too_high(t: pd.Series, only_independent: bool = False):
    """
    Check if the maximum value of the secret would make the transmission fall
    outside of the address space (therefore inhibiting the signal that the
    attacker wants to retrieve).
    """

    if t[f'has_valid_base'] == False:
        # This check is redundant without a valid base
        return False

    if only_independent:
        base_min = t[f'independent_base_range{branch_suffix()}_min']
        base_max = t[f'independent_base_range{branch_suffix()}_max']
    else:
        base_min = t[f'base_range{branch_suffix()}_min']
        base_max = t[f'base_range{branch_suffix()}_max']

    #
    # We don't use with_branches here because it does no make sense. Example
    #    if secret < 10
    #        transmit(secret)
    #
    # In this case either we follow the constraint, so we cannot leak secrets
    # above 10, or we mispredict, and then we have the original secret max.
    #
    secret_min = t[f'transmitted_secret_range_min']
    secret_max = t[f'transmitted_secret_range_max']

    # Get the transmitted secret maximum.
    if secret_min <= secret_max:
        valid_secret_max = secret_max
    else:
        valid_secret_max = (2 ** t['transmitted_secret_size']) - 1

    # The secret will not fit in RAM without base adjusting if it
    # exceeds MAX_SECRET_WO_ADJUSTING_BASE
    if valid_secret_max > MAX_SECRET_WO_ADJUSTING_BASE:
        return True

    for r in addressSpace.MAPPED_REGIONS:

        if base_min <= base_max:
            valid_min = max(base_min, r[0])
        else:
            # If we are here, we have a range that wraps around.
            if r[0] < base_max or r[0] > base_min:
                # Case 1: the region start is inside the range: use that.
                valid_min = r[0]
            else:
                # Case 2: the region start is outside the range - between
                # base_max and base_min -. so first valid value is base_min
                valid_min = base_min

        if valid_min + valid_secret_max <= r[1]:
            return False

    return True


def base_has_direct_secret_dependency(t: pd.Series):
    return t['base_control_type'] == 'BaseControlType.BASE_DEPENDS_ON_SECRET_ADDR'


def base_has_indirect_secret_dependency(t: pd.Series):
    return (t['base_control_type']
            == 'BaseControlType.BASE_INDIRECTLY_DEPENDS_ON_SECRET_ADDR')


def is_base_controlled(t: pd.Series):
    return t['base_control'] in ['ControlType.CONTROLLED',
                                 'ControlType.REQUIRES_MEM_LEAK']


def is_branch_dependent_from_secret(t: pd.Series):
    return t['branch_control_type'] in [
        'BranchControlType.BRANCH_DEPENDS_ON_SECRET_ADDRESS',
        'BranchControlType.BRANCH_DEPENDS_ON_SECRET_VALUE']


def is_branch_dependent_from_uncontrolled(t: pd.Series):
    return (t['branch_control_type']
            == 'BranchControlType.BRANCH_DEPENDS_ON_UNCONTROLLED')

# ----------------- Transformations


def _has_valid_independent_base(t: pd.Series):
    """
    Check if the independent part of the base can point to a valid address
    """

    if t['base_expr'] == '' or pd.isna(t['base_expr']):
        return True

    base_min = t[f'independent_base_range{branch_suffix()}_min']
    base_max = t[f'independent_base_range{branch_suffix()}_max']

    return addressSpace.range_overlaps_regions(base_min, base_max,
                                               t['independent_base_size'],
                                               addressSpace.MAPPED_REGIONS)


def transform_partial_control_into_aliasing(t: pd.Series):
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


def can_perform_sliding(t: pd.Series):
    """
    Check if we have enough control over the least significant bits of the
    base. If we can adjust these bits, and are able to make the transmission
    happen at a page boundary, we can observe a signal even if the secret
    bits are below cache-line granularity
    """

    if not is_base_controlled(t):
        return False

    stride = t[f'independent_base_range{branch_suffix()}_stride']
    window = t[f'independent_base_range{branch_suffix()}_window']
    return stride <= 2**t['inferable_bits_spread_low'] and window >= 4096


def can_perform_known_prefix(t: pd.Series):
    """
    If we can adjust the secret address with enough precision and independently
    from the base, we can adjust the transmission to first read some known
    bytes before the secret, and then increasing the secret address until
    we reach the secret.
    """
    if t[f'secret_address_control'] != 'ControlType.CONTROLLED':
        return False

    # TODO: should we check the secret address window also?
    return t[f'secret_address_range{branch_suffix()}_stride'] <= MAX_ENTROPY


def can_adjust_base(t: pd.Series):
    """
    Check if we have enough control of the base to overflow the transmission
    address in case the secret is too high.
    """

    if not is_base_controlled(t):
        return False

    base_controllable_window = t[f'independent_base_range{branch_suffix()}_window']
    secret_max = t[f'transmitted_secret_range{branch_suffix()}_max']
    secret_window = t[f'transmitted_secret_range{branch_suffix()}_window']

    # TODO: quick fix for stupid cases, we need a more sophisticated way of sampling
    # the range.
    if secret_window >= 2**48 and base_controllable_window <= 2**32:
        return False

    for r in addressSpace.MAPPED_REGIONS:
        # We assume the attacker can subtract the window from a valid address.
        # it is an approximation, but good enough
        valid_min = r[0] - \
            base_controllable_window if r[0] > base_controllable_window else 0

        # First see if we can simple take a low base
        if valid_min + secret_max <= r[1]:
            return True

        # If not, check if we can overflow
        if base_controllable_window > r[0] and (
           secret_max + base_controllable_window - (2 ** ADDRESS_BIT_LEN) >= r[0]):
            return True

    return False


def can_ignore_direct_dependency(t: pd.Series, slam=False):
    """
    For gadgets where the base address depends on the secret address, check if
    we need to modify the base independently from the secret.
    If not, we can safely ignore the dependency between the base and the secret
    address.
    """
    if _has_valid_independent_base(t):
        return True
    else:
        if slam:
            # With slam we don't adjust the base to compensate
            # for the secret

            if is_secret_below_cache_granularity(t):
                return False

            secret_range_exact = t[f'transmitted_secret_range_exact']
            secret_window = t[f'transmitted_secret_range_window']

            # We need a full secret range in order to overflow the kernel
            # base address to get an user address
            if secret_range_exact != True or secret_window != ((2 ** 64) - 1):
                return False

            return True

        else:
            return not (is_secret_below_cache_granularity(t)
                        or is_max_secret_too_high(t, only_independent=True))


# -- SLAM Covert channel
# To use the SLAM covert channel bit 47 and 63 should be equal to pass
# the canonicality check, and they should be zero such that the attacker
# can map the resulting page in user-space.


def slam_has_exact_secret_range(t: pd.Series):
    """
    The bit positions are really strict, so we need a exact range
    """

    secret_range_exact = t[f'transmitted_secret_range_exact']

    assert (type(secret_range_exact) == bool)

    if secret_range_exact == False:
        return False

    return True


def slam_has_aligned_secret_bytes(t: pd.Series):
    """
    Shift operations should not misplace secret bytes, since we make use
    of the fact that all ASCII characters have the 8th bit set to 0
    """

    secret_stride = t[f'transmitted_secret_range_stride']

    # Shifts are fine, as long as we shift one or more complete bytes
    if secret_stride not in [2 ** x for x in range(0, 64 + 1, 8)]:
        return False

    return True


def slam_is_an_user_address_translation(t: pd.Series):
    """
    To use the SLAM covert channel bit 47 and 63 should be zero. This
    can be tricky if you have a secret <= 32 bits.
    """

    secret_window = t[f'transmitted_secret_range_window']

    base_controllable_window = t[f'independent_base_range_window']

    if (secret_window <= 2 ** 32) and base_controllable_window < 2 ** 63:
        # If the secret is smaller than 32 bits then bits 47 and 63 are
        # probably one (kernel address) which will fail SLAM.
        # (e.g., [0xffffffff81000000 + eax])
        # if we control the base almost complexly, we do not have to worry
        return False

    n_inferable_bits = int(t['inferable_bits_n_inferable_bits'])
    secret_stride = int(t[f'transmitted_secret_range_stride'])

    if ((n_inferable_bits + (secret_stride - 1) <= 32)
            and base_controllable_window < 2 ** 63):
        # We do the same check as above, but now with the inferable bits
        # information to catch the 'complex' range cases (base expr
        # is included in transmitted secret expr)
        return False

    return True


def slam_can_ignore_direct_dependency(t: pd.Series):
    return can_ignore_direct_dependency(t, slam=True)


def perform_training(t: pd.Series):
    return True


def perform_out_of_place_training(t: pd.Series):
    return True


def leak_secret_near_valid_base(t: pd.Series):
    return True

# -- Secret dependent branch
# A covert channel on the directional branch predictor, leaking the results
# of a comparison on a secret value
# e.g.,: if (secret_value == cmp_value)
#
# We consider two cases:
# 1) cmp_value (or base) is attacker controlled: since the attacker can choose arbitrary
#    values for cmp_value, it can leak the secret by observing when the branch is taken.
# 2) Comparison of _one_ secret bit with a (non-secret dependent) value.
#    Leaks 1-bit secret, needs multiple of these gadgets (comparing different bits) to
#    leak 1 full byte.
#    If the comparison is with an uncontrolled non-constant value, we assume the
#    attacker can first leak the value of this uncontrolled value (e.g., by pointing the
#    secret address to attacker known values)

def get_registers(regs) -> set:
    """
    Return the registers of a requirements column, e.g., both
    "['<BV64 rdi>']" (direct regs) and "[\"<BV64 rdi>: ['0x0']\"]" (indirect regs)
    give {'<BV64 rdi>'}.
    """
    if not isinstance(regs, str):
        return set()

    return {r.split(':')[0] for r in ast.literal_eval(regs)}


def _is_cmp_value_independent(t: pd.Series):

    secret_addr_direct_regs = t['secret_address_requirements_direct_regs']
    secret_addr_indirect_regs = t['secret_address_requirements_indirect_regs']
    cmp_value_direct_regs = t['cmp_value_requirements_direct_regs']
    cmp_value_indirect_regs = t['cmp_value_requirements_indirect_regs']

    # direct dependency
    # cmp_value should not depend on the same registers as the secret address
    if (secret_addr_indirect_regs != '[]'
            and secret_addr_indirect_regs == cmp_value_indirect_regs):
        return False

    if (secret_addr_direct_regs != '[]'
            and secret_addr_direct_regs == cmp_value_direct_regs):
        return False

    secret_addr_direct_reg_set = get_registers(secret_addr_direct_regs)
    cmp_value_indirect_reg_set = get_registers(cmp_value_indirect_regs)

    # indirect dependency
    # cmp_value should not be loaded near the secret value
    if (len(secret_addr_direct_reg_set) > 0
            and secret_addr_direct_reg_set == cmp_value_indirect_reg_set):
        return False

    return True

def _is_cmp_value_independently_controlled(t: pd.Series):
    """
    The attacker controls cmp_value, independently from the secret.
    """
    if t['cmp_value_control'] != 'ControlType.CONTROLLED':
        return False

    return _is_cmp_value_independent(t)


def _is_sdb_base_controlled(t: pd.Series):
    """
    The attacker controls the base, independently from the secret.
    """
    if t['base_control'] != 'ControlType.CONTROLLED':
        return False

    if t['base_control_type'] not in ['BaseControlType.BASE_INDEPENDENT_FROM_SECRET',
                                      'BaseControlType.COMPLEX_TRANSMISSION']:
        return False

    return True


def cmp_value_not_independently_controlled(t: pd.Series):
    """
    The attacker can not choose the value the secret is compared with, neither
    via cmp_value nor via the base.
    """
    return not (_is_cmp_value_independently_controlled(t) or _is_sdb_base_controlled(t))


def cmp_value_not_controlled(t: pd.Series):

    if (t['base_control'] == 'ControlType.CONTROLLED'
            or t['cmp_value_control'] == 'ControlType.CONTROLLED'):
        return False

    return True


def do_one_bit_compare(t: pd.Series):
    """
    One secret bit is compared with a static value.
    """

    return (int(t['inferable_bits_n_inferable_bits']) == 1
            and _is_cmp_value_independent(t))

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
    {'problem': is_secret_entropy_high,
     'solution': can_perform_known_prefix},
    {'problem': is_max_secret_too_high,
     'solution': can_adjust_base},
    {'problem': base_has_indirect_secret_dependency,
     'solution': leak_secret_near_valid_base},
    {'problem': base_has_direct_secret_dependency,
     'solution': can_ignore_direct_dependency},
    {'problem': is_branch_dependent_from_secret,
     'solution': perform_training},
    {'problem': is_branch_dependent_from_uncontrolled,
     'solution': perform_out_of_place_training},
]

slam_basic_checks = [
    is_secret_inferable,
    has_valid_secret_address,
    is_cmove_independent_from_secret,
    has_no_speculation_stop,
    slam_has_exact_secret_range,
    slam_has_aligned_secret_bytes,
    slam_is_an_user_address_translation
]

slam_advanced_checks = [
    {'problem': is_secret_below_cache_granularity, 'solution': can_perform_sliding},
    {'problem': is_secret_entropy_high,
     'solution': can_perform_known_prefix},

    {'problem': base_has_indirect_secret_dependency,
     'solution': leak_secret_near_valid_base},

    {'problem': base_has_direct_secret_dependency,
     'solution': slam_can_ignore_direct_dependency},

    {'problem': is_branch_dependent_from_secret,
     'solution': perform_training},
    {'problem': is_branch_dependent_from_uncontrolled,
     'solution': perform_out_of_place_training},
]

sdb_basic_checks = [is_secret_inferable,
                    has_valid_secret_address,
                    is_cmove_independent_from_secret,
                    has_no_speculation_stop
                    ]

sdb_extra_checks = [
    {'problem': cmp_value_not_controlled, 'solution': do_one_bit_compare},
    {'problem': cmp_value_not_independently_controlled,
     'solution': do_one_bit_compare},
]


def evaluate_checks(t: pd.Series, checks: list, extra_checks: list):
    exploitable = True

    fail_reasons = []
    required_solutions = []

    for b in checks:
        if not b(t):
            exploitable = False
            fail_reasons.append(b.__name__)

    for c in extra_checks:
        if t[f'{c["problem"].__name__}{branch_suffix()}']:
            if t[f'{c["solution"].__name__}{branch_suffix()}']:
                # Multiple problems can have the same solution, only add it once
                if c['solution'].__name__ not in required_solutions:
                    required_solutions.append(c['solution'].__name__)
            else:
                exploitable = False
                fail_reasons.append(c['problem'].__name__.replace('is_', ''))

    return exploitable, required_solutions if exploitable else [], fail_reasons


def is_exploitable(t: pd.Series):
    return evaluate_checks(t, basic_checks, advanced_checks)


def slam_is_exploitable(t: pd.Series):
    return evaluate_checks(t, slam_basic_checks, slam_advanced_checks)


def sdb_is_exploitable(t: pd.Series):
    return evaluate_checks(t, sdb_basic_checks, sdb_extra_checks)


def reason_transmissions(df: pd.DataFrame) -> pd.DataFrame:
    global with_branches

    # --------------------------------------------------------------------------
    # Add results of exploitability analysis.
    print("[-] Performing exploitability analysis...")
    with_branches = False
    for b in basic_checks:
        df[b.__name__] = df.apply(b, axis=1)

    for transformation in transformations:
        df['base_control_type'] = df.apply(transformation, axis=1)

    for c in advanced_checks:
        df[c['problem'].__name__] = df.apply(c['problem'], axis=1)
        df[c['solution'].__name__] = df.apply(c['solution'], axis=1)

    df[['exploitable', 'required_solutions', 'fail_reasons']] = df.apply(
        is_exploitable, axis=1, result_type="expand")

    print(f"Found {len(df[df['exploitable'] == True])} exploitable gadgets!")

    # --------------------------------------------------------------------------
    # Add results of exploitability analysis considering branches.
    print("[-] Performing exploitability analysis including branch constraints...")
    with_branches = True
    for b in basic_checks:
        df[b.__name__ + '_w_branches'] = df.apply(b, axis=1)

    for transformation in transformations:
        df['base_control_type'] = df.apply(transformation, axis=1)

    for c in advanced_checks:
        df[c['problem'].__name__ +
            '_w_branches'] = df.apply(c['problem'], axis=1)
        df[c['solution'].__name__ +
            '_w_branches'] = df.apply(c['solution'], axis=1)

    df[['exploitable_w_branches', 'required_solutions_w_branches',
        'fail_reasons_w_branches']] = df.apply(is_exploitable, axis=1,
                                               result_type="expand")

    print(
        f"Found {len(df[df['exploitable_w_branches'] == True])} exploitable gadgets!")

    # --------------------------------------------------------------------------
    # Perform the checks for the SLAM attack
    print("[-] Performing exploitability analysis assuming the SLAM covert channel...")
    with_branches = False

    for b in slam_basic_checks:
        if b.__name__ not in df.columns:
            df[b.__name__] = df.apply(b, axis=1)

    for c in slam_advanced_checks:

        if c['problem'].__name__ not in df.columns:
            df[c['problem'].__name__] = df.apply(c['problem'], axis=1)

        if c['solution'].__name__ not in df.columns:
            df[c['solution'].__name__] = df.apply(c['solution'], axis=1)

    df[['exploitable_w_slam', 'required_solutions_w_slam',
        'fail_reasons_w_slam']] = df.apply(slam_is_exploitable, axis=1,
                                           result_type="expand")

    print(
        f"Found {len(df[df['exploitable_w_slam'] == True])} exploitable gadgets!")

    return df


def reason_secret_dependent_branches(df: pd.DataFrame) -> pd.DataFrame:
    global with_branches

    print("[-] Performing exploitability analysis for secret dependent branches...")
    for with_branches in [False, True]:
        suffix = "" if not with_branches else "_w_branches"

        for b in sdb_basic_checks:
            df[b.__name__ + suffix] = df.apply(b, axis=1)

        for c in sdb_extra_checks:
            df[c['problem'].__name__ + suffix] = df.apply(c['problem'], axis=1)
            df[c['solution'].__name__ + suffix] = df.apply(c['solution'], axis=1)

        result_columns = ['exploitable_w_sdb' + suffix,
                          'required_solutions_w_sdb' + suffix,
                          'fail_reasons_w_sdb' + suffix]
        df[result_columns] = df.apply(sdb_is_exploitable, axis=1, result_type="expand")

        n_exploitable = len(df[df['exploitable_w_sdb' + suffix] == True])
        print(f"Found {n_exploitable} exploitable secret dependent branches"
              f"{' with branches' if with_branches else ''}!")

    return df


def add_missing_columns(df: pd.DataFrame) -> pd.DataFrame:
    """
    Make sure all check and result columns exist (empty for rows they do not
    apply to), also if there are no transmissions or no secret dependent
    branches, so that the output always has the same columns.
    """
    def names(checks, extra_checks):
        return ([c.__name__ for c in checks]
                + [c['problem'].__name__ for c in extra_checks]
                + [c['solution'].__name__ for c in extra_checks])

    results = ['exploitable', 'required_solutions', 'fail_reasons']

    # Transmissions and SDBs are checked with and without branches, SLAM without
    columns = []
    for suffix in ['', '_w_branches']:
        columns += [x + suffix for x in names(basic_checks, advanced_checks)]
        columns += [x + suffix for x in names(sdb_basic_checks, sdb_extra_checks)]
        columns += [x + suffix for x in results]
        columns += [x + '_w_sdb' + suffix for x in results]
    columns += names(slam_basic_checks, slam_advanced_checks)
    columns += [x + '_w_slam' for x in results]

    for col in columns:
        if col not in df.columns:
            df[col] = pd.NA

    return df


def run(in_csv, out_csv):
    global with_branches

    integer_cols = ['base_range_max',
                    'base_range_min',
                    'base_range_stride',
                    'base_range_window',
                    'independent_base_range_max',
                    'independent_base_range_min',
                    'independent_base_range_stride',
                    'independent_base_range_window',
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

    file = open(in_csv, 'r')
    data = file.read()
    file.close()

    df_header = pd.read_csv(StringIO(data), delimiter=';')
    types_dict = {
        col: 'UInt64' if col in integer_cols else df_header[col].dtype.name
        for col in df_header}

    # Via this method we avoid pandas mixing types
    df = pd.read_csv(StringIO(data), delimiter=';', dtype=types_dict)

    if df.empty:
        print(f"[-] Imported {len(df)} gadgets")
        return

    # Transform columns.
    for i in integer_cols:
        df[i] = df[i].fillna(0)

    df['base_size'] = df.apply(calc_base_size, axis=1)
    df['transmitted_secret_size'] = df.apply(
        calc_transmitted_secret_size, axis=1)
    df['pc_as_int'] = df.apply(get_pc_as_number, axis=1)
    print(f"[-] Imported {len(df)} gadgets")

    # Secret dependent branches are reasoned separately
    is_sdb = df['transmitter'] == 'TransmitterType.SECRET_DEP_BRANCH'
    df_sdb = df[is_sdb].copy()
    df = df[~is_sdb].copy()

    if not df.empty:
        df = reason_transmissions(df)

    if not df_sdb.empty:
        df_sdb = reason_secret_dependent_branches(df_sdb)
        df = df_sdb if df.empty else pd.concat([df, df_sdb])

    df = add_missing_columns(df)

    # Save to new file.
    print(f"[-] Saving to {out_csv}")
    df.to_csv(out_csv, sep=';', index=False)

    print("[-] Done!")
