#!/opt/homebrew/bin/python3

import os
import pandas as pd

# Base directory containing your folders
base_dir = "./"

# List to hold all data for the master CSV
master_data = []

# Iterate through all folders and subfolders
for root, dirs, files in os.walk(base_dir):
    # Look for files named "_MCS5.txt"
    for file in files:
        if file == "_MCS5.txt":
            # Get the top folder (parent directory of the subfolder)
            top_folder = os.path.basename(os.path.dirname(root))
            subfolder_name = os.path.basename(root)
            
            # Extract PulseWidth (pw) and PulseWidthSlotIdx (PWSI) from the top folder
            parts = top_folder.split("_")
            pw = parts[2].split('pw')[1]
            pwsi = int(parts[4])
            
            # Extract TTI value from the subfolder name
            # print(subfolder_name)
            tti = subfolder_name.split("_")[1]
            # print(tti)
            # Full path to the text file
            file_path = os.path.join(root, file)

            # Read the CSV content
            try:
                # Read the content of _MCS5.txt
                df = pd.read_csv(file_path)

                # Add PulseWidth, PWSI, and TTI columns
                df["PulseWidth"] = pw
                df["PulseWidthSlotIdx"] = pwsi
                df["TTI"] = tti

                # Append to master data
                master_data.append(df)
            except Exception as e:
                print(f"Error processing file {file_path}: {e}")

# Combine all data into a master DataFrame
if master_data:  # Check if there's any data collected
    master_df = pd.concat(master_data, ignore_index=True)

    # Save to a master CSV file
    df_4 = master_df[master_df['TTI'] == '4']
    output_file = os.path.join(base_dir, "rnd_PW_rnd_PWSltIdx_tti_4.csv")
    df_4.to_csv(output_file, index=False)

    df_2 = master_df[master_df['TTI'] == '2']
    output_file = os.path.join(base_dir, "rnd_PW_rnd_PWSltIdx_tti_2.csv")
    df_2.to_csv(output_file, index=False)

    print(f"Master CSV file saved as {output_file}")
else:
    print("No data files found or processed.")