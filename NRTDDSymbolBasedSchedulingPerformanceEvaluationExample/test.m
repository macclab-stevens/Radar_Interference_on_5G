txWaveform = nrOFDMModulate(carrier, txGrid);
spectrogram(txWaveform,ones(512,1),0,512,'centered',768000,'yaxis','MinThreshold',-130)