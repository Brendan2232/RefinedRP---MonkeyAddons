AddCSLuaFile()

hook.Protect = function( eventName, identifier, func )

    if ( not isstring( eventName ) or not identifier or not isfunction( func ) ) then return end 

    local hookFunc = hook.Add 

    hookFunc( eventName, identifier, function( ... )

        local success, err = pcall( func, ... )

        if ( not success and err ) then 

            ErrorNoHaltWithStack( err )
            
        end

        return nil 
    end )
    
end

hook.SafeRun = function( ... )  

    local pData = { pcall( hook.Run, ... ) }

    local succ, err = pData[1], pData[2]

    if ( not succ and isstring( err ) ) then 
            
        ErrorNoHaltWithStack( err )

    end

    return unpack( 2, pData )
end 

ProtectFunction = function( fn )

    return function(...)

        local pData = { pcall( fn, ... ) } // Returns our data inside a table! 

        local succ, err = pData[1], pData[2]

        if ( not succ and err ) then 
            
            ErrorNoHaltWithStack( err )

            return false  
        end

        return true, unpack( pData, 2 )
    end 
end


AssertF = function( statement, err, ... )

    assert( isstring( err ), "AssertF format isn't a string!" )
    
    err = err:format( ... )

    return assert( statement, err )
end 
