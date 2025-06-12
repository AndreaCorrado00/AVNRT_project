function sub_bands_feature_values=get_STFT_subbands_values(method, STFT, idx_sub_bands,STFT_peaks_positions)

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
