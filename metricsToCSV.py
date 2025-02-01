import os
import scipy.io
import pandas as pd
import numpy as np


def process_sim_parameters(sim_params_file):
    """Load radar parameters and TTI from simParameters.mat."""
    try:
        sim_params = scipy.io.loadmat(sim_params_file)

        # Access the main simParameters structure
        sim_parameters_struct = sim_params.get("simParameters", None)
        if sim_parameters_struct is None:
            raise ValueError("simParameters not found in .mat file.")

        sim_parameters = sim_parameters_struct[0, 0]  # Access the first (and only) instance

        # Extract TTI granularity
        tti = sim_parameters["TTIGranularity"][0, 0] if "TTIGranularity" in sim_parameters.dtype.names else None
        PulseBWoffset = sim_parameters['PulseBWoffset'][0,0]
        numRBs = sim_parameters['NumRBs'][0,0]
        NumFrames = sim_parameters['NumFramesSim'][0,0]
        pulseAttenuation  = sim_parameters['pulseAttenuation'][0,0]
        # Extract radar parameters (ensure 'radar' field exists)
        radar_params = {}
        if "radar" in sim_parameters.dtype.names:
            radar_struct = sim_parameters["radar"][0, 0]  # Access the radar structure
            radar_params = {
                field: radar_struct[field][0, 0]
                for field in radar_struct.dtype.names
                if field != "waveform"  # Exclude the "waveform" field
                
            }

        return radar_params, tti,PulseBWoffset,numRBs,NumFrames,pulseAttenuation
    except Exception as e:
        #print(f"Error processing simParameters file {sim_params_file}: {e}")
        return {}, None

def process_timestep_logs(timestep_logs):
    """Process timestepLogs to extract throughput and goodput for each RNTI."""
    throughput_goodput = {}
    #slot indicies
    dirIdx = 4 ; gpIdx = 13; tpIdx=12
    #symbol based indicies
    # dirIdx = 3 ; gpIdx = 12; tpIdx=11
    for entry in timestep_logs:
        for row in entry:
            if isinstance(row, (list, np.ndarray)):  # Ensure row has enough columns
                try:
                    # Extract throughput and goodput arrays
                    if row[3] == ['Type']: dirIdx = 3 ; gpIdx = 12; tpIdx=11
                    # if row[4] != "DL" or row[4]!="UL": 
                    #     dirColumn = 
                    direction = str(row[dirIdx].item() if isinstance(row[dirIdx], np.ndarray) else row[4])
                    throughput_array = row[tpIdx]  # Throughput is at index 12
                    goodput_array = row[gpIdx]  # Goodput is at index 13
                    # Check if throughput_array and goodput_array are valid arrays
                    if isinstance(throughput_array, np.ndarray):
                        throughput_array = throughput_array.flatten()  # Convert to 1D
                    if isinstance(goodput_array, np.ndarray):
                        goodput_array = goodput_array.flatten()  # Convert to 1D

                    # Iterate through all UEs (assumed to match by index)
                    for rnti, (throughput, goodput) in enumerate(zip(throughput_array, goodput_array), start=1):
                        if rnti not in throughput_goodput:
                            throughput_goodput[rnti] = {
                                "DL_throughput": 0,
                                "DL_goodput": 0,
                                "UL_throughput": 0,
                                "UL_goodput": 0,
                            }

                        # Convert throughput and goodput from bytes to bits (multiply by 8)
                        throughput_bits = throughput * 8
                        goodput_bits = goodput * 8

                        # Accumulate throughput and goodput based on direction
                        if direction == 'DL':
                            throughput_goodput[rnti]["DL_throughput"] += throughput_bits
                            throughput_goodput[rnti]["DL_goodput"] += goodput_bits
                        elif direction == 'UL':
                            throughput_goodput[rnti]["UL_throughput"] += throughput_bits
                            throughput_goodput[rnti]["UL_goodput"] += goodput_bits

                except Exception as e:
                    #print(f"Skipping invalid timestep row: {row}, error: {e}")
                    continue  # Skip invalid rows

    return throughput_goodput


