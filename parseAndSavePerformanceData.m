function parseAndSavePerformanceData(output,simParameters)

% Input string data
output = [
    'Peak UL Throughput: 11.38 Mbps. Achieved Cell UL Throughput: 3.46 Mbps' newline ...
    'Achieved UL Throughput for each UE: [0.64        0.73        0.72        0.67        0.71]' newline ...
    'Achieved Cell UL Goodput: 2.15 Mbps' newline ...
    'Achieved UL Goodput for each UE: [0.4        0.45        0.45        0.42        0.44]' newline ...
    'Peak UL spectral efficiency: 2.28 bits/s/Hz. Achieved UL spectral efficiency for cell: 0.43 bits/s/Hz' newline ...
    'Peak DL Throughput: 12.80 Mbps. Achieved Cell DL Throughput: 3.60 Mbps' newline ...
    'Achieved DL Throughput for each UE: [0.73        0.75        0.78        0.68        0.67]' newline ...
    'Achieved Cell DL Goodput: 2.03 Mbps' newline ...
    'Achieved DL Goodput for each UE: [0.41        0.42        0.42         0.4        0.39]' newline ...
    'Peak DL spectral efficiency: 2.56 bits/s/Hz. Achieved DL spectral efficiency for cell: 0.41 bits/s/Hz'
];

% Parse data using regular expressions
parsedData = struct();
parsedData.Peak_UL_Throughput = extractValue(output, 'Peak UL Throughput: ([\d.]+) Mbps');
parsedData.Achieved_Cell_UL_Throughput = extractValue(output, 'Achieved Cell UL Throughput: ([\d.]+) Mbps');
parsedData.Achieved_UL_Throughput_per_UE = extractArray(output, 'Achieved UL Throughput for each UE: \[([^\]]+)\]');
parsedData.Achieved_Cell_UL_Goodput = extractValue(output, 'Achieved Cell UL Goodput: ([\d.]+) Mbps');
parsedData.Achieved_UL_Goodput_per_UE = extractArray(output, 'Achieved UL Goodput for each UE: \[([^\]]+)\]');
parsedData.Peak_UL_Spectral_Efficiency = extractValue(output, 'Peak UL spectral efficiency: ([\d.]+) bits/s/Hz');
parsedData.Achieved_UL_Spectral_Efficiency = extractValue(output, 'Achieved UL spectral efficiency for cell: ([\d.]+) bits/s/Hz');
parsedData.Peak_DL_Throughput = extractValue(output, 'Peak DL Throughput: ([\d.]+) Mbps');
parsedData.Achieved_Cell_DL_Throughput = extractValue(output, 'Achieved Cell DL Throughput: ([\d.]+) Mbps');
parsedData.Achieved_DL_Throughput_per_UE = extractArray(output, 'Achieved DL Throughput for each UE: \[([^\]]+)\]');
parsedData.Achieved_Cell_DL_Goodput = extractValue(output, 'Achieved Cell DL Goodput: ([\d.]+) Mbps');
parsedData.Achieved_DL_Goodput_per_UE = extractArray(output, 'Achieved DL Goodput for each UE: \[([^\]]+)\]');
parsedData.Peak_DL_Spectral_Efficiency = extractValue(output, 'Peak DL spectral efficiency: ([\d.]+) bits/s/Hz');
parsedData.Achieved_DL_Spectral_Efficiency = extractValue(output, 'Achieved DL spectral efficiency for cell: ([\d.]+) bits/s/Hz');

% Convert the struct to a table
T = struct2table(parsedData);
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');

global pulON; % Access the global variable pulON

pulONStatus = 'ON';
if ~pulON
    pulONStatus = 'OFF';
end
fileName = sprintf('Analysis/throughput_%s_pulON_%s_NumUEs_%d_TTIGran_%d.csv', ...
                   timestamp, pulONStatus, simParameters.NumUEs, simParameters.TTIGranularity);
% Generate the file name with date and time
% fileName = sprintf('Analysis/throughput_%s.csv', timestamp);

% Save the table to a CSV file
if ~exist('Analysis', 'dir')
    mkdir('Analysis');
end
writetable(T, fileName);

disp(['Data successfully saved to: ' fileName]);

% Helper function to extract single values
function value = extractValue(inputStr, pattern)
    tokens = regexp(inputStr, pattern, 'tokens');
    if ~isempty(tokens)
        value = str2double(tokens{1}{1});
    else
        value = NaN;
    end
end

% Helper function to extract arrays
function array = extractArray(inputStr, pattern)
    tokens = regexp(inputStr, pattern, 'tokens');
    if ~isempty(tokens)
        array = str2num(tokens{1}{1}); %#ok<ST2NM>
    else
        array = [];
    end
end
end