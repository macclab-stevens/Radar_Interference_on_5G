# Radar Interference in 5G comparing the performance of TTI. 
This matlab code is designed to run multiple simulations of radar with varying characteristics and evaluate the performance impact on 5G in n78. 
n78 is known to be contested with radar, therefore we leverage the TDD schduler example from matlab. 
5G introduced TTI (Transmission Time Intervals) in 5G which allows the operator to allocate resources down to the symbol level. Based on various symbol level schedule we evualte the performance against various radar parameters. 

The number of users, distance, and other various 5G paremters are set as controls against the simulatons. With each simulation running against TTI 2,4,7 and Slot Based, (Or TTI == 14.) Here the # of symbols / slot is 14.

# Example PRF(Pulse Repetition Frequency) changes
For example we can run a simulation roughly 2000 times. In this simulation run we vary the radar prf from 1 - 2000KHz, and the 5G TTI from 2 to 14. In each simulation there are 20 users at 300m requesting 10Mbps in the DL and the UL. We ran each simulation for 5 frames. This is done for TTI schduleing of 2,4,7,14. (Again 14 is the same as "slot based" schduling.)
Here goodput is the measure of "Actual throughput" the user would see. The difference between goodput and the commonly used language of "throughput" is that throughput in the matlab model also include packet retransmissions. With radar collosions happening so often many packets need to be retranmssited, which is the function of HARQ. To keep things simple it is more useful to graph the system level UE perceived data rate (aka Goodput). 
![Run_30Khz_Prf_2_10-5000/goodput_v_prf_2.png](https://github.com/macclab-stevens/Radar_Interference_on_5G/blob/main/Run_30Khz_Prf_2_10-5000/goodput_v_prf_2.png)

# How it works:
Each of the runs are started with a simulation_*.mlx file that puts the variables as an array into a NxM Matrix. The simluation then runs a parfor (Parallel for loops) based on the size of the matrix and calls the main() script that many times. Each simulation run is saved as a .mat file. However thousand of these files ends up beging fairly large. E.g. a 2000 simulation run can be over 3Gb. Therefore we do not save the .mat files. Instead there is a .mat to csv conversion script that is run on the repo and then saved.

# Experiment Setup

## 20MHz B78 with UE attached w/ 10Mbps DL Iperf Test
<img width="1880" alt="image" src="https://github.com/user-attachments/assets/edde6682-7396-4aba-8493-aa668ed2cf8c" />


## Narrow Pulse Radar on next to 5G Signal with No UE data. 
<img width="934" alt="image" src="https://github.com/user-attachments/assets/05acc3bf-740b-4779-98ba-8043d394cce4" />

## Interference 
These are GQRX Images from the limeSDR Mini I have that is measuring the RF System. 
<img width="1664" alt="image" src="https://github.com/user-attachments/assets/97dbc9c5-705c-49b3-9ee6-6e557bec653e" />

### 20MHZ BW 5000Hz PRF
Radar Tx Gain: 45
<img width="1675" alt="image" src="https://github.com/user-attachments/assets/1a1605d0-2e55-4753-8afb-dfde45f9d735" />

Radar Tx Gain: 80
<img width="1672" alt="image" src="https://github.com/user-attachments/assets/2eb98e78-23f1-4858-99e7-2270fbb283cc" />


### 1MHz BW 500Hz PRF
<img width="1650" alt="image" src="https://github.com/user-attachments/assets/fec7b9a2-a750-4bfa-b30a-5186063ad903" />
