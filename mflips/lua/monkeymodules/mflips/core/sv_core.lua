MonkeyFlips.Cooldowns = MonkeyFlips.Cooldowns or {}

require( "monkeyhooks" )

require( "async" )

util.AddNetworkString( "MonkeyFlips:Send:DeleteFlip" )

util.AddNetworkString( "MonkeyFlips:Send:CreateFlip" )

util.AddNetworkString( "MonkeyFlips:Send:JoinFlip" )

util.AddNetworkString( "MonkeyFlips:Send:AllFlips" )

local minimumCoinflipPrice, maximumCoinflipPrice, taxAmount = MonkeyFlips.MinimumFlipPrice, MonkeyFlips.MaximumFlipPrice, MonkeyFlips.TaxRate

local flipActionCooldown = MonkeyFlips.ActionCooldown 

local flipCooldowns = MonkeyFlips.Cooldowns

local appendCooldown = function( ply, cooldownType )

    if ( not IsValid( ply ) or not isstring( cooldownType ) ) then  

        return false  
    end

    local steamID64 = ply:SteamID64()
    
    flipCooldowns[steamID64] = flipCooldowns[steamID64] or {}

    flipCooldowns[steamID64][cooldownType] = ( SysTime() + flipActionCooldown ) 

end

local removeCooldown = function( ply )

    if ( not IsValid( ply ) ) then 

        return 
    end

    local steamID64 = ply:SteamID64()

    flipCooldowns[steamID64] = nil 

end 

local getCooldown = function( ply, cooldownType )

    if ( not IsValid( ply ) or not isstring( cooldownType ) ) then  

        return false  
    end

    local steamID64 = ply:SteamID64()

    return ( flipCooldowns[steamID64] or {} )[cooldownType]
end

local canDoAction = function( ply, cooldownType )

    if ( not IsValid( ply ) or not isstring( cooldownType ) ) then 

        return true   
    end

    local foundCooldown = getCooldown( ply, cooldownType )

    if ( not isnumber( foundCooldown ) ) then 

        return true  
    end

    return SysTime() >= foundCooldown 
end

local L = function( message )

    return MonkeyFlips.Messages[message] or message 
end

local getName = function( steamID64 ) // I need to move this to a global function with cache - promise, cba for now. I'll 100% do it before the server opens. 

    if ( not MonkeyLib.isSteamID64( steamID64 ) ) then return "NULL" end 

    local foundPlayer = player.GetBySteamID64( steamID64 )
    
    if ( IsValid( foundPlayer ) ) then 

        return foundPlayer:Name()
    end

    local steamID = util.SteamIDFrom64( steamID64 )

    local foundName = MonkeyLib.SQL:QueryValue( "SELECT name FROM sam_players WHERE steamid = %s", { steamID } )

    return foundName or "NULL"
end

local createFlip = function( steamID64, price )

    local createTime = os.time()

    MonkeyLib.SQL:Query( "INSERT INTO mflips ( steamID64, price, createTime ) VALUES( %s, %s, %s );", {
        steamID64, price, createTime 
    } )

    local sqlID = MonkeyLib.SQL:QueryValue( "SELECT last_insert_rowid()" ) 
    sqlID = tonumber( sqlID )

    return sqlID 
end

MonkeyFlips.DeleteFlip = function( flipID )

    if ( not isnumber( flipID ) ) then return end 
      
    MonkeyLib.SQL:Query( "DELETE FROM mflips WHERE flipID = %s;", { flipID } )

    MonkeyNet.WriteStructure( "MonkeyFlips:Send:DeleteFlip", MonkeyFlips.NetStructure.DeleteFlip, { flipID } )

end

MonkeyFlips.GetFlip = function( flipID )

    if ( not isnumber( flipID ) ) then return end 

    local foundFlip = MonkeyLib.SQL:QueryRow( "SELECT steamID64, price, createTime FROM mflips WHERE flipID = %s;", { flipID } )
    if ( not istable( foundFlip ) ) then return end 
    
    local flipPrice, createTime = foundFlip.price, foundFlip.createTime 
    if ( not flipPrice or not createTime ) then return end 

    foundFlip.price, foundFlip.createTime = tonumber( flipPrice ), tonumber( createTime )

    return foundFlip
end

MonkeyFlips.GetFlips = function()

    local allFlips = MonkeyLib.SQL:Query("SELECT flipID, steamID64, price FROM mflips;") or {}

    return allFlips 
