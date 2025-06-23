function visualise_trace_features(rov_trace,trace_features_table,main_title,main_ambient)
% VISUALISE_TRACE_FEATURES
%
% This function visualizes multiple features extracted from a given ROV signal trace.
% It generates a comprehensive 2x3 subplot figure that includes:
%   1. Peaks by magnitude with classification (Dominant, Subdominant, Minor)
%   2. Peaks by temporal occurrence (First, Second, Third)
%   3. App feature annotation with a vertical arrow and value display
%   4. Correlation peak and signal for Template Matching 1 (TM1)
%   5. Correlation peak and signal for Template Matching 2 (TM2)
%   6. Short-Time Fourier Transform (STFT) power spectrum visualization 
%      segmented by predefined frequency bands and time sectors with 
%      corresponding mean power annotations
%
% INPUTS:
%   rov_trace            - vector containing the raw ROV signal trace; the last element
%                          is the class label (removed internally before plotting)
%   trace_features_table - table containing extracted features for the trace,
%                          including peak values, peak times, App values, correlation peaks,
%                          and STFT sector averages
%   main_title           - string title for the entire figure
%   main_ambient         - struct containing environment parameters and feature extraction options,
%                          such as sampling frequency (fc), template matching options,
%                          STFT parameters, and envelope settings
%
% NOTES:
% - Peaks in the table are stored as absolute values; the function restores correct sign
%   by referencing the original trace values at peak times.
% - The function uses helper functions: get_correlation_signal, get_template, get_time_thresholds,
%   and get_STFT_peaks, which must be available in the workspace.
% - The STFT subplot visualizes power spectral density in dB/Hz and overlays frequency band boxes
%   and corresponding mean power feature values for dominant, subdominant, and minor peaks.
%
% Author: Andrea Corrado

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
% correlation signal evaluation
tm1_corr_signal=get_correlation_signal(rov_trace, get_template(main_ambient.feature_extraction_opt.TemplateMatching.template_names(1),main_ambient),main_ambient);

% peak position and value
peaks_names=["cross_peak_TM1","cross_peak_time_TM1"];
peaks_values_pos=trace_features_table(:,peaks_names);

subplot(234)
hold on
plot(t,rov_trace,"LineWidth",1.1,"Color","#0072BD","HandleVisibility","off")
plot(t,tm1_corr_signal,"LineWidth",1.5,"Color",[1,0.5,0])
plot(double(peaks_values_pos{:,2}),double(peaks_values_pos{:,1}),"Color",[0.60, 0.00, 0.10],"Marker","o","LineWidth",2)

title('Correlation peak for tmp1')
legend(["Corr signal", "Corr Peak"],"Location","northeast","FontSize",8)
%% SP5: TM2 corr signal peak
% correlation signal evaluation
tm2_corr_signal=get_correlation_signal(rov_trace, get_template(main_ambient.feature_extraction_opt.TemplateMatching.template_names(2),main_ambient),main_ambient);

% peak position and value
peaks_names=["cross_peak_TM2","cross_peak_time_TM2"];
peaks_values_pos=trace_features_table(:,peaks_names);

subplot(235)
hold on
plot(t,rov_trace,"LineWidth",1.1,"Color","#0072BD","HandleVisibility","off")
plot(t,tm2_corr_signal,"LineWidth",1.5,"Color",[1,0.5,0])
plot(double(peaks_values_pos{:,2}),double(peaks_values_pos{:,1}),"Color",[0.60, 0.00, 0.10],"Marker","o","LineWidth",2)

title('Correlation peak for tmp2')
legend(["Corr signal", "Corr Peak"],"Location","northeast","FontSize",8)

%% SP6: STFT mean by sector
subplot(236)
ax6 = gca;
hold on

% Sampling frequency
fc = main_ambient.fc;

