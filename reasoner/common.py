"""
Constants shared by the reasoners.
"""

# The attacker can choose the value (with REQUIRES_MEM_LEAK, the attacker needs
# to know the uncontrolled part first)
ATTACKER_CONTROL_TYPES = ['ControlType.CONTROLLED', 'ControlType.REQUIRES_MEM_LEAK']
