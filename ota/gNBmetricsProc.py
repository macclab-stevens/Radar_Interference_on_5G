#! /opt/local/bin/python3

import csv
import json
import os
import argparse
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

def convert_metrics_to_csv(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
        writer = csv.writer(outfile)
        # Adjust headers as needed
        writer.writerow([
            'timestamp', 'error_indication_count', 'average_latency', 'latency_histogram',
            'pci', 'rnti', 'cqi', 'ri', 'dl_mcs', 'dl_brate', 'dl_nof_ok', 'dl_nof_nok', 'dl_bs',
            'pusch_snr_db', 'pucch_snr_db', 'ta_ns', 'ul_mcs', 'ul_brate', 'ul_nof_ok', 'ul_nof_nok', 'bsr'
        ])

        for line in infile:
            try:
                data = json.loads(line.strip())
                cell_metrics = data['cell_metrics']
                ue_container = data['ue_list'][0]['ue_container'] if data['ue_list'] else {}

                writer.writerow([
                    data['timestamp'],
                    cell_metrics['error_indication_count'],
                    cell_metrics['average_latency'],
                    cell_metrics['latency_histogram'],
                    ue_container.get('pci', ''),
                    ue_container.get('rnti', ''),
                    ue_container.get('cqi', ''),
                    ue_container.get('ri', ''),
                    ue_container.get('dl_mcs', ''),
                    ue_container.get('dl_brate', ''),
                    ue_container.get('dl_nof_ok', ''),
                    ue_container.get('dl_nof_nok', ''),
                    ue_container.get('dl_bs', ''),
                    ue_container.get('pusch_snr_db', ''),
                    ue_container.get('pucch_snr_db', ''),
                    ue_container.get('ta_ns', ''),
                    ue_container.get('ul_mcs', ''),
                    ue_container.get('ul_brate', ''),
                    ue_container.get('ul_nof_ok', ''),
                    ue_container.get('ul_nof_nok', ''),
                    ue_container.get('bsr', '')
                ])
            except json.JSONDecodeError as e:
                print(f"Error parsing line: {line.strip()}")
                print(f"JSONDecodeError: {e}")
                continue

def process_all_metrics_files(directory):
    for filename in os.listdir(directory):
        if filename.endswith('.metrics'):
            input_file = os.path.join(directory, filename)
            output_file = os.path.join(directory, filename.replace('.metrics', '.csv'))
            print(f"Processing File: {input_file}")
            convert_metrics_to_csv(input_file, output_file)

def process_single_metrics_file(input_file):
    output_file = input_file.replace('.metrics', '.csv')
    convert_metrics_to_csv(input_file, output_file)

def find_middle_low_point(csv_file, column_name='dl_brate'):
    df = pd.read_csv(csv_file)
    dl_brate = df[column_name]
    
    # Ensure the column contains only numeric values
    dl_brate = pd.to_numeric(dl_brate, errors='coerce')
    
    # Drop NaN values resulting from non-numeric conversion
    dl_brate = dl_brate.dropna()
    
    # Smooth the data using a rolling window to ignore blips
    smoothed_dl_brate = dl_brate.rolling(window=5, center=True).mean()
    
    # Define thresholds for detecting the initial ramp-up and the drop-off point
    if column_name == 'Bitrate':
        ramp_up_threshold = 0.9 * 44
    else:
        ramp_up_threshold = 0.9 * 44e6  # 90% of 44 Mbps
    change_rate_threshold = 0.01  # 2% change
    consecutive_changes_required = 1  # Number of consecutive changes required
    
    # Find the first value that exceeds the ramp-up threshold
    initial_index = -1
    for i in range(1, len(smoothed_dl_brate)):
        print(f"Smoothed_dl_brate[i]: ", smoothed_dl_brate[i])
        if smoothed_dl_brate[i] > ramp_up_threshold:
            initial_index = i
            break
    
    if initial_index == -1:
        print("No valid initial index found that meets the ramp-up threshold.")
        return
    
    print(f"Initial index: {initial_index}")
    
    # Find the point where multiple consecutive changes exceed the change rate threshold
    start_index = -1
    consecutive_changes = 0
    for i in range(initial_index + 1, len(smoothed_dl_brate)):
        if smoothed_dl_brate[i-1] != 0:  # Avoid division by zero
            change_percentage = abs(smoothed_dl_brate[i] - smoothed_dl_brate[i-1]) / smoothed_dl_brate[i-1]
            print(f"Index: {i}, Value: {smoothed_dl_brate[i]}, Change %: {change_percentage * 100:.2f}%")
            if change_percentage > change_rate_threshold:
                consecutive_changes += 1
                if consecutive_changes >= consecutive_changes_required:
                    start_index = i - consecutive_changes + 1
                    break
            else:
                consecutive_changes = 0
    
    if start_index == -1:
        print("No valid starting point found that meets the consecutive change rate threshold.")
        return
    
    print(f"Start index: {start_index}")
    
    # Normalize x-values to start from zero
    x = np.arange(start_index, len(smoothed_dl_brate))
    y = smoothed_dl_brate[start_index:].dropna()  # Drop NaN values resulting from rolling window
    x = x[:len(y)]  # Adjust x to match the length of y
    
    # Fit a quadratic polynomial to the smoothed data
    coefficients = np.polyfit(x, y, 2)
    polynomial = np.poly1d(coefficients)
    
    # Find the minimum value of the polynomial within the range
    x_fit = np.linspace(x.min(), x.max(), 100)
    y_fit = polynomial(x_fit)
    min_x_value = x_fit[np.argmin(y_fit)]
    
    # Find the average low point in the smoothed data around the min_x_value +/- 1
    min_x_index = int(min_x_value)
    low_point_values = y[max(0, min_x_index - 1):min(len(y), min_x_index + 2)]
    if len(low_point_values) == 0:
        closest_index = np.argmin(np.abs(x - min_x_value))
        low_point_values = y[max(0, closest_index - 1):min(len(y), closest_index + 2)]
    average_low_point = low_point_values.mean()
    
    # Convert the average low point from bytes per second to megabits per second (Mbps)
    if column_name == 'dl_brate':
        average_low_point_mbps = (average_low_point * 8) / 1e6
    else:
        average_low_point_mbps = average_low_point
    print(f"Average low point of {column_name} between the two highs: {average_low_point_mbps} Mbps")
    
    # Plot the data and the fitted curve
    plt.clf()
    plt.plot(x, y, 'o', label='Data')
    plt.plot(x_fit, y_fit, '-', label='Fitted curve')
    plt.axvline(x=min_x_value, color='r', linestyle='--', label='Min X Value')
    plt.xlabel('Index')
    plt.ylabel(column_name)
    plt.legend()
    plt.savefig(csv_file.replace('.csv', '_plot.png'))

    return average_low_point_mbps

def convert_iperf_to_csv(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
        writer = csv.writer(outfile)
        writer.writerow(['Time', 'Transfer', 'Bitrate', 'Retr', 'Cwnd'])
        
        for line in infile:
            if line.startswith('['):
                parts = line.split()
                if len(parts) >= 9:
                    time = parts[2].split('-')[0]  # Extract the start time of the interval
                    transfer = parts[4]
                    bitrate = parts[6]
                    retr = parts[8]
                    cwnd = parts[10] if len(parts) > 10 else ''
                    writer.writerow([time, transfer, bitrate, retr, cwnd])

def process_all_iperf_files(directory):
    results = []
    for filename in os.listdir(directory):
        if filename.endswith('.iperf.csv'):
            input_file = os.path.join(directory, filename)
            print(f"Processing File: {input_file}")
            average_low_point_mbps = find_middle_low_point(input_file, column_name='Bitrate')
            prf = filename.split('_')[0]  # Assuming the PRF is the first part of the filename
            results.append([prf, filename, average_low_point_mbps])
    
    output_file = os.path.join(directory, 'iperfLowPoints.csv')
    with open(output_file, 'w', newline='') as outfile:
        writer = csv.writer(outfile)
        writer.writerow(['PRF', 'Filename', 'Average Low Point (Mbps)'])
        writer.writerows(results)
    print(f"Results saved to {output_file}")

def plot_iperf_low_points(csv_file):
    df = pd.read_csv(csv_file)
    df.sort_values(by='PRF', inplace=True)
    print(df)
    plt.clf()
    plt.plot(df['PRF'], df['Average Low Point (Mbps)'], 'o-')
    plt.xlabel('PRF')
    plt.ylabel('Average Low Point (Mbps)')
    plt.title('Average Low Point vs PRF')
    
    # Reduce the number of ticks on the x-axis
    df.fillna(0)
    
    plt.savefig(csv_file.replace('.csv', '_plot.png'))
    plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Convert .metrics files to .csv and analyze dl_brate')
    parser.add_argument('-f', '--folder', type=str, help='Convert all .metrics files in the specified folder')
    parser.add_argument('-c', '--file', type=str, help='Convert a single .metrics file')
    parser.add_argument('-m', '--middle-low-point', type=str, help='Find the middle low point of dl_brate in a .csv file')
    parser.add_argument('-i', '--middle-low-point-iperf', type=str, help='Find the middle low point of bitrate in an iperf .csv file')
    parser.add_argument('-I', '--iperf-folder', type=str, help='Find the middle low point of bitrate in all iperf .csv files in the specified folder')
    parser.add_argument('-p', '--iperf', type=str, help='Convert an iperf report to a .csv file')
    parser.add_argument('-l', '--plot-iperf-low-points', type=str, help='Plot the iperfLowPoints.csv file')

    args = parser.parse_args()

    if args.folder:
        process_all_metrics_files(args.folder)
    elif args.file:
        process_single_metrics_file(args.file)
    elif args.middle_low_point:
        find_middle_low_point(args.middle_low_point, column_name='dl_brate')
    elif args.middle_low_point_iperf:
        find_middle_low_point(args.middle_low_point_iperf, column_name='Bitrate')
    elif args.iperf_folder:
        process_all_iperf_files(args.iperf_folder)
    elif args.iperf:
        output_file = args.iperf.replace('.iperf', '.csv')
        convert_iperf_to_csv(args.iperf, output_file)
    elif args.plot_iperf_low_points:
        plot_iperf_low_points(args.plot_iperf_low_points)
    else:
        print("Please specify either a folder with -f, a file with -c, a CSV file with -m, an iperf file with -p, or an iperf CSV file with -i or -I")