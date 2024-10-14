// Very basic SQLite Library. 

local queryFunc = sql.Query 
local queryRowFunc = sql.QueryRow
local queryValueFunc = sql.QueryValue

MonkeyLib.SQL = MonkeyLib.SQL or {}

local sqlErr = function( statement, ... )

    if ( not isstring( statement ) ) then return end 

    statement = string.format( "%s " .. statement, "[SQLError]", ... )

    error( statement )
end

local sqlAssert = function( var, ... )

    if ( var ) then return end 

    sqlErr( ... )

end

// Just makes error handling better. 
local runQuery = function( queryFunc, sqlQuery, unformattedTable, ... )

    sqlAssert( isfunction( queryFunc ), "Failed to run SQL query, invalid query function." ) 

    sqlAssert( isstring( sqlQuery ), "Failed to parse SQL query, no query parsed." ) 

    sqlQuery = MonkeyLib.SQL:SQLFormat( sqlQuery, unformattedTable ) 

    sqlAssert( isstring( sqlQuery ), "Failed to run SQL query, malformed query." ) 

    local ranQuery = queryFunc( sqlQuery, ... )

    if ( ranQuery == false ) then 

        local sqlError = sql.LastError( ) 

        sqlErr( "Failed to run query, error: %s", sqlError )

    end

    return ranQuery 
end

// Simple SQL Formatter, makes sure strings are SQL formatted, bools are turned into 1 or 0. 
// MonkeyLib.SQL:SQLFormat( "SELECT * FROM %s", { "monkey_table" } ) 

function MonkeyLib.SQL:SQLFormat( sqlQuery, unformattedTable ) 
    
    sqlAssert( isstring( sqlQuery ), "Failed to parse SQL Query, no query parsed.")

    local formattedRow = {}

    if ( istable( unformattedTable ) and #unformattedTable >= 1 ) then 
        
        for k = 1, #unformattedTable do 

            local row = unformattedTable[k]

            if ( istable( row ) or isfunction( row ) ) then

                ErrorNoHaltWithStack( "What dumass tried to throw a function / table into the sql formatter!?!? NEXT ROW!!!" )

                continue 
            end 

            if ( isbool( row ) ) then

                row = ( row and 1 or 0 ) 
            
            end 

            if ( isnumber( row ) ) then 
                
                formattedRow[k] = row 

                continue 
            end 

            formattedRow[k] = sql.SQLStr( row )
        end
    end


    local formattedQuery = string.format( sqlQuery, unpack( formattedRow ) )

    return formattedQuery or false 
end

// Simple SQL Query system, uses the MonkeyLib.SQL:FormatQuery system. 

function MonkeyLib.SQL:Query( sqlQuery, queryTable )

    local query = runQuery( queryFunc, sqlQuery, queryTable )

    return query 
end

function MonkeyLib.SQL:QueryRow( sqlQuery, queryTable, queryIndex )

    local query = runQuery( queryRowFunc, sqlQuery, queryTable, queryIndex or 1 )

    return query 
end

function MonkeyLib.SQL:QueryValue( sqlQuery, queryTable )

    local query = runQuery( queryValueFunc, sqlQuery, queryTable )

    return query 
end

// Hopefully an easier method of creating SQL Tables

local asyncCreate = function( sqlTables )
    
    if ( not istable( sqlTables ) ) then

        ErrorNoHaltWithStack( "Failed to create SQL tables, no table parsed." ) 

        return 
    end 

    sql.Begin( )

        for k = 1, #sqlTables do 

            local tableQuery = sqlTables[k]
            if ( not isstring( tableQuery ) ) then continue end 

            MonkeyLib.SQL:Query( tableQuery )
        
        end

    sql.Commit( )
end

function MonkeyLib.SQL:CreateTables( sqlTables )

    if ( not istable( sqlTables ) ) then 
        
        ErrorNoHaltWithStack("Failed to create SQL tables, no table parsed.") 

        return 
    end 

    async( asyncCreate, sqlTables )
end

