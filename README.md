# Radar Interference in 5G comparing the performance of TTI. 
This matlab code is designed to run multiple simulations of radar with varying characteristics and evaluate the performance impact on 5G in n78. 
n78 is known to be contested with radar, therefore we leverage the TDD schduler example from matlab. 
5G introduced TTI (Transmission Time Intervals) in 5G which allows the operator to allocate resources down to the symbol level. Based on various symbol level schedule we evualte the performance against various radar parameters. 

The number of users, distance, and other various 5G paremters are set as controls against the simulatons. With each simulation running against TTI 2,4,7 and Slot Based, (Or TTI == 14.) Here the # of symbols / slot is 14.

# Example PRF(Pulse Repetition Frequency) changes
For example we can run a simulation roughly 2000 times. In this simulation run we vary the radar prf from 1 - 2000KHz, and the 5G TTI from 2 to 14. In each simulation there are 20 users at 300m requesting 10Mbps in the DL and the UL. We ran each simulation for 5 frames. This is done for TTI schduleing of 2,4,7,14. (Again 14 is the same as "slot based" schduling.)
Here goodput is the measure of "Actual throughput" the user would see. The difference between goodput and the commonly used language of "throughput" is that throughput in the matlab model also include packet retransmissions. With radar collosions happening so often many packets need to be retranmssited, which is the function of HARQ. To keep things simple it is more useful to graph the system level UE perceived data rate (aka Goodput). 
![Run_30Khz_Prf_2_10-5000/goodput_v_prf_2.png](https://github.com/macclab-stevens/Radar_Interference_on_5G/blob/main/Run_30Khz_Prf_2_10-5000/goodput_v_prf_2.png)

