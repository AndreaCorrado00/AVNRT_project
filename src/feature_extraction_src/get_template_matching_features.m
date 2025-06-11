function [template_matching_feature_vector,template_matching_features_names]=get_template_matching_features(signal, main_ambient)
% GET_TEMPLATE_MATCHING_FEATURES - Extracts template-matching features from an input signal.
%
% Syntax:
%   [features, feature_names] = get_template_matching_features(signal, main_ambient)
%
% Description:
%   This function computes a set of template-matching features based on the
%   cross-correlation between the input signal and predefined templates.
%   For each template defined in main_ambient, it evaluates:
%     - The peak of the cross-correlation signal within a specified time window
%     - The time position of that peak
%     - The energy of the cross-correlation signal
%
% Inputs:
%   signal       - A vector representing the signal to be analyzed
%   main_ambient - A struct containing configuration parameters, including:
%                  * Sampling frequency (fc)
%                  * Feature extraction options (template names and time window)
%
% Outputs:
%   features       - A vector of extracted features, one triplet per template:
%                    [cross_peak, cross_peak_time, cross_energy]
%   feature_names  - A string array of feature names corresponding to each value in 'features'
%
% Notes:
%   - The time window for peak extraction is defined in seconds and converted
%     into indices using the sampling frequency.
%   - NaN values in the correlation signal are handled via 'omitnan' and 'omitmissing' options.
%   - The correlation energy is normalized by the valid signal length.
%
% Dependencies:
%   GET_TEMPLATE, GET_CORRELATION_SIGNAL
%
% Author: Andrea Corrado

%% Feature extraction options
N_template=length(main_ambient.feature_extraction_opt.TemplateMatching.template_names);
fc=main_ambient.fc;

%% Template matching evaluation
% feature vector initialization
template_matching_feature_vector=[];
template_matching_features_names=[];

for i=1:N_template
    % template type definition
    template_type=main_ambient.feature_extraction_opt.TemplateMatching.template_names(i);
    % template evaluation
    template=get_template(template_type,main_ambient);
    % cross correlation signal evaluation
    corr_signal=get_correlation_signal(signal, template, main_ambient);

    %% Feature extraction
    % Defining the analysis window
    start_idx = round(fc * main_ambient.feature_extraction_opt.TemplateMatching.time_window(1));
    end_idx =  round(fc * main_ambient.feature_extraction_opt.TemplateMatching.time_window(2));

    % Find the peak value and its position in the cross-correlation signal 
    [cross_peak, cross_peak_pos] = max(corr_signal(start_idx:end_idx), [], 'omitmissing');
    cross_peak_pos = (cross_peak_pos + start_idx) / fc;  % Convert index to time (in seconds)

    % Compute the energy of the cross-correlation signal for Template 1
    M = find(~isnan(corr_signal), 1, 'last') - find(~isnan(corr_signal), 1, 'first');
    corr_energy = sum(corr_signal.^2, 'omitnan') / M;

    template_matching_feature_vector=[template_matching_feature_vector,cross_peak,cross_peak_pos,corr_energy];

    template_matching_features_names=[template_matching_features_names,"cross_peak_TM"+num2str(i),"cross_peak_time_TM"+num2str(i),"cross_energy_TM"+num2str(i)];

end

template_matching_feature_vector=string(template_matching_feature_vector);
