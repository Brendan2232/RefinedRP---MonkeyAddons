require( "mlogs" )

assert( istable( MonkeyLogs ), "Failed to load Flip Logs, module doesn't exist." ); 

local log = MonkeyLogs.NewLog()
log:SetTitle( "MFlips" )

local flipLogs = function( logLookup, ... )

    assert( IsValid( log ), "Log isn't valid." )

    local logReference = MonkeyFlips.Logs[logLookup]

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

hook.Protect( "MonkeyFlips:FlipCreated", "MonkeyFlips:Log:Created", function( ply, _, price )

    assert( IsValid( ply ), "Player isn't valid." ) // hook.Protect to save the day!

    local name, steamID64 = ply:Name(), ply:SteamID64()

    flipLogs( "flip_created", steamID64, name, MonkeyLib.FormatMoney( price ) )

    commitLog()
end )

hook.Protect( "MonkeyFlips:FlipDeleted", "MonkeyFlips:Log:Deleted", function( ply, _, price )

    assert( IsValid( ply ), "Player isn't valid." )

    local name, steamID64 = ply:Name(), ply:SteamID64()

    flipLogs( "flip_deleted", steamID64, name, MonkeyLib.FormatMoney( price ) )

    commitLog()
end )

hook.Protect( "MonkeyFlips:FlipJoined", "MonkeyFlips:Log:Joined", function( winner, loser, price )

    assert( isnumber( price ), "Price isn't a number." )

    MonkeyLib.GetName( winner, function( name )
        
        flipLogs( "flip_win", winner, name, MonkeyLib.FormatMoney( price ) )
        
        commitLog()

    end )
    
    MonkeyLib.GetName( loser, function( name )
        
        flipLogs( "flip_lost", loser, name, MonkeyLib.FormatMoney( price ) )

        commitLog()
        
    end )

end )

