clc
clear
close all

%% SET UP
%%% Open InitialiseScript and change the filepaths to match your system
InitialiseScript %runs initialistion script for file paths and names

rng default %for reproducibility


%set a vector of lower and upper bounds for the optimisation
lb = [-10,-10, 2]; %lower bounds
ub = [ 10,10, 10]; %upper bounds

% constraints for GA
A = [];
b = [];
Aeq = [];
beq = [];
nonlcon = [];

%set the number of variables and the objective function
nvars = 3; %number of variables
fun = @(X)objFunc(X,Params); %objective function

intcon=[3];

%run the genetic algorithm
options = optimoptions('ga','PlotFcn',@gaplotbestf,'MaxGenerations',20,'PopulationSize',20,'FunctionTolerance',1e-6);
[x,fval,exitflag,output,population,scores] = ga(fun,nvars,A,b,Aeq,beq,lb,ub,nonlcon,intcon,options);

% Display the optimal results
disp('Optimal X values:');
disp(x);
disp('Maximum CP value:');
disp(-fval); % Since we minimized the negative CP, the actual CP is -fval


databaseConnect(db_path,projectFilePath,'Disconnect')

function F = objFunc(X,Params)
        
    numBlades=3; %number of blades
    lambda=X(3); %tip speed ratio

    % there are 25 stations, going from root to tip
    r = linspace(0,1,25); % radial position of blade in 25 steps
    lambda_r = lambda*r; % local tip speed ratio

    twist_root = X(1); % Twist at the root
    twist_tip = X(2); % Twist at the tip
    newTwist = linspace(twist_root, twist_tip, 25); % Linearly varying twist distribution

    newChord = optimalChord(numBlades,r,lambda_r);

       
    disp(strcat('twist = ',num2str(X(1)),' at root and  ',num2str(X(2)),' degrees at tip'))
    % display number of blades and tip speed ratio
    disp(strcat('numBlades = ',num2str(numBlades),' and lambda = ',num2str(lambda)))


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

