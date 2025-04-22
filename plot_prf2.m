clear
close all
data = readtable('./Run_30Khz_1UE_Prf_0-5k_test20250418_1/1_AvgData.csv')  % Read the CSV file into a table
% data = readtable('./Run_30Khz_Prf_2_10-5000/0_RunData.csv')  % Read the CSV file into a table

% data = data(data.BW == 5000000,:)
% data = data(mod(data.prf, 5) == 0, :);
% Filter data for different TTI values
tti2 = data(data.TTI == 2, :);
tti4 = data(data.TTI == 4, :);
tti7 = data(data.TTI == 7, :);
tti14 = data(data.TTI == 14, :);

% Define colors
color1 = [1, 0.3, 0];   % Bright orange
color2 = [0, 0.5, 0.8]; % Cool blue
color3 = [0.2, 0.7, 0.2]; % Vibrant green
color4 = [0.5, 0.2, 0.7]; % Optional color for TTI 14
% Define a blending factor for lighter colors (closer to white)
blend_factor = 0.6;

% Create lighter versions of the colors
color5 = color1 + blend_factor * ([1, 1, 1] - color1); % Lighter orange
color6 = color2 + blend_factor * ([1, 1, 1] - color2); % Lighter blue
color7 = color3 + blend_factor * ([1, 1, 1] - color3); % Lighter green
color8 = color4 + blend_factor * ([1, 1, 1] - color4); % Lighter purple
alpha_level = 0.5;


% Create figure
xvar = 'prf';
yvar = 'DL_goodput_bps';
% yvar2 = 'DL_throughput_bps';
figure;
gcf;
hold on;
grid on;
title('Avg Goodput Per UE against varying PRF Radar Pulses');
xlabel('prf');
ylabel('Avg Goodput per UE (Mbps)');
% 
% Plot scatter points with specific colors
xscale = 1;
yscale = 1e-6;
tti2.(xvar) = tti2.(xvar)* xscale;tti2.(yvar) = tti2.(yvar)* yscale;%tti2.(yvar2) = tti2.(yvar2)* yscale;
tti4.(xvar) = tti4.(xvar)* xscale;tti4.(yvar) = tti4.(yvar)* yscale;%tti4.(yvar2) = tti4.(yvar2)* yscale;
tti7.(xvar) = tti7.(xvar)* xscale;tti7.(yvar) = tti7.(yvar)* yscale;%tti7.(yvar2) = tti7.(yvar2)* yscale;
tti14.(xvar) = tti14.(xvar)* xscale;tti14.(yvar) = tti14.(yvar)* yscale;%tti14.(yvar2) = tti14.(yvar2)* yscale;

tti2_plot = scatter((tti2.(xvar)), (tti2.(yvar)), 50, 'filled', 'DisplayName', 'TTI 2 GP', 'MarkerFaceColor', color1,'MarkerFaceAlpha', alpha_level);
tti4_plot = scatter((tti4.(xvar)), (tti4.(yvar)), 50, 'filled', 'DisplayName', 'TTI 4 GP', 'MarkerFaceColor', color2,'MarkerFaceAlpha', alpha_level);
tti7_plot = scatter((tti7.(xvar)), (tti7.(yvar)), 50, 'filled', 'DisplayName', 'TTI 7 GP', 'MarkerFaceColor', color3,'MarkerFaceAlpha', alpha_level);
tti14_plot = scatter((tti14.(xvar)), (tti14.(yvar)), 50, 'filled', 'DisplayName', 'TTI 14 GP', 'MarkerFaceColor', color4,'MarkerFaceAlpha', alpha_level);

