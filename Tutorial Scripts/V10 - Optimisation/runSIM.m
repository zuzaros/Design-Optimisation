function [rotor,blade] = runSIM(Params,newTwist,newChord,Foils,foilsDist,numBlades)
    %Params = {ashesExePath,BatchPath,BatchFileName,projectFilePath,caseNames,dbids};
    ashesExePath = Params{1};
    BatchPath = Params{2};
    BatchFileName = Params{3};
    projectFilePath = Params{4};
    caseNames = Params{5};
    dbids = Params{6};

    
    %update the blade parameters with new twist, chord and aerofoil
    %distributions
    changeBladeParams(dbids,newTwist,newChord,Foils,foilsDist,numBlades)
    
    if nargout == 1
        %run simulation and extract results
        [rotor] = runAshes(ashesExePath, projectFilePath, BatchPath, BatchFileName, caseNames);
    elseif nargout == 2
        [rotor,blade] = runAshes(ashesExePath, projectFilePath, BatchPath, BatchFileName, caseNames);
    else
    end
    


end