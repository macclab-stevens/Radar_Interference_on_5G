function resultsTable = mainFunc(simParameters)
%effectivly the same as Main but calling it with a different static MCS
%each time

% NR TDD Symbol Based Scheduling Performance Evaluation

% Scenario Configuration
% Check if the Communications Toolbox Wireless Network Simulation Library support package is installed. If the support package is not installed, MATLAB® returns an error with a link to download and install the support package.
wirelessnetworkSupportPackageCheck
% Configure simulation parameters in the simParameters structure.
rng('default'); % Reset the random number generator
% simParameters = []; % Clear simParameters variable
% simParameters.NumFramesSim = 10; % Simulation time in terms of number of 10 ms frames (100 = 10s
simParameters.SchedulingType = simParameters.slotOrSymbol; % Set the value to 0 (slot-based scheduling) or 1 (symbol-based scheduling)
% Specify the number of UEs in the cell, assuming that UEs have sequential radio network temporary identifiers (RNTIs) from 1 to simParameters.NumUEs. If you change the number of UEs, ensure that the number of rows in simParameters.UEPosition parameter equals to the value of simParameters.NumUEs.
% simParameters.NumUEs = 1;
% Assign position to the UEs assuming that the gNB is at (0, 0, 0). N-by-3
% matrix where 'N' is the number of UEs. Each row has (x, y, z) position of a
% UE (in meters)
% simParameters.UEPosition = [500 0 0];% Validate the UE positions
validateattributes(simParameters.UEPosition,{'numeric'},{'nonempty','real','nrows',simParameters.NumUEs,'ncols',3, ...
    'finite'},'simParameters.UEPosition','UEPosition');

% Application traffic configuration
% Set the periodic DL and UL application traffic pattern for UEs.
% Set the periodic DL and UL application traffic pattern for UEs
% simParameters.dlAppDataRate = 16e4*ones(simParameters.NumUEs,1); % DL application data rate in kilo bits per second (kbps)
% simParameters.dlAppDataRate = [10e3];
% simParameters.ulAppDataRate = [10e3];

%% MCS TABLE SELECTION
global mcsTable_selection
mcsTable_selection = simParameters.mcsTable;


%% 

% Set the channel bandwidth to 5 MHz and the subcarrier spacing (SCS) to 15 kHz as defined in 3GPP TS 38.104 Section 5.3.2. The complete bandwidth is assumed to be allotted for PUSCH or PDSCH.
suppBW_15 = [ 10 15 20  25  30  40  50 ]
rbsBW_15 =  [ 52 79 106 133 160 216 270    ]
suppBW_30 = [10 15 20 25 30 40  50  60  70  80  90  100]
rbsBW_30 =  [24 38 51 65 78 106 133 162 189 217 245 273]
simParameters.NumRBs = 51;
simParameters.SCS = 15*2^(simParameters.numerology); % kHz
simParameters.DLBandwidth = 20e6; % Hz
simParameters.ULBandwidth = 20e6; % Hz
simParameters.DLCarrierFreq = 2.595e9; % Hz
simParameters.ULCarrierFreq = 2.595e9; % Hz
%% 

% Specify the TDD DL-UL pattern. The reference subcarrier spacing used for calculating slot duration for the pattern is assumed to be same as actual subcarrier spacing used for transmission as defined by simParameters.SCS. Keep only the symbols intended for guard period during DLULPeriodicity with type (DL or UL) unspecified.
simParameters.DLULPeriodicity = 5; % Duration of the DL-UL pattern in ms
simParameters.NumDLSlots = 7; % Number of consecutive full DL slots at the beginning of each DL-UL pattern
simParameters.NumDLSyms = 8; % Number of consecutive DL symbols in the beginning of the slot following the last full DL slot
simParameters.NumULSyms = 4; % Number of consecutive UL symbols in the end of the slot preceding the first full UL slot
simParameters.NumULSlots = 2; % Number of consecutive full UL slots at the end of each DL-UL pattern
%% 

% Specify the scheduling strategy, the time domain resource assignment granualarity and the maximum limit on the RBs allotted for PDSCH and PUSCH. The time domain resource assignment granualarity is applicable only for symbol-based scheduling. If the number of symbols (DL or UL) are less than the configured time domain resource assignment granularity, then a smaller valid granularity is chosen. For slot-based scheduling, biggest possible granularity in a slot is chosen. The RB transmission limit applies only to new transmissions and not to the retransmissions.
simParameters.SchedulerStrategy = simParameters.schStrat; % Supported scheduling strategies: 'PF', 'RR' and 'BestCQI'
global staticMCS ;
global schStrat ;
schStrat = simParameters.schStrat;
staticMCS = simParameters.mcsInt;
if strcmp(simParameters.schStrat,'StaticMCS')
    staticMCS = simParameters.mcsInt;
end
% simParameters.TTIGranularity = 4;

simParameters.RBAllocationLimitUL = 51; % For PUSCH
simParameters.RBAllocationLimitDL = 51; % For PDSCH
%% 
% Set the UL scheduling related configurations - BSR periodicity and PUSCH preparation time. gNB ensures that PUSCH assignment is received at the UEs at least PUSCHPrepTime ahead of the transmission time.
simParameters.BSRPeriodicity = 1; % Buffer status report transmission periodicity (in ms)
simParameters.PUSCHPrepTime = 200; % In microseconds
%% 
% Set the channel quality related configurations for the UEs. Channel quality is periodically improved or deteriorated by CQI Delta for all RBs of a UE. Whether channel conditions for a particular UE improve or deteriorate is randomly determined by: RB_CQI = RB_CQI +/- CQIDelta. However, the maximum allowed CQI value depends on the UE position and is determined by CQIvsDistance mapping table. This mapping is only applicable when passthrough PHY is used.
simParameters.ChannelUpdatePeriodicity = 0.2; % In sec
simParameters.CQIDelta = 1;
%% 
% Mapping between distance from gNB (first column in meters) and maximum achievable UL CQI value (second column)
simParameters.CQIvsDistance = [ 
    200  15;
    300  12;
    500  10;    
    1000  8;
    1200  7];
%% 
% Specify the PUSCH and PDSCH associated DMRS configurations.
simParameters.DMRSTypeAPosition = 2; % Type-A DM-RS position as 2 or 3
% PUSCH DM-RS configuration
simParameters.PUSCHDMRSAdditionalPosTypeB = 0;
simParameters.PUSCHDMRSAdditionalPosTypeA = 0;
simParameters.PUSCHDMRSConfigurationType = 1;
% PDSCH DM-RS configuration
simParameters.PDSCHDMRSAdditionalPosTypeB = 0;
simParameters.PDSCHDMRSAdditionalPosTypeA = 0;
simParameters.PDSCHDMRSConfigurationType = 1;
%% 


% simParameters.ulAppDataRate = 16e4*ones(simParameters.NumUEs,1); % UL application data rate in kbps
% Validate the DL application data rate
validateattributes(simParameters.dlAppDataRate, {'numeric'},{'nonempty','vector','numel',simParameters.NumUEs,'finite','>',0}, ...
    'dlAppDataRate','dlAppDataRate');
% Validate the UL application data rate
validateattributes(simParameters.ulAppDataRate,{'numeric'},{'nonempty','vector','numel',simParameters.NumUEs,'finite','>',0}, ...
    'ulAppDataRate', 'ulAppDataRate');
%% 
%% 
% Logging and visualization configuration
% The CQIVisualization and RBVisualization parameters control the display of the CQI visualization and the RB assignment visualization respectively. To enable the RB visualization plot, set the RBVisualization field to true.
simParameters.CQIVisualization = false;
simParameters.RBVisualization = false;
% Set the enableTraces as true to log the traces. If the enableTraces is set to false, then CQIVisualization and RBVisualization are disabled automatically and traces are not logged in the simulation. To speed up the simulation, set the enableTraces to false.
enableTraces = true;
% The example updates the metrics plots periodically. Set the number of updates during the simulation. Number of steps must be less than or equal to number of slots in simulation
simParameters.NumMetricsSteps = 20;
% Write the logs to MAT-files. The example uses these logs for post-simulation analysis and visualization.
parametersLogFile = 'simParameters'; % For logging the simulation parameters
simulationLogFile = 'simulationLogs'; % For logging the simulation traces
simulationMetricsFile = 'simulationMetrics'; % For logging the simulation metrics
%% 

% Derived Parameters
% Compute the derived parameters based on the primary configuration parameters specified in the previous section and additionally set some example-specific constants.
simParameters.DuplexMode = 1; % FDD (Value as 0) or TDD (Value as 1)
simParameters.NCellID = 1; % Physical cell ID
simParameters.Position = [0 0 0]; % Position of gNB in (x,y,z) coordinates
% Compute the number of slots in the simulation.
numSlotsSim = (simParameters.NumFramesSim * 10 * simParameters.SCS)/15;
% Determine the PDSCH/PUSCH mapping type.
if simParameters.SchedulingType % Symbol-based scheduling
    simParameters.PUSCHMappingType = 'B';
    simParameters.PDSCHMappingType = 'B';
else % Slot-based scheduling
    simParameters.PUSCHMappingType = 'A';
    simParameters.PDSCHMappingType = 'A';
end
% Set the interval at which the example updates metrics visualization in terms of number of slots.
simParameters.MetricsStepSize = ceil(numSlotsSim / simParameters.NumMetricsSteps);
% Specify one logical channel for each UE, and set the logical channel configuration for all nodes (UEs and gNBs) in the example.
numLogicalChannels = 1;
simParameters.LCHConfig.LCID = 4;
% Specify the RLC entity type in the range [0, 3]. The values 0, 1, 2, and 3 indicate RLC UM unidirectional DL entity, RLC UM unidirectional UL entity, RLC UM bidirectional entity, and RLC AM entity, respectively.
simParameters.RLCConfig.EntityType = 2;
% Construct information for RLC logger.
lchInfo = repmat(struct('RNTI',[],'LCID',[],'EntityDir',[]), [simParameters.NumUEs 1]);
for idx = 1:simParameters.NumUEs
    lchInfo(idx).RNTI = idx;
    lchInfo(idx).LCID = simParameters.LCHConfig.LCID;
    lchInfo(idx).EntityDir = simParameters.RLCConfig.EntityType;
end
% Create RLC channel configuration structure.
rlcChannelConfigStruct.LCGID = 1; % Mapping between logical channel and logical channel group ID
rlcChannelConfigStruct.Priority = 1; % Priority of each logical channel
rlcChannelConfigStruct.PBR = 8; % Prioritized bitrate (PBR), in kilobytes per second, of each logical channel
rlcChannelConfigStruct.BSD = 10; % Bucket size duration (BSD), in ms, of each logical channel
rlcChannelConfigStruct.EntityType = simParameters.RLCConfig.EntityType;
rlcChannelConfigStruct.LogicalChannelID = simParameters.LCHConfig.LCID;
% Set the maximum RLC SDU length (in bytes) as per 3GPP TS 38.323
simParameters.maxRLCSDULength = 9000;
% Calculate maximum achievable CQI value for the UEs based on their distance from the gNB
maxUECQIs = zeros(simParameters.NumUEs, 1); % To store the maximum achievable CQI value for UEs
for ueIdx = 1:simParameters.NumUEs
    % Based on the distance of the UE from gNB, find matching row in CQIvsDistance mapping
    matchingRowIdx = find(simParameters.CQIvsDistance(:, 1) > simParameters.UEPosition(ueIdx,1));
    if isempty(matchingRowIdx)
        maxUECQIs(ueIdx) = simParameters.CQIvsDistance(end, 2);
    else
        maxUECQIs(ueIdx) = simParameters.CQIvsDistance(matchingRowIdx(1), 2);
    end
end
% Define initial UL and DL channel quality as an N-by-P matrix, where 'N' is the number of UEs and 'P' is the number of RBs in the carrier bandwidth. The initial value of CQI for each RB, for each UE, is given randomly and is limited by the maximum achievable CQI value corresponding to the distance of the UE from gNB.
simParameters.InitialChannelQualityUL = zeros(simParameters.NumUEs, simParameters.NumRBs); % To store current UL CQI values on the RBs for different UEs
simParameters.InitialChannelQualityDL = zeros(simParameters.NumUEs, simParameters.NumRBs); % To store current DL CQI values on the RBs for different UEs
for ueIdx = 1:simParameters.NumUEs
    % Assign random CQI values for the RBs, limited by the maximum achievable CQI value
    simParameters.InitialChannelQualityUL(ueIdx, :) = randi([1 maxUECQIs(ueIdx)], 1, simParameters.NumRBs);
    % Initially, DL and UL CQI values are assumed to be equal
    simParameters.InitialChannelQualityDL(ueIdx, :) = simParameters.InitialChannelQualityUL(ueIdx, :);
end

% gNB and UEs Setup
% Create the gNB and UE objects, initialize the channel quality information for UEs and set up the logical channel at gNB and UE. The helper classes hNRGNB.m and hNRUE.m create gNB and UE node respectively, containing the RLC and MAC layer. For MAC layer, hNRGNB.m uses the helper class hNRGNBMAC.m to implement the gNB MAC functionality and  hNRUE.m uses hNRUEMAC.m to implement the UE MAC functionality. Schedulers are implemented in hNRSchedulerRoundRobin.m (RR), hNRSchedulerProportionalFair.m (PF), hNRSchedulerBestCQI.m (Best CQI). All the schedulers inherit from the base class hNRScheduler.m which contains the core scheduling functionality. For RLC layer, both hNRGNB.m and hNRUE.m use hNRUMEntity.m to implement the functionality of the RLC transmitter and receiver. Passthrough PHY layer for UE and gNB is implemented in hNRUEPassThroughPhy.m and hNRGNBPassThroughPhy.m, respectively.
% Create the gNB node and add scheduler
gNB = hNRGNB(simParameters); 
switch(simParameters.SchedulerStrategy)
    case 'RR' % Round-robin scheduler
        scheduler = hNRSchedulerRoundRobin(simParameters);
    case 'PF' % Proportional fair scheduler
        scheduler = hNRSchedulerProportionalFair(simParameters);
    case 'BestCQI' % Best CQI scheduler
        scheduler = hNRSchedulerBestCQI(simParameters);
    case 'StaticMCS' %new Scheduler
        scheduler = hNRSchedulerStaticMCS(simParameters);
end
addScheduler(gNB, scheduler); % Add scheduler to gNB

% gNB.PhyEntity = hNRGNBPassThroughPhy(simParameters); % Add passthrough PHY
gNB.PhyEntity = hNRGNBPhy(simParameters); % Add PHY

configurePhy(gNB, simParameters);
setPhyInterface(gNB); % Set the interface to PHY layer
% Create the set of UE nodes.
UEs = cell(simParameters.NumUEs, 1);
for ueIdx = 1:simParameters.NumUEs
    simParameters.Position = simParameters.UEPosition(ueIdx, :); % Position of the UE
    UEs{ueIdx} = hNRUE(simParameters, ueIdx);
    % UEs{ueIdx}.PhyEntity = hNRUEPassThroughPhy(simParameters, ueIdx); % Add passthrough PHY
    UEs{ueIdx}.PhyEntity = hNRUEPhy(simParameters, ueIdx); % Add PHY
    configurePhy(UEs{ueIdx}, simParameters);
    setPhyInterface(UEs{ueIdx}); % Set the interface to PHY layer

    % Initialize the UL CQI values at gNB scheduler
    channelQualityInfoUL = struct('RNTI', ueIdx, 'CQI', simParameters.InitialChannelQualityUL(ueIdx, :));
    updateChannelQualityUL(gNB.MACEntity.Scheduler, channelQualityInfoUL);
    
    % Initialize the DL CQI values at gNB scheduler
    channelQualityInfoDL = struct('RNTI', ueIdx, 'CQI', simParameters.InitialChannelQualityDL(ueIdx, :));
    updateChannelQualityDL(gNB.MACEntity.Scheduler, channelQualityInfoDL);
 
    % Initialize the DL CQI values at UE for packet error probability estimation
    updateChannelQualityDL(UEs{ueIdx}.MACEntity, channelQualityInfoDL);

    % Setup logical channel at gNB for the UE
    configureLogicalChannel(gNB, ueIdx, rlcChannelConfigStruct);
    % Setup logical channel at UE
    configureLogicalChannel(UEs{ueIdx}, ueIdx, rlcChannelConfigStruct);

    % Create an object for On-Off network traffic pattern and add it to the
    % specified UE. This object generates the uplink (UL) data traffic on the UE
    ulApp = networkTrafficOnOff('GeneratePacket', true, ...
        'OnTime', simParameters.NumFramesSim/100, 'OffTime', 0, 'DataRate', simParameters.ulAppDataRate(ueIdx));
    UEs{ueIdx}.addApplication(ueIdx, simParameters.LCHConfig.LCID, ulApp);

    % Create an object for On-Off network traffic pattern for the specified
    % UE and add it to the gNB. This object generates the downlink (DL) data
    % traffic on the gNB for the UE
    dlApp = networkTrafficOnOff('GeneratePacket', true, ...
        'OnTime', simParameters.NumFramesSim/100, 'OffTime', 0, 'DataRate', simParameters.dlAppDataRate(ueIdx));
    gNB.addApplication(ueIdx, simParameters.LCHConfig.LCID, dlApp);
end


% Radar Setup    
simParameters.radar = [];
simParameters.radar.prf = simParameters.prf; %Hz e.g. 1e3 = 1Khz = 1ms PRI
simParameters.radar.FreqOffset = simParameters.PulseBWoffset;
% simParameters.radar.PulseWidth = 60e-6;
simParameters.radar.PulseWidth = simParameters.PulseWidth; 
% pw = simParameters.radar.PulseWidth * 10^(6)
simParameters.radar.BW =  simParameters.PulseBW;
% pulseSlotId = 1;
% simParameters.radar.pulseSlotId = pulseSlotId;
nfft1 = 512*2^simParameters.numerology;
fs = 7680000*2*2^simParameters.numerology;
w = taylorwin(200,4,-35);
freq = nlfmspec2freq(simParameters.radar.BW ,w);
symLgths = [552   548   548   548   548   548   548   552   548   548   548   548   548   548];
symStarts = [0 552 1100 1648 2196 2744 3292 3840 4392 4940 5488 6036 6584 7132 7680 ];
% slotStartIdx = symStarts(pulseSlotId);
slotStartIdx = simParameters.PulseStartIndx
% slotLength = symLgths(pulseSlotId);
a = zeros(1,slotStartIdx);
x = complex(a,0);
% simParameters.radar.slotStartIdx = slotStartIdx

%num PUlses such that PRI*numPulses > numFrames. 
% each frame is 1ms. 
%Therefor nummPulses = roundUP(numFrames/Pri)
simParameters.radar.numPulses = ceil((simParameters.NumFramesSim *10 * 1e-3)/simParameters.radar.prf)
if mod(fs, simParameters.radar.prf) ~= 0
    fs = fs - mod(fs,simParameters.radar.prf)
end
fm = phased.CustomFMWaveform('SampleRate',fs, ...
    'PulseWidth',simParameters.radar.PulseWidth, ...
    'NumPulses',simParameters.radar.numPulses, ...
    'PRF',simParameters.radar.prf, ...
    'FrequencyModulation',freq, ...
    'PRF',simParameters.radar.prf, ...
    'FrequencyOffsetSource','Property', ...
    'FrequencyOffset',simParameters.radar.FreqOffset, ...
    OutputFormat='Samples', ...
    NumSamples=(7680*2*simParameters.NumFramesSim*10*2^(simParameters.numerology)));
y = fm();
y = y(1:end-slotStartIdx);
% z = [x';y];
% spectrogram(z,100,0,nfft1,fs,'centered','yaxis') 


simParameters.radar.waveform = [x';y];
simParameters.radar.pulseIdxOffset_ms = (slotStartIdx/length(simParameters.radar.waveform) ) * 1e-3

% Assuming x and y are defined
pulse = [x'; y];  % Combine x and y into the pulse array

%apply SignalAttenuation
pulse = db2mag(simParameters.pulseAttenuation)*pulse;

% Number of parts to divide into
n = simParameters.NumFramesSim*10*2^(simParameters.numerology)  % Example: divide into n parts

% Determine the size of each part
total_length = length(pulse);
part_length = floor(total_length / n);  % Length of each part

% Preallocate a cell array to store the parts
pulse_parts = cell(1, n);

% Divide the pulse into n parts
for i = 1:n
    start_idx = (i - 1) * part_length + 1;  % Start index of the current part
    if i == n
        % Last part includes any leftover elements
        end_idx = total_length;
    else
        end_idx = i * part_length;  % End index of the current part
    end
    pulse_parts{i} = pulse(start_idx:end_idx);  % Store the part in the cell array
end

% Display the sizes of each part
for i = 1:n
    disp(['Part ', num2str(i), ' size: ', num2str(length(pulse_parts{i}))]);
end
pulse_parts;
global pulse 
global pulON
pulON = simParameters.RadarOn;
% pulse = [x';y];
pulse = pulse_parts;
% if false
    % spectrogram([x'; y],50,0,nfft1,fs,'centered','yaxis') ;
    % spectrogram(pulse_parts{1},50,0,nfft1,fs,'centered','yaxis') ;
    % spectrogram(pulse_parts{2},50,0,nfft1,fs,'centered','yaxis') ;
%     print("")
%     % signalAnalyzer(pulse{1},'SampleRate',fs)
%     % signalAnalyzer(pulse{1},'SampleRate',fs)
% 
% end

% Configure the channel model
  Apply_ChannelModel = true;
  if Apply_ChannelModel
      % CDL
      % channel = nrCDLChannel;
      % channel.DelayProfile = 'CDL-D';
      % channel.DelaySpread = 300e-9;
      % channel.CarrierFrequency = simParameters.DLCarrierFreq;
      % channel.TransmitAntennaArray.Size = [1 1 1 1 1];
      % channel.ReceiveAntennaArray.Size = [1 1 1 1 1];
      % waveformInfo = nrOFDMInfo(simParameters.NumRBs, simParameters.SCS);
      % channel.SampleRate = waveformInfo.SampleRate;
      % channel = nrCDLChannel;

      %TDL
      channel = nrTDLChannel('NumReceiveAntennas',1);
      channel.DelayProfile = 'TDL-D';
      % channel.DelaySpread = 300e-9;
      % channel.NumReceiveAntennas = 1;
      % channel.CarrierFrequency = simParameters.DLCarrierFreq;
      % channel.TransmitAntennaArray.Size = [1 1 1 1 1];
      % channel.ReceiveAntennaArray.Size = [1 1 1 1 1];
      waveformInfo = nrOFDMInfo(simParameters.NumRBs, simParameters.SCS);
      channel.SampleRate = waveformInfo.SampleRate;
      for ueIdx = 1:simParameters.NumUEs
        simParameters.ChannelModel{ueIdx} = channel;
      end
  end

% Simulation
% Initialize wireless network simulator
nrNodes = [{gNB}; UEs];
networkSimulator = hWirelessNetworkSimulator(nrNodes);
% Create objects to log RLC and MAC traces.
if enableTraces

    % RLC metrics are logged for every 1 slot duration
    simRLCLogger = hNRRLCLogger(simParameters, lchInfo, networkSimulator, gNB, UEs);
    
    simSchedulingLogger = hNRSchedulingLogger(simParameters, networkSimulator, gNB, UEs);
    
    % Create an object for CQI and RB grid visualization
    if simParameters.CQIVisualization || simParameters.RBVisualization
        gridVisualizer = hNRGridVisualizer(simParameters, 'MACLogger', simSchedulingLogger);
    end
end
% Create an object for RLC and MAC metrics visualization.
ViewPlots = false;
metricsVisualizer = hNRMetricsVisualizer(simParameters, 'EnableSchedulerMetricsPlots', ViewPlots, ...
    'EnableRLCMetricsPlots', ViewPlots, 'LCHInfo', lchInfo, 'NetworkSimulator', networkSimulator, 'GNB', gNB, 'UEs', UEs);
% Run the simulation for the specified NumFramesSim frames.
% Calculate the simulation duration (in seconds) from 'NumFramesSim'
simulationTime = simParameters.NumFramesSim * 1e-2;

% addChannelModel(networkSimulator,@hAddImpairment)

% Run the simulation
run(networkSimulator, simulationTime);
% At the end of the simulation, the achieved value for system performance indicator is compared to their theoretical peak values (considering zero overheads). Performance indicators displayed are achieved data rate (UL and DL), and achieved spectral efficiency (UL and DL). The peak values are calculated as per 3GPP TR 37.910.
displayPerformanceIndicators(metricsVisualizer)
% Get the simulation metrics and save it in a MAT-file. The simulation metrics are saved in a MAT-file with the file name as simulationMetricsFile
metrics = getMetrics(metricsVisualizer);
save(simulationMetricsFile, 'metrics'); % Save simulation metrics in a MAT-file


% if enableTraces
% 
% 
% 
%     fprintf("Logs Saved: \n%s\n%s\n", simFileName, parFileName);
% 
%     % Read the logs and write them to MAT-files
%     % Get the logs
%     fprintf("Saving logs...")
%     simulationLogs = cell(1,1);
%     logInfo = struct('TimeStepLogs',[], 'SchedulingAssignmentLogs',[] ,'RLCLogs', []);
%     [logInfo.TimeStepLogs] = getSchedulingLogs(simSchedulingLogger);
%     logInfo.SchedulingAssignmentLogs = getGrantLogs(simSchedulingLogger); % Scheduling assignments log
%     logInfo.RLCLogs = getRLCLogs(simRLCLogger); % RLC statistics logs
%     simulationLogs{1} = logInfo;
% 
%     % resultsTable = findReTransmissions(simulationLogs, simParameters); %add the reTx to the log files
% 
%     save(simulationLogFile, 'simulationLogs'); % Save simulation logs in a MAT-file
%     save(parametersLogFile, 'simParameters'); % Save simulation parameters in a MAT-file
% 
% 
%     dt = datestr(now,'yymmdd-HHMMSS');
%     newFolderName = strcat(simParameters.folderName,dt,"_",string(simParameters.parForId),"/");
%     mkdir(newFolderName)
%     simFileName = strcat(newFolderName,dt,'_',simulationMetricsFile);
%     save(simFileName, 'simulationLogs'); % Save simulation logs in a MAT-file
%     parFileName = strcat(newFolderName,dt,'_',parametersLogFile);
%     save(parFileName, 'simParameters'); % Save simulation parameters in a MAT-file
%     fprintf("Logs Saved: \n%s/%s\n/%s/%s\n",newFolderName,simFileName,newFolderName,parFileName)
%     % pyrun(../)
% end

if enableTraces
    fprintf("Collecting and saving logs...\n");
    
    % Prepare simulation log structure
    simulationLogs = cell(1, 1);
    logInfo = struct('TimeStepLogs', [], 'SchedulingAssignmentLogs', [], 'RLCLogs', []);
    
    % Collect logs
    logInfo.TimeStepLogs = getSchedulingLogs(simSchedulingLogger);
    logInfo.SchedulingAssignmentLogs = getGrantLogs(simSchedulingLogger); % Scheduling assignments log
    logInfo.RLCLogs = getRLCLogs(simRLCLogger); % RLC statistics logs
    simulationLogs{1} = logInfo;
    
    % Save logs, parameters, and metrics in uniquely named folders and files
    dt = datestr(now, 'yymmdd-HHMMSS'); % Timestamp for folder and file uniqueness
    uniqueRunID = strcat("_Run_", string(simParameters.parForId), "_Idx_", num2str(randi(1e5))); % Unique run identifier
    newFolderName = strcat(simParameters.folderName, dt, uniqueRunID, "/");
    mkdir(newFolderName); % Create a unique directory for this simulation run
    
    % Save simulation logs
    simLogFile = strcat(newFolderName, 'Logs_', dt, '_', uniqueRunID, '.mat');
    save(simLogFile, 'simulationLogs');
    
    % Save simulation parameters
    simParamFile = strcat(newFolderName, 'Params_', dt, '_', uniqueRunID, '.mat');
    save(simParamFile, 'simParameters');
    
    % Save simulation metrics
    simMetricsFile = strcat(newFolderName, 'Metrics_', dt, '_', uniqueRunID, '.mat');
    save(simMetricsFile, 'metrics');
    
    fprintf("Logs saved successfully:\n");
    fprintf("  Logs: %s\n", simLogFile);
    fprintf("  Parameters: %s\n", simParamFile);
    fprintf("  Metrics: %s\n", simMetricsFile);
else
    fprintf("Traces are disabled. Skipping log saving.\n");
end

% Display simulation completion message
fprintf("Simulation completed for run ID: %s\n", uniqueRunID);

end

