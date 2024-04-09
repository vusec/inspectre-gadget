# Configuration

A YAML file must be provided to the tool with the `--config` flag.
The config file defines which registers and stack locations are controlled by the
user, as well as some analysis parameters. Here's an example:

```yaml
# Which registers are attacker-controlled.
# Note that we generally consider everything controlled,
# and later filter the gadgets based on the "Requirements" column.
controlled_registers:
  - rax
  - rbx
  # Argument registers
  - rdi
  - rsi
  - rdx
  - rcx
  - r8
  - r9
  # General purpose
  - r10
  - r11
  - r12
  - r13
  - r14
  - r15

# What portion of the stack is attacker-controlled.
controlled_stack:
  # 20 64-bit values
  - start: 0
    end: 160
    size: 8

# Verbosity of the logging output.
# Level 0: no output
# Level 1: coarse-grained log
# Level 2: fine-grained log (debug)
LogLevel: 1

# Forward stored values to subsequent loads.
STLForwarding: True

# Timeout of the Z3 solver when evaluating constraints.
Z3Timeout: 10000 # ms = 10s

# Maximum number of basic blocks to explore for each entrypoint.
MaxBB: 5

# Distribute left shifts over + and -.
DistributeShifts: True

# Also look for tainted function pointers (i.e. dispatch gadgets).
TaintedFunctionPointers: True
```

Note that, since InSpectre Gadget lists which registers and memory locations are
really needed for each gadget, the easiest approach is to mark everything as
controlled, and apply filters later on the CSV. However, it is also possible to
restrict the set of controlled registers beforehand.

Some other parameters that can be tweaked are:

- **MaxBB**: Maximum number of basic blocks to explore for each entrypoint
- **STLForwarding**: When enabled, the scanner will forward stored values
  to subsequent loads to the same address
- **DistributeShifts**: When enabled, left-shift expressions like
  `(rax + rbx) << 8` will be treated as `(rax << 8) + (rbx << 8)` during range and control analysis
- **TaintedFunctionPointers**: When enabled, the scanner will scan also for
  TaintedFunctionPointers (a.k.a dispatch gadgets, see the paper for more details)
