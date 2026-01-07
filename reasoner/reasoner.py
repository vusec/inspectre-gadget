import pandas as pd
from io import StringIO

from . import tfpReasoner
from . import transmissionReasoner


def run(in_csv, out_csv):

    with open(in_csv) as f:
        columns = f.readline()

    if ';transmission_expr;' in columns:
        return transmissionReasoner.run(in_csv, out_csv)
    elif ';reg;' in columns:
        return tfpReasoner.run(in_csv, out_csv)
    elif ';loaded_expr;' in columns:
        print("HalfGadget reasoner not implemented yet, exiting...")
        return
