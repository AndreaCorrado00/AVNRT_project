function App=get_App(example_rov,main_ambient)
    % The function computes the peak-to-peak (PP) amplitude of a given signal,
    % but only over a portion of the signal that is selected based on the sampling
    % frequency `fc`.
    %
    % Inputs:
    % - example_rov: The input signal (example of the ROV or any time-series data).
    % - fc: The sampling frequency of the signal (in Hz).
    %
    % Output:
    % - App: The peak-to-peak amplitude calculated from the selected portion of the signal.
    %
    % Author: Andrea Corrado 

    %% Step 1: Extract a portion of the signal
    example_rov = example_rov(round(main_ambient.fc*main_ambient.feature_extraction_opt.envelope.time_window(1)):round(main_ambient.feature_extraction_opt.envelope.time_window(2)*main_ambient.fc)); 
    
    %% Step 2: Calculate the peak-to-peak amplitude (max - min)
    App = max(example_rov) - abs(min(example_rov)); 
end
