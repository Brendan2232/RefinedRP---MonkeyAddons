require( "mlogs" )

assert( istable( MonkeyLogs ), "Failed to load Flip Logs, module doesn't exist." ); 

local logStrings = {
    ["player_connect_money"] = "%s | %s - Has Connected to the server, their money is %s.",
    ["player_disconnect_money"] = "%s | %s - Has Left the server, their money is %s.", 
}

local L = function( str )

    return logStrings[str] or str 
end

local log = MonkeyLogs.NewLog()
log:SetTitle( "MonkeyTransactions" )
log:SetLogDirectory( "MonkeyTransactions" )

local compileLog = function( logLookup, ... )

    assert( IsValid( log ), "Log isn't valid." )

    local logReference = L( logLookup )
    
    assert( logReference, "Failed to find log reference." )

    do 
        
        MonkeyLib.Debug( false, logReference, ... )

        log:Log( logReference, ... )

    end 

end

local commitLog = function()

    assert( IsValid( log ), "Log isn't valid." )

    log:Commit()
end

do // Connect / Disconnect Money logs. 

    local moneyEventLog = function( ply, isConnecting )

        if ( not IsValid( ply ) ) then return end 

        local playerName, playerSteamID64 = ply:Name(), ply:SteamID64()

        local formattedMoney = "NULL"

        do 

            local foundMoney = MonkeyLib.GetMoney( ply )

            formattedMoney = MonkeyLib.FormatMoney( foundMoney )
    
        end

        compileLog( ( isConnecting and "player_connect_money" or "player_disconnect_money" ), playerName, playerSteamID64, formattedMoney )
        
        commitLog()

    end

    hook.Protect( "MonkeyLib:PlayerNetReady", "MonkeyLib:MonkeyLogs:ConnectMoney", function( ply )
    
        moneyEventLog( ply, true )

    end )

    hook.Protect( "PlayerDisconnected", "MonkeyLib:MonkeyLogs:DisconnectMoney", function(ply)
    
        moneyEventLog( ply, false )

    end )
    
end
