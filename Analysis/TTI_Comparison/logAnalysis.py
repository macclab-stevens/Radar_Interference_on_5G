#!/opt/homebrew/bin/python3
#Script Used to graph 5G TDD slot patterns, and calculate symbol interfeerence based on radar charcterisitics. 
__author__ = "Eric Forbes"
__version__ = "0.1.0"
__license__ = "MIT"
import scipy.io
import pandas as pd
import numpy as np
import seaborn as sns

import matplotlib
import matplotlib.pyplot as plt 
import matplotlib.patches as patches
from matplotlib.offsetbox import AnchoredText
from datetime import datetime
import sys
import os

def readSimLogFile(fileName):
    print("readSimLogFile()")
    mat = scipy.io.loadmat(fileName)
    
    #pull the relevant arrary from
    simLogs = mat['simulationLogs']
    simLogs = simLogs[0][0]['SchedulingAssignmentLogs'][0][0]
    
    #convert to DataFrame
    df = pd.DataFrame(simLogs)
    
    #Remove array chars
    for i in range(15):
        df[i] = df[i].astype(str).str.replace('[','')
        df[i] = df[i].astype(str).str.replace(']','')
        df[i] = df[i].astype(str).str.replace('\'','')
        df[i] = df[i].astype(str).str.replace(';',' ')
    
    #make new DF with the right column
    header = df.iloc[0]
    df  = pd.DataFrame(df.values[1:], columns=header)
    # print(header)
    df = df.rename(columns={'RBG Allocation Map':'RBG',
                            'Feedback Slot Offset (DL grants only)':'FdbkOffst',
                            'CQI on RBs':'CQIs'})
    
    #convert relevant columns to the right types
    toInts = ['RNTI','Frame','Slot','Start Sym', 'Num Sym', 'MCS', 'NumLayers', 'HARQ ID', 'NDI Flag', 'RV']
    #--INTS
    for i in toInts:
        df[i] = pd.to_numeric(df[i])
    toStrs = ['Grant type','Tx Type']
    #--Strings
    for i in toStrs:
        df[i] = df[i].astype(str)
    #--ARRAYS
    df['RBG'] = df['RBG'].astype(str).str.split(pat=' ')
    df['RBG'] = df['RBG'].apply(lambda lst: list(map(int, lst)))
    df['CQIs'] = df['CQIs'].astype(str).str.split(pat=' ')
    df['CQIs'] = df['CQIs'].apply(lambda lst: list(map(int, lst)))

    return df

def convertMATtoDIC(searchDir):
    directory = os.listdir(searchDir)
    for fname in directory:
        # print(fname)
        if "Metrics.mat" in fname:
            df = readSimLogFile(fname)
            csvFname = fname.rsplit( ".", 2 )[ 0 ] + ".csv"
            print(csvFname)
            df.to_csv(csvFname)
            print(fname)

def fileAnalysis(folder):
    print(folder)
    dataDF = pd.DataFrame()
    id = 1
    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        print(file_path)
        if "TTI" not in file_path: continue
        df = pd.read_csv(file_path)
        df.columns = df.columns.str.replace(' ', '') 
        print(df)
        if 'TTI2' in file_path: TTI =2
        if 'TTI4' in file_path: TTI =4
        if 'TTI7' in file_path: TTI =7
        print("TTI:",TTI)
        df['TTI'] = TTI
        print(df)
        print(df.columns) 
        # d = {}
        unique_rntis = df['RNTI'].unique()
        print('UNIQUE RNTIS: ',unique_rntis)
        for rnti in unique_rntis:
            rnti_id = df.loc[df['RNTI'] == rnti]
            print(rnti_id)
            d = {}
            d['rnti'] = rnti
            d['tti'] = TTI
            d['newTx'] = rnti_id['TxType'].value_counts()['newTx']  
            d["reTx"]= rnti_id['TxType'].value_counts()['reTx'] 
            d["avgHarqID"] = rnti_id['HARQID'].mean()
            id += 1
            d ['id']= id
            d ['percnt'] = d['reTx']/(d['newTx'] + d['reTx'])
            print("data: ",d)
            # new_df = pd.DataFrame([d])
            # dataDF = pd.concat([dataDF, new_df], ignore_index=True)
            new_data_df = pd.DataFrame([d])
            dataDF = pd.concat([dataDF, new_data_df], ignore_index=True)
            # dataDF = pd.concat([dataDF, pd.DataFrame([d])], ignore_index=True)

            # print(data)
    print(dataDF)
    dataDF.to_csv("Results.csv")

def boxPlot(file):
    # Load the data
    df = pd.read_csv(file)
    df.columns = df.columns.str.replace(' ', '') 

    # Create a boxplot using seaborn
    plt.figure(figsize=(12, 8))
    sns.set_theme(style="whitegrid")  # Set the theme for a cleaner look

    # Create the boxplot
    ax = sns.boxplot(x='tti', y='avgHarqID', data=df, palette="Set2", width=0.6, fliersize=5)

    # Add titles and labels with enhanced formatting
    plt.title('Distribution of Percent Values Across Harq ID', fontsize=14, fontweight='bold')
    plt.xlabel('Average Harq ID', fontsize=12)
    plt.ylabel('avgHarqID', fontsize=12)
    plt.xticks(fontsize=10)
    plt.yticks(fontsize=10)

    # Annotate median and IQR
    for patch, median in zip(ax.artists, ax.lines[4::6]):
        # Calculate the median value
        median_value = median.get_ydata()[0]
        # Annotate the median
        ax.annotate(f'Median: {median_value:.2f}', 
                    xy=(patch.get_x() + patch.get_width() / 2, median_value),
                    xytext=(0, 5), textcoords='offset points',
                    ha='center', va='bottom', fontsize=10, color='black')

    # Highlight outliers
    # outliers = df[np.abs(df['percnt'] - df['percnt'].median()) > 1.5 * (df['percnt'].quantile(0.75) - df['percnt'].quantile(0.25))]
    # for index, row in outliers.iterrows():
    #     plt.annotate(f"{row['percnt']:.2f}", 
    #                  (row['tti'], row['percnt']),
    #                  xytext=(5, 0), textcoords='offset points',
    #                  fontsize=9, color='red', alpha=0.7)

    # Display a legend for outliers
    # plt.text(0.95, 0.02, 'Red annotations indicate outliers', 
    #          transform=plt.gca().transAxes, fontsize=9, color='red', alpha=0.7,
    #          ha='right', va='bottom')

    # Add a grid for better readability
    plt.grid(visible=True, linestyle='--', alpha=0.5)

    # Add titles and labels with enhanced formatting
    plt.title('Distribution of Harq IDs Across Transmission Time Intervals (TTI) Scheduling', fontsize=16, fontweight='bold')
    plt.xlabel('TTI (Transmission Time Interval)', fontsize=14, labelpad=10)
    plt.ylabel('Harq ID', fontsize=14, labelpad=10)
    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)

    # Show the plot
    plt.tight_layout()  # Adjust layout to make space for annotations
    plt.show()

def main():
    print("Start")
    # df = readSimLogFile('5UE_TTI2_241018-135922_simulationMetrics.mat')
    # convertMATtoDIC("./")
    # fileAnalysis("./csv/")

    boxPlot("Results.csv")

if __name__ == "__main__":
    """ This is executed when run from the command line """
    main()