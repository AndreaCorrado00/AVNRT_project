function visualise_trace_features(trace,trace_features_table,main_title,main_ambient)

%% Initialization
fc=main_ambient.fc;
t = [0:1/fc:1-1/fc]';
class=trace(end);
trace=double(trace(1:end-1)); % class elimination
%% Figure initialisation 
fig=figure(1);
fig.WindowState = "maximized";
sgtitle(main_title)

%% SP1: peaks by magnitude
peaks_names=["Dominant_peak","Dominant_peak_time","Subdominant_peak","Subdominant_peak_time","Minor_peak","Minor_peak_time"];
peaks_values_pos=trace_features_table(:,peaks_names);

subplot(231)
hold on
plot(t,trace,"LineWidth",1.1,"Color","#0072BD")
for i=1:2:size(peaks_values_pos,2)
    plot(double(peaks_values_pos{:,i+1}),double(peaks_values_pos{:,i}),'ro')
end
title('Peaks by magnitude')
%% SP2: peaks by time occurance
subplot(232)
hold on

title('Peaks by time occurance')
%% SP3: App
subplot(233)
hold on

title('App')
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
