% design optimisation skills 1 task
% main function to calculate the cost of the truss members

function skills1()
    % Setting up fmincon optimization
    initial_xC = 1; % Initial guess for xC
    initial_rAB = 0.1; % Initial guess for rAB
    initial_rAC = 0.1; % Initial guess for rAC
    initial_rBC = 0.1; % Initial guess for rBC

    X0 = [initial_xC, initial_rAB, initial_rAC, initial_rBC]; % Initial guess
    lb = [0, 0.01, 0.01, 0.01]; % Lower bounds
    ub = [10, 1, 1, 1]; % Upper bounds

    options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');
    [X_optimal, cost_min] = fmincon(@objective_and_constraints, X0, [], [], [], [], lb, ub, [], options);

    % Display the optimal solution
    disp('Optimal design variables:');
    disp(X_optimal);
    disp('Minimum cost:');
    disp(cost_min);

    function [cost, c, ceq] = objective_and_constraints(X)
        
        % --- original parameter definitions ---

        % neseted functions
        % calculate the second moment of area for the truss members
        function I= secondMomentOfArea(radius, thickness)
            I = pi/4*(radius^2 - (radius-thickness)^2);
        end

        % calculate the cross sectional area of the truss members
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
        yA = 1.3*RD; % rotot hub height (m)
        Rm = 300; % rotor mass (kg)
        F_y = 9.81*Rm; % rotor weight (N)

        CT = 0.9; % thrust coefficient
        V_rotor = 25; % rotor speed (m/s)
        A_rotor = pi*(RD^2); % rotor area (m^2)
        rho_air = 1.225; % air density (kg/m^3)

        F_x = 0.5*rho_air*A_rotor*(V_rotor^2)*CT; % rotor thrust (N)

        t = 6*10^(-3); % wall thickness of the truss members (m)
        rho_al = 2700; % density of aluminium (kg/m^3)
        E_al = 70*10^9; % Young's modulus of aluminium (Pa)
        sigma_al = 276*10^6; % yield strength of aluminium (Pa)

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
        A_AB = area(rAB,t);
        A_AC = area(rAC,t);
        A_BC = area(rBC,t);

        % calculate the total volume of the truss members
        V_AB = L_AB*A_AB;
        V_AC = L_AC*A_AC;
        V_BC = L_BC*A_BC;
        total_volume = V_AB + V_AC + V_BC;

        % define the objective function
        cost = cost_per_kg*rho_al*total_volume;
        
        %--- calculate the constraints ---
        % define formulas for the forces in the truss members
        F_AB = F_y + F_x*(yA/xC); 
        F_AC = -F_x*(sqrt((xC^2)+(yA^2))/xC);
        F_BC = F_x;

        % yield stress cannot be exceeded for all truss members
        % calculate the yield load for the truss members
        yield_AB = sigma_al*A_AB;
        yield_AC = sigma_al*A_AC;
        yield_BC = sigma_al*A_BC;
        
        % buckling stress cannot be exceeded for the truss members in compression
        % calculate the second moment of area for the truss members
        I_AB = secondMomentOfArea(rAB,t);
        I_AC = secondMomentOfArea(rAC,t);
        I_BC = secondMomentOfArea(rBC,t);

        % calculate the critical buckling load for the truss members
        buckling_AB = (pi^2)*E_al*I_AB/(L_AB^2);
        buckling_AC = (pi^2)*E_al*I_AC/(L_AC^2);
        buckling_BC = (pi^2)*E_al*I_BC/(L_BC^2);

        % define the inequality constraints for yield and buckling stress (c<=0)
        c = [yield_AB - F_AB; yield_AC - F_AC; yield_BC - F_BC; F_AC - buckling_AC; F_BC - buckling_BC; F_AB - buckling_AB];
        ceq = []; % no equality constraints
        
    end
end

