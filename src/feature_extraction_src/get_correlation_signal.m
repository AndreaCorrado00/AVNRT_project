function corr_signal=get_correlation_signal(signal, template, main_ambient)

%% Correlation signal options 
smoothing_window=main_ambient.feature_extraction_opt.TemplateMatching.corr_signal_smoothing_window;

%% Correlation signal evaluation
norm_signal = sqrt(sum(signal.^2));  % Signal normalization
signal = signal / norm_signal;  % Normalize the signal
signal = movmean(signal, smoothing_window);  % Smooth the signal

% Generate multiphasic template
norm_template = sqrt(sum(template.^2));  % Template normalization
template = template / norm_template;  % Normalize the template

% Compute cross-correlation between the signal and the template
corr = conv(signal, flip(template), 'same');  % Convolution (cross-correlation)

% Apply moving average to the correlation for smoothing
corr_signal = movmean(corr, smoothing_window);  % Store the result