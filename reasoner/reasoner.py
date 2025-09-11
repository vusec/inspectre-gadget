import pandas as pd
from io import StringIO

from . import tfpReasoner
from . import transmissionReasoner


def run(in_csv, out_csv):

    # Replace 'None' with 0
    # TODO: Hack, we should adjust the analyzer output.
    file = open(in_csv, 'r')
    data = file.read()
    data = data.replace('None', '')
    data = data.replace('nan', '')
    data = data.replace('Nan', '')
    file.close()

    df = pd.read_csv(StringIO(data), delimiter=';')

    if 'transmission_expr' in df.columns:
        return transmissionReasoner.run(in_csv, out_csv)
    elif 'reg' in df.columns:
        return tfpReasoner.run(in_csv, out_csv)
    elif 'loaded_expr' in df.columns:
        print("HalfGadget reasoner not implemented yet, exiting...")
        return
