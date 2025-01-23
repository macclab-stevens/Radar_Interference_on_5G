% MATLAB Script to Process 27 MCS Data Files and Compile Averaged Results

% Clear workspace and command window
clear; clc;

% Define the folder containing the files
folderPath = './Results/TTI_Run_241028-072929/tti_780_MCSWalk_256QAM/'; % Replace with your folder path

% Initialize an array to store the final results
finalResults = [];

% Loop over MCS values from 1 to 27
for mcsIndex = 5:5
    % Construct the file name
    fileName = fullfile(folderPath, ['_MCS' num2str(mcsIndex) '.txt']);
    
    % Check if the file exists
    if ~isfile(fileName)
        warning('File %s does not exist. Skipping.', fileName);
        continue;
    end
    
    % Read the data from the file
    % Assuming the file has a header row
    dataTable = readtable(fileName);
    
    % Check if the table is empty
    if isempty(dataTable)
        warning('File %s is empty. Skipping.', fileName);
        continue;
    end
    
    % Calculate the mean for each RNTI over all the rows in the file
    % Group by the RNTI column and calculate the averages for the other columns
    avgDataTable = varfun(@mean, dataTable);

    % Remove the 'GroupCount' column that is generated during averaging
    % avgDataTable.GroupCount = [];
    
    % Add an MCS column corresponding to the current MCS index
    avgDataTable.MCS = repmat(mcsIndex, height(avgDataTable), 1);
    
    % Rearrange the table so that the MCS column is the first column
    avgDataTable = movevars(avgDataTable, 'MCS', 'Before', 'mean_RNTIs_DL');
    
    % Append the averaged data to the final results array
    finalResults = [finalResults; avgDataTable];
end

% Convert the results array to a table for better readability
resultsTable = finalResults;

% Display the results
disp(resultsTable);

% Optionally, write the results to a CSV file
% writetable(resultsTable, 'averaged_MCS_results.csv');