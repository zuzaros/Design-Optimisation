clc

% Data for positions and twist angles
positions = [
    0, 0.136, 0.4481, 0.8001, 1.0767, 1.2779, 1.4958, 1.7137, 1.9149, 2.116, ...
    2.334, 2.552, 2.753, 2.9542, 3.1721, 3.39, 3.5912, 3.7924, 3.9684, 4.1444, ...
    4.3456, 4.5216, 4.597
];

angles = [
    0, 0, 0, 0, 0, 0, 0, 0, 0;
    0, 0, 0, 0, 0, 0, 0, 0, 0;
    -0.098, -0.098, -0.098, -0.098, -0.098, -0.098, -0.098, -0.098, -0.098;
    15.6705, 14.3956, 23.5589, 28.3914, 24.1554, 27.7957, 30.5284, 31.5753, 36.5962;
    15.4087, 13.0777, 17.5893, 23.9619, 21.4265, 24.7895, 27.5979, 28.9475, 32.8829;
    15.1469, 11.7599, 11.6198, 19.5324, 18.6977, 21.7833, 24.6675, 26.3197, 29.1697;
    11.5575, 11.0272, 11.2435, 16.9635, 15.9689, 18.7771, 21.7370, 23.6919, 25.4564;
    7.968, 10.2945, 10.8672, 14.3947, 13.2401, 15.7710, 18.8065, 21.0642, 21.7432;
    5.8462, 7.5471, 10.681, 13.5584, 12.2359, 14.5127, 17.4861, 19.4248, 20.2981;
    3.7244, 4.7997, 10.4947, 12.7221, 11.2318, 13.2544, 16.1656, 17.7854, 18.8531;
    1.6026, 2.0523, 10.3085, 11.8858, 10.2276, 11.9962, 14.8452, 16.146, 17.4081;
    0.9617, 1.3347, 7.335, 8.7709, 9.2234, 10.7379, 13.5247, 14.5067, 15.963;
    0.3207, 0.6171, 4.3615, 5.6561, 8.2193, 9.4797, 12.2043, 12.8673, 14.518;
    -0.3202, -0.1005, 1.3881, 2.5412, 7.8323, 9.0886, 11.6502, 12.5378, 14.4166;
    -0.9611, -0.8181, -1.5854, -0.5736, 7.4453, 8.6975, 11.0962, 12.2082, 14.3152;
    -1.3274, -1.1741, -1.7252, -0.8972, 7.0583, 8.3065, 10.5421, 11.8787, 14.2138;
    -1.6938, -1.5302, -1.865, -1.2207, 6.6713, 7.9154, 9.9881, 11.5491, 14.1124;
    -2.0601, -1.8863, -2.0048, -1.5442, 6.2843, 7.5244, 9.4341, 11.2196, 14.0111;
    -2.4265, -2.2423, -2.1446, -1.8677, 5.8974, 7.1333, 8.88, 10.89, 13.9097;
    -3.6521, -2.368, -2.4604, -2.2064, 5.6476, 6.8675, 8.7025, 10.6464, 12.762;
    -4.8777, -2.4937, -2.7762, -2.545, 5.3978, 6.6016, 8.5249, 10.4028, 11.6143;
    -6.1033, -2.6194, -3.092, -2.8837, 5.148, 6.3358, 8.3474, 10.1591, 10.4666;
    -7.329, -2.7451, -3.4078, -3.2224, 4.8982, 6.07, 8.1699, 9.9155, 9.3189
];

wind_speeds = 5:13;

% Fit and plot rational fits for each wind speed
figure;
hold on;
colors = lines(length(wind_speeds)); % Generate unique colors
markers = {'o', 's', '^', 'd', 'p', 'h', 'v', '<', '>', '*', 'x', '+', '>'}; % Different markers

coeff_matrix = [];

% Starting points for the rational function (2/2)
start_points = [-5.9866, 17.9690, -4.7276, -1.8453, 1.2805];

for i = 1:length(wind_speeds)
    speed_data = angles(:, i);
    
    % Plot original points with the same color as the fit line and filled markers
    scatter(positions, speed_data, 50, 'filled', 'MarkerFaceColor', colors(i, :), ...
        'MarkerEdgeColor', colors(i, :), 'Marker', markers{i}, ...
        'DisplayName', sprintf('%d m/s', wind_speeds(i)));
    
    % Fit rational function (2/2) with starting points
    fit_type = 'rat22';
    custom_fit = fit(positions(:), speed_data(:), fit_type, 'StartPoint', start_points);
    
    % Evaluate the custom fit
    x_fit = linspace(min(positions), max(positions), 500);
    y_fit = feval(custom_fit, x_fit);
    
    % Plot the custom fit
    plot(x_fit, y_fit, 'LineWidth', 1.5, 'Color', colors(i, :), ...
        'DisplayName', sprintf('Rational Fit (2/2) for %d m/s', wind_speeds(i)));
    
    % Get the coefficients and add to the matrix
    coeffs = coeffvalues(custom_fit);
    coeff_matrix = [coeff_matrix; coeffs];
end

% Print the coefficients matrix
disp('Coefficients matrix:');
disp(coeff_matrix);

% Labels and legend
xlabel('Position (m)', 'FontSize', 16);
ylabel('Twist Angle (degrees)', 'FontSize', 16);
legend('Location', 'northeast');
title('Rational Function Fits (2/2) for All Wind Speeds');
hold off;