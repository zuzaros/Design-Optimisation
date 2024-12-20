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

wind_speeds = 5; % Select wind speed 5
selected_column = 1; % Corresponding column in the angles matrix

% Initialize arrays to hold combined smoothed spline data
combined_x_smooth = [];
combined_y_smooth = [];

% Fit and plot cubic splines for the selected wind speed
figure;
colors = lines(1); % Generate unique color
markers = {'o'}; % Marker

speed_data = angles(:, selected_column);
spline_fit = spline(positions, speed_data);
x_smooth = linspace(min(positions), max(positions), 500);
y_smooth = ppval(spline_fit, x_smooth);

% Combine smoothed spline data for fitting
combined_x_smooth = [combined_x_smooth, x_smooth];
combined_y_smooth = [combined_y_smooth, y_smooth];

% Average the y values for each unique x value
[unique_x, ~, idx] = unique(combined_x_smooth);
average_y = accumarray(idx, combined_y_smooth, [], @mean);

% Ensure unique_x and average_y are column vectors
unique_x = unique_x(:);
average_y = average_y(:);

% Add the (0,0) starting point for rational fit
unique_x = [0; unique_x];
average_y = [0; average_y];

% Subplot 1: Polynomial Fits
subplot(1,3, 1);
hold on;
plot(positions, speed_data, '-k', 'LineWidth', 2); % Connect the dots with straight lines
scatter(positions, speed_data, 20, 'k', markers{1}, 'filled', ...
    'DisplayName', sprintf('%d m/s', wind_speeds));

% Fit polynomials of orders 2, 3, 4, 5, and 6 to the averaged data
poly_orders = [2, 3, 4, 5, 6];
poly_fits = cell(length(poly_orders), 1);
poly_coeffs = cell(length(poly_orders), 1);

for i = 1:length(poly_orders)
    degree = poly_orders(i);
    [p, S, mu] = polyfit(unique_x, average_y, degree);
    poly_fits{i} = p;
    poly_coeffs{i} = p;
    
    % Evaluate the polynomial fit
    y_fit = polyval(p, linspace(min(positions), max(positions), 500), [], mu);
    
    % Plot the polynomial fit
    plot(linspace(min(positions), max(positions), 500), y_fit, 'LineWidth', 1.5, 'DisplayName', sprintf('Polynomial Fit (order %d)', degree));
    
    % Display the polynomial coefficients
    disp(sprintf('Polynomial coefficients (order %d):', degree));
    disp(p);
end

xlabel('Position (m)', 'FontSize', 12);
ylabel('Twist Angle (degrees)', 'FontSize', 12);
legend('Location', 'northeast');
title('Polynomial Fits');
hold off;

% Subplot 2: Fourier Series Fits
subplot(1,3, 2);
hold on;
plot(positions, speed_data, '-k', 'LineWidth', 2); % Connect the dots with straight lines
scatter(positions, speed_data, 20, 'k', markers{1}, 'filled', ...
    'DisplayName', sprintf('%d m/s', wind_speeds));

fourier_orders = [1, 2, 3];
fourier_fits = cell(length(fourier_orders), 1);
fourier_coeffs = cell(length(fourier_orders), 1);

for i = 1:length(fourier_orders)
    order = fourier_orders(i);
    fourier_fit = fit(unique_x, average_y, sprintf('fourier%d', order));
    fourier_fits{i} = fourier_fit;
    fourier_coeffs{i} = coeffvalues(fourier_fit);
    
    % Evaluate the Fourier series fit
    y_fourier = feval(fourier_fit, linspace(min(positions), max(positions), 500));
    
    % Plot the Fourier series fit
    plot(linspace(min(positions), max(positions), 500), y_fourier, 'LineWidth', 1.5, 'DisplayName', sprintf('Fourier Series Fit (order %d)', order));
    
    % Display the Fourier series coefficients
    disp(sprintf('Fourier series coefficients (order %d):', order));
    disp(coeffvalues(fourier_fit));
end

xlabel('Position (m)', 'FontSize', 12);
ylabel('Twist Angle (degrees)', 'FontSize', 12);
legend('Location', 'northeast');
title('Fourier Series Fits');
hold off;

% Subplot 3: Rational Function Fits
subplot(1, 3, 3);
hold on;
plot(positions, speed_data, '-k', 'LineWidth', 2); % Connect the dots with straight lines
scatter(positions, speed_data, 20, 'k', markers{1}, 'filled', ...
    'DisplayName', sprintf('%d m/s', wind_speeds));

fit_types = {'rat11', 'rat22', 'rat33'};
fit_names = {'Rational Fit (1/1)', 'Rational Fit (2/2)', 'Rational Fit (3/3)'};

for i = 1:length(fit_types)
    fit_type = fit_types{i};
    fit_name = fit_names{i};
    custom_fit = fit(unique_x, average_y, fit_type);
    
    % Evaluate the custom fit
    y_custom = feval(custom_fit, linspace(min(positions), max(positions), 500));
    
    % Plot the custom fit
    plot(linspace(min(positions), max(positions), 500), y_custom, 'LineWidth', 1.5, 'DisplayName', fit_name);
    
    % Display the custom fit coefficients
    disp(sprintf('%s coefficients:', fit_name));
    disp(coeffvalues(custom_fit));
end

xlabel('Position (m)', 'FontSize', 12);
ylabel('Twist Angle (degrees)', 'FontSize', 12);
legend('Location', 'northeast');
title('Rational Function Fits');
hold off;