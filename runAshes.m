function [rotor, blade] = runAshes(ashesExePath, projectFilePath, BatchPath, BatchFileName, caseNames)

    %checks and deletes any previous runs - do not remove!
    if isfolder(strcat(BatchPath,'/',BatchFileName))
        disp('Batch Run folder already exists, deleting folder')
        rmdir(strcat(BatchPath,'/',BatchFileName),'s')
    end

    
    % run the batch defined by the csv file. This will run a linear static analysis
    cmd = sprintf('"%s" -runbatch -projectfile "%s" -batchcsvfile "%s"', ashesExePath, projectFilePath, strcat(BatchFileName,'.csv'));
    [status, cmdout] = system(cmd);
 
    
    % read results
    resultsPath = strcat(BatchPath,'\',BatchFileName,"\Load case set 1\");

    for i = 1:length(caseNames) %loop over number of cases in batch file, defined in caseNames
        %sometimes simulations fail (though that should be quite rate) -
        %which will cause errors when attempting to read the file
        %this will catch the error and assign a NaN to that value
        try
            casePath = strcat(resultsPath,caseNames{i}); %define file path for each case
            rotorData = table2array(readtable(strcat(casePath,"\Time simulation\Rotor.txt"),'Delimiter','\t','NumHeaderLines',18));
            Power(i) =  rotorData(2,2)*1000; %Power output, W
            Torque(i) = rotorData(2,3)*1000; %Torque output, Nm
            Thrust(i) = rotorData(2,4)*1000; %Thrust output, N        
            CP(i) = rotorData(2,8)./100; %output CP as decimal
            CT(i) = rotorData(2,9)./100; %output CT as decimal
        catch
            Power(i) =  NaN; %Power output, W
            Torque(i) = NaN; %Torque output, Nm
            Thrust(i) = NaN; %Thrust output, N        
            CP(i) = NaN; %output CP as decimal
            CT(i) = NaN; %output CT as decimal  
        end
    end
    
    rotor = struct('CP',CP,'CT',CT,'Power',Power,'Torque',Torque,'Thrust',Thrust);

    if nargout > 1 %if nuber of output arguments greater than 1 - i.e. you've requested the bldae span data as well, the following code will execute
        
            for i = 1:length(caseNames) %loop over number of cases in batch file, defined in caseNames

                nameList = {'Time','AngleOfAttack','Cd','Cl','Cm','ClCd','LocalWindSpeed','RelativeWindSpeed','Re','Ma',...
                            'Axial_IF','Tang_IF','AxialIndVel','TangIndVel','LiftDist',...
                            'DragDist','PitchMomDist','ThrustDist','TorqueDist'};
        
                %the following propeties are across the blade, from root to tip 
                %Time = Time [s] - ignore for a static simulation
                %AngleOfAttack = angle of attack of each blade station in degrees
                %Cd = Coefficient of drag at each blade station
                %Cl = Coefficient of lift at each blade station
                %Cm = Pitching moment coefficient at each blade station
                %ClCd = lift to drag ratio at each blade station
                %LocalWindSpeed = incoming freestream wind speed local to each blade station
                %RelativeWindSpeed = relative velocity experienced by each blade station
                %Re = Reynolds number at each blade station
                %Ma = Mach number at each blade station (negligible at these scales)
                %Axial_IF = Axial induction factor
                %Tang_IF = Tangential induction factor
                %LiftDist = Lift distribution across blade in N/m
                %DragDist = Drag distribution across blade in N/m
                %PitchMomDist = Pitching moment distribution across blade in Nm/m
                %ThrustDist = Thrust force distribution across blade in N/m
                %TorqueDist = Torque distribution across blade in Nm/m
            
                casePath = strcat(resultsPath,caseNames{i}); %define file path for each case

                try
                    bladeData = readtable(strcat(casePath,'\Time simulation\Blade [Span] [Blade 1].txt'),'Delimiter','\t','NumHeaderLines',18);
        
                    count = 0;
                    for j = 2:length(nameList)
                        data = table2array(bladeData(2,j+count));
                        if i == 1 %create variable name in blade 
                            blade.(nameList{j}) = str2num(data{1});
                        else %append rest of load cases
                            blade.(nameList{j}) = [blade.(nameList{j});
                                                   str2num(data{1})];
                        end
                        count = count + 1;
                    end

                catch

                    count = 0;
                    for j = 2:length(nameList)
                        if i == 1 %create variable name in blade 
                            blade.(nameList{j}) = NaN*ones(1,25);
                        else %append rest of load cases
                            blade.(nameList{j}) = [blade.(nameList{j});
                                                   NaN(ones(1,25))];
                        end
                        count = count + 1;
                    end
                end
    
        end

    end

    % remove the results that were generated when running the batch
    % Otherwise the results of the next run will be in a folder with a different name
    rmdir(strcat(BatchPath,'\',BatchFileName),'s');
    
end