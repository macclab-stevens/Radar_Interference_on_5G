

     

     % MATLAB Script to Compare Coding Rates Against MCS Index for Two MCS Tables

% Clear workspace and figures
clear; close all; clc;

%% Define MCS Table 1 (Up to 64-QAM)
% Columns: [Modulation Order (Qm), Target Code Rate (R), Spectral Efficiency (SE)]
MCSTable1 = [ ...
    2,  120, 0.2344;
    2,  157, 0.3066;
    2,  193, 0.3770;
    2,  251, 0.4902;
    2,  308, 0.6016;
    2,  379, 0.7402;
    2,  449, 0.8770;
    2,  526, 1.0273;
    2,  602, 1.1758;
    2,  679, 1.3262;
    4,  340, 1.3281;
    4,  378, 1.4766;
    4,  434, 1.6953;
    4,  490, 1.9141;
    4,  553, 2.1602;
    4,  616, 2.4063;
    4,  658, 2.5703;
    6,  438, 2.5664;
    6,  466, 2.7305;
    6,  517, 3.0293;
    6,  567, 3.3223;
    6,  616, 3.6094;
    6,  666, 3.9023;
    6,  719, 4.2129;
    6,  772, 4.5234;
    6,  822, 4.8164;
    6,  873, 5.1152;
    6,  910, 5.3320;
    6,  948, 5.5547];

% Extract MCS indices (0 to 31)
MCSIndex1 = (0:length(MCSTable1)-1)';

% Extract coding rates (divide Target Code Rate by 1024)
CodingRate1 = MCSTable1(:,2) / 1024;

% Extract modulation orders
ModOrder1 = MCSTable1(:,1);

%% Define MCS Table 2 (Up to 256-QAM)
% Columns: [Modulation Order (Qm), Target Code Rate (R), Spectral Efficiency (SE)]
MCSTable2 = [ ...
    2,  120, 0.2344;
    2,  193, 0.3770;
    2,  308, 0.6016;
    2,  449, 0.8770;
    2,  602, 1.1758;
    4,  378, 1.4766;
    4,  434, 1.6953;
    4,  490, 1.9141;
    4,  553, 2.1602;
    4,  616, 2.4063;
    4,  658, 2.5703;
    6,  466, 2.7305;
    6,  517, 3.0293;
    6,  567, 3.3223;
    6,  616, 3.6094;
    6,  666, 3.9023;
    6,  719, 4.2129;
    6,  772, 4.5234;
    6,  822, 4.8164;
    6,  873, 5.1152;
    8, 682.5,5.3320;
    8,  711, 5.5547;
    8,  754, 5.8906;
    8,  797, 6.2266;
    8,  841, 6.5703;
    8,  885, 6.9141;
    8,916.5, 7.1602;
    8,  948, 7.4063];

% Extract MCS indices (0 to 31)
MCSIndex2 = (0:length(MCSTable2)-1)';

% Extract coding rates (divide Target Code Rate by 1024)
CodingRate2 = MCSTable2(:,2) / 1024;

% Extract modulation orders
ModOrder2 = MCSTable2(:,1);

%% Plot Coding Rate vs MCS Index for Both Tables

figure;
hold on; grid on; box on;

% Plot MCS Table 1
plot(MCSIndex1, CodingRate1, 'bo-', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'MCS Table 1 (Up to 64-QAM)');

% Plot MCS Table 2
plot(MCSIndex2, CodingRate2, 'rs--', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'MCS Table 2 (Up to 256-QAM)');

% Add labels and title
xlabel('MCS Index');
ylabel('Coding Rate (R_c)');
title('Coding Rate vs MCS Index Comparison');
legend('Location', 'NorthWest');

% Adjust x-axis limits
xlim([0 28]);

% Annotate modulation order changes
for idx = 1:length(MCSIndex1)-1
    if ModOrder1(idx) ~= ModOrder1(idx+1)
        xline(MCSIndex1(idx+1)-0.5, '--k', ['Qm = ' num2str(ModOrder1(idx+1))], 'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom','Color','b');
    end
end

% Repeat for MCS Table 2
for idx = 1:length(MCSIndex2)-1
    if ModOrder2(idx) ~= ModOrder2(idx+1)
        xline(MCSIndex2(idx+1)-0.5, '--k', ['Qm = ' num2str(ModOrder2(idx+1))], 'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top','Color','r');
    end
end

hold off;
        