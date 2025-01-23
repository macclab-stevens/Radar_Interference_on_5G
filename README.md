# Radar Interference in 5G comparing the performance of TTI. 
This matlab code is designed to run multiple simulations of radar with varying characteristics and evaluate the performance impact on 5G in n78. 
n78 is known to be contested with radar, therefore we leverage the TDD schduler example from matlab. 
5G introduced TTI (Transmission Time Intervals) in 5G which allows the operator to allocate resources down to the symbol level. Based on various symbol level schedule we evualte the performance against various radar parameters. 

The number of users, distance, and other various 5G paremters are set as controls against the simulatons. With each simulation running against TTI 2,4,7 and Slot Based, (Or TTI == 14.) Here the # of symbols / slot is 14.

For example we can run a simulation of 2000 varying the radar prf from 1 - 2000KHz. In each simulation there are 20 users at 300m requesting 10Mbps in the DL and the UL. We run the simulation for 5 frames. This is done for TTI schduleing of 2,4,7,14. (Again 14 is the same as "slot based" schduling.)
![Run_30Khz_Prf_2_10-5000/goodput_v_prf_2.png]([http://url/to/img.png](https://github.com/macclab-stevens/Radar_Interference_on_5G/blob/main/Run_30Khz_Prf_2_10-5000/goodput_v_prf_2.png)

