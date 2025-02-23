function RadarTx(prf)
fprintf("Starting Script")
prf
folderName = 'Run_30Khz_PulsePowerLevels_3/';
numerology = 1; % 0 = 15KHz, 1 = 30KHz
fs = 30720000;
if mod(fs,prf) ~= 0
    fs = fs - mod(fs,prf)
end

% Sampling frequency

fc = 3410.1e6; %Center Frequency
if nargin < 1
    prf = 1
end
% PulseWidth = 100 * 1e-6; 
PulseWidth = 50e-6; 
pulseAttenuation = 0;
PulseBW = 20e6;
FreqOffset = 0e6;%9.5e6;
% NumFramesSim = 5000; %each is 10ms. 5= 50ms, 10 = 100ms, 100 = 1s


% Radar Setup    
nfft1 = 512*2;
w = taylorwin(200,4,-35);
freq = nlfmspec2freq(PulseBW ,w);

fm = phased.CustomFMWaveform( ...
    'SampleRate',fs, ...
    'PulseWidth',PulseWidth, ...
    'NumPulses',1, ...
    'PRF',prf, ...
    'FrequencyModulation',freq, ...
    'FrequencyOffsetSource','Property', ...
    'FrequencyOffset',FreqOffset, ...
    OutputFormat='Pulses')
% bbWriter = comm.BasebandFileWriter('prf100.bb',fs,fc)
% bbWriter(fm())
% release(bbWriter)

% Transmit Signal
% bbReader = comm.BasebandFileReader('prf1000.bb')
tx = comm.SDRuTransmitter(Platform="B210",SerialNum='31577EF',...
    CenterFrequency=fc,...
    ClockSource="External",...
    MasterClockRate =fs,...
    InterpolationFactor=1,...  
    Gain=80)   

% txData = fm()
RunTime_s = 20; %seconds
Reps = prf * RunTime_s;
fprintf("setting up data\n")
txData = repmat(fm(),Reps,1);

fprintf("Starting iperf")
iperfLogName = strcat(string(prf), "Hz");
system(sprintf('ssh m70q /home/eric/srsRAN_Project/scripts/PRFLogCollectorCTL.sh %s %s','start', iperfLogName))
pause(5)

fprintf("Radar ON")
tx(txData);

release(tx);
fprintf("Radar OFF")
pause(5)
fprintf("Ending Iperf Run")
system(sprintf('ssh m70q /home/eric/srsRAN_Project/scripts/PRFLogCollectorCTL.sh %s','stop'))