function visualise_trace_features(rov_trace,trace_features_table,main_title,main_ambient)

%% Initialization
fc=main_ambient.fc;
t = [0:1/fc:1-1/fc]';
class=rov_trace(end);
rov_trace=double(rov_trace(1:end-1)); % class elimination
%% Figure initialisation 
fig=figure(1);
fig.WindowState = "maximized";
sgtitle(main_title)

%% SP1: peaks by magnitude
peaks_names=["Dominant_peak","Dominant_peak_time","Subdominant_peak","Subdominant_peak_time","Minor_peak","Minor_peak_time"];
peaks_values_pos=trace_features_table(:,peaks_names);
% peaks are evaluated in modulus -> getting the real peak value:
for i=1:2:size(peaks_values_pos,2)-1
    if ~isnan(double(peaks_values_pos{:,i+1})) && rov_trace(round(double(peaks_values_pos{:,i+1})*main_ambient.fc))<0
        peaks_values_pos{:,i}="-"+peaks_values_pos{:,i};
    end
end
% plotting 
subplot(231)
hold on
plot(t,rov_trace,"LineWidth",1.1,"Color","#0072BD","HandleVisibility","off")
palette = [
    0.60, 0.00, 0.10;   
    1.00, 0.50, 0.00;  
    1.00, 0.80, 0.00 
];
for i=1:2:size(peaks_values_pos,2)-1
    color_idx = mod((i-1)/2, size(palette,1)) + 1;
    plot(double(peaks_values_pos{:,i+1}),double(peaks_values_pos{:,i}),"Color",palette(color_idx,:),"Marker","o","LineWidth",2)
end

title('Peaks by magnitude')
ylim([min(rov_trace)-abs(0.05*min(rov_trace)),max(rov_trace)+0.05*max(rov_trace)])
ylabel("rov trace [mv]")
xlabel("time [s]")
legend(["Dominant", "Subdominant", "Minor"],"Location","northeast","FontSize",8)
%% SP2: peaks by time occurance
peaks_names=["First_peak","First_peak_time","Second_peak","Second_peak_time","Third_peak","Third_peak_time"];
peaks_values_pos=trace_features_table(:,peaks_names);
% peaks are evaluated in modulus -> getting the real peak value:
for i=1:2:size(peaks_values_pos,2)-1
    if ~isnan(double(peaks_values_pos{:,i+1})) && rov_trace(round(double(peaks_values_pos{:,i+1})*main_ambient.fc))<0
        peaks_values_pos{:,i}="-"+peaks_values_pos{:,i};
    end
end
% plotting 
subplot(232)
hold on
plot(t,rov_trace,"LineWidth",1.1,"Color","#0072BD","HandleVisibility","off")
palette = [
   0.00, 0.45, 0.00;  
    0.00, 0.70, 0.20;  
    0.35, 0.90, 0.40 
];
for i=1:2:size(peaks_values_pos,2)-1
    color_idx = mod((i-1)/2, size(palette,1)) + 1;
    plot(double(peaks_values_pos{:,i+1}),double(peaks_values_pos{:,i}),"Color",palette(color_idx,:),"Marker","o","LineWidth",2)
end

title('Peaks by temporal position')
ylim([min(rov_trace)-abs(0.05*min(rov_trace)),max(rov_trace)+0.05*max(rov_trace)])
ylabel("rov trace [mv]")
xlabel("time [s]")
legend(["First", "Second", "Third"],"Location","northeast","FontSize",8)

%% SP3: App
subplot(2,3,3)
hold on

% Extract features
App_value = double(trace_features_table{:,"App"});
Dominant_peak_time = double(trace_features_table{:,"Dominant_peak_time"});

% Plot signal
plot(t, rov_trace, "LineWidth", 1.1, "Color", "#0072BD", "HandleVisibility", "off");
title('App')

% Set y-axis limits with margin
y_min = min(rov_trace);
y_max = max(rov_trace);
y_margin = 0.05;

ylim([y_min - abs(y_margin * y_min), y_max + y_margin * y_max]);

% Force axes to update
drawnow;

% Define arrow x-position (slightly right of dominant peak)
App_arrow_x_pos = Dominant_peak_time + 0.01 * range(t);

% Define true start and end points of App (min to max)
y_start = y_min;
y_end = y_max;

% Convert data coords to normalized figure units for annotation
ax = gca;
pos = ax.Position;
x_lim = ax.XLim;
y_lim = ax.YLim;

x_norm = @(x) pos(1) + (x - x_lim(1)) / (x_lim(2) - x_lim(1)) * pos(3);
y_norm = @(y) pos(2) + (y - y_lim(1)) / (y_lim(2) - y_lim(1)) * pos(4);

x0 = x_norm(App_arrow_x_pos);
y0 = y_norm(y_start);
y1 = y_norm(y_end);

% Add vertical double-headed arrow for App
annotation('doublearrow', [x0 x0], [y0 y1], 'Color', 'r', 'LineWidth', 1.5);

% Add text label (App value) next to arrow
text(App_arrow_x_pos + 0.01 * range(t), (y_start + y_end)/2, ...
    sprintf('%.3f', App_value), ...
    'Color', 'r', 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');

%% SP4: TM1 corr signal peak
subplot(234)
hold on

title('Correlation peak for tmp1')
%% SP5: TM2 corr signal peak
subplot(235)
hold on

title('Correlation peak for tmp2')
%% SP6: STFT mean by sector
subplot(236)
hold on

title('STFT mean into sectors ')