end

MonkeyFlips.CreateFlip = function( ply, price )

    if ( not IsValid( ply ) or not isnumber( price ) ) then 
        
        return false, "flip_create_fail" 
    end 

    local steamID64 = ply:SteamID64()

    if ( not MonkeyLib.CanAfford( ply, price ) ) then 
        
        return false, "cant_afford", {"create"}
    end 

    if ( price < minimumCoinflipPrice or price > maximumCoinflipPrice ) then 

        return false, "invalid_price", { MonkeyLib.FormatMoney( minimumCoinflipPrice ), MonkeyLib.FormatMoney( maximumCoinflipPrice ) }
    end

    local canCreateFlip, err = hook.Run( "MonkeyFlips:CanCreateFlip", ply, price )

    if ( canCreateFlip == false ) then 

        return false, err or "flip_create_fail" 
    end

    local hasCreateCooldown = canDoAction( ply, "create" )

    if ( hasCreateCooldown == false ) then 

        return false
    end

    local flipID = createFlip( steamID64, price )

    MonkeyLib.AddMoney( ply, -price )

    appendCooldown( ply, "create" )

    do 

        local flipDataStructure = { ply, flipID, price }

        MonkeyNet.WriteStructure( "MonkeyFlips:Send:CreateFlip", MonkeyFlips.NetStructure.SendCreatedFlip, flipDataStructure )

        hook.Run( "MonkeyFlips:FlipCreated", unpack( flipDataStructure ) )

    end

    local flipReturn = {

        ["flipCreator"] = ply,

        ["flipID"] = flipID,

        ["flipPrice"] = price

    }

    return true, "flip_create_succ", flipReturn
end 

MonkeyFlips.RemoveFlip = function( ply, flipID )

    if ( not IsValid( ply ) or not isnumber( flipID ) ) then 
        
        return false, "flip_remove_fail" 
    end 

    local steamID64 = ply:SteamID64()

    local foundFlip = MonkeyFlips.GetFlip( flipID )
    
    if ( not istable( foundFlip ) ) then 
        
        return false, "flip_remove_fail"
    end 

    local flipOwner = foundFlip.steamID64 

    if ( flipOwner ~= steamID64 ) then 

        return false, "flip_remove_fail" 
    end 

    local flipPrice = foundFlip.price
    
    if ( not isnumber( flipPrice ) ) then 
        
        return false, "flip_remove_fail" 
    end 

    do // Delete the flip and take the players money! 

        MonkeyFlips.DeleteFlip( flipID )

        MonkeyLib.AddMoney( ply, flipPrice )

    end

    hook.Run( "MonkeyFlips:FlipDeleted", ply, flipID, flipPrice )

    local flipReturn = {

        ["flipCreator"] = ply,

        ["flipID"] = flipID,

        ["flipPrice"] = flipPrice

    }

    return true, "flip_remove_succ", flipReturn
end

MonkeyFlips.JoinFlip = function( ply, flipID ) 

    if ( not IsValid( ply ) or not isnumber( flipID ) ) then 
        
        return false, "flip_join_fail" 
    end 
    
    local steamID64 = ply:SteamID64()

    local foundFlip = MonkeyFlips.GetFlip( flipID )

    if ( not istable( foundFlip ) ) then 
        
        return false, "flip_join_fail" 
    end 
    
    local flipCreator, price = foundFlip.steamID64, foundFlip.price 

    if ( not MonkeyLib.isSteamID64( flipCreator ) or not isnumber( price ) ) then 
        
        return false, "flip_join_fail"
    end 

    if ( flipCreator == steamID64 ) then 
        
        return false, "flip_join_fail" 
    end 

    local canJoinFlip, err = hook.Run( "MonkeyFlips:CanJoinFlip", ply, flipCreator, flipID, price )

    if ( canJoinFlip == false ) then 

        return false, err or "flip_join_fail" 
    end

    local hasJoinCooldown = canDoAction( ply, "join" )

    if ( hasJoinCooldown == false ) then 

        return false
    end
    
    if ( not MonkeyLib.CanAfford( ply, price ) ) then 
    
        return false, "cant_afford", { "join" }
    end 

    appendCooldown( ply, "join" )

    local winningAmount = math.Round( ( price * 2 ) * taxAmount )

    MonkeyFlips.DeleteFlip( flipID )

    MonkeyLib.AddMoney( ply, -price )
    
    math.random( )
    math.random( )

    local winner = math.random( 1, 2 )
    winner = ( winner == 1 and steamID64 or flipCreator )

    local loser = ( winner ~= steamID64 and steamID64 or flipCreator ) 
    
    MonkeyLib.addToOfflineAccount( winner, winningAmount )

    hook.Run( "MonkeyFlips:FlipJoined", winner, loser, winningAmount )

    local flipReturn = {

        ["flipWinner"] = winner,
         
        ["flipLoser"] = loser,

        ["winningAmount"] = winningAmount

    }

    return true, nil, flipReturn // For GLuaTester!
