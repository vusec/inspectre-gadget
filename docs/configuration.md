# Configuration

A YAML file can be provided to the tool with the `--config` flag.
The config file defines which registers and stack locations are controlled by the
user, as well as some analysis parameters. Here's an example:

```yaml
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
controlled_stack:
  # 20 64-bit values
  - start: 0
    end: 160
    size: 8

EnableLogging: False
STLForwarding: True

Z3Timeout: 10000 # ms = 10s
AnalysisTimeout: 50 #s
MaxBB: 5
DistributeShifts: True
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
