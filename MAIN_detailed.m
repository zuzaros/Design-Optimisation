

load population5050GAall4.mat

% Replace 'population5050GAall4' with the correct variable name from the .mat file
final_population = population; 

% Check the dimensions of final_population
if size(final_population, 2) ~= 5
    error('The final_population variable does not have the expected dimensions of 50x5.');
end

%%% Open InitialiseScript and change the filepaths to match your system
InitialiseScript %runs initialistion script for file paths and names

% Initialize variables to store results
nVars = size(final_population, 2); % Number of variables
fmincon_results = zeros(size(final_population)); % To store refined solutions
fmincon_scores = zeros(size(final_population, 1), 1); % To store objective function values

% Optimization options for fmincon
options_fmincon = optimoptions('fmincon', ...
    'Display', 'iter', ... % Display progress
    'Algorithm', 'sqp', ... % Use active-set algorithm for robust performance
    'MaxIterations', 1000, ... % Maximum number of iterations
    'FunctionTolerance', 1e-6, ... % Function tolerance
    'StepTolerance', 1e-6, ... % Step tolerance
    'ConstraintTolerance', 1e-6, ... % Constraint tolerance
    'OptimalityTolerance', 1e-6); % Optimality tolerance

% Bounds and constraints (same as GA)
lb = [-10, -10, -5, -10, 0.1];
ub = [10, 10, 5, 10, 5];

A = [];
b = [];
Aeq = [];
beq = [];

% Select a subset of points from the population as starting points
num_starting_points = 5; % Number of starting points to select
starting_indices = randperm(size(final_population, 1), num_starting_points);
starting_points = final_population(starting_indices, :);


% Initialize figure for plotting optimization progress
figure(1);
hold on;
xlabel('Iteration');
ylabel('Optimized Objective Value');
title('Optimization Progress');
grid on;

% Iterate through each selected starting point
for i = 1:size(starting_points, 1)
    % Starting point (selected individual from the final population)
    x0 = double(starting_points(i, :)); % Ensure x0 is of type double

    % Run fmincon
    [x_opt, fval_opt] = fmincon(@(X)objFunc(X, Params), ... % Objective function
                                x0, ...                    % Starting point
                                A, b, Aeq, beq, ...        % Constraints
                                lb, ub, ...                % Bounds
                                @(X)nonlcon(X), ...        % Nonlinear constraints
                                options_fmincon);          % Optimization options

    % Store results
    fmincon_results(i, :) = x_opt; % Optimized parameters
    fmincon_scores(i) = fval_opt; % Optimized objective value

    % Plot the optimized objective value against iteration number
    plot(i, fval_opt, 'ro');
end

% Find the best solution from fmincon results
[best_score, best_idx] = min(fmincon_scores(1:num_starting_points));
best_solution = fmincon_results(best_idx, :);

% Display the best solution and score
disp('Best solution found by fmincon:');
disp(best_solution);
disp('Best objective value:');
disp(best_score);

% Plot the best solution
plot(best_idx, best_score, 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');

% Connect to Ashes (if required)
databaseConnect(db_path, projectFilePath, 'Disconnect');

function F = objFunc(X, Params)
        
    numBlades=3; %number of blades
    lambda=4; %tip speed ratio

    % Get the twist distribution coefficients
    p1 = X(1);
    p2 = X(2);
    p3 = X(3);
    q1 = X(4);
    q2 = X(5);

    % there are 25 stations, going from root to tip
    r = linspace(0,1,25); % radial position of blade in 25 steps
    lambda_r = lambda*r; % local tip speed ratio

    % Rational (2/2) for newTwist
    newTwist = (p1 * r.^2 + p2 * r + p3) ./ (r.^2 + q1 * r + q2);

    newChord = optimalChord(numBlades,r,lambda_r);

    Foils = {'naca2424'}; %specifies aerofoils to be used (must match name in Ashes aerofoil database)
    foilsDist = [ones(1,25)]; %specifies aerofoil distribution based on Foils index
    %^^ in the above foils distribution, foilDist is set to a vector of ones,
    %as there is only 1 aerofoil in the Fois variable
    
    %submit the simulation and read the results - do not change
    [rotor,blade] = runSIM(Params,newTwist,newChord,Foils,foilsDist,numBlades);

    %THE FOLLOWING CODE IS FOR YOU TO CHANGE%
    
    %rotor and blade are structures, and can be epxlored. 
    %For example - double clicking "rotor" in the workspace, there are 5 fields
    %within the structure. 
    %You can access each of these variables by typing rotor.variablename
    %e.g. here's the rotor CP plotted for each load case in the batch file
    %looking at the batch file, you can see it runs different tip speed ratios
    %(TSRs), and each element in rotor.CP is the CP for each TSR
    %we also plot the angle of attack of the blade (at the highest CP) across the span to give
    %an example of exploring the blade results output.

    %my simple objective funciton 
    [Cp,I] = max(rotor.CP); %I is load case index that produced max power

    % calculate AEP
    AEP=calcEnergyOutput(Cp);
    
    F = -AEP; %to convert to minimisation 

    %create a subplot for the rotor CP and the angle of attack across the
    %blade
    
    figure(2);
    %create first subplot
    subplot(2,2,1)
    plot([2,4,6,8,10],rotor.CP)
    xlabel('TSR')
    ylabel('C_P')
    hold on

    %create second subplot
    subplot(2,2,2)
    plot(linspace(0,1,25),blade.AngleOfAttack(I,:)) %plot the angle of attack distribution for the load case that produced the max CP
    xlabel('r/R') %normalised spanwise location across blade - where r/R  
    ylabel('Angle of attack')
    hold on
    drawnow

    subplot(2,2,3)
    plot(r,newChord)
    xlabel('r')
    ylabel('Chord (m)')
    title('Chord Distribution')
    hold on
     
    subplot(2,2,4)
    plot(r,newTwist)
    xlabel('r')
    ylabel('Twist (degrees)')
    title('Twist Distribution')
    hold on
    drawnow
   
end

function [c, ceq] = nonlcon(X)
    % Get the twist distribution coefficients
    p1 = X(1);
    p2 = X(2);
    p3 = X(3);
    q1 = X(4);
    q2 = X(5);

    % There are 25 stations, going from root to tip
    r = linspace(0, 1, 25); % radial position of blade in 25 steps

    % Rational Fit (2/2) for newTwist
    newTwist = (p1 * r.^2 + p2 * r + p3) ./ (r.^2 + q1 * r + q2);

    % Define the inequality constraints
    c = [newTwist - 20; % Twist angle should be less than or equal to 20 degrees
         -(-newTwist - 20)]; % Twist angle should be greater than or equal to -20 degrees

    % No equality constraints
    ceq = [];
end

