function dbids = databaseConnect(db_path,projectFilePath,connect)
%creates data base connections needed to change simulation parameters

    if strcmp(connect,'Connect')
        % Create a connection to the blade database
        dbid = mksqlite(0, 'open', db_path);
        
        % Create a connection to the ash file
        dbid2 = mksqlite(0,'open', projectFilePath);

        dbids = [dbid, dbid2];
    elseif strcmp(connect,'Disconnect')
        mksqlite(1,'close');
        mksqlite(2,'close');
    end
    
end