% tti2_plot = scatter((tti2.(xvar)), (tti2.(yvar2)), 50, 'filled', 'DisplayName', 'TTI 2 TP', 'MarkerFaceColor', color5,'MarkerFaceAlpha', alpha_level);
% tti4_plot = scatter((tti4.(xvar)), (tti4.(yvar2)), 50, 'filled', 'DisplayName', 'TTI 4 TP', 'MarkerFaceColor', color6,'MarkerFaceAlpha', alpha_level);
% tti7_plot = scatter((tti7.(xvar)), (tti7.(yvar2)), 50, 'filled', 'DisplayName', 'TTI 7 TP', 'MarkerFaceColor', color7,'MarkerFaceAlpha', alpha_level);
% tti14_plot = scatter((tti14.(xvar)), (tti14.(yvar2)), 50, 'filled', 'DisplayName', 'TTI 14 TP', 'MarkerFaceColor', color8,'MarkerFaceAlpha', alpha_level);

tti2DLMax = yline(496696.0 * yscale,'--','LabelHorizontalAlignment','right', 'Color',color1);
tti4DLMax = yline(2081720.0* yscale,'--','TTI 4 DL Max','LabelHorizontalAlignment','right', 'Color',color2);
tti7DLMax = yline(3430896.0* yscale,'--','TTI 7 DL Max','LabelHorizontalAlignment','right', 'Color',color3);
tti14DLMax = yline(3785808.0* yscale,'--','TTI 14 DL Max','LabelHorizontalAlignment','right', 'Color',color4);


% Add trendlines for TTI = 2, 4, and 7
% Trendline for TTI = 2
trendlineNumeral = 3;
[x_fit2, y_fit2] = setupTrendlines(tti2, trendlineNumeral,xvar,yvar);
[x_fit4, y_fit4] = setupTrendlines(tti4, trendlineNumeral,xvar,yvar);
[x_fit7, y_fit7] = setupTrendlines(tti7, trendlineNumeral,xvar,yvar);
[x_fit14, y_fit14] = setupTrendlines(tti14, trendlineNumeral,xvar,yvar);
TTI2_trend = plot(x_fit2, y_fit2, '-', 'Color', color1, 'LineWidth', 2, 'DisplayName', 'TTI 2 GP');
TTI4_trend =plot(x_fit4, y_fit4, '-', 'Color', color2, 'LineWidth', 2, 'DisplayName', 'TTI 4 GP');
TTI7_trend =plot(x_fit7, y_fit7, '-', 'Color', color3, 'LineWidth', 2, 'DisplayName', 'TTI 7 GP');
TTI14_trend =plot(x_fit14, y_fit14, '-', 'Color', color4, 'LineWidth', 2, 'DisplayName', 'TTI 14 GP');


% 
% [x_fit2, y_fit2] = setupTrendlines(tti2, trendlineNumeral,xvar,yvar2);
% [x_fit4, y_fit4] = setupTrendlines(tti4, trendlineNumeral,xvar,yvar2);
% [x_fit7, y_fit7] = setupTrendlines(tti7, trendlineNumeral,xvar,yvar2);
% [x_fit14, y_fit14] = setupTrendlines(tti14, trendlineNumeral,xvar,yvar2);
% TTI2_trend2 = plot(x_fit2, y_fit2, '-', 'Color', color5, 'LineWidth', 2, 'DisplayName', 'TTI 2 TP');
% TTI4_trend2 =plot(x_fit4, y_fit4, '-', 'Color', color6, 'LineWidth', 2, 'DisplayName', 'TTI 4 TP');
% TTI7_trend2 =plot(x_fit7, y_fit7, '-', 'Color', color7, 'LineWidth', 2, 'DisplayName', 'TTI 7 TP');
% TTI14_trend2 =plot(x_fit14, y_fit14, '-', 'Color', color8, 'LineWidth', 2, 'DisplayName', 'TTI 14 TP');

% Create legend
legend('Location', 'north','NumColumns', 2);
% legend([TTI2_trend,TTI4_trend,TTI7_trend,TTI14_trend,TTI2_trend2,TTI4_trend2,TTI7_trend2,TTI14_trend2])
legend([TTI2_trend,TTI4_trend,TTI7_trend,TTI14_trend])
saveFolder = 'Images/Plots/' ;
save_name = strcat(saveFolder,xvar, '_vs_', yvar,'20MHzPulseBW_3');
% saveas(gcf, strcat(save_name, '.png'));  % Save as PNG
hold off;