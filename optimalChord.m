% this function calculates the optimal chord distribution for a rotor blade

function newChord = optimalChord(N,lambda_r)
           
    % chord distribution equations from literature
    Phi_T = deg2rad(90) - (2/3)*atan(1./lambda_r);
    
    newChord = (8*pi*r.*cos(Phi_T)) ./ (3*N*lambda_r);
    
end