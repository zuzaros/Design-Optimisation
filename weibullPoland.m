clc 
clear all
close all

% this function plots the Weibull distribution and finds its peak value
% for the data from Poland

% parameters from literature
k = 2.0974232; % shape parameter
A = 5.1039554; % scale parameter
u = -1.2692170; % location parameter

% formula for the Weibull distribution
f = @(x) (k/A) * ((x-u)/A).^(k-1) .* exp(-((x-u)/A).^k);

% plot the Weibull distribution
x = 0:0.01:16;
y = f(x);
figure;
plot(x, y, 'LineWidth', 3) % Super thick line for the Weibull distribution
xlabel('Wind Speed (m/s)', 'FontWeight', 'bold')
ylabel('Distribution Probability', 'FontWeight', 'bold')
% Switch off the upper and right-hand side axis lines
ax = gca;
ax.Box = 'off';
ax.TickDir = 'out';

% find the peak value
[peakValue, peakIndex] = max(y);
peakX = x(peakIndex);
fprintf('The peak value of the Weibull distribution for Poland is %f\n', peakValue)
fprintf('The peak value occurs at x=%f\n', peakX)

% find the mean and standard deviation
[mean, var] = wblstat(A, k);
stdDev = sqrt(var);
fprintf('The mean of the Weibull distribution for Poland is %f\n', mean)
fprintf('The standard deviation of the Weibull distribution for Poland is %f\n', stdDev)

% plot the peak, mean, and standard deviation
hold on
plot([peakX peakX], [0 peakValue], 'b', 'LineWidth', 3) % Super thick line for the peak
plot([mean mean], [0 f(mean)], 'r', 'LineWidth', 3) % Super thick line for the mean
hold off

% Add titles to the peak, mean, and standard deviation lines
text(peakX, peakValue, sprintf('   Mode = %.2f m/s', peakX), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'Color', 'b', 'FontSize', 12, 'FontWeight', 'bold')
text(mean, f(mean), sprintf('   Mean = %.2f m/s', mean), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold')

% calculate the 5th and 95th percentiles
p5 = wblinv(0.05, A, k);
p95 = wblinv(0.95, A, k);
fprintf('The 5th percentile of the Weibull distribution for Poland is %f\n', p5)
fprintf('The 95th percentile of the Weibull distribution for Poland is %f\n', p95)
