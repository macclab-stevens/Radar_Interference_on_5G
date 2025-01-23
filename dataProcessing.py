import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os

df = pd.read_csv('./Run_30Khz_NoRadar/0_RunData.csv')
df.columns = df.columns.str.replace(' ', '')

print(df.keys())
ttis = [2,4,7,14]
for tti in ttis:
    print(f'TTI: {tti}')
    dfTTI = df[df['TTI'] == tti]
    print(f'DL bps: {dfTTI['DL_goodput_bps'].mean()}')
