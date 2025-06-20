function [envelope_feature_vector,features_names] = get_envelope_features(example_env,example_rov,main_ambient)

% Extracts a comprehensive set of time- and amplitude-based features from 
% the envelope and roving signals of a single cardiac cycle.
%
% This function analyzes the input envelope (`example_env`) and roving 
% (`example_rov`) signals by identifying active regions of interest based 
% on dynamic thresholds, peak amplitudes, and temporal characteristics. 
% It outputs a feature vector summarizing the shape and temporal dynamics 
% of the cardiac signal envelope. The computed features are suitable for 
% downstream classification, clustering, or signal comparison tasks.
%
% INPUTS:
%   - example_env : [Nx1 double]  
%       The envelope signal extracted from the original cardiac waveform.
%
%   - example_rov : [Nx1 double]  
%       The roving signal corresponding to the same cardiac segment.
%
%   - main_ambient : [struct]  
%       Structure containing the global parameters and configuration 
%       for signal analysis. Required fields:
%         • fc: Sampling frequency
%         • feature_extraction_opt.envelope 
%
% OUTPUT:
%   - envelope_feature_vector : [1xN string]  
%       Row vector containing the extracted features, formatted as strings.
%       The features include:
%         • Number of active areas
%         • Amplitude and timing of top 3 peaks (in order of magnitude and time)
%         • Total duration and silent phase characteristics
%         • Atrial and ventricular peak amplitude/time ratios
%         • Relative number of activations over the duration
%
%   feature_names  - A string array of feature names corresponding to each value in 'features'
%
% DEPENDENCIES:
%   - get_time_thresholds.m
%   - find_atrial_ventricular_areas (nested within this file)
%
% AUTHOR: Andrea Corrado

%% ############ ENVELOPE FEATURE EVALUATION PIPELINE ############ %%

%% Extraction of time thresholds and fc
fc=main_ambient.fc;
time_th = get_time_thresholds(example_rov,example_env,main_ambient);

%% Features names vector initialization
features_names=[];

%% Features Evaluation
% Number of active areas detected
active_areas_number = size(time_th, 1);
features_names=["active_areas_number"];

[original_env_peaks_val_pos,original_rov_peaks_val_pos]=get_envelope_peaks(example_rov,example_env,time_th,fc);

%% FIRST BLOCK OF FEATURES: Peaks in order of magnitude
% Sorting peaks in descending order of magnitude
env_peaks_val_pos = sortrows(original_env_peaks_val_pos, 1, "descend","MissingPlacement","last");
rov_peaks_val_pos = sortrows(original_rov_peaks_val_pos, 1, "descend","MissingPlacement","last");

% Handling zeros in the peaks
env_peaks_val_pos(env_peaks_val_pos == 0) = nan;
rov_peaks_val_pos(rov_peaks_val_pos == 0) = nan;

% Roving signal peak details
Major_peak = rov_peaks_val_pos(1, 1);
Major_peak_time = rov_peaks_val_pos(1, 2);

Medium_peak = rov_peaks_val_pos(2, 1);
Medium_peak_time = rov_peaks_val_pos(2, 2);

Lowest_peak = rov_peaks_val_pos(3, 1);
Lowest_peak_time = rov_peaks_val_pos(3, 2);

% Envelope signal peak details
Major_peak_env = env_peaks_val_pos(1, 1);
Major_peak_env_time = env_peaks_val_pos(1, 2);

Medium_peak_env = env_peaks_val_pos(2, 1);
Medium_peak_env_time = env_peaks_val_pos(2, 2);

Lowest_peak_env = env_peaks_val_pos(3, 1);
Lowest_peak_env_time = env_peaks_val_pos(3, 2);

features_names=[features_names,"Dominant_peak", "Dominant_peak_time", ...
                "Subdominant_peak", "Subdominant_peak_time", "Minor_peak", "Minor_peak_time", ...
                "Dominant_peak_env", "Dominant_peak_env_time", "Subdominant_peak_env", ...
                "Subdominant_peak_env_time", "Minor_peak_env", "Minor_peak_env_time"];
%% SECOND BLOCK OF FEATURES: Peaks in order of time occurrence
% Sorting peaks by time of occurrence
env_peaks_val_pos = sortrows(original_env_peaks_val_pos, 2, "ascend","MissingPlacement","last");
rov_peaks_val_pos = sortrows(original_rov_peaks_val_pos, 2, "ascend","MissingPlacement","last");

% Handling zeros in the peaks
env_peaks_val_pos(env_peaks_val_pos == 0) = nan;
rov_peaks_val_pos(rov_peaks_val_pos == 0) = nan;

% Roving signal peaks by time
First_peak = rov_peaks_val_pos(1, 1);
First_peak_time = rov_peaks_val_pos(1, 2);

Second_peak = rov_peaks_val_pos(2, 1);
Second_peak_time = rov_peaks_val_pos(2, 2);

Third_peak = rov_peaks_val_pos(3, 1);
Third_peak_time = rov_peaks_val_pos(3, 2);

% Envelope signal peaks by time
First_peak_env = env_peaks_val_pos(1, 1);
First_peak_env_time = env_peaks_val_pos(1, 2);

Second_peak_env = env_peaks_val_pos(2, 1);
Second__peak_env_time = env_peaks_val_pos(2, 2);

