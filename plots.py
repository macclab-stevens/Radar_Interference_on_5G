# File: simulation_plot.py

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os

# Setup and Variables
# Check if the CSV file exists and load data
csv_file = './Run_30Khz_2/0_RunData.csv'
data = pd.read_csv(csv_file)
data.columns = data.columns.str.replace(' ', '')

print(data.keys())

# Filter data for different TTI values
tti2 = data[data['TTI'] == 2]
tti4 = data[data['TTI'] == 4]
tti7 = data[data['TTI'] == 7]
tti14 = data[data['TTI'] == 14]

# Define colors and transparency
color1 = (1, 0.3, 0)    # Bright orange
color2 = (0, 0.5, 0.8)  # Cool blue
color3 = (0.2, 0.7, 0.2)  # Vibrant green
color4 = (0.5, 0.2, 0.7)  # Optional color for TTI 14
alpha_level = 0.1

# Plot Setup
xvar = 'PulseBWoffset'
yvar = 'DL_goodput_bps'

# Scatter Plot with Trendlines
def plot_scatter_with_trendlines(xvar, yvar, tti_data, color, label):
    """Plot scatter and trendline for given TTI data."""
    
    # Scatter Plot
    plt.scatter(tti_data[xvar], tti_data[yvar], s=50, alpha=alpha_level, label=label, color=color)
    
    # Trendline
    print(tti_data)
    z = np.polyfit(tti_data[xvar], tti_data[yvar], 2)
    p = np.poly1d(z)
    x_fit = np.linspace(tti_data[xvar].min(), tti_data[xvar].max(), 100)
    y_fit = p(x_fit)
    plt.plot(x_fit, y_fit, '-', color=color, linewidth=2, label=f'{label} Trendline')

# Plot All TTI Data
plt.figure(figsize=(12, 8))
plt.title(f'{xvar} vs {yvar}')
plt.xlabel(xvar)
plt.ylabel(yvar)

plot_scatter_with_trendlines(xvar, yvar, tti2, color1, 'TTI 2')
plot_scatter_with_trendlines(xvar, yvar, tti4, color2, 'TTI 4')
plot_scatter_with_trendlines(xvar, yvar, tti7, color3, 'TTI 7')
plot_scatter_with_trendlines(xvar, yvar, tti14, color4, 'TTI 14')

# Add Legend
plt.legend(loc='upper right')

# Save the plot
save_folder = 'Images/Plots/'
os.makedirs(save_folder, exist_ok=True)
save_name = os.path.join(save_folder, f'{xvar}_vs_{yvar}_20MHzPulseBW.png')
plt.savefig(save_name)
print(f'Plot saved as {save_name}')

# Show plot
plt.show()