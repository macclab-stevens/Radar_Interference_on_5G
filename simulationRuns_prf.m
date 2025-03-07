% File: /Users/ericforbes/Documents/GitHub/NRTPIS/simulationRuns.m

% Initialize simulation parameters
simParametersBase.folderName = 'Run_30Khz_Prf_2_10-5000/';
simParametersBase.numerology = 1; % 0 = 15KHz, 1 = 30KHz

% Define supported bandwidths
suppBW_15 = [10, 15, 20, 25, 30, 40, 50];
rbsBW_15 = [52, 79, 106, 133, 160, 216, 270];
suppBW_30 = [10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100];
rbsBW_30 = [24, 38, 51, 65, 78, 106, 133, 162, 189, 217, 245, 273];

radarBWarr = [1, 2, 5, 10, 20];
radarBWoffsetArr = [0,2,4,6,8,10,12,14,16,18,19];

% Sampling frequency
fs = 7680000 * 2^simParametersBase.numerology;

simParametersBase.RadarOn = true;

% Generate PRF and PulseWidth steps
prf_steps = 10:10:5000;
% prf_steps = prf_steps(mod(fs, prf_steps) == 0) % Ensure divisors of fs
pwSteps = linspace(0.1e-6, 100e-6, 100)%0.1:0.2:100;

% Generate TTI values
ttis = [2, 4, 7, 14];

% Intervals for PulsePower    
PulsePowerAtten = 20:-5:-100;

% Create all combinations of TTI and radarBWoffset
[ttiGrid, prf_stepsGrid] = ndgrid(ttis, prf_steps);
ttiPairs = [ttiGrid(:), prf_stepsGrid(:)]
numCombinations = size(ttiPairs, 1);

fprintf("NumCombinations %f \n",numCombinations)
% Number of simulations
numSimulations = numCombinations;

% Run simulations in parallel
parfor i = 1:numSimulations
    % Initialize simulation-specific parameters
    simParameters = simParametersBase;
    simParameters.parForId = i;

    simParameters.TTIGranularity = ttiPairs(i,1);
    simParameters.prf = ttiPairs(i, 2);
    simParameters.PulseWidth = 50 * 1e-6; %ttiPairs(i, 2);%
    simParameters.pulseAttenuation = 0% ttiPairs(i, 2);
    % Set slotOrSymbol based on TTIGranularity
    if simParameters.TTIGranularity == 14
        simParameters.slotOrSymbol = 0;
    else
        simParameters.slotOrSymbol = 1;
    end

    % Generate random parameters
    % simParameters.prf = 2000; % Example fixed PRF
    % simParameters.PulseWidth = 50 * 1e-6;
    
    pulseStartIndx = 1000; %randperm(15350, 1);
    simParameters.PulseStartIndx = int32(pulseStartIndx);
    simParameters.PulseBW = 20e6;
    simParameters.PulseBWoffset = 0%9.5e6;
    simParameters.schStrat = "RR";
    simParameters.mcsInt = 10;
    simParameters.NumFramesSim = 5;
    simParameters.mcsTable = '256QAM';
    simParameters.NumUEs = 20;

    simParameters.UEPosition = repmat([300, 0, 0], simParameters.NumUEs, 1);
    simParameters.ulAppDataRate = repmat(10e6, simParameters.NumUEs, 1);
    simParameters.dlAppDataRate = repmat(10e6, simParameters.NumUEs, 1);

    % Generate output folder structure
    dt = datestr(now, 'yymmdd-HHMMSS');
    newFolderName = strcat('Results/TTI_Run_', dt, '_PWSl_', ...
        string(simParameters.PulseStartIndx), '/tti_', ...
        string(simParameters.TTIGranularity), "_BWOffset_", ...
        string(simParameters.PulseBWoffset / 1e6), "_MCSWalk_", ...
        string(simParameters.mcsTable), "/");

    % Run the main function
    mainFunc(simParameters);
    % try
    %     mainFunc(simParameters);
    % catch ME
    %     fprintf('Error in simulation %d: %s\n', i, ME.message);
    %     disp(i)
    %     mainFunc(simParameters);
    % end
end