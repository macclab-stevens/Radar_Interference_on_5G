#!/opt/homebrew/bin/python3

import os
import pandas as pd

# Base directory containing your folders
base_dir = "/Results/rndPW_PWIdx"

# List to hold all data for the master CSV
master_data = []

# Iterate through all folders and subfolders
for root, dirs, files in os.walk(base_dir):
    # Look for files named "_MCS5.txt"
    for file in files:
        if file == "_MCS5.txt":
            # Extract folder-specific data
            folder_name = os.path.basename(root)
            parts = folder_name.split("_")
            
            # Extract PulseWidth (pw) and PulseWidthSlotIdx (PWSI)
            pw = next((int(part[2:]) for part in parts if part.startswith("pw")), None)
            pwsi = next((int(part[4:]) for part in parts if part.startswith("PWSI")), None)
            
            # Extract TTI value from the subfolder (tti_x_MCSWalk)
            tti_folder = os.path.basename(root)
            tti = next((int(part[4:]) for part in tti_folder.split("_") if part.startswith("tti")), None)
            
            # Full path to the text file
            file_path = os.path.join(root, file)
            
            # Read the CSV content
            try:
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
master_df = pd.concat(master_data, ignore_index=True)

# Save to a master CSV file
output_file = "master_data.csv"
master_df.to_csv(output_file, index=False)

print(f"Master CSV file saved as {output_file}")