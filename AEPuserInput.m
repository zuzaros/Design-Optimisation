clc;
clear all;

% Load necessary data
load ratFitCoeff.mat;

%%% Open InitialiseScript and change the filepaths to match your system
InitialiseScript %runs initialistion script for file paths and names

% Define input parameters
numBlades = 3;
lambda = 4;

% Scale the coefficients
p1 = 9.4511;
p2 = 1.2359;
p3 = 4.5949;
q1 = 1.0781;
q2 = 1.1677;

% There are 25 stations, going from root to tip
r = linspace(0, 1, 25); % Radial position of blade in 25 steps
lambda_r = lambda .* r; % Local tip speed ratio

% Rational Fit (2/2) for newTwist
newTwist = (p1 * r.^2 + p2 * r + p3) ./ (r.^2 + q1 * r + q2);

%subplot to show the twist distribution
subplot(2,1,1)
plot(r,newTwist)
xlabel('r')
ylabel('Twist (degrees)')
title('Twist Distribution')
grid on

% Calculate the new chord distribution
newChord = optimalChord(numBlades, r, lambda_r);

%subplot to show the chord distribution
subplot(2,1,2)
plot(r,newChord)
xlabel('r')
ylabel('Chord (m)')
title('Chord Distribution')
grid on

Foils = {'2424'}; % Specifies aerofoils to be used (must match name in Ashes aerofoil database)
foilsDist = ones(1, 25); % Specifies aerofoil distribution based on Foils index

% Submit the simulation and read the results - do not change
[rotor, blade] = runSIM(Params, newTwist, newChord, Foils, foilsDist, numBlades);

% Check the Cp values
Cp = rotor.CP; % Extract the Cp values from the rotor structure
disp('Cp values:');
disp(Cp);

% Calculate the AEP using the Cp from Ashes
AEP = calcEnergyOutput(Cp); % Calculate the AEP

% Display the AEP
fprintf('The Annual Energy Production (AEP) is %.2f kWh\n', AEP);

% Close the connection to the databases
databaseConnect(db_path, projectFilePath, 'Disconnect');
