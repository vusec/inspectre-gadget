import os
import pandas as pd

dfs = []
tfps = []

for f in os.listdir('gadgets'):
    if not f.endswith('.csv'):
        continue

    name = f.split('-')[0]

    try:
        df = pd.read_csv('gadgets/' + f, sep=";")
        df['name'] = name
        dfs.append(df)
    except:
        pass

    try:
        df = pd.read_csv('tfps/' + f, sep=";")
    except:
        continue

    df['name'] = name
    tfps.append(df)


res = pd.concat(dfs)
res.to_csv('all-gadgets.csv', sep=";")

res = pd.concat(tfps)
res.to_csv('all-tfps.csv', sep=";")
