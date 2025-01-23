function channels = hCreateCDLChannels(channelConfig,gNB,UEs,simParameters)
%createCDLChannels Create channels between gNB and UEs in a cell
%   CHANNELS = createCDLChannels(CHANNELCONFIG,GNB,UES) creates channels
%   between the GNB and UE nodes in a cell.
%
%   CHANNELS is an N-by-N array, where N represents the number of nodes in the cell.
%
%   CHANNLECONFIG is a structure with these fields - DelayProfile and
%   DelaySpread.
%
%   GNB is an nrGNB object.
%
%   UES is an array of nrUE objects.

numUEs = length(UEs);
numNodes = length(gNB) + numUEs;
% Create channel matrix to hold the channel objects
channels = cell(numNodes,numNodes);

% Obtain the sample rate of waveform
waveformInfo = nrOFDMInfo(simParameters.NumRBs,simParameters.SCS);
sampleRate = waveformInfo.SampleRate;
channelFiltering = strcmp('none','none');

for ueIdx = 1:numUEs
    % Configure the uplink channel model between the gNB and UE nodes
    channel = nrCDLChannel;
    channel.DelayProfile = channelConfig.DelayProfile;
    channel.DelaySpread = channelConfig.DelaySpread;
    channel.Seed = 73 + (ueIdx - 1);
    channel.CarrierFrequency = simParameters.DLCarrierFreq;
    channel = hArrayGeometry(channel, 1,1,...
        "uplink");
    channel.SampleRate = sampleRate;
    channel.ChannelFiltering = channelFiltering;
    channels{UEs{ueIdx,1}.ID, gNB.ID} = channel;
    % Configure the downlink channel model between the gNB and UE nodes
    % if gNB.DuplexMode == "FDD"
    %     channel = nrCDLChannel;
    %     channel.DelayProfile = channelConfig.DelayProfile;
    %     channel.DelaySpread = channelConfig.DelaySpread;
    %     channel.Seed = 73 + (ueIdx - 1);
    %     channel.CarrierFrequency = gNB.CarrierFrequency;
    %     channel = hArrayGeometry(channel, 1,1,...
    %         "downlink");
    %     channel.SampleRate = sampleRate;
    %     channel.ChannelFiltering = channelFiltering;
    %     channels{gNB.ID, UEs(ueIdx).ID} = channel;
    % else
        cdlUL = clone(channel);
        cdlUL.swapTransmitAndReceive();
        channels{gNB.ID, UEs{ueIdx,1}.ID} = cdlUL;
    % end
end
end