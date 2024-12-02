clc
clear
close all

%% SET UP
%%% Open InitialiseScript and change the filepaths to match your system
InitialiseScript %runs initialistion script for file paths and names

rng default %for reproducibility


%set a vector of lower and upper bounds for the optimisation
lb = [2, -20, -20, -20, -20, -20]; %lower bounds
ub = [10, 20, 20, 20, 20, 20]; %upper bounds

% constraints for GA
A = [];
b = [];
Aeq = [];
beq = [];
nonlcon = [];

%set the number of variables and the objective function
nvars = 6; %number of variables
fun = @(X)objFunc(X,Params); %objective function

% Define the initial population (based on the Rational Fit SP coefficients)
initial_population = [
    6, -5.9866, 17.9690, -4.7276, -1.8453, 1.2805;
    6, -6.4647, 18.5039, -3.4771, -1.9282, 1.4646;
    6, -5.3317, 16.7600, -2.7657, -1.9457, 1.5886;
    6, -10.2486, 36.1042, -4.7691, -1.3941, 1.6585;
    6, -8.5806, 32.1355, -5.3311, -1.6156, 1.3753;
    6, 4.4113, 0.3003, -0.7812, -1.5046, 0.6608;
    6, 5.2884, 0.2179, -0.8799, -1.5004, 0.6595;
    6, 7.0592, -0.8130, -0.7869, -1.4679, 0.6382;
    6, 8.3346, -1.8094, -0.6264, -1.4490, 0.6255;
    6, 9.7365, -3.3674, -0.3146, -1.4390, 0.6006
];

intcon=1;

%run the genetic algorithm
options = optimoptions('ga','MaxGenerations',5,'PopulationSize',10,'FunctionTolerance',1e-6);
[x,fval,exitflag,output,population,scores] = ga(fun,nvars,A,b,Aeq,beq,lb,ub,nonlcon,intcon,options);

% print optimal values of the variables in command window
disp('Optimal values of the variables are:')
disp(x)

databaseConnect(db_path,projectFilePath,'Disconnect')

function F = objFunc(X,Params)
        
    numBlades=3; %number of blades
    lambda=X(1); %tip speed ratio

    % Get the twist distribution coefficients
    a = X(2); % coefficient a
    b = X(3); % coefficient b
    c = X(4); % coefficient c
    d = X(5); % coefficient d
    e = X(6); % coefficient e

    % there are 25 stations, going from root to tip
    r = linspace(0,1,25); % radial position of blade in 25 steps
    lambda_r = lambda*r; % local tip speed ratio

    % Rational Fit (2/2) for newTwist
    newTwist = (a * r.^2 + b * r + c) ./ (d * r + e ); % rational fit equation

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
    [F,I] = max(rotor.CP); %I is load case index that produced max power
    F = -F; %to convert to minimisation 

    %create a subplot for the rotor CP and the angle of attack across the
    %blade
    
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
    plot(linspace(0,1,25), newChord)
    ylabel('Chord length, m')
    xlabel('r/R')
    hold on
     
    subplot(2,2,4)
    plot(linspace(0,1,25), newTwist)
    ylabel('Local twist, deg')
    xlabel('r/R')
    hold on
    drawnow
   
end

