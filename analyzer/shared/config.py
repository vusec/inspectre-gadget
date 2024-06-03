global_config = {}

def init_config(config):
    global global_config

    # Apply default config.
    global_config["Z3Timeout"] = 10*1000 # ms = 10s
    global_config["MaxBB"] = 5
    global_config["STLForwarding"] = True
    global_config["DistributeShifts"] = True
    global_config["AnalyzeDuringScanning"] = True
    global_config["LogLevel"] = 1
    global_config["TaintedFunctionPointers"] = True
    global_config["SpeculationStopMnemonics"] = {'lfence', 'mfence', 'cpuid'}

    # Apply user config.
    for c in config:
        global_config[c] = config[c]

