clc
clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%THE FOLLOWING CODE IS FOR YOU TO CHANGE%

%%% Open InitialiseScript and change the filepaths to match your system
InitialiseScript %runs initialistion script for file paths and names


%define number of blades, twist, chord, and aerofoil at each aerodynamical station
%there are 25 stations, going from root to tip
numBlades = 3; %define number of blades on rotor (must be an integer!!)

newTwist = ones(1,25)*5; %creates a constant twist distribution of 5 degrees
newChord = ones(1,25)*0.2; %creates a constant chord distribution of 0.2 meters

Foils = {'S826'}; %specifies aerofoils to be used (must match name in Ashes aerofoil database)
foilsDist = [ones(1,25)]; %specifies aerofoil distribution based on Foils index
%^^ in the above foils distribution, foilDist is set to a vector of ones,
%as there is only 1 aerofoil in the Fois variable

%See below for an example where two aerofoils are used (you can then
%generalise to more aerofoils if desired)

% Foils = {'NACA0012','S826'}; %specifies aerofoils to be used (must match name in Ashes aerofoil database)
% foilsDist = [1 1 1 1 1 1 1 1 1 1 1 1 1 ...
%                2 2 2 2 2 2 2 2 2 2 2 2]; %specifies aerofoil distribution based on Foils index
%^^ in the above foils distribution, the first 13 aerodynamical stations
%(from blade root) will be assigned the NACA0012 (the first element in foilsDist), and the remaining 12 will
%be assigned the S826 (the second element in foilsDist)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%submit the simulation and read the results - do not change
[rotor,blade] = runSIM(Params,newTwist,newChord,Foils,foilsDist,numBlades);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%THE FOLLOWING CODE IS FOR YOU TO CHANGE%

%rotor and blade are structures, and can be explored. 
%For example - double clicking "rotor" in the workspace, there are 5 fields
%within the structure. 
%You can access each of these variables by typing rotor.variablename
%e.g. here's the rotor CP plotted for each load case in the batch file
%looking at the batch file, you can see it runs different tip speed ratios
%(TSRs), and each element in rotor.CP is the CP for each TSR. 
%it is up to you to interprety the data coming back depending on your batch
%file.

plot([2, 4, 6, 8, 10],rotor.CP)    
xlabel('TSR')
ylabel('C_P')
hold on


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%close the connection to the databases
databaseConnect(db_path,projectFilePath,'Disconnect')


