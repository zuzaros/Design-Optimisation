clc
clear
close all

%% SET UP
%%% Open InitialiseScript and change the filepaths to match your system
InitialiseScript %runs initialistion script for file paths and names

rng default %for reproducibility


%set a vector of lower and upper bounds for the optimisation
lb = [2, -10, -10, -5, -10, 0.1]; %lower bounds
ub = [10, 10, 10, 5, 10, 5]; %upper bounds

% constraints for GA
A = [];
b = [];
Aeq = [];
beq = [];

%set the number of variables and the objective function
nvars = 6; %number of variables
fun = @(X)objFunc(X,Params); %objective function

% Define the initial population (based on the Rational Fit SP coefficients)
initial_population = [
    2,-1.3023, 3.9089, -1.0284, -0.4014, 0.2786
    4,-1.4063, 4.0252, -0.7564, -0.4194, 0.3186
    5,-1.1598, 3.6459, -0.6016, -0.4233, 0.3456
    6,-2.2294, 7.8539, -1.0374, -0.3033, 0.3608
    7,-1.8666, 7.0000, -1.1597, -0.3514, 0.2992
    8, 0.9596, 0.0653, -0.1700, -0.3273, 0.1437
    9, 1.1504, 0.0474, -0.1914, -0.3264, 0.1435
    10, 1.5356, -0.1769, -0.1712, -0.3193, 0.1388
    9, 1.8131, -0.3936, -0.1363, -0.3152, 0.1361
    8, 2.1180, -0.7325, -0.0684, -0.3130, 0.1307
    4, 9.4511, 1.2359, 4.5949, 1.0781, 1.1677;
    ]; 

intcon=1;


%run the genetic algorithm
options = optimoptions('ga', ...
    'MaxGenerations', 100, ... % Increase generations for more iterations
    'PopulationSize', 100, ... % Adjust population size
    'FunctionTolerance', 1e-6, ...
    'OutputFcn', @(options, state, flag) gaOutputFunction(options, state, flag));

[x,fval,exitflag,output,population,scores] = ga(fun,nvars,A,b,Aeq,beq,lb,ub,@nonlcon,intcon,options);

% print optimal values of the variables in command window
disp('Optimal values of the variables are:')
disp(x)

databaseConnect(db_path,projectFilePath,'Disconnect')

function F = objFunc(X,Params)
        
    numBlades=3; %number of blades
    lambda=X(1); %tip speed ratio

    % Get the twist distribution coefficients
    p1 = X(2);
    p2 = X(3);
    p3 = X(4);
    q1 = X(5);
    q2 = X(6);

    % there are 25 stations, going from root to tip
    r = linspace(0,1,25); % radial position of blade in 25 steps
    lambda_r = lambda*r; % local tip speed ratio

    % Rational Fit (2/2) for newTwist
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
    
    figure(1);
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


%% Custom Output Function for GA Visualization
function [state, options, optchanged] = gaOutputFunction(options, state, flag)
    % Initialize optchanged to false
    optchanged = false;

   
    % Check the flag to determine the current state of the GA
    switch flag
        case 'init'
            % Initialization state
            disp('Starting the Genetic Algorithm...');
        case 'iter'
            % Iteration state
            % Log the best fitness value at each iteration
            bestFitness = min(state.Score);
            % Display the best fitness value and X at each iteration
            disp(['Iteration ', num2str(state.Generation), ': Best fitness = ', num2str(bestFitness)])
                     
            % new figure
            figure(2);
            % plot best fitness value at each iteration
            BestAEP=-state.Best;
            plot(BestAEP,'o','MarkerEdgeColor', 'auto', 'MarkerFaceColor', 'k');
            xlabel('Generation');
            ylabel('Best AEP');
            title('Genetic Algorithm Progress');
            hold on;
                        
        case 'done'
            % Final state
            disp('Genetic Algorithm has finished.');
            % Log the final best fitness value
            bestFitness = min(state.Score);
            disp(['Final best fitness = ', num2str(bestFitness)]);
    end
end

function [c, ceq] = nonlcon(X)
    % Get the twist distribution coefficients
    p1 = X(2);
    p2 = X(3);
    p3 = X(4);
    q1 = X(5);
    q2 = X(6);

    % There are 25 stations, going from root to tip
    r = linspace(0, 1, 25); % radial position of blade in 25 steps

    % Rational Fit (2/2) for newTwist
    newTwist = (p1 * r.^2 + p2 * r + p3) ./ (r.^2 + q1 * r + q2);

    % Define the inequality constraints
    c = [newTwist - 20; % Twist angle should be less than or equal to 45 degrees
         -newTwist - 20]; % Twist angle should be greater than or equal to -45 degrees

    % No equality constraints
    ceq = [];
end
