function skills1()
    % Define initial guess for the design variables (xC, rAB, rAC, rBC)
    initial_guess = [1, 0.5, 0.5, 0.5]; % Example starting values
    
    % Define lower bounds to ensure all variables are non-negative
    lb = [0, 0, 0, 0]; % Lower bounds (>= 0)
    
    % Set options for fmincon (optional)
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
    
    % Create a figure for the animation
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

    function cost = objective_function(X)
        % Calculate cost from the objective_and_constraints function
        [cost, ~, ~] = objective_and_constraints(X);
    end

    function [c, ceq] = nonlinear_constraints(X)
        % Calculate constraints from the objective_and_constraints function
        [~, c, ceq] = objective_and_constraints(X);
    end

    function [cost, c, ceq] = objective_and_constraints(X)
        % --- original parameter definitions ---
        % nested functions
        % calculate the second moment of area for the truss members
        function I = secondMomentOfArea(radius, thickness)
            I = pi/4*(radius^2 - (radius-thickness)^2);
        end

        % calculate the cross-sectional area of the truss members
        function A = area(radius, thickness)
            A = pi*(radius^2 - (radius-thickness)^2);
        end  

        % --- design variables ---
        % xC: location of node C
        % rAB, rAC, rBC: Radii of the truss members
        xC = X(1);
        rAB = X(2);
        rAC = X(3);
        rBC = X(4);

        % --- parameters ---
        RD = 5; % rotor diameter (m)
        yA = 1.3 * RD; % rotor hub height (m)
        Rm = 300; % rotor mass (kg)
        F_y = 9.81 * Rm; % rotor weight (N)

        CT = 0.9; % thrust coefficient
        V_rotor = 25; % rotor speed (m/s)
        A_rotor = pi * (RD^2); % rotor area (m^2)
        rho_air = 1.225; % air density (kg/m^3)

        F_x = 0.5 * rho_air * A_rotor * (V_rotor^2) * CT; % rotor thrust (N)

        t = 6 * 10^(-3); % wall thickness of the truss members (m)
        rho_al = 2700; % density of aluminium (kg/m^3)
        E_al = 70 * 10^9; % Young's modulus of aluminium (Pa)
        sigma_al = 276 * 10^6; % yield strength of aluminium (Pa)

        cost_per_kg = 500; % cost per unit mass (£/kg)

        % coordinates
        x_A = 0; 
        y_A = yA; % known variable
        x_B = 0;
        y_B = 0;
        x_C = xC; % design variable
        y_C = 0;

        % calculate the length of the truss members
        L_AB = sqrt((x_B - x_A)^2 + (y_B - y_A)^2); % Length between A and B
        L_AC = sqrt((x_C - x_A)^2 + (y_C - y_A)^2); % Length between A and C
        L_BC = sqrt((x_C - x_B)^2 + (y_C - y_B)^2); % Length between B and C
    
        % calculate each area of the truss members
        A_AB = area(rAB, t);
        A_AC = area(rAC, t);
        A_BC = area(rBC, t);

        % calculate the total volume of the truss members
        V_AB = L_AB * A_AB;
        V_AC = L_AC * A_AC;
        V_BC = L_BC * A_BC;
        total_volume = V_AB + V_AC + V_BC;

        % define the objective function (total cost)
        cost = cost_per_kg * rho_al * total_volume;
        
        %--- calculate the constraints ---
        % define formulas for the forces in the truss members
        F_AB = F_y + F_x * (yA / xC); 
        F_AC = -F_x * (sqrt((xC^2) + (yA^2)) / xC);
        F_BC = F_x;

        % yield stress cannot be exceeded for all truss members
        % calculate the yield load for the truss members
        yield_AB = sigma_al * A_AB;
        yield_AC = sigma_al * A_AC;
        yield_BC = sigma_al * A_BC;
        
        % buckling stress cannot be exceeded for the truss members in compression
        % calculate the second moment of area for the truss members
        I_AB = secondMomentOfArea(rAB, t);
        I_AC = secondMomentOfArea(rAC, t);
        I_BC = secondMomentOfArea(rBC, t);

        % calculate the critical buckling load for the truss members
        buckling_AB = (pi^2) * E_al * I_AB / (L_AB^2);
        buckling_AC = (pi^2) * E_al * I_AC / (L_AC^2);
        buckling_BC = (pi^2) * E_al * I_BC / (L_BC^2);

        % define the inequality constraints for yield and buckling stress (c<=0)
        c = [
            yield_AB - F_AB;          % Yield constraint for member AB
            yield_AC - F_AC;          % Yield constraint for member AC
            yield_BC - F_BC;          % Yield constraint for member BC
            F_AC - buckling_AC;       % Buckling constraint for member AC
            F_BC - buckling_BC;       % Buckling constraint for member BC
            F_AB - buckling_AB        % Buckling constraint for member AB
        ];
        ceq = []; % no equality constraints
    end
    % Output function to store optimization history
    function stop = outfun(x, optimValues, state)
        stop = false;
        switch state
            case 'init'
                hold on
            case 'iter'
                % Store the current point and objective function value
                history.x = [history.x, x];
                history.fval = [history.fval, optimValues.fval];
            case 'done'
                hold off
            otherwise
        end
    end
end
