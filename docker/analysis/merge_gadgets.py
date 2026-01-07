import os
import pandas as pd
import numpy
from io import StringIO

GADGET_FOLDER = 'gadgets'
TFP_FOLDER = 'tfps'

# Gadgets

data = ''
header = ''


if os.path.isdir(GADGET_FOLDER):
    for file_name in os.listdir(GADGET_FOLDER):
        if not file_name.endswith('.csv'):
            continue

        with open(os.path.join(GADGET_FOLDER, file_name)) as f:
            first = f.readline()

            if not header:
                header = first
                data += first
            else:
                assert (header == first)

            data += f.read()

    with open('all-gadgets.csv', "w") as f:
        # Writing data to a file
        f.write(data)

# TFPs

data = ''
header = ''

if os.path.isdir(TFP_FOLDER):
    for file_name in os.listdir(TFP_FOLDER):
        if not file_name.endswith('.csv'):
            continue

        with open(os.path.join(TFP_FOLDER, file_name)) as f:
            first = f.readline()

            if not header:
                header = first
                data += first
            else:
                assert (header == first)

            data += f.read()

    with open('all-tfps.csv', "w") as f:
        # Writing data to a file
        f.write(data)
