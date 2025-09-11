global_config = {}


def init_config(config):
    global global_config

    # Apply default config.
    # Timeout of the Z3 solver when evaluating constraints
    global_config["Z3Timeout"] = 10 * 1000  # ms = 10s
    # Maximum number of basic blocks to explore for each entrypoint
    global_config["MaxBB"] = 5
    # Forward stored values to subsequent loads
    global_config["STLForwarding"] = True
    # Distribute left shifts over + and -
    global_config["DistributeShifts"] = True
    # Analyze found gadgets directly during scanning, instead after scanning
    global_config["AnalyzeDuringScanning"] = True
    # AggressiveSpeculation follows branches even if their condition is always false.
    global_config["AggressiveSpeculation"] = False
    # Mnemonics which are assumed to stop speculation
    global_config["SpeculationStopMnemonics"] = {'lfence', 'mfence', 'cpuid'}
    # Crash (exit) on exceptions
    global_config["CrashOnExceptions"] = False
    # Enable search for transmission gadgets
    global_config["TransmissionGadgets"] = True
    # Enable search for tainted function pointers (i.e. dispatch gadgets).
    global_config["TaintedFunctionPointers"] = True
    # If TFP enabled, also output function pointers with no taint
    global_config["NonTaintedFunctionPointers"] = False
    # If TFP enabled, also attacker controlled info for register dereferences
    global_config["TaintedFunctionPointersRegisterDereference"] = True
    # Enable search for Half Spectre gadgets
    global_config["HalfSpectre"] = False
    # Verbosity of the logging output. 0-3: No / coarse-grained / fine-grained
    global_config["LogLevel"] = 1

    # Apply user config.
    for c in config:
        global_config[c] = config[c]