end

MonkeyNet.ReadStructure( "MonkeyFlips:Send:CreateFlip", MonkeyFlips.NetStructure.CreateFlip, function ( _, ply, flipPrice )
    
    local succ, err, messageArguments = MonkeyFlips.CreateFlip( ply, flipPrice )

    if ( err == nil ) then return end 
    
    MonkeyLib.FancyChatMessage( L( err ), not succ, messageArguments, ply )

end )

MonkeyNet.ReadStructure( "MonkeyFlips:Send:DeleteFlip", MonkeyFlips.NetStructure.DeleteFlip, function ( _, ply, flipID )
    
    local succ, err, messageArguments = MonkeyFlips.RemoveFlip( ply, flipID )

    if ( err == nil ) then return end 
    
    MonkeyLib.FancyChatMessage( L( err ), not succ, messageArguments, ply )
    
end )

MonkeyNet.ReadStructure( "MonkeyFlips:Send:JoinFlip", MonkeyFlips.NetStructure.JoinFlip, function ( _, ply, flipID )
    
    local succ, err, messageArguments = MonkeyFlips.JoinFlip( ply, flipID )

    if ( err == nil ) then return end 
    
    MonkeyLib.FancyChatMessage( L( err ), not succ, messageArguments, ply )
    
end )

hook.Protect( "Initialize", "MonkeyFlips:Init", function()

    MonkeyLib.SQL:Query( "CREATE TABLE IF NOT EXISTS mflips ( flipID INTEGER PRIMARY KEY AUTOINCREMENT, steamID64 VARCHAR(255), price INT, createTime INT )" )

end )

hook.Protect( "MonkeyLib:PlayerNetReady", "MonkeyFlips:NetworkFlips", function( ply )

    local allFlips = MonkeyFlips.GetFlips()

    assert( IsValid( ply ), "Failed to network flips, invalid player." )

    assert( istable( allFlips ), "Failed to network flips, flip table isn't valid." )

    if ( #allFlips <= 0 ) then return end 

    net.Start( "MonkeyFlips:Send:AllFlips" )

        net.WriteUInt( #allFlips, 11 )
        
        for k = 1, #allFlips do

            local flipRow = allFlips[k]
            if ( not istable( flipRow ) ) then continue end 

            local flipID, steamID64, flipPrice = flipRow.flipID, flipRow.steamID64, flipRow.price 
            if ( not flipID or not steamID64 or not flipPrice ) then continue end 

            flipID, flipPrice = tonumber( flipID ), tonumber( flipPrice )

            net.WriteUInt( flipID, 32 )
        
            MonkeyLib.WriteSteamID64( steamID64 )
     
            net.WriteUInt( flipPrice, 32 )

        end

    net.Send( ply )
 
end )

hook.Protect( "MonkeyFlips:FlipCreated", "MonkeyFlips:Send:Message", function( ply, _, flipPrice )

    assert( IsValid( ply ), "Player isn't valid!")

    assert( isnumber( flipPrice ), "Flip price isn't a number!" )

    local playerName = ply:Name()

    MonkeyLib.ChatMessage( L"flip_create_global_succ", { playerName, MonkeyLib.FormatMoney( flipPrice ) } )

end )

hook.Protect( "MonkeyFlips:FlipJoined", "MonkeyFlips:Send:Message", function( winner, loser, winningAmount )
    
    assert( isnumber( winningAmount ), "Flip price isn't a number!" )

    local winnerName, loserName = getName( winner ), getName( loser )
    
    assert( isstring( winnerName ), "Winner name isn't a string!" )
    assert( isstring( loserName ), "Loser name isn't a string!" )

    MonkeyLib.ChatMessage( L"flip_won", { winnerName, loserName, MonkeyLib.FormatMoney( winningAmount ) } )

end )

