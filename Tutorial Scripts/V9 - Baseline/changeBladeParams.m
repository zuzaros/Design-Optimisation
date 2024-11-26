function changeBladeParams(dbids,newTwist,newChord,Foils,foilsDist,numBlades)
%script that changes the blade parameters in the Ashes database

    %define blade name (must be in Ashes blade database)
    blade_name = 'NewBlade';
    
    foilsID = cell(1,length(Foils));
    for j = 1:length(Foils)
        foilsID{j} = mksqlite(dbids(1),'SELECT id FROM foils WHERE name = ?', Foils{j});
    end

    %get blade_id
    blade_id = mksqlite(dbids(1),'SELECT id FROM blades WHERE name = ?', blade_name);

    %get blade length
    blade_length = mksqlite(dbids(1),'SELECT length FROM blades WHERE name = ?', blade_name);
    
    %convert to type char for use in query statement
    id = char(blade_id.id);
    
    
    % Update the values of twist for each station
    %relativeRootDistance is extracted as a unique identifier for each blade
    %station
    mksqlite(dbids(1),'BEGIN')
    
    rootDist = mksqlite(dbids(1),'SELECT relativeRootDistance FROM blades_stations WHERE blades_id = ?', id);
    
    for i = 1:length(newTwist)
        update_query = 'UPDATE blades_stations SET twist = ? WHERE blades_id = ? AND relativeRootDistance = ?';
        mksqlite(dbids(1), update_query, newTwist(i), id, rootDist(i).relativeRootDistance);

        update_query = 'UPDATE blades_stations SET relativeChordLength = ? WHERE blades_id = ? AND relativeRootDistance = ?';
        mksqlite(dbids(1), update_query, newChord(i)/blade_length.length, id, rootDist(i).relativeRootDistance);        

        update_query = 'UPDATE blades_stations SET foils_id = ? WHERE blades_id = ? AND relativeRootDistance = ?';
        mksqlite(dbids(1), update_query, foilsID{foilsDist(i)}.id, id, rootDist(i).relativeRootDistance);

    end

    %update number of rotor blades
    mksqlite(dbids(2),'UPDATE analysis_parameters_values SET value = ? WHERE key = ?',num2str(numBlades),'Rotor.NumBlades')

    % Save the changes into the database
    mksqlite(dbids(1), 'COMMIT' )

end

