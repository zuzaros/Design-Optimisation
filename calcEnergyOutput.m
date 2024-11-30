function [AEP] = calcEnergyOutput(Cp)
   
    % Parameters
    air_density = 1.225; % Air density (kg/m^3)
    A = 3.6; % Swept area (m^2)
    v_cut_in = 2.9; % Cut-in speed (m/s)
    v_cut_out = 13; % Cut-out speed (m/s)
    
    % Wind speed range
    v = linspace(0, 16, 1000); % Discretize wind speeds (m/s)
    
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
    
    % Implement cut-in and cut-out speeds
    P_turbine(v < v_cut_in | v > v_cut_out) = 0;
    
    % Calculate the Annual Energy Production (AEP)
    AEP = trapz(v, P_turbine .* WBD_values) * 8760; % Integrate and scale for hours in a year
    
    % Display the AEP
    fprintf('The Annual Energy Production (AEP) is %.2f kWh\n', AEP);
    

    %% Visualization for debugging purposes

    %{
    figure;
    
    % Plot the Weibull distribution
    subplot(3, 1, 1);
    plot(v, WBD_values, 'LineWidth', 2);
    xlabel('Wind Speed (m/s)');
    ylabel('Probability Density');
    title('Weibull Distribution');
    
    % Plot the turbine power output
    subplot(3, 1, 2);
    plot(v, P_turbine, 'LineWidth', 2);
    xlabel('Wind Speed (m/s)');
    ylabel('Power Output (W)');
    title('Turbine Power Output');
    
    % Plot the product of turbine power output and Weibull distribution
    subplot(3, 1, 3);
    plot(v, P_turbine .* WBD_values, 'LineWidth', 2);
    xlabel('Wind Speed (m/s)');
    ylabel('Contribution to AEP');
    title('Power Output * Weibull Distribution');
    
    % Hatch the area under the curve
    hold on;
    x_fill = [v, fliplr(v)];
    y_fill = [zeros(size(v)), fliplr(P_turbine .* WBD_values)];
    fill(x_fill, y_fill, 'b', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    
    hold off;
    %}

end





