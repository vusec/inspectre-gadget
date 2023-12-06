import os
import pandas as pd
import IPython

dfs = []
tfps = []

for f in os.listdir('gadgets'):
    if not f.endswith('.csv'):
        continue

    name = f.split('-')[0]
    
    try:
        df = pd.read_csv('gadgets/' + f)
        df['name'] = name
        dfs.append(df)
    except:
        pass

    try:
        df = pd.read_csv('tfps/' + f)
    except:
        continue

    df['name'] = name
    tfps.append(df)

# IPython.embed()

res = pd.concat(dfs)
res.to_csv('all-gadgets.csv')

res = pd.concat(tfps)
res.to_csv('all-tfps.csv')