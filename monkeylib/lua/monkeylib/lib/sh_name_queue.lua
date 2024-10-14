// Typically, there can be multiple requests on the same person. So we store the callback from the requested trace, once the name is recieved we return all information fetched. 

require( "mqueue" )

MonkeyLib.NameCache = MonkeyLib.NameCache or {}

local nameQueue = MQueue.CreateQueue()

local serverQueue, getName

if ( SERVER ) then

    util.AddNetworkString( "MonkeyLib:NameQueue:Get" )

    getName = function( steamID64 )

        if ( not MonkeyLib.isSteamID64( steamID64 ) ) then 

            return "NULL"
        end

        local isOnline = player.GetBySteamID64( steamID64 )

        if ( IsValid( isOnline ) ) then

            return isOnline:Name()
        end

        if ( MonkeyLib.NameCache[steamID64] ) then 

            return MonkeyLib.NameCache[steamID64]
        end

        local query = MonkeyLib.SQL:QueryValue( "SELECT rpname from darkrp_player WHERE uid = %s", { steamID64 } ) or "NULL"
        
        return query 
    end

    serverQueue = function( steamID64 )
        
        local foundName = getName( steamID64 ) or "NULL" 

        nameQueue:ResolveQueue( steamID64, foundName )
        
        MonkeyLib.NameCache[steamID64] = foundName 

    end
end 

net.Receive( "MonkeyLib:NameQueue:Get", function( l, ply )
     
    local steamID64 = MonkeyLib.ReadSteamID64()

    if ( CLIENT ) then 

        local name = net.ReadString() or "NULL"

        nameQueue:ResolveQueue( steamID64, name )

        MonkeyLib.NameCache[steamID64] = name  

        return 
    end

    local foundName = getName( steamID64 )
    
    net.Start( "MonkeyLib:NameQueue:Get" )

        MonkeyLib.WriteSteamID64( steamID64 )

        net.WriteString( foundName )

    net.Send( ply )

end )

MonkeyLib.GetName = function( steamID64, callback )
    
    if ( not MonkeyLib.isSteamID64( steamID64 ) ) then return end 
    
    nameQueue:Insert( steamID64, callback )

    local cachedName = MonkeyLib.NameCache[steamID64]

    if ( cachedName ) then 

        nameQueue:ResolveQueue( steamID64, cachedName )

        return 
    end

    if ( SERVER ) then 
        
        serverQueue( steamID64 ) 
        
        return 
    end 

    net.Start( "MonkeyLib:NameQueue:Get" )

        MonkeyLib.WriteSteamID64( steamID64 )

    net.SendToServer()
end

