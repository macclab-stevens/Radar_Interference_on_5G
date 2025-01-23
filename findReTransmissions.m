% ------------------------------------------------------------------------
% Function: findReTransmissions
% Description:
%   This function processes simulation logs to analyze and summarize
%   retransmission data for both Downlink (DL) and Uplink (UL) transmissions.
%   It calculates the number of retransmissions, average MCS (Modulation
%   and Coding Scheme), and maps these values to the closest coding rate
%   using the MCS Table.
%
% Inputs:
%   - simulationLogs: Cell array containing scheduling assignment logs.
%   - simParameters: Struct containing simulation configuration parameters.
%
% Outputs:
%   - resultsTable: A table summarizing the results, including:
%       - RNTIs_DL: Unique RNTIs for Downlink.
%       - numDLTotal: Total DL transmissions.
%       - numDLnew: New DL transmissions.
%       - numReTx_DL: Retransmitted DL packets.
%       - avgMCS_DL: Average DL MCS.
%       - numULTotal: Total UL transmissions.
%       - numULnew: New UL transmissions.
%       - numReTx_UL: Retransmitted UL packets.
%       - avgMCS_UL: Average UL MCS.
%
% Author:
%   [Your Name]
%
% Date:
%   [Date of Creation]
%
% ------------------------------------------------------------------------
function resultsTable = findReTransmissions(simulationLogs,simParameters)

    analyzeSimulationLogs(simulationLogs);
    
    simTable = simulationLogs{1, 1}.SchedulingAssignmentLogs();
    numReTxDL =  zeros(simParameters.NumUEs,1);
    numReTxUL = zeros(simParameters.NumUEs,1);
    avgMCS = zeros(simParameters.NumUEs,1);
    [rows, cols] = size(simTable);
   
    % Define MCS Table with indices
    MCS_Table = table();
    MCS_Table.Index = (0:27)';  % MCS indices from 0 to 27
    MCS_Table.qm = [2; 2; 2; 2; 2; 4; 4; 4; 4; 4; 4; 6; 6; 6; 6; 6; 6; 6; 6; 6; 8; 8; 8; 8; 8; 8; 8; 8];
    MCS_Table.coding_rate = [120; 193; 308; 449; 602; 378; 434; 490; 553; 616; 658; 466; 517; 567; 616; 666; 719; 772; 822; 873; 682.5; 711; 754; 797; 841; 885; 916.5; 948];
    MCS_Table.efficiency = [0.2344; 0.3770; 0.6016; 0.8770; 1.1758; 1.4766; 1.6953; 1.9141; 2.1602; 2.4063; 2.5703; 2.7305; 3.0293; 3.3223; 3.6094; 3.9023; 4.2129; 4.5234; 4.8164; 5.1152; 5.3320; 5.5547; 5.8906; 6.2266; 6.5703; 6.9141; 7.1602; 7.4063];
        
    % Step 1: Extract headers and data
    headers = simTable(1, :);
    data = simTable(2:end, :);
    
    % Step 2: Convert data to table
    T = cell2table(data, 'VariableNames', headers);
    
    % Step 3: Clean and prepare the table
    % Rename variables to valid identifiers
    T.Properties.VariableNames = matlab.lang.makeValidName(T.Properties.VariableNames);
    
    % % Convert numeric variables
    % numericVars = {'RNTI', 'Frame', 'Slot', 'StartSym', 'NumSym', 'MCS', 'NumLayers', 'HARQID', 'RV', 'FeedbackSlotOffset'};
    % for i = 1:length(numericVars)
    %     varName = numericVars{i};
    %     if iscell(T.(varName))
    %         T.(varName) = cellfun(@str2double, T.(varName));
    %     end
    % end
    
    % Convert 'NDIFlag' to logical
    if iscell(T.NDIFlag)
        T.NDIFlag = cellfun(@(x) isequal(x, true) || strcmpi(x, 'true'), T.NDIFlag);
    end
    
    % Ensure 'TxType' and 'GrantType' are strings
    if iscell(T.TxType)
        T.TxType = string(T.TxType);
    end
    
    if iscell(T.GrantType)
        T.GrantType = string(T.GrantType);
    end
    
    % Step 4: Filter retransmissions ('TxType' == 'reTx')
    reTxData = T(T.TxType == "reTx", :);
    dlTotal = T(T.GrantType == "DL", :);
    ulTotal = T(T.GrantType == "UL", :);
    dlNew = dlTotal(dlTotal.TxType == "newTx", :);
    ulNew = ulTotal(ulTotal.TxType == "newTx", :);

    % Step 5: Separate retransmissions by 'DL' and 'UL' based on 'GrantType'
    reTxData_DL = reTxData(reTxData.GrantType == "DL", :);
    reTxData_UL = reTxData(reTxData.GrantType == "UL", :);
    
    % Step 6: Group retransmissions by 'RNTI' and 'GrantType'
    

    
    

    % For DL retransmissions
    [groups_DL, RNTIs_DL] = findgroups(reTxData_DL.RNTI);
    numReTx_DL = splitapply(@numel, reTxData_DL.TxType, groups_DL);
    avgMCS_DL = splitapply(@mean, reTxData_DL.MCS, groups_DL);
    [groups_DL, RNTIs_DL] = findgroups(dlTotal.RNTI);
    numDLTotal = splitapply(@numel, dlTotal.GrantType, groups_DL);
    [groups_DL, RNTIs_DL] = findgroups(dlNew.RNTI);
    numDLnew = splitapply(@numel, dlNew.GrantType, groups_DL);

    % For UL retransmissions
    [groups_UL, RNTIs_UL] = findgroups(reTxData_UL.RNTI);
    numReTx_UL = splitapply(@numel, reTxData_UL.TxType, groups_UL);
    avgMCS_UL = splitapply(@mean, reTxData_UL.MCS, groups_UL);
    
    [groups_UL, RNTIs_UL] = findgroups(ulTotal.RNTI);
    numULTotal = splitapply(@numel, ulTotal.GrantType, groups_UL);

    [groups_UL, RNTIs_UL] = findgroups(ulNew.RNTI);
    numULnew = splitapply(@numel, ulNew.GrantType, groups_UL);
    
    % Combine DL and UL summaries into one table
    % First, create individual tables
    DL_Summary = table(RNTIs_DL, numReTx_DL, avgMCS_DL, 'VariableNames', {'RNTI', 'NumDLReTx', 'AverageMCS_DL'});
    UL_Summary = table(RNTIs_UL, numReTx_UL, avgMCS_UL, 'VariableNames', {'RNTI', 'NumULReTx', 'AverageMCS_UL'});
    
    % Merge the DL and UL summaries based on RNTI
    Summary = outerjoin(DL_Summary, UL_Summary, 'Keys', 'RNTI', 'MergeKeys', true);
    
    Results = table(RNTIs_DL,numDLTotal,numDLnew,numReTx_DL, avgMCS_DL, ...
                 numULTotal,numULnew,numReTx_UL, avgMCS_UL, 'VariableNames', {'RNTIs_DL','numDLTotal','numDLnew','numReTx_DL', 'avgMCS_DL','numULTotal','numULnew','numReTx_UL', 'avgMCS_UL'})

    % Replace NaN with zeros for counts and averages where appropriate
    Summary.NumDLReTx(isnan(Summary.NumDLReTx)) = 0;
    Summary.NumULReTx(isnan(Summary.NumULReTx)) = 0;
    Summary.AverageMCS_DL(isnan(Summary.AverageMCS_DL)) = 0;
    Summary.AverageMCS_UL(isnan(Summary.AverageMCS_UL)) = 0;
    
    % Step 7: Define the MCS Table with indices
    MCS_Table = table();
    MCS_Table.Index = (0:27)';  % MCS indices from 0 to 27
    MCS_Table.qm = [2; 2; 2; 2; 2; 4; 4; 4; 4; 4; 4; 6; 6; 6; 6; 6; 6; 6; 6; 6; 8; 8; 8; 8; 8; 8; 8; 8];
    MCS_Table.coding_rate = [120; 193; 308; 449; 602; 378; 434; 490; 553; 616; 658; 466; 517; 567; 616; 666; 719; 772; 822; 873; 682.5; 711; 754; 797; 841; 885; 916.5; 948];
    MCS_Table.efficiency = [0.2344; 0.3770; 0.6016; 0.8770; 1.1758; 1.4766; 1.6953; 1.9141; 2.1602; 2.4063; 2.5703; 2.7305; 3.0293; 3.3223; 3.6094; 3.9023; 4.2129; 4.5234; 4.8164; 5.1152; 5.3320; 5.5547; 5.8906; 6.2266; 6.5703; 6.9141; 7.1602; 7.4063];
    
    % Step 8: Map average MCS to approximate closest coding rate
    
    % For DL retransmissions
    Summary.ClosestMCSIndex_DL = NaN(height(Summary), 1);
    Summary.CodingRate_DL = NaN(height(Summary), 1);
    
    for i = 1:height(Summary)
        avg_mcs_dl = Summary.AverageMCS_DL(i);
        if avg_mcs_dl > 0
            % Find the closest MCS index (rounding to nearest integer)
            [~, idx] = min(abs(MCS_Table.Index - avg_mcs_dl));
            mcs_idx = MCS_Table.Index(idx);
            % Store the closest MCS index and corresponding coding rate
            Summary.ClosestMCSIndex_DL(i) = mcs_idx;
            Summary.CodingRate_DL(i) = MCS_Table.coding_rate(idx);
        end
    end
    
    % For UL retransmissions
    Summary.ClosestMCSIndex_UL = NaN(height(Summary), 1);
    Summary.CodingRate_UL = NaN(height(Summary), 1);
    
    for i = 1:height(Summary)
        avg_mcs_ul = Summary.AverageMCS_UL(i);
        if avg_mcs_ul > 0
            % Find the closest MCS index (rounding to nearest integer)
            [~, idx] = min(abs(MCS_Table.Index - avg_mcs_ul));
            mcs_idx = MCS_Table.Index(idx);
            % Store the closest MCS index and corresponding coding rate
            Summary.ClosestMCSIndex_UL(i) = mcs_idx;
            Summary.CodingRate_UL(i) = MCS_Table.coding_rate(idx);
        end
    end
    
    % Step 9: Display the results
    disp('Retransmissions Summary:');
    disp(Summary);
    class(Summary)
    
    % scatter(Summary.CodingRate_DL,Summary.NumDLReTx)

    resultsTable = Results;
  
