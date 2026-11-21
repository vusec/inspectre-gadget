import pandas as pd
import yaml
from io import StringIO

from . import addressSpace
from . import tfpReasoner
from . import transmissionReasoner


def load_config(config_file):
    """
    Return the reasoner config: the defaults, overwritten by the 'reasoner'
    section of the config file (if given).
    """
    config = {}

    # Apply default config.
    config["AllowKernelAddresses"] = True
    config["AllowUserAddresses"] = False

    # Apply user config.
    if config_file:
        with open(config_file, "r") as f:
            user_config = yaml.safe_load(f) or {}

        for c, v in (user_config.get('reasoner') or {}).items():
            config[c] = v

    return config


def run(in_csv, out_csv, config_file=None):

    addressSpace.init(load_config(config_file))

    with open(in_csv) as f:
        columns = f.readline()

    if ';transmission_expr;' in columns:
        return transmissionReasoner.run(in_csv, out_csv)
    elif ';reg;' in columns:
        return tfpReasoner.run(in_csv, out_csv)
    elif ';loaded_expr;' in columns:
        print("HalfGadget reasoner not implemented yet, exiting...")
        return