def process_scheduling_logs(scheduling_logs):
    """Process SchedulingAssignmentLogs and compute metrics."""
    metrics = {}

    for entry in scheduling_logs:
        for row in entry:
            if isinstance(row, (list, np.ndarray)) and len(row) > 12:  # Validate row structure
                try:
                    # Extract and flatten scalar fields
                    rnti = int(row[0].item() if isinstance(row[0], np.ndarray) else row[0])
                    direction = str(row[3].item() if isinstance(row[3], np.ndarray) else row[3])
                    num_sym = int(row[6].item() if isinstance(row[6], np.ndarray) else row[6])
                    mcs = int(row[7].item() if isinstance(row[7], np.ndarray) else row[7])

                    # Extract transmission type and ensure it's valid
                    tx_type = (
                        row[12].item().strip()
                        if isinstance(row[12], np.ndarray) and isinstance(row[12].item(), str)
                        else row[12].strip()
                        if isinstance(row[12], str)
                        else None
                    )
                    if tx_type is None or tx_type not in ['newTx', 'reTx']:
                        raise ValueError(f"Invalid tx_type: {tx_type}")

                except (ValueError, TypeError, IndexError, AttributeError) as e:
                    #print(f"Skipping invalid scheduling row: {row}, error: {e}")
                    continue  # Skip invalid rows

                if rnti not in metrics:
                    metrics[rnti] = {
                        "numDLTotal": 0,
                        "numDLnew": 0,
                        "numReTx_DL": 0,
                        "avgMCS_DL": [],
                        "numULTotal": 0,
                        "numULnew": 0,
                        "numReTx_UL": 0,
                        "avgMCS_UL": [],
                        "DL_throughput": 0,
                        "DL_goodput": 0,
                        "UL_throughput": 0,
                        "UL_goodput": 0,
                    }

                # Count DL/UL metrics based on `tx_type` and `direction`
                if direction == "DL":
                    metrics[rnti]["numDLTotal"] += 1
                    if tx_type == "newTx":
                        metrics[rnti]["numDLnew"] += 1
                    elif tx_type == "reTx":
                        metrics[rnti]["numReTx_DL"] += 1
                    metrics[rnti]["avgMCS_DL"].append(mcs)
                elif direction == "UL":
                    metrics[rnti]["numULTotal"] += 1
                    if tx_type == "newTx":
                        metrics[rnti]["numULnew"] += 1
                    elif tx_type == "reTx":
                        metrics[rnti]["numReTx_UL"] += 1
                    metrics[rnti]["avgMCS_UL"].append(mcs)

    # Calculate averages
    for rnti, data in metrics.items():
        data["avgMCS_DL"] = np.mean(data["avgMCS_DL"]) if data["avgMCS_DL"] else 0
        data["avgMCS_UL"] = np.mean(data["avgMCS_UL"]) if data["avgMCS_UL"] else 0

    return metrics


def process_mat_file(filepath, sim_params_file):
    """Load and process a .mat file."""
    try:
        mat_data = scipy.io.loadmat(filepath)

        if "simulationLogs" in mat_data:
            simulation_logs = mat_data["simulationLogs"][0][0]

            # Extract and process scheduling logs
            scheduling_logs = simulation_logs["SchedulingAssignmentLogs"]
            scheduling_data = [entry[0] for entry in scheduling_logs if len(entry) > 0]
            metrics = process_scheduling_logs(scheduling_data)

            # Extract and process timestep logs
            timestep_logs = simulation_logs["TimeStepLogs"]
            timestep_data = [entry[0] for entry in timestep_logs if len(entry) > 0]
            throughput_goodput = process_timestep_logs(timestep_data)

            # Integrate throughput and goodput into metrics
            for rnti, tg_data in throughput_goodput.items():
                if rnti in metrics:
                    metrics[rnti]["DL_throughput"] = tg_data["DL_throughput"]
                    metrics[rnti]["DL_goodput"] = tg_data["DL_goodput"]
                    metrics[rnti]["UL_throughput"] = tg_data["UL_throughput"]
                    metrics[rnti]["UL_goodput"] = tg_data["UL_goodput"]

            # Process simulation parameters
            radar_params, tti,PulseBWoffset,numRBs,NumFrames,pulseAttenuation = process_sim_parameters(sim_params_file)

            return metrics, radar_params, tti,PulseBWoffset,numRBs,NumFrames,pulseAttenuation
        else:
            #print(f"No simulationLogs found in {filepath}")
            return None, None, None
    except Exception as e:
        #print(f"Error processing {filepath}: {e}")
        return None, None, None


def save_metrics_to_csv(metrics, radar_params, tti,PulseBWoffset,numRBs,NumFrames,pulseAttenuation, output_file,folder_name):
    """Save computed DL/UL metrics, radar parameters, and TTI to a CSV file."""
    rows = []
    for rnti, data in metrics.items():
        row = {
            "RNTI": rnti,
            "numDLTotal": data["numDLTotal"],
            "numDLnew": data["numDLnew"],
            "numReTx_DL": data["numReTx_DL"],
            "avgMCS_DL": round(data["avgMCS_DL"], 2),
            "numULTotal": data["numULTotal"],
            "numULnew": data["numULnew"],
            "numReTx_UL": data["numReTx_UL"],
            "avgMCS_UL": round(data["avgMCS_UL"], 2),
            "DL_throughput_bits": round(data["DL_throughput"], 2),
            "DL_goodput_bits": round(data["DL_goodput"], 2),
            "UL_throughput_bits": round(data["UL_throughput"], 2),
            "UL_goodput_bits": round(data["UL_goodput"], 2),
            "TTI": tti,
            'PulseBWoffset':PulseBWoffset,
            "numRBs":numRBs,
            'NumFrames':NumFrames,
            'pulseAttenuation':pulseAttenuation,
            "FolderName": folder_name
        }
        # Add radar parameters
        for key, value in radar_params.items():
            row[key] = value
        rows.append(row)

    # Convert to DataFrame and save
    df = pd.DataFrame(rows)
    df.to_csv(output_file, index=False)
    print(f"Saved metrics to {output_file}")


