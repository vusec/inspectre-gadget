# Configuration

A YAML file must be provided to the tool with the `--config` flag.
The config file defines which registers and stack locations are controlled by the
user, as well as some analysis parameters.

An updated example with an explanation of the flags is available
[in the top folder](https://github.com/vusec/inspectre-gadget/blob/main/config_all.yaml).

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

# Also output "Half-Spectre" gadgets, a.k.a MDS gadgets.
# https://download.vusec.net/papers/halfspectre_sp25.pdf
HalfSpectre: False

# If this is true, any exception thrown during scanning will cause immediate
# abort of the execution. This is not desirable during long runs on e.g. the
# Linux Kernel because we want the scanning to continue to the next gadget
# if, for some reason, the execution crashes on a specific gadget.
# It can be however useful for debugging purposes.
CrashOnExceptions: False

# Should we analyse the transmissions only after scanning the whole gadget,
# or should we try to output transmissions as soon as they are found?
# This has consequences on interrupting, e.g., if you analyse only _after_ scanning
# you won't have any outputted transmission in case of  e.g.timeouts.
AnalyzeDuringScanning: True
```

Note that, since InSpectre Gadget lists which registers and memory locations are
needed for each gadget, the easiest approach is to mark everything as
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
- **HalfSpectre**: When enabled, the scanner will scan also for
  Half-Spectre gadgets (a.k.a prefetch gadgets, a.k.a dispatch gadgets,
  see for example[https://download.vusec.net/papers/halfspectre_sp25.pdf](https://download.vusec.net/papers/halfspectre_sp25.pdf)).
