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
options = optimoptions('gamultiobj','PlotFcn',@gaplotpareto,'ParetoFraction',0.8);

nvar = 17; %declare number of variables

% run the optimisation
[X,fval] = gamultiobj(@(X) objFunc(X),nvar,A,b,Aeq,beq,lb,ub,nonlcon,options);

% plot the pareto front
figure(2)
hold on;
plot(abs(fval(:,1)).*10^-6, abs(fval(:,2)).*10^-6, 'ko', 'MarkerFaceColor','k')
xlabel('Energy (GWh)')
ylabel('Cost (millions of GBP)')
ylim([0.2,0.65])
xlim([2.5,3.25])

%% take a sample of final generation and plot them
% take 5 samples across fval

ix = round(linspace(1,length(fval),6));

R = X(:,1:8);
h = X(:,9:16);
C = X(:,17); % coordinate scaling

% need to convert C values into an array for x
x_pos = linspace(0,2000,8);
x = 0.0005*(1-C).*x_pos.^2 + C.*x_pos;


% Create a tiled layout with 3 rows and 6 columns
figure(4);
t = tiledlayout(3, 6);
i=1;

% Loop through rows
for row = 1:3
    % Subplot 1: turbine array
    idx = ix(i);
    nexttile((row-1)*6 + 1, [1 2]); % Start at tile 1 of the row, span 2 columns
    plotTurbineArray(x(idx,:),R(idx,:),h(idx,:))

    % Subplot 2: bar graph of costs
    nexttile((row-1)*6 + 3); % Tile 3 of the row
    yyaxis left; % Left y-axis
    bar([1,2],[abs(fval(idx, 1))*10^-6,0],'FaceColor', 'b')
    ylabel('Energy (GWh)')
    ylim([0,3.5])
    yyaxis right; % Right y-axis
    bar([1,2],[0, fval(idx,2)*10^-6],'FaceColor', 'r')
    ylabel('Cost (millions of GBP)')
    ylim([0,0.5])
    i=i+1;

    % Subplot 3: turbine array
    idx = ix(i);
    nexttile((row-1)*6 + 4, [1 2]); % Tile 4 of the row, span 2 columns
    plotTurbineArray(x(idx,:),R(idx,:),h(idx,:))

    % Subplot 4: bar graph of costs
    nexttile((row-1)*6 + 6); % Tile 3 of the row
    yyaxis left; % Left y-axis
    bar([1,2],[abs(fval(idx, 1))*10^-6,0],'FaceColor', 'b')
    ylabel('Energy (GWh)')
    ylim([0,3.5])
    yyaxis right; % Right y-axis
    bar([1,2],[0, fval(idx,2)*10^-6],'FaceColor', 'r')
    ylabel('Cost (millions of GBP)')
    ylim([0,0.5])
    i=i+1;
end


%% find each end of pareto curve and give variables that gets these

[max_cost, max_cost_idx] = max(fval(:,2));
[max_energy, max_energy_idx] = max(abs(fval(:,1)));

[min_cost, min_cost_idx] = min(fval(:,2));
[min_energy, min_energy_idx] = min(abs(fval(:,1)));

if max_cost_idx == max_energy_idx && min_cost_idx == min_energy_idx
    sprintf('Maximum values:\nC: %.2f\nh: %s\nR: %s',C(max_cost_idx), sprintf('%.2f ', h(max_cost_idx,:)), sprintf('%.2f ', R(max_cost_idx,:)))
    sprintf('Minimum values:\nC: %.2f\nh: %s\nR: %s',C(min_cost_idx), sprintf('%.2f ', h(max_cost_idx,:)), sprintf('%.2f ', R(max_cost_idx,:)))
else
    disp('Indexes not the same')
end

figure(2)
hold on;
plot(abs(fval(min_energy_idx,1)).*10^-6, abs(fval(min_energy_idx,2)).*10^-6, 'ro', 'MarkerFaceColor','r')
plot(abs(fval(max_cost_idx,1)).*10^-6, abs(fval(max_cost_idx,2)).*10^-6, 'ro', 'MarkerFaceColor','r')

%% FUNCTIONS

function F = objFunc(X)
    
    % get array of turbine radii out from x
    R = X(1:8);
    h = X(9:16);
    C = X(17);

    x_pos = linspace(0,2000,8);
    x = 0.0005*(1-C).*x_pos.^2 + C.*x_pos;


    [m,N,N_Vals] = calcNoRadiiGroups(R);
    cost = calcCost(R,m,N,N_Vals);

    energy = calcEnergyOutput(x,h,R);

    F = [-energy, cost]; % energy is negative as want to maximise, not minimise

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