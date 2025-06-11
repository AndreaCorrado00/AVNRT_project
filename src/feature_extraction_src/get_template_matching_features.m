function [template_matching_feature_vector,template_matching_features_names]=get_template_matching_features(signal, main_ambient)

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
