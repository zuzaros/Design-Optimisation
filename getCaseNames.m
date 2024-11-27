function caseNames = getCaseNames(BatchFileName)
    
    %get load case names from bath file
    %needed for reading the correct results later

    txt = readtable(strcat(BatchFileName,'.csv')); %read in RunStatic.csv batch file - we will get the Load case names from here
    
    LoadCase = txt.LoadCase;
    count = 1;
    for i = 1:size(LoadCase,1)
        if ~isempty(LoadCase{i})
            caseNames{count} = LoadCase{i};
            count = count + 1;
            %specify case names (defined in column B of the RunStatic.csv batch file)
            %this will point the data reader script to the right folder names to
             %read and return the simulation data
        else
        end
    end

end