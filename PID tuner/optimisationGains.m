clc
clear all
close all

%MAKE SURE DCmotor.slx IS OPEN BEFORE RUNNING THIS SCRIPT!
%Be sure to press the "Fast Restart" option in the "Simulation" tab, for
%rapid iteration. Otherwise Simulink will compile the .slx file every time,
%which is really slow!

%set initial conditions, a first "guess" at what might be the optimal gains
X0 = [5 0 0]; %here X0 represents [Kp, Ki, Kd] - the different gains for the PID controller
options = optimset('MaxIter',35); %set optimiser options, here I limit to 35 iterations, just for speed during the demo
X = fminsearch(@runDCmotor,X0,options); %use Nelder-Mead algorithm (fminsearch) on the runDCmotor function, with initial conditions (X0)

%X is the "optimal" gains returned by the optimiser