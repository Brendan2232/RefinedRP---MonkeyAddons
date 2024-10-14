MonkeyLib.OnlinePlayers = MonkeyLib.OnlinePlayers or {}

local addOnlinePlayer = function( ply )

    if ( not IsValid( ply ) ) then return end 

    local steamID64 = ply:SteamID64()

    MonkeyLib.OnlinePlayers[steamID64] = ply 

end

local removeOnlinePlayer = function( ply )

    if ( not IsValid( ply ) ) then return end 

    local steamID64 = ply:SteamID64()

    MonkeyLib.OnlinePlayers[steamID64] = nil 

end

MonkeyLib.GetPlayerBySteamID64 = function( steamID64 )

    if ( not MonkeyLib.isSteamID64( steamID64 ) ) then 

        return nil 
    end

    return MonkeyLib.OnlinePlayers[steamID64]
end

MonkeyLib.GetPlayerBySteamID = function( steamID )

    if ( not MonkeyLib.isSteamID( steamID ) ) then 

        return nil 
    end 

    local steamID64 = util.SteamIDTo64( steamID ) 

    return MonkeyLib.GetPlayerBySteamID64( steamID64 )
end

do // Over-write our old player functions!  

    player.GetBySteamID = MonkeyLib.GetPlayerBySteamID
    player.GetBySteamID64 = MonkeyLib.GetPlayerBySteamID64

end

do 

    local queue = {}

    hook.Protect( "PlayerInitialSpawn", "MonkeyLib:Player:StartPlayer", function( ply )

        if not IsValid( ply ) then return end 
    
        local steamID64 = ply:SteamID64()
    
        queue[ ply ] = true 

        addOnlinePlayer( ply )
   
    end )
    
    hook.Protect( "PlayerDisconnected", "MonkeyLib:Player:RemovePlayer", function( ply )

        if not IsValid( ply ) then return end 

        removeOnlinePlayer( ply )
   
    end )    

    hook.Protect( "SetupMove", "MonkeyLib:RemoveStackedPlayers", function( ply, _, cmd )
    
        if ( not IsValid( ply ) or not cmd or not queue[ ply ] ) then return end 
    
        if cmd:IsForced() then return end 
    
        queue[ ply ] = nil 

        hook.Run( "MonkeyLib:PlayerNetReady", ply )
  
    end )

end


