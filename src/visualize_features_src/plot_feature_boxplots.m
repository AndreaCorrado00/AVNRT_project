function plot_feature_boxplots(data, class, feature_name)

% Extract the feature column from the table and convert it to double
feature = data{:, feature_name};  % Extract the feature data from the table
feature = double(feature);        % Convert to double if it's not already numeric

% Extract class column and convert it to a categorical array
class_data = class{:, 1};         % Extract the class data from the table
desired_order = {'Indifferent', 'Effective', 'Dangerous'}; % Specify the desired order
class_data = categorical(cellstr(class_data), desired_order, 'Ordinal', true); % Convert to categorical with specific order

% Create a new figure with the specified feature name as title
figure('Position', [100, 100, 900, 700]);

% Format feature_name for the title (replace underscores with spaces)
formatted_feature_name = strrep(feature_name, '_', ' ');

% Calculate y-limits based on the data, excluding outliers
[lower_bound, upper_bound] = get_boxplots_ylim(feature, class_data);

% Generate boxcharts by class with specific colors
hold on; 

colors = {[0.6, 0.6, 0.8], [0.2, 0.8, 0.2], [0.8, 0.2, 0.2]}; % Blue for Indifferent, Green for Effective, Red for Dangerous
jitter_amount = 0.4; % Amount of horizontal jitter for scatter points

for i = 1:length(desired_order)
    % Get the data for the current category
    current_category = desired_order{i};
    idx = class_data == current_category;

    % Plot the boxchart
    boxchart(repmat(i, sum(idx), 1), feature(idx), 'BoxWidth', 0.5, ...
        'MarkerStyle', 'none', ...
        'BoxFaceColor', colors{i});

    % Add scatter points for the data
    jittered_x = i + (rand(sum(idx), 1) - 0.5) * jitter_amount; % Add jitter to x-coordinates
    scatter(jittered_x, feature(idx), 20, 'filled', 'MarkerFaceAlpha', 0.30, 'MarkerFaceColor', colors{i}); % Scatter points with transparency
end
hold off;

% Adjust axes and formatting
ylim([lower_bound, upper_bound]);   % Adjust y-limits to exclude outliers
set(gca, 'XTick', 1:length(desired_order), 'XTickLabel', desired_order,"FontSize",22); % Set class labels on x-axis
xlabel('Class',"FontSize",22);
ylabel(formatted_feature_name,"FontSize",24);

% Set the title
title("Boxplots for " + formatted_feature_name + " by Class", "FontSize", 26);
end
