require( "monkeyhooks" )

do // Cache API ( Memoize isn't exactly suitable here )

    local banCache = {}

    MDetection.InsertBanCache = function( steamID64, unbanDate )

        banCache[steamID64] = unbanDate
 
    end
    
    MDetection.DissolveBanCache = function( steamID64 )
    
        banCache[steamID64] = nil 
    
    end
    
    MDetection.GetBanCache = function( steamID64 )
    
        return banCache[ steamID64 ]
    end

end

MDetection.GetBan = function( steamID64 )

    if ( not MonkeyLib.isSteamID64( steamID64 ) ) then 
        
        return 
    end 

    local unbanTime = MDetection.GetBanCache( steamID64 )

    if ( isnumber( unbanTime ) ) then 

        local isExpired = MDetection.SamDateIsExpired( unbanTime )

        if ( isExpired ) then 

            MDetection.DissolveBanCache( steamID64 )

            return  
        end
    
        return unbanTime
    end

    local steamID = util.SteamIDFrom64( steamID64 )

    local unbanDate = MonkeyLib.SQL:QueryValue( "SELECT unban_date FROM sam_bans WHERE steamid = %s;", {

        steamID, 

    } )

    if ( not unbanDate ) then 

        return 
    end

    unbanDate = tonumber( unbanDate )

    local isExpired = MDetection.SamDateIsExpired( unbanDate )

    if ( isExpired ) then 

        return 
    end

    MDetection.InsertBanCache( steamID64, unbanDate ) // Insert our ban 

    return unbanDate 
end

local findFamilySharedAccount = function( mainSteamID64 )

    if ( not MonkeyLib.isSteamID64( mainSteamID64 ) ) then 

        return 
    end

    local players = player.GetAll()

    for k = 1, #players do 

        local ply = players[k]
    
        if ( not IsValid( ply ) ) then 

            continue  
        end

        local awaitingBan = MDetection.PlayerAwaitingBan( ply )

        if ( awaitingBan ) then 

            continue 
        end

        local ownerSteamID64 = ply:OwnerSteamID64()

        if ( mainSteamID64 == ownerSteamID64 ) then 
        
            return ply
        end 

    end

end 

do // Ban interface

    hook.Protect( "SAM.BannedPlayer", "MDetection:BanInteraction:BanPlayer", function( ply, unbanDate )
    
        if ( not IsValid( ply ) ) then 

            return 
        end

        local steamID64 = ply:SteamID64()

        MDetection.InsertBanCache( steamID64, unbanDate )
        
    end )

    hook.Protect( "SAM.BannedSteamID", "MDetection:BanInteraction:BanSteamID", function( steamID, unbanDate )
    
        local steamID64 = util.SteamIDTo64( steamID )

        if ( not MonkeyLib.isSteamID64( steamID64 ) ) then 

            return 
        end

        MDetection.InsertBanCache( steamID64, unbanDate ) // Insert into cache first > check for family shared accounts in a second. 
        
        do 

            local foundPlayer = findFamilySharedAccount( steamID64 ) 

            if ( not IsValid( foundPlayer ) ) then 

                return 
            end

            MDetection.BanFamilySharedAccount( foundPlayer )

        end

    end )

end

do 

    hook.Protect( "SAM.UnbannedSteamID", "MDetection:BanInteraction:UnbanSteamID", function( steamID )
    
        local steamID64 = util.SteamIDTo64( steamID )

        if ( not MonkeyLib.isSteamID64( steamID64 ) ) then 

            return 
        end

        MDetection.DissolveBanCache( steamID64 )
        
    end )

end