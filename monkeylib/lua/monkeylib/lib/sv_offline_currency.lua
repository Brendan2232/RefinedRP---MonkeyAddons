MonkeyLib.getOfflineAccount = function( steamID64 )

    assert( MonkeyLib.isSteamID64( steamID64 ), "Failed to get offline account, malformed steamID64." )
 
    local ranQuery = MonkeyLib.SQL:QueryValue( "SELECT storedMoney FROM mlib_offline_money WHERE steamID64 = %s", {
        steamID64, 
    } ) 

    local storedMoney = tonumber( ranQuery or 0 ) 

    return storedMoney 
end

MonkeyLib.addToOfflineAccount = function( steamID64, amount )

    assert( MonkeyLib.isSteamID64( steamID64 ), "Failed to insert money into offline account, malformed steamID64." )
    assert( isnumber( amount ), "Failed to insert money into offline account, malformed amount." )

    local playerOnline = player.GetBySteamID64( steamID64 )

    if ( IsValid( playerOnline ) ) then 
        
        MonkeyLib.AddMoney( playerOnline, amount ) 
        
        return 
    end 

    local storedMoney = MonkeyLib.getOfflineAccount( steamID64 ) or 0 

    storedMoney = storedMoney + amount 

    MonkeyLib.SQL:Query( "REPLACE INTO mlib_offline_money ( steamID64, storedMoney ) VALUES( %s, %s );", {
        steamID64, 
        storedMoney, 
    } )
end

MonkeyLib.addMoneyToAccount = function( ply )

    if ( not IsValid( ply ) ) then return end 
    
    local steamID64 = ply:SteamID64()

    local storedMoney = MonkeyLib.getOfflineAccount( steamID64 )

    if ( not isnumber( storedMoney ) ) then
        
        return 
    end 

    MonkeyLib.SQL:Query( "DELETE FROM mlib_offline_money WHERE steamID64 = %s", {
        steamID64, 
    } )

    MonkeyLib.AddMoney( ply, storedMoney )
end

hook.Protect( "MonkeyLib:PlayerNetReady", "MonkeyLib:AddOfflineMoney", MonkeyLib.addMoneyToAccount )

