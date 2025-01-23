#!/opt/homebrew/bin/python3

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


df = pd.read_csv("./csv/data.csv")
print(df['TTI'])

sns.boxplot(x='TTI',y='ReTx',data=df)
plt.show()