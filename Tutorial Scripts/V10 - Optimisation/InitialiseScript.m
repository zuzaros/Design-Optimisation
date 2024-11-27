%%%%% For you to change to your specific file paths!!! %%%%%%

% path for the ashes-cli.exe file
ashesExePath = "C:\Program Files\Ashes 3.28\ashes-cli.exe";

%file path where the batch runs are saved to - can find this by opening Ashes -> tools -> preferences -> batch computing
BatchPath = "C:/Users/zuzar/OneDrive/Documents/Ashes 3.28/Batch runs";

%name of batch file (the .csv)
BatchFileName = "RunStatic";    

list=dir(BatchPath);
list=list(~ismember({list.name},{'.','..'}));
if ~size(list,1) > 0
    disp('deleting previous bath runs')
    for i = 1:size(list,1)
        rmdir(strcat(BatchPath,'\',list(i).name),'s')
    end
end

list=dir(BatchPath);
list=list(~ismember({list.name},{'.','..'}));

% Ashes model that will be used for the simulations
projectFilePath = 'BaseModel.ash';        

%define database path
db_path = 'C:\Users\zuzar\AppData\Roaming\Simis\Ashes 3.28\ashescl.db';
%closes in case a connection is left open
databaseConnect(db_path,projectFilePath,'Disconnect')

%get load case names from bath file, needed for reading the correct results later
caseNames = getCaseNames(BatchFileName); 

%connects to database (dbid is the database ID)
dbids = databaseConnect(db_path,projectFilePath,'Connect'); 

%check if NewBlade exists - if not, add it to the database
blade_id = mksqlite(dbids(1),'SELECT id FROM blades WHERE name = ?', 'NewBlade');
if isempty(blade_id)

  shapePath = "NewBlade blade shape.txt";               % file that will contain the shape information and be added to Ashes
  structurePath = "NewBlade blade structure.txt";          % file with the structure information
  bladeName = "NewBlade";                         % new blade name

  % add NewBlade blade to the Ashes database
  disp('NewBlade does not exist in blade database, adding to database')
  cmd = sprintf('"%s" -addblade -bladeshapefile "%s" -bladestructurefile "%s" -bladename "%s"', ashesExePath, shapePath, structurePath, bladeName);
  system(cmd);
end

Params = {ashesExePath,BatchPath,BatchFileName,projectFilePath,caseNames,dbids};

%%% *********************************************************** %%%



