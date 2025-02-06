import os
import scipy.io
import pandas as pd
import numpy as np

def generateAvgCsv(folder_name):
    df = pd.read_csv(os.path.join(folder_name, '0_RunData.csv'))
    df.columns = df.columns.str.strip() #remove whitespaces from column names 
    print("Keys: {}".format(df.keys()))
    numFolders = df['FolderName'].nunique()
    print(f"Number of unique folders: {numFolders}")
    dic_list = []
    for f in df['FolderName'].unique():
        print("Folder: {}".format(f))
        fold = df.loc[df['FolderName'] == f]
        # print("Folder Values == {}".format(fold))
        foldAvg = fold.select_dtypes(include='number').mean()
        dic_list.append(foldAvg.to_dict())
    
    df_final = pd.DataFrame.from_dict(dic_list)
    outputName = '1_AvgData.csv'
    df_final.to_csv(os.path.join(folder_name,outputName))
    print(df_final)
    return
# Main
if __name__ == "__main__":
    root_directory = "./Run_30Khz_BW_test3_prf3.002k_w_20atten/"  # Change this to the root directory of your files
    generateAvgCsv(root_directory)