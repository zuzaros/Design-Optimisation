clc, clear, close all

%% Set Up

% variables: want R for all turbines, h for all turbines, and then b for
% quadratic for positioning

%rng default % makes the randomness the same each time

% make a vector of lower bounds (lb) and upper bounds (ub) 
lb = [30 30 30 30 30 30 30 30 90 90 90 90 90 90 90 90 0];
ub = [50 50 50 50 50 50 50 50 110 110 110 110 110 110 110 110 2];

% constraints
A = []; b = []; Aeq = []; beq = [];
nonlcon = [];

% additional options
options = optimoptions('ga', 'Display','final');

nvar = 17; %declare number of variables
wList = linspace(0,1,500);

% cost_Opt = zeros(1,length(lb));
% energy_Opt = zeros(1,length(lb));
i=1;

figure(1)
hold on;
for w=wList

    %sprintf('Staring Iteration %d', i)

    % run the optimisation
    [X,fval] = ga(@(X) objFunc(X,w),nvar,A,b,Aeq,beq,lb,ub,nonlcon,options);
    
    R = X(1:8);
    h = X(9:16);
    C = X(17);
    x_pos = linspace(0,2000,8);
    x = 0.0005*(1-C).*x_pos.^2 + C.*x_pos;
    [m,N,N_Vals] = calcNoRadiiGroups(R);
    cost = calcCost(R,m,N,N_Vals);
    energy = calcEnergyOutput(x,h,R);

    cost_Opt(i) = cost;
    energy_Opt(i) = energy;
    x_Opt(i,:) = X(:);

    plot(energy,cost,'ko', 'MarkerFaceColor','k')
    xlabel('Energy (kWh)')
    ylabel('Cost (GBP)')

    %sprintf('Iteration %d complete',i)
    i=i+1;

end




%% FUNCTIONS

function F = objFunc(X,w)
    
    % get array of turbine radii out from x
    R = X(1:8);
    h = X(9:16);
    C = X(17);

    x_pos = linspace(0,2000,8);
    x = 0.0005*(1-C).*x_pos.^2 + C.*x_pos;


    [m,N,N_Vals] = calcNoRadiiGroups(R);
    cost = calcCost(R,m,N,N_Vals);

    energy = calcEnergyOutput(x,h,R);

    F = w*cost - (1-w)*energy; % energy is negative as want to maximise, not minimise

end


function plotTurbineArray(x,R,h)
    
    for i = 1:8
        hold on;
        % plot size of rotor
        plot([x(i),x(i)], [h(i)-R(i), h(i)+R(i)],'r-', 'LineWidth', 3 )
        %plot turbine height
        plot([x(i),x(i)], [0, h(i)], 'k-', 'LineWidth', 1);
        xlabel('Position (m)');
        ylabel('Height (m)');
        xlim([-100,2100])
        ylim([0,170])
    end
end