Third_peak_env = env_peaks_val_pos(3, 1);
Third_peak_env_time = env_peaks_val_pos(3, 2);

features_names=[features_names,"First_peak", "First_peak_time", ...
                "Second_peak", "Second_peak_time", "Third_peak", "Third_peak_time", ...
                "First_peak_env", "First_peak_env_time", "Second_peak_env", ...
                "Second_peak_env_time", "Third_peak_env", "Third_peak_env_time"];
%% THIRD BLOCK OF FEATURES: Temporal activation features
% Computing the signal duration
duration = (time_th(end, end) - time_th(1, 1)) / fc;

% Computing the silent phase (inactive period)
silent_phase = ((time_th(end, end) - time_th(1, 1)) - sum(diff(time_th, 1, 2))) / fc;

% Computing the silent phase ratio to the total duration
silent_rateo = silent_phase / duration;

% Computing the number of active areas relative to the duration
n_active_areas_on_duration_ratio = active_areas_number / duration;

%% FOURTH BLOCK OF FEATURES: atrial and ventricular peaks evaluation 
% Using the start and end areas to detect the atrial and ventricular peaks
[start_end_areas] = find_atrial_ventricular_areas(example_rov, example_env, main_ambient);

if sum(sum(isnan(start_end_areas))) == 0
    % Using the defined peaks for atrial and ventricular phases
    [atr_peak, atr_peak_pos] = max(example_rov(start_end_areas(1, 1):start_end_areas(1, 2)), [], "omitnan");
    [vent_peak, vent_peak_pos] = max(example_rov(start_end_areas(2, 1):start_end_areas(2, 2)), [], "omitnan");
    atrial_ventricular_ratio = atr_peak / vent_peak;
    atrial_ventricular_time_ratio = atr_peak_pos / vent_peak_pos;
else
    atrial_ventricular_ratio = nan;
    atrial_ventricular_time_ratio = nan;
end

% Third peak evaluation
if sum(sum(isnan(start_end_areas))) == 0
    third_major_ratio = atr_peak / Major_peak;
    third_second_ratio = atr_peak / Medium_peak;
else
    third_major_ratio = nan;
    third_second_ratio = nan;
end

features_names=[features_names,"duration", "silent_phase", "silent_rateo", ...
                "atrial_ventricular_ratio", "atrial_ventricular_time_ratio", "minor_to_dominant_ratio", ...
                "minor_to_subdominant_ratio", "n_active_areas_on_duration_ratio"];
%% BUILDING THE ENVELOPE FEATURE VECTOR
envelope_feature_vector=[active_areas_number,...
    Major_peak, Major_peak_time, Medium_peak, Medium_peak_time, Lowest_peak, Lowest_peak_time,...
    Major_peak_env, Major_peak_env_time, Medium_peak_env, Medium_peak_env_time, Lowest_peak_env, Lowest_peak_env_time,...
    First_peak, First_peak_time, Second_peak, Second_peak_time, Third_peak, Third_peak_time,...
    First_peak_env, First_peak_env_time, Second_peak_env, Second__peak_env_time, Third_peak_env, Third_peak_env_time,...
    duration,silent_phase,...
    silent_rateo,atrial_ventricular_ratio,atrial_ventricular_time_ratio,...
    third_major_ratio,third_second_ratio,n_active_areas_on_duration_ratio];

%% Final output
envelope_feature_vector=string(envelope_feature_vector);

end


%% ------------------------------------------------------------------------

%% Helper function
function [start_end_areas] = find_atrial_ventricular_areas(signal, example_env, main_ambient)
    %% Envelope active areas
    time_th=get_time_thresholds(signal, example_env,main_ambient);
    
    %% Atrial phase: highest peak before 0.4 s
    t_i = round(main_ambient.feature_extraction_opt.envelope.time_window(1) * main_ambient.fc); % Signal start point
    t_vent = round(main_ambient.feature_extraction_opt.envelope.time_window(2) * main_ambient.fc);    % Signal end point
    fc=main_ambient.fc;
    
    i = 1;
    atr_peak = 0;
    t_atr_start = nan;
    t_atr_end = nan;
    
    while t_i < t_vent && time_th(i, 2) < t_vent && i < size(time_th, 1)
        t_s = time_th(i, 1);
        t_e = time_th(i, 2);
        [candidate_atr_peak, candidate_atr_peak_pos] = max(signal(t_s:t_e));
    
        if candidate_atr_peak > atr_peak
            atr_peak = candidate_atr_peak;
            t_atr_start = t_s;
            t_atr_end = t_e;
        end
        i = i + 1;
        t_i = candidate_atr_peak_pos / fc;
    end
    
    %% Ventricular phase: highest peak after 0.4 s
    t_vent_start = nan;
    t_vent_end = nan;
    vent_peak = 0;
    
    while i <= size(time_th, 1)
        t_s = time_th(i, 1);
        t_e = time_th(i, 2);
        candidate_vent_peak = max(signal(t_s:t_e));
    
        if candidate_vent_peak > vent_peak
            vent_peak = candidate_vent_peak;
            t_vent_start = t_s;
            t_vent_end = t_e;
        end
        i = i + 1;
    end
    
    start_end_areas = [t_atr_start, t_atr_end;
        t_vent_start, t_vent_end];
end



