require("monkeyhooks")

local deleteTime = 1 * 86400

local folderName = "brendan_advanced_dupe"

file.CreateDir( folderName )

local formatFileName

do 

    local fileFormat = "%s/%s-%s_dupe.txt"

    local dateFormat = "%H-%M-%S_%d-%m-%Y"

    formatFileName = function( steamID64 )

        if ( not MonkeyLib.isSteamID64( steamID64 ) ) then 

            return 
        end 

        local currentDate = os.date( dateFormat )

        return fileFormat:format( folderName, currentDate, steamID64 )
    end
    
end

local fail = function( success, str, ... )
    
    assert( success, str:format( ... ) )

end

local saveDupe = ProtectFunction( function( ply, dupe, info )

    fail( IsValid( ply ), "Failed to save dupe, invalid player!" )

    local name, steamID64 = ply:Name(), ply:SteamID64()

    fail( istable( dupe ) and istable( info ), "%s | %s | Failed to save dupe, dupe is malformed!.", name, steamID64 )

    local fileTitle = formatFileName( steamID64 )

    fail( isstring( fileTitle ), "%s | %s | Failed to save dupe, file name is malformed.", name, steamID64 )

    AdvDupe2.Encode( dupe, info, function( encodedDupe )
   
        file.Write( fileTitle, encodedDupe )

    end )
   
end )

local checkDupes = function()

    local folderFormat = "%s/"

    folderFormat = folderFormat:format( folderName )

    local foundDupes = file.Find( folderFormat .. "*", "DATA" )

    if ( not istable( foundDupes ) ) then 

        return 
    end

    if ( next( foundDupes ) == nil ) then 

        return 
    end 

    local maxStorageTime = os.time()

    for k = 1, #foundDupes do 

        local directoryName = foundDupes[k]

        if ( not isstring( directoryName ) ) then 

            continue 
        end

        local absoluteDirectory = ( folderFormat .. directoryName )

        local fileCreateTime = file.Time( absoluteDirectory, "DATA" )

        if ( fileCreateTime == 0 ) then 

            continue 
        end

        if ( ( maxStorageTime - fileCreateTime ) < deleteTime ) then 

            continue 
        end

        file.Delete( absoluteDirectory )
 
    end
end

do 

    local M_oldDupeFunc  

    local dupeLoadFunc = function( ply, success, dupe, info, moreinfo )

        fail( isfunction( M_oldDupeFunc ), "Failed to load dupe, dupe return function doesn't exist!?!?!?!" )

        if ( not success ) then 

            M_oldDupeFunc( ply, success, dupe, info, moreinfo )
            
            return 

        end

        saveDupe( ply, dupe, info )

        M_oldDupeFunc( ply, success, dupe, info, moreinfo )
    end
    
    hook.Protect( "Initialize", "MonkeyLib:Dupes:CheckDupes",function()
    
        M_oldDupeFunc = AdvDupe2.LoadDupe

        AdvDupe2.LoadDupe = dupeLoadFunc

        checkDupes()

    end )
end