% STFT parameters
win_length = main_ambient.feature_extraction_opt.STFT.win_length;
overlap = round(win_length / main_ambient.feature_extraction_opt.STFT.overlap_ratio);
window = hamming(win_length, 'periodic');
nfft = main_ambient.feature_extraction_opt.STFT.nfft;

% STFT computation
[~, F, T, STFT] = spectrogram(rov_trace, window, overlap, nfft, fc);

% Frequency bands (Hz)
Low_band = main_ambient.feature_extraction_opt.STFT.Low_band;
Medium_band = main_ambient.feature_extraction_opt.STFT.Medium_band;
High_band = main_ambient.feature_extraction_opt.STFT.High_band;

% Indices for each band
idx_Low_band = F >= Low_band(1) & F <= Low_band(2);
idx_Medium_band = F > Medium_band(1) & F <= Medium_band(2);
idx_High_band = F > High_band(1) & F <= High_band(2);
idx_sub_bands = [idx_Low_band, idx_Medium_band, idx_High_band];

% Time thresholds for sector segmentation
[trace_envelope, ~] = envelope(rov_trace, main_ambient.feature_extraction_opt.envelope.N_env_points, main_ambient.feature_extraction_opt.envelope.evalutaion_method);
time_th = get_time_thresholds(rov_trace, trace_envelope, main_ambient);

% STFT peak positions (sorted by magnitude)
STFT_peaks_positions = get_STFT_peaks(rov_trace, time_th, fc, T);
STFT_peaks_positions = sortrows(STFT_peaks_positions, 1, "descend", "MissingPlacement", "last");

% Feature names (must match table column names)
avg_names = ["Dominant_AvgPowLF", "Dominant_AvgPowMF", "Dominant_AvgPowHF", ...
             "Subdominant_AvgPowLF", "Subdominant_AvgPowMF", "Subdominant_AvgPowHF", ...
             "Minor_AvgPowLF", "Minor_AvgPowMF", "Minor_AvgPowHF"];

% Extract feature values
peaks_values_pos = trace_features_table(:, avg_names);

% STFT visualization
imagesc('XData', T, 'YData', F, 'CData', 10*log10(abs(STFT)), 'CDataMapping', 'scaled');
axis xy;
set(gca, 'YDir', 'normal');
xlabel('Time [s]', "FontSize", 8);
ylabel('Frequency [Hz]', "FontSize", 8);
ylim([0, 400]);
hColorbar = colorbar('southoutside');
ylabel(hColorbar, 'Power/Frequency [dB/Hz]');

% Draw boxes and label power values (scientific notation)
for s = 1:height(time_th)
    t_start = time_th(s, 1) / fc;
    t_end = time_th(s, 2) / fc;

    if isnan(t_start) || isnan(t_end)
        continue;
    end

    for b = 1:3
        switch b
            case 1
                f_start = Low_band(1); f_end = Low_band(2);
            case 2
                f_start = Medium_band(1); f_end = Medium_band(2);
            case 3
                f_start = High_band(1); f_end = High_band(2);
        end

        % Draw rectangle
        rectangle('Position', [t_start, f_start, t_end - t_start, f_end - f_start], ...
                  'EdgeColor', 'k', 'LineStyle', '--', 'LineWidth', 1);

        % Retrieve feature value (using pre-defined column names)
        idx = (s - 1) * 3 + b;
        if idx <= width(peaks_values_pos)
            value = peaks_values_pos{1, idx};
            if ~ismissing(value) && ~isnan(value)
                t_mid = (t_start + t_end) / 2;
                f_mid = (f_start + f_end) / 2;
                text(t_mid, f_mid, sprintf('%.1e', value), ...
                     'HorizontalAlignment', 'center', ...
                     'VerticalAlignment', 'middle', ...
                     'FontSize', 7, 'FontWeight', 'bold', ...
                     'Color', 'k', 'BackgroundColor', 'w', ...
                     'Margin', 0.5);
            end
        end
    end
end

title('STFT mean in time-frequency sectors')