end 

function analyzeSimulationLogs(simulationLogs)
    % Analyze TimeStepLogs and SchedulingAssignmentLogs

    % Check if simulationLogs is a cell array and access the first element
    if iscell(simulationLogs)
        simulationLogs = simulationLogs{1, 1}; % Adjust index as needed
    end

    % Validate if simulationLogs contains TimeStepLogs and SchedulingAssignmentLogs
    if isfield(simulationLogs, 'TimeStepLogs') && isfield(simulationLogs, 'SchedulingAssignmentLogs')
        timeStepLogs = simulationLogs.TimeStepLogs;
        schedulingAssignmentLogs = simulationLogs.SchedulingAssignmentLogs;
    else
        error('simulationLogs does not contain the expected fields: TimeStepLogs and SchedulingAssignmentLogs.');
    end

    % Initialize containers for results
    if iscell(timeStepLogs) && ~isempty(timeStepLogs{1, 1}) && isstruct(timeStepLogs{1, 1})
        firstLogEntry = timeStepLogs{1, 1};
        if isfield(firstLogEntry, 'BufferStatusOfUes')
            numUes = size(firstLogEntry.BufferStatusOfUes, 1);
        else
            error('BufferStatusOfUes field is missing in TimeStepLogs.');
        end
    else
        error('TimeStepLogs is not structured as expected.');
    end

    throughputPerUe = zeros(numUes, 1);
    goodputPerUe = zeros(numUes, 1);

    % Process TimeStepLogs
    disp('Processing TimeStepLogs...');
    for i = 1:size(timeStepLogs, 1)
        logEntry = timeStepLogs{i, 1};
        if isfield(logEntry, 'ThroughputBytes') && isfield(logEntry, 'GoodputBytes')
            throughputPerUe = throughputPerUe + logEntry.ThroughputBytes(:);
            goodputPerUe = goodputPerUe + logEntry.GoodputBytes(:);
        else
            warning(['TimeStepLogs entry ', num2str(i), ' is missing ThroughputBytes or GoodputBytes fields.']);
        end
    end

    % Summarize SchedulingAssignmentLogs
    disp('Processing SchedulingAssignmentLogs...');
    schedulingSummary = zeros(numUes, 1); % Example metric
    for i = 1:size(schedulingAssignmentLogs, 1)
        logEntry = schedulingAssignmentLogs{i, 1};
        if isfield(logEntry, 'Rnti') && isfield(logEntry, 'NumScheduledSymbols')
            for j = 1:length(logEntry.Rnti)
                if logEntry.Rnti(j) <= numUes
                    schedulingSummary(logEntry.Rnti(j)) = schedulingSummary(logEntry.Rnti(j)) + logEntry.NumScheduledSymbols(j);
                else
                    warning(['RNTI ', num2str(logEntry.Rnti(j)), ' exceeds the number of UEs.']);
                end
            end
        else
            warning(['SchedulingAssignmentLogs entry ', num2str(i), ' is missing Rnti or NumScheduledSymbols fields.']);
        end
    end

    % Display results
    disp('Throughput per UE:');
    disp(throughputPerUe);
    disp('Goodput per UE:');
    disp(goodputPerUe);
    disp('Scheduling Summary:');
    disp(schedulingSummary);

    % Write results to a CSV file
    resultsTable = table((1:numUes)', throughputPerUe, goodputPerUe, schedulingSummary, ...
                         'VariableNames', {'UE', 'Throughput', 'Goodput', 'ScheduledSymbols'});
    writetable(resultsTable, 'simulation_results.csv');
    disp('Results written to simulation_results.csv');
end