CpTry=0.5;

energyOutput(CpTry)

function [AEP] = energyOutput(Cp)
   
    % Parameters
    air_density = 1.225; % Air density (kg/m^3)
    A = 3.6; % Swept area (m^2)
    v_cut_in = 1.5; % Cut-in speed (m/s)
    v_cut_out = 15; % Cut-out speed (m/s)
    
    % Wind speed range
    v = linspace(0, 30, 1000); % Discretize wind speeds (m/s)
    
    % parameters from literature
    k = 2.0974232; % shape parameter
    c = 5.1039554; % scale parameter
    u = -1.2692170; % location parameter
    
    % 3-parameter formula for the Weibull distribution
    WBD = @(v) (k/c) * ((v-u)/c).^(k-1) .* exp(-((v-u)/c).^k);
    
    % Evaluate the Weibull distribution at the wind speed values
    WBD_values = WBD(v);
    
    % Turbine power output
    P_turbine = 0.5 * air_density * A * v.^3 * Cp;
    
    % Calculate the Annual Energy Production (AEP)
    AEP = trapz(v, P_turbine .* WBD_values) * 8760; % Integrate and scale for hours in a year
    
    % Display the AEP
    fprintf('The Annual Energy Production (AEP) is %.2f kWh\n', AEP);
end





