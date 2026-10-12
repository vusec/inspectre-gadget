"""
Address regions that the reasoner considers valid targets for memory accesses.
"""

# Linux x86-64 (4-level paging) kernel space.
KERNEL_VALID_REGIONS = [
    (0xffff800000000000, 0xffffffff9fffffff)
]
KERNEL_MAPPED_REGIONS = [
    (0xffffffff81000000, 0xffffffff84000000),  # Kernel text
    (0xffff888000000000, 0xffffc87fffffffff)   # Direct physical memory map
]

# Linux x86-64 user space, starting from the default mmap_min_addr.
# User-space layouts differ per process (ASLR, PIE, libraries), so we assume
# the attacker can map (or knows) any user-space address.
USER_VALID_REGIONS = [
    (0x0000000000010000, 0x00007fffffffffff)
]
USER_MAPPED_REGIONS = USER_VALID_REGIONS

# Canonical addresses that can be accessed.
VALID_REGIONS = KERNEL_VALID_REGIONS
# Addresses that are mapped (i.e., contain data/code).
MAPPED_REGIONS = KERNEL_MAPPED_REGIONS


def init(config: dict):
    """
    Set the valid and mapped regions based on the reasoner config
    (see reasoner.load_config()).
    """
    global VALID_REGIONS, MAPPED_REGIONS

    VALID_REGIONS = []
    MAPPED_REGIONS = []

    if config['AllowUserAddresses']:
        VALID_REGIONS += USER_VALID_REGIONS
        MAPPED_REGIONS += USER_MAPPED_REGIONS
    if config['AllowKernelAddresses']:
        VALID_REGIONS += KERNEL_VALID_REGIONS
        MAPPED_REGIONS += KERNEL_MAPPED_REGIONS

    if len(VALID_REGIONS) == 0:
        raise ValueError("Invalid reasoner config: AllowKernelAddresses and "
                         "AllowUserAddresses are both disabled")


def is_overlapping(x_min, x_max, y_min, y_max):
    return x_max >= y_min and y_max >= x_min


def range_overlaps_regions(range_min, range_max, size, regions):
    """
    Check if the range [range_min, range_max] of a value of 'size' bits overlaps
    with any of the given regions. If range_min > range_max, the range wraps
    around: [range_min, 2 ** size - 1] + [0, range_max].
    """
    for r in regions:
        if range_min <= range_max:
            if is_overlapping(range_min, range_max, r[0], r[1]):
                return True
        elif (is_overlapping(0, range_max, r[0], r[1])
                or is_overlapping(range_min, (2 ** size) - 1, r[0], r[1])):
            return True

    return False
