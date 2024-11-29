clc
clear
close all




%%% Open InitialiseScript and change the filepaths to match your system
InitialiseScript %runs initialistion script for file paths and names

f = @(X) objFunc(X,Params);

X = fminbnd(f,-10,10); %efficient one-parameter, gradient-free optimiser

databaseConnect(db_path,projectFilePath,'Disconnect')

function F = objFunc(X,Params)
    
    %define number of blades, twist, chord, and aerofoil at each aerodynamical station
    
    numBlades = 3; %define number of blades on rotor (must be an integer!!)
    lambda = 7; %define the tip speed ratio (TSR) for the rotor

    % there are 25 stations, going from root to tip
    r = linspace(0,1,25); % radial position of blade in 25 steps
    lambda_r = lambda*r; % local tip speed ratio

    newTwist = ones(25,1)*X(1); %creates a constant twist distribution of X(1) degrees
    newChord = optimalChord(numBlades,lambda_r);

    
    disp(strcat('twist = ',num2str(X(1)),' degrees'))

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
    subplot(1,2,1)
    plot([2,4,6,8,10],rotor.CP)
    xlabel('TSR')
    ylabel('C_P')
    hold on

    %create second subplot
    subplot(1,2,2)
    plot(linspace(0,1,25),blade.AngleOfAttack(I,:)) %plot the angle of attack distribution for the load case that produced the max CP
    xlabel('r/R') %normalised spanwise location across blade - where r/R  
    ylabel('Angle of attack')
    hold on
    drawnow


   
end

