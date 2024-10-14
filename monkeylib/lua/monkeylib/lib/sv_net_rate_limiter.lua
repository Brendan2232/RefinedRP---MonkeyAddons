require( "monkeyhooks" )
require( "mlogs" )

local resetTime = .65
local overflowMessages = 30

local netMessageBypass = { 

    ["sP:Networking"] = true,

    ["WinemakingSystemNW"] = true, 

    ["MonkeyLib:NameQueue:Get"] = true,

    ["gmodadminsuite:offline_player_data"] = true,   
    
    ["SH_ACC_REQUEST"] = true,
     
}

local trafficLogCooldown = {}

local composeTraffic, trafficCommitTimer 

do 

    local cooldown = .7

    local logs = {
        ["net_sent"] = "%s | %s - Sent Net Message %s, overall count %d.",
        ["net_rated"] = "%s | %s - Sent too many %s messages, amount %d."
    }

    composeTraffic = ProtectFunction( function( success, client, netMessage, sendAmount )

        assert( IsValid( client ), "Client isn't valid!" )

        local name, steamID64 = client:Name(), client:SteamID64()

        local logLookup = success and "net_sent" or "net_rated"

        do // Cooldowns

            trafficLogCooldown[steamID64] = trafficLogCooldown[steamID64] or {}

            local foundCooldown = trafficLogCooldown[steamID64][netMessage] or 0 
    
            if ( ( SysTime() - foundCooldown ) < cooldown ) then 
            
                return 
            end

        end

        local logReference = logs[logLookup] or logLookup
    
        MonkeyLib.Debug( false, logReference, name, steamID64, netMessage, sendAmount or 0 )
    
    end )
    
end

local netStack = {}

local getNetStack = function( steamID64 )

    if ( not MonkeyLib.isSteamID64( steamID64 ) ) then 

        return 
    end

    return netStack[steamID64]
end 

local getNetStackTarget = function( steamID64, netUtil )

    if ( not MonkeyLib.isSteamID64( steamID64 ) or not isstring( netUtil ) ) then 

        return 
    end

    return ( getNetStack( steamID64 ) or {} )[netUtil]
end 

local insertNetStack = function( steamID64, netMessage )

    do // Insert our data into memory! 

        netStack[steamID64] = netStack[steamID64] or {}

        netStack[steamID64][netMessage] = netStack[steamID64][netMessage] or {} 

    end

    local netPointer = netStack[steamID64][netMessage]

    netPointer.LastSentTime = SysTime()

    netPointer.SendAmount = ( netPointer.SendAmount or 0 ) + 1 

end 

local deleteNetStack = function( steamID64, netMessage )

    ( netStack[steamID64] or {} )[netMessage] = nil  

end

local canSendMessage = function( ply, netMessage )

    if ( not IsValid( ply ) or not isstring( netMessage ) ) then 

        return false, 0
    end

    if ( netMessageBypass[netMessage] ) then 
        
        return true, 1
    end

    local steamID64 = ply:SteamID64()

    local foundStack = getNetStackTarget( steamID64, netMessage )

    if ( not istable( foundStack ) ) then 

        insertNetStack( steamID64, netMessage )
        
        return true, 1 
    end
    
    local lastSendTime, sentAmount = foundStack.LastSentTime or 0, foundStack.SendAmount or 0

    if ( ( SysTime() - lastSendTime ) >= resetTime ) then 

        deleteNetStack( steamID64, netMessage )

        insertNetStack( steamID64, netMessage )

        return true, 1
    end

    insertNetStack( steamID64, netMessage )

    sentAmount = sentAmount + 1

    if ( sentAmount > overflowMessages ) then 

        return false, sentAmount 
    end

    return true, sentAmount
end

local netIncoming = function( len, client )
    
    local i = net.ReadHeader()
    local strName = util.NetworkIDToString( i )

    if ( !strName ) then return end

    local canSend, sentAmount = canSendMessage( client, strName )

    do // Log the message! 

        sentAmount = ( isnumber( sentAmount ) and sentAmount or 0 )

        composeTraffic( canSend, client, strName, sentAmount )

    end

    if ( not canSend ) then 

        return 
    end

    local func = net.Receivers[ strName:lower() ]
    if ( !func ) then return end

    --
    -- len includes the 16 bit int which told us the message name
    --
    len = len - 16

    func( len, client )

end

hook.Protect( "Initialize", "MonkeyLib:NetTraffic:Logger", function()

    MonkeyLib.Debug( false, "Over-writing net.Incoming to enable net_traffic_logs" )

    net.Incoming = netIncoming // I've committed a sin 

end )

hook.Protect( "PlayerDisconnected", "MonkeyLib:NetTraffic:WipeMem", function( ply )

    if ( not IsValid( ply ) ) then return end 

    local steamID64 = ply:SteamID64()

    netStack[steamID64] = nil 

    trafficLogCooldown[steamID64] = nil 

end )
