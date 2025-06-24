function [lower_bound, upper_bound] = get_boxplots_ylim(feature, class_data)

    % Preallocate arrays for lower and upper whiskers for the three groups
    lower_whiskers = zeros(1, 3);
    upper_whiskers = zeros(1, 3);

    % Get the unique class labels (assuming three unique classes)
    maps = unique(class_data, "stable");

    % Loop through each class to calculate the whiskers
    for i = 1:3
        % Extract data for the current class
        class_feature = feature(class_data == maps(i));

        % Calculate the quartiles and the interquartile range (IQR)
        q1 = prctile(class_feature, 25);
        q3 = prctile(class_feature, 75);
        iqr_val = q3 - q1;

        % Calculate the whisker limits for the current class
        lower_whiskers(i) = max(min(class_feature), q1 - 1.5 * iqr_val);
        upper_whiskers(i) = min(max(class_feature), q3 + 1.5 * iqr_val);
    end

    % Determine the y-axis bounds by finding the min and max whiskers
    % Adjust the bounds to ensure the boxplot is not too tight
    lower_bound = min(lower_whiskers) - 0.5 * abs(min(lower_whiskers));
    upper_bound = max(upper_whiskers) + 0.05 * max(upper_whiskers);
end
