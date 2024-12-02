%%% Open InitialiseScript and change the filepaths to match your system
InitialiseScript %runs initialistion script for file paths and names

% Ask the user for input parameters
numBlades = 3;
lambda = 4;
%twist_root = 8.3424;
%twist_tip = 2.1664;

a=10.7725/4.957;   
b=15.4296/4.957;       
c=4.2999/4.957;   
d=-0.8226/4.957;   
e=5.4569/4.957;   

% There are 25 stations, going from root to tip
r = linspace(0, 1, 25); % Radial position of blade in 25 steps
lambda_r = lambda .* r; % Local tip speed ratio

%% Linearly varying twist distribution
%newTwist = linspace(twist_root, twist_tip, 25);

% Rational Fit (2/2) for newTwist
newTwist = (a * r.^2 + b * r + c) ./ (d * r + e ); % rational fit equation

% Calculate the new chord distribution
newChord = optimalChord(numBlades, r, lambda_r);

Foils = {'2424'}; %specifies aerofoils to be used (must match name in Ashes aerofoil database)
foilsDist = [ones(1,25)]; %specifies aerofoil distribution based on Foils index

%submit the simulation and read the results - do not change
[rotor,blade] = runSIM(Params,newTwist,newChord,Foils,foilsDist,numBlades);


% Calculate the AEP using the Cp from Ashes
Cp = rotor.CP; % Extract the Cp values from the rotor structure
AEP = calcEnergyOutput(Cp); % Calculate the AEP

% Display the AEP
fprintf('The Annual Energy Production (AEP) is %.2f kWh\n', AEP);

% Plot the result
figure;
plot(r, newTwist, '-o', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('Radial Position (r)');
ylabel('Twist Angle (degrees)');
title('Twist Distribution Along Blade Span');
grid on;

%close the connection to the databases
databaseConnect(db_path,projectFilePath,'Disconnect')


