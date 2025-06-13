function App=get_App(example_rov,fc)
    % The function computes the peak-to-peak (PP) amplitude of a given signal,
    % but only over a portion of the signal that is selected based on the sampling
    % frequency `fc`. The selected portion is between 15% and 65% of the total signal length.
    %
    % Inputs:
    % - example_rov: The input signal (example of the ROV or any time-series data).
    % - fc: The sampling frequency of the signal (in Hz).
    %
    % Output:
    % - App: The peak-to-peak amplitude calculated from the selected portion of the signal.
    %
    % Author: Andrea Corrado 

    %% Step 1: Extract a portion of the signal from 15% to 65% of the signal length
    example_rov = example_rov(round(fc*0.15):round(0.65*fc)); 
    
    %% Step 2: Calculate the peak-to-peak amplitude (max - min)
    App = max(example_rov) - abs(min(example_rov)); 
end
