% Coefficients matrix
coefficients = [
   -6.4647, 18.5039, -3.4771, -1.9282, 1.4646;
   -5.3317, 16.7600, -2.7657, -1.9457, 1.5886;
  -10.2486, 36.1042, -4.7691, -1.3941, 1.6585;
   -8.5806, 32.1355, -5.3311, -1.6156, 1.3753;
    4.4113,  0.3003, -0.7812, -1.5046, 0.6608;
    5.2884,  0.2179, -0.8799, -1.5004, 0.6595;
    7.0592, -0.8130, -0.7869, -1.4679, 0.6382;
    8.3346, -1.8094, -0.6264, -1.4490, 0.6255;
    9.7365, -3.3674, -0.3146, -1.4390, 0.6006
];

load ratFitCoeff.mat

% Scaling factor
scaling_factor = 1 / 4.597;

% Scale the matrix
scaled_coefficients = coefficients * scaling_factor;

% Define the numerator and denominator
numerator = [-6.4647, 18.5039, -3.4771,];
denominator = [-1.9282, 1.4646];

%   -6.4647   18.5039   -3.4771   -1.9282    1.4646
custom_fit.p1 = numerator(1);
custom_fit.p2 = numerator(2);
custom_fit.p3 = numerator(3);
custom_fit.q1 = denominator(1);
custom_fit.q2 = denominator(2);


% Generate x-values
x = linspace(0, 4.6, 1000);

% Fit rational function (2/2) with starting points
fit_type = 'rat22';

% Evaluate the custom fit
x_fit = x;
y_fit = feval(custom_fit, x_fit);

% Plot the rational function
plot(x_fit, y_fit, 'b-', 'LineWidth', 1.5);
grid on;
xlabel('x');
ylabel('f(x)');
title('Rational Function Plot');
xlim([0 4.6])