# def process_directory(root_dir):
#     """Recursively process .mat files in the directory."""
#     for subdir, _, files in os.walk(root_dir):
#         sim_params_file = None
#         folder_name = os.path.basename(subdir)  # Extract folder name

#         for file in files:
#             if file.endswith("simParameters.mat"):
#                 sim_params_file = os.path.join(subdir, file)

#         for file in files:
#             if file.endswith("simulationMetrics.mat"):
#                 filepath = os.path.join(subdir, file)
#                 print(f"Processing file: {filepath}")
#                 if not sim_params_file:
#                     print(f"No simParameters.mat found for {filepath}")
#                     continue
#                 metrics, radar_params, tti,PulseBWoffset,numRBs,NumFrames = process_mat_file(filepath, sim_params_file)
#                 if metrics:
#                     output_file = os.path.join(subdir, "processed_metrics.csv")
#                     save_metrics_to_csv(metrics, radar_params, tti,PulseBWoffset,numRBs,NumFrames, output_file,folder_name)

def process_directory(root_dir):
    """Recursively process .mat files in the directory."""
    for subdir, _, files in os.walk(root_dir):
        #print(subdir)
        folder_name = os.path.basename(subdir)  # Extract folder name
        #print(f"Processing folder: {folder_name}")  # Debugging: Log the folder being processed

        # Check if folder is being skipped
        if not files:
            #print(f"Skipping empty folder: {folder_name}")
            continue

        sim_params_file = None

        # Find simParameters.mat file
        for file in files:
            if file.endswith("simParameters.mat") or file.startswith("Params"):
                sim_params_file = os.path.join(subdir, file)
                break

        if not sim_params_file:
            #print(f"Skipping folder without simParameters.mat: {folder_name}")
            continue

        # Process simulationMetrics.mat files in the folder
        metrics_processed = False
        for file in files:
            if file.endswith("simulationMetrics.mat") or file.startswith('Logs'):
                filepath = os.path.join(subdir, file)
                #print(f"Processing file: {filepath}")  # Debugging: Log the file being processed

                metrics, radar_params, tti, PulseBWoffset, numRBs, NumFrames,pulseAttenuation = process_mat_file(filepath, sim_params_file)
                if metrics:
                    output_file = os.path.join(subdir, "processed_metrics.csv")
                    save_metrics_to_csv(metrics, radar_params, tti, PulseBWoffset, numRBs, NumFrames,pulseAttenuation, output_file, folder_name)
                    metrics_processed = True

        # if not metrics_processed:
            #print(f"No simulationMetrics.mat processed for folder: {folder_name}")

def generateMainCSV(root_dir):
    df = pd.DataFrame()
    for subdir, _, files in os.walk(root_dir):
        sim_params_file = None
        for file in files:
            if file.endswith("metrics.csv"):
                filepath = os.path.join(subdir, file)
                #print(filepath)
                csvDF = pd.read_csv(filepath)
                #print(csvDF)
                df = pd.concat([df,csvDF],ignore_index=True,axis=0).drop_duplicates()
                # print(df)
    # print(df)
    df = df.drop(['numPulses','pulseIdxOffset_ms'],axis=1)
    # print(df.keys())
    df['DL_throughput_bps'] = df.apply(lambda row: row['DL_throughput_bits'] / (row['NumFrames'] * 10e-3), axis=1)
    df['DL_goodput_bps'] = df.apply(lambda row: row['DL_goodput_bits'] / (row['NumFrames'] * 10e-3), axis=1)
    df['UL_throughput_bps'] = df.apply(lambda row: row['UL_throughput_bits'] / (row['NumFrames'] * 10e-3), axis=1)
    df['UL_goodput_bps'] = df.apply(lambda row: row['UL_goodput_bits'] / (row['NumFrames'] * 10e-3), axis=1)
    df['DLReTxPrcnt'] = df.apply(lambda row: row['numReTx_DL'] / (row['numDLTotal']), axis=1)
    df['ULReTxPrcnt'] = df.apply(lambda row: row['numReTx_UL'] / (row['numULTotal']), axis=1)

    # df['DL_goodput_bps']
    df.to_csv(os.path.join(root_dir, '0_RunData.csv'))
    return 

# Main
if __name__ == "__main__":
    root_directory = "./Run_30Khz_BW_test3_prf3.002k/"  # Change this to the root directory of your files
    process_directory(root_directory)
    generateMainCSV(root_directory)