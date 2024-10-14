require( "memoize" )

MDetection.SamDateToSeconds = function( time )      

    assert( isnumber( time ), "Time isn't a number!" ) 

    if ( time <= 0 ) then 

        return 0 
    end

    do 
    
        time = ( time - os.time() ) / 60 

        time = math.max( time, 1 )

    end 

    return time 
end

MDetection.PlayerAwaitingBan = function( ply )

    if ( not IsValid( ply ) ) then
        
        return false 
    end

    return ( ply.sam_is_banned or false )
end

MDetection.SamDateIsExpired = function( time )

    assert( isnumber( time ), "Time isn't a number!" )

    if ( time <= 0 ) then   

        return false 
    end

    return ( os.time() >= time )
end

MDetection.isUsingFamilyAccount = function( ply )

    if ( not IsValid( ply ) ) then 

        return 
    end

    local accountOwnerSteamID64, steamID64 = ply:OwnerSteamID64(), ply:SteamID64()

    return ( accountOwnerSteamID64 ~= steamID64 ), accountOwnerSteamID64
end

MDetection.GetOnlineFamilySharedAccounts = memoize( function( )

    local onlinePlayers = player.GetAll() 

    local onlinePlayerLen = #onlinePlayers 

    if ( onlinePlayerLen <= 0 ) then 

        return {}
    end

    local familySharedAccounts = {}

    for k = 1, onlinePlayerLen do 

        local ply = onlinePlayers[k]

        if ( not IsValid( ply ) ) then 

            continue 
        end

        local isAuthed = ply:IsFullyAuthenticated()

        if ( not isAuthed ) then 

            continue 
        end

        local awaitingBan = MDetection.PlayerAwaitingBan( ply )
        
        if ( awaitingBan ) then 

            continue 
        end
        
        local isUsingFamilyAccount, familySteamID64 = MDetection.isUsingFamilyAccount( ply )

        if ( not isUsingFamilyAccount ) then 

            continue 
        end

        local familyStructure = {

            ply,

            familySteamID64,

        }

        table.insert( familySharedAccounts, familyStructure )

    end 

    return familySharedAccounts
    
end, {}, 5 )