function sub_bands_feature_values=get_STFT_subbands_values(method, STFT, idx_sub_bands,STFT_peaks_positions)
%GET_STFT_SUBBANDS_VALUES Compute statistical features from selected STFT sub-bands within time-localized signal segments.
%
%   sub_bands_feature_values = GET_STFT_SUBBANDS_VALUES(method, STFT, idx_sub_bands, STFT_peaks_positions)
%
%   This function extracts statistical descriptors (mean, max, min, std) from three predefined
%   frequency sub-bands in the time-frequency (STFT) representation of a signal. The features
%   are computed within specific time intervals centered around signal peaks, as defined in
%   the input matrix STFT_peaks_positions.
%
%   INPUTS:
%       method               : String
%           Statistical operation to apply across each sub-band. Accepted values are:
%               - "mean" : Compute the average power in each sub-band
%               - "max"  : Compute the maximum power in each sub-band
%               - "min"  : Compute the minimum power in each sub-band
%               - "std"  : Compute the standard deviation of power in each sub-band
%
%       STFT                : Matrix (F x T)
%           Time-frequency representation of the signal (typically obtained via spectrogram).
%           Rows correspond to frequency bins; columns correspond to time frames.
%
%       idx_sub_bands       : Matrix (F x 3)
%           Matrix containing row indices for each of the 3 sub-bands.
%           Each column specifies the frequency bin indices corresponding to one sub-band.
%           For example, idx_sub_bands(:,1) indexes the first sub-band, etc.
%
%       STFT_peaks_positions : Matrix (3 x 8)
%           Time-localized peak information, as returned by GET_STFT_PEAKS.
%           Columns 5 and 6 define the start and end indices in the STFT time dimension
%           for each region of interest.
%
%   OUTPUT:
%       sub_bands_feature_values : Matrix (3 x 3)
%           A matrix where rows correspond to time segments (1 to 3), and columns correspond to
%           sub-bands (1 to 3). Each element is the computed feature over the respective sub-band
%           and time region. Values are returned as NaN where computation is not possible.
%
%   Notes:
%       - If a region of interest contains no peak (i.e., NaN in STFT_peaks_positions), its output
%         will be set to NaN.
%       - Zero values are treated as missing and replaced with NaNs to preserve downstream robustness.
%       - Output is transposed at the end so that rows index time windows and columns index sub-bands.
%
%   Example:
%       features = get_STFT_subbands_values("mean", my_STFT, my_subbands_idx, peak_info);
%
% Author: Andrea Corrado

sub_bands_feature_values=zeros(3,3);
switch method
    case "mean"
        for i=1:3
            if ~isnan(STFT_peaks_positions(i,1))
                sub_bands_feature_values(1,i)=mean(STFT(idx_sub_bands(:,1),STFT_peaks_positions(i,5):STFT_peaks_positions(i,6)),'all');
                sub_bands_feature_values(2,i)=mean(STFT(idx_sub_bands(:,2),STFT_peaks_positions(i,5):STFT_peaks_positions(i,6)),'all');
                sub_bands_feature_values(3,i)=mean(STFT(idx_sub_bands(:,3),STFT_peaks_positions(i,5):STFT_peaks_positions(i,6)),'all');
            end
        end
    case "max"
        for i=1:3
            if ~isnan(STFT_peaks_positions(i,1))
                sub_bands_feature_values(1,i)=max(STFT(idx_sub_bands(:,1),STFT_peaks_positions(i,5):STFT_peaks_positions(i,6)),[],'all');
                sub_bands_feature_values(2,i)=max(STFT(idx_sub_bands(:,2),STFT_peaks_positions(i,5):STFT_peaks_positions(i,6)),[],'all');
                sub_bands_feature_values(3,i)=max(STFT(idx_sub_bands(:,3),STFT_peaks_positions(i,5):STFT_peaks_positions(i,6)),[],'all');
            end
        end

    case "min"
        for i=1:3
            if ~isnan(STFT_peaks_positions(i,1))
                sub_bands_feature_values(1,i)=min(STFT(idx_sub_bands(:,1),STFT_peaks_positions(i,5):STFT_peaks_positions(i,6)),[],'all');
                sub_bands_feature_values(2,i)=min(STFT(idx_sub_bands(:,2),STFT_peaks_positions(i,5):STFT_peaks_positions(i,6)),[],'all');
                sub_bands_feature_values(3,i)=min(STFT(idx_sub_bands(:,3),STFT_peaks_positions(i,5):STFT_peaks_positions(i,6)),[],'all');
            end
        end
    case "std"
        for i=1:3
            if ~isnan(STFT_peaks_positions(i,1))
                sub_bands_feature_values(1,i)=std(STFT(idx_sub_bands(:,1),STFT_peaks_positions(i,5):STFT_peaks_positions(i,6)),0,'all');
                sub_bands_feature_values(2,i)=std(STFT(idx_sub_bands(:,2),STFT_peaks_positions(i,5):STFT_peaks_positions(i,6)),0,'all');
                sub_bands_feature_values(3,i)=std(STFT(idx_sub_bands(:,3),STFT_peaks_positions(i,5):STFT_peaks_positions(i,6)),0,'all');
            end
        end
end

% Replace zeros with NaN to handle missing data or uncalculated regions
sub_bands_feature_values(sub_bands_feature_values==0)=nan;
% Transposition for the following steps
sub_bands_feature_values=sub_bands_feature_values';

end
