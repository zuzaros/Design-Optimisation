function skills1()
    % Define initial guess for the design variables (xC, rAB, rAC, rBC)
    initial_guess = [5, 0.1, 0.1, 0.1]; % Adjust initial guess as needed
    
    % Define lower bounds to ensure all variables are positive
    lb = [0, 0.001, 0.001, 0.001]; % Small positive lower bounds for radii
    
    % Set options for fmincon
    options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp', ...
                           'OutputFcn', @outfun);
    
    % Initialize arrays to store optimization history
    history.x = [];
    history.fval = [];
    
    % Run the optimization using fmincon with bounds
    [optimized_X, fval] = fmincon(@objective_function, initial_guess, [], [], [], [], lb, [], @nonlinear_constraints, options);
    
    % Display the optimized results
    disp('Optimized Design Variables (xC, rAB, rAC, rBC):');
    disp(optimized_X);
    disp('Minimum Cost:');
    disp(fval);
    
    % Plot the optimization process
    figure;
    subplot(2, 1, 1);
    h1 = plot(history.fval, 'o-');
    xlabel('Iteration');
    ylabel('Objective Function Value');
    title('Convergence of Objective Function');
    
    subplot(2, 1, 2);
    h2 = plot(history.x');
    xlabel('Iteration');
    ylabel('Design Variables');
    legend('xC', 'rAB', 'rAC', 'rBC');
    title('Convergence of Design Variables');

    % Animate the optimization process
    for k = 1:length(history.fval)
        set(h1, 'YData', history.fval(1:k));
        set(h2, 'YData', history.x(:, 1:k)');
        drawnow;
        pause(0.5); % Adjust the pause duration as needed
    end

    % Objective function
    function cost = objective_function(X)
        [cost, ~, ~] = objective_and_constraints(X);
    end

    % Nonlinear constraint function
    function [c, ceq] = nonlinear_constraints(X)
        [~, c, ceq] = objective_and_constraints(X);
    end

    % Combined objective and constraint function
    function [cost, c, ceq] = objective_and_constraints(X)
        % Parameters
        RD = 5; 
        yA = 1.3 * RD;
        Rm = 300;
        F_y = 9.81 * Rm;
        CT = 0.9;
        V_rotor = 25;
        A_rotor = pi * RD^2;
        rho_air = 1.225;
        F_x = 0.5 * rho_air * A_rotor * V_rotor^2 * CT;
        t = 6e-3;
        rho_al = 2700;
        E_al = 70e9;
        sigma_al = 276e6;
        cost_per_kg = 500;

        % Design variables
        xC = X(1);
        rAB = X(2);
        rAC = X(3);
        rBC = X(4);

        % Coordinates
        x_A = 0; 
        y_A = yA; 
        x_B = 0;
        y_B = 0;
        x_C = xC; 
        y_C = 0;

        % Second moments of area
        I_AB = pi/4 * (rAB^2 - (rAB - t)^2);
        I_AC = pi/4 * (rAC^2 - (rAC - t)^2);
        I_BC = pi/4 * (rBC^2 - (rBC - t)^2);

        
        % Lengths of truss members
        L_AB = sqrt((pi^2 * E_al * I_AB) / abs(F_y + F_x * (yA / xC)));
        L_AC = sqrt((pi^2 * E_al * I_AC) / abs(F_x * (sqrt((xC^2) + (yA^2)) / xC)));
        L_BC = sqrt((pi^2 * E_al * I_BC) / abs(F_x));
    
        % Buckling constraints
        buckling_AB = (pi^2) * E_al * I_AB / L_AB^2;
        buckling_AC = (pi^2) * E_al * I_AC / L_AC^2;
        buckling_BC = (pi^2) * E_al * I_BC / L_BC^2;
    
        % Cross-sectional areas
        A_AB = pi * (rAB^2 - (rAB - t)^2);
        A_AC = pi * (rAC^2 - (rAC - t)^2);
        A_BC = pi * (rBC^2 - (rBC - t)^2);

        % Volume calculation
        V_AB = L_AB * A_AB;
        V_AC = L_AC * A_AC;
        V_BC = L_BC * A_BC;
        total_volume = V_AB + V_AC + V_BC;

        % Objective function (total cost)
        cost = cost_per_kg * rho_al * total_volume;
        
        % Truss member forces
        F_AB = F_y + F_x * (yA / xC); 
        F_AC = -F_x * (sqrt((xC^2) + (yA^2)) / xC);
        F_BC = F_x;

        % Yield constraints
        yield_AB = sigma_al * A_AB;
        yield_AC = sigma_al * A_AC;
        yield_BC = sigma_al * A_BC;



        % Inequality constraints
        c = [
            yield_AB - abs(F_AB);    % Yield constraint for AB
            yield_AC - abs(F_AC);    % Yield constraint for AC
            yield_BC - abs(F_BC);    % Yield constraint for BC
            abs(F_AC) - buckling_AC; % Buckling constraint for AC
            abs(F_BC) - buckling_BC; % Buckling constraint for BC
            abs(F_AB) - buckling_AB  % Buckling constraint for AB
        ];
        
        ceq = []; % No equality constraints
    end

    % Output function to store optimization history
    function stop = outfun(x, optimValues, state)
        stop = false;
        switch state
            case 'iter'
                history.x = [history.x, x];
                history.fval = [history.fval, optimValues.fval];
        end
    end
end
