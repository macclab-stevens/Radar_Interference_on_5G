import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import linregress

# Reload the data after the reset
tti_4_data = pd.read_csv('./rnd_PW_rnd_PWSltIdx_tti_4_1500.csv')
tti_2_data = pd.read_csv('./rnd_PW_rnd_PWSltIdx_tti_2_1500.csv')

# Extract radar pulse width and retransmission percent
# Calculate retransmission percentages for TTI = 4
pulse_width_4 = tti_4_data['PulseWidth']
numReTx_4 = tti_4_data['numReTx_DL']
numDLTotal_4 = tti_4_data['numDLTotal']
retransmission_4 = numReTx_4 / numDLTotal_4

# Calculate retransmission percentages for TTI = 2
pulse_width_2 = tti_2_data['PulseWidth']
numReTx_2 = tti_2_data['numReTx_DL']
numDLTotal_2 = tti_2_data['numDLTotal']
retransmission_2 = numReTx_2 / numDLTotal_2


# Compute trendlines
slope_4, intercept_4, _, _, _ = linregress(pulse_width_4, retransmission_4)
slope_2, intercept_2, _, _, _ = linregress(pulse_width_2, retransmission_2)

# Generate trendline data
trendline_4 = slope_4 * pulse_width_4 + intercept_4
trendline_2 = slope_2 * pulse_width_2 + intercept_2

# Plot the scatter plot with trendlines
plt.figure(figsize=(10, 6))
plt.scatter(pulse_width_4, retransmission_4, color='blue', alpha=0.5, label='TTI = 4 Symbols')
plt.plot(pulse_width_4, trendline_4, color='blue', linestyle='--', label='Trendline (TTI = 4)')
plt.scatter(pulse_width_2, retransmission_2, color='red', alpha=0.5, label='TTI = 2 Symbols')
plt.plot(pulse_width_2, trendline_2, color='red', linestyle='--', label='Trendline (TTI = 2)')

# Add annotations and labels
plt.title('Variable Radar Pulse Widths Compared to DL Retransmission Percent')
plt.xlabel('Radar Pulse Width (µs)')
plt.ylabel('DL Retransmission Percent')
plt.legend()
plt.grid(True, linestyle='--', alpha=0.6)
plt.tight_layout()

# Display the plot
plt.show()


from numpy.polynomial.polynomial import Polynomial


# Sort data for consistent trendlines
sorted_indices_4 = np.argsort(pulse_width_4)
pulse_width_4_sorted = pulse_width_4.iloc[sorted_indices_4]
retransmission_4_sorted = retransmission_4.iloc[sorted_indices_4]

sorted_indices_2 = np.argsort(pulse_width_2)
pulse_width_2_sorted = pulse_width_2.iloc[sorted_indices_2]
retransmission_2_sorted = retransmission_2.iloc[sorted_indices_2]

# Fit a single second-order polynomial for each dataset
coeffs_4 = np.polyfit(pulse_width_4_sorted, retransmission_4_sorted, deg=2)
coeffs_2 = np.polyfit(pulse_width_2_sorted, retransmission_2_sorted, deg=2)

# Generate trendlines using the sorted pulse widths
trendline_4 = np.polyval(coeffs_4, pulse_width_4_sorted)
trendline_2 = np.polyval(coeffs_2, pulse_width_2_sorted)

# Plot the scatter plot with single trendlines
plt.figure(figsize=(10, 6))
plt.scatter(pulse_width_4, retransmission_4, color='blue', alpha=0.2, label='TTI = 4 Symbols')
plt.plot(pulse_width_4_sorted, trendline_4, color='blue',linewidth=5, linestyle='--', label='Quadratic Trend (TTI = 4)')
plt.scatter(pulse_width_2, retransmission_2, color='red', alpha=0.2, label='TTI = 2 Symbols')
plt.plot(pulse_width_2_sorted, trendline_2, color='red',linewidth=5, linestyle='--', label='Quadratic Trend (TTI = 2)')

# Add labels and legend
plt.title('Variable Radar Pulse Widths Compared to DL Retransmission Percent')
plt.xlabel('Radar Pulse Width (µs)')
plt.ylabel('DL Retransmission Percent')
plt.legend()
plt.grid(True, linestyle='--', alpha=0.6)
plt.tight_layout()

# Display the plot
plt.show()



# from scipy.interpolate import UnivariateSpline

# # Sort the TTI = 4 data by pulse width
# sorted_indices_4 = np.argsort(pulse_width_4)
# pulse_width_4_sorted = pulse_width_4[sorted_indices_4]
# retransmission_4_sorted = retransmission_4[sorted_indices_4]

# # Sort the TTI = 2 data by pulse width
# sorted_indices_2 = np.argsort(pulse_width_2)
# pulse_width_2_sorted = pulse_width_2[sorted_indices_2]
# retransmission_2_sorted = retransmission_2[sorted_indices_2]

# # Fit a cubic spline for TTI = 4
# spline_4 = UnivariateSpline(pulse_width_4_sorted, retransmission_4_sorted, k=3, s=0.5)
# trendline_4 = spline_4(pulse_width_4_sorted)

# # Fit a cubic spline for TTI = 2
# spline_2 = UnivariateSpline(pulse_width_2_sorted, retransmission_2_sorted, k=3, s=0.5)
# trendline_2 = spline_2(pulse_width_2_sorted)

# # Plot the scatter plot with spline regression trendlines
# plt.figure(figsize=(10, 6))
# plt.scatter(pulse_width_4, retransmission_4, color='blue', alpha=0.5, label='TTI = 4 Symbols')
# plt.plot(pulse_width_4_sorted, trendline_4, color='blue', linestyle='--', label='Spline Trend (TTI = 4)')
# plt.scatter(pulse_width_2, retransmission_2, color='red', alpha=0.5, label='TTI = 2 Symbols')
# plt.plot(pulse_width_2_sorted, trendline_2, color='red', linestyle='--', label='Spline Trend (TTI = 2)')

# # Add labels and legend
# plt.title('Variable Radar Pulse Widths Compared to DL Retransmission Percent')
# plt.xlabel('Radar Pulse Width (µs)')
# plt.ylabel('DL Retransmission Percent')
# plt.legend()
# plt.grid(True, linestyle='--', alpha=0.6)
# plt.tight_layout()

# # Display the plot
# plt.show()
