util.AddNetworkString( "MonkeyBail:Bail:Send" )
util.AddNetworkString( "MonkeyBail:Bail:Remove" )
util.AddNetworkString( "MonkeyBail:Bail:Set" )
util.AddNetworkString( "MonkeyBail:Bail:Pay" )
util.AddNetworkString( "MonkeyBail:Bail:SendGUI" )
util.AddNetworkString( "MonkeyBail:Bail:SendBails" )

local minBailPrice = MBail.Config.MinBailPrice
local maxBailPrice = MBail.Config.MaxBailPrice

local cachedMessages = MBail.Config.Messages 

local L = function( message )

    return cachedMessages[message] or message 
end

local networkRemove = function( bailIndex )

    net.Start( "MonkeyBail:Bail:Remove" )
        net.WriteUInt( bailIndex, 8 )
    net.Broadcast()

end

local NPCCache = {}

MBail.InNPCRange = function( ply )

    if ( not MBail.Config.RequiresNPCInteraction ) then return true end 

    local ent = NPCCache[ply]
    if ( not IsValid( ent ) ) then return false end 

    local playerPos = ply:GetPos()
    local entPos = ent:GetPos()

    return playerPos:Distance( entPos ) < MBail.Config.MaxNPCRange
end

MBail.BailPlayer = function( ply, bailIndex )

    if ( not IsValid( ply ) or not isnumber( bailIndex ) ) then 
        
        return false, "bail_pay_fail" 
    end 

    if ( ply:isArrested() ) then 

        return false, "player_arrested"
    end

    local inNPCRange = MBail.InNPCRange( ply )

    if ( not inNPCRange ) then

        return false, "bail_pay_fail"
    end

    local foundBail = MBail.GetBail( bailIndex )

    if ( not istable( foundBail ) or ply:isCP() ) then 
        
        return false, "bail_pay_fail" 
    end 
        
    local arrestedPlayer, bailPrice = foundBail.arrestedPlayer, foundBail.bailPrice

    if ( not IsValid( arrestedPlayer ) ) then 
        
        return false, "bail_pay_fail" 
    end 

    if ( arrestedPlayer == ply ) then 
        
        return false, "bail_pay_fail"
    end

    if ( not MonkeyLib.CanAfford( ply, bailPrice ) ) then 

        return false, "cant_afford" 
    end

    local canBailPlayer, err = hook.Run( "MonkeyBail:CanBailPlayer", ply, arrestedPlayer, bailIndex, bailPrice )

    if ( canBailPlayer == false ) then 

        return false, err or "bail_pay_fail"
    end

    MonkeyLib.AddMoney( ply, -bailPrice )

    MBail.RemoveBail( bailIndex )
    
    arrestedPlayer:unArrest()

    local bailStruct = {

        ["ply"] = ply, 
    
        ["bailTarget"] = arrestedPlayer, 

        ["bailPrice"] = bailPrice, 

    }

    return true, "bail_pay_succ", bailStruct // For GluaTester! 
end

MBail.SetBail = function( ply, bailIndex, newPrice )

    if ( not IsValid( ply ) or not isnumber( bailIndex ) or not isnumber( newPrice ) ) then 
        
        return false, "bail_set_fail" 
    end 

    local inNPCRange = MBail.InNPCRange( ply )

    if ( not inNPCRange or not ply:isCP() ) then
         
        return false, "bail_set_fail"
    end

    if ( newPrice < minBailPrice or newPrice > maxBailPrice ) then

        return false, "bail_set_fail"
    end

    local foundBail = MBail.GetBail( bailIndex )
    
    if ( not istable( foundBail ) ) then 
        
        return false, "bail_set_fail" 
    end 

    local arrestedPlayer = foundBail.arrestedPlayer

    if ( not IsValid( arrestedPlayer ) or not arrestedPlayer:isArrested() ) then 

        return false, "bail_set_fail"
    end

    local canSetBail, err = hook.Run( "MonkeyBail:CanSetBail", ply, arrestedPlayer, bailIndex, newPrice )

    if ( canSetBail == false ) then 
        
        return false, err or "bail_set_fail"
    end

    foundBail.bailPrice = newPrice 

    net.Start( "MonkeyBail:Bail:Set" )
        net.WriteUInt( bailIndex, 8 )
        net.WriteUInt( newPrice, 32 )
    net.Broadcast()

    local bailStruct = {

        ["ply"] = ply,

        ["bailTarget"] = arrestedPlayer, 

        ["bailPrice"] = newPrice, 

    }

    return true, "bail_set_succ", bailStruct
end

MBail.DeleteBail = function( ply )

    if ( not IsValid( ply ) ) then return end 

    local cache = MBail.ArrestCache

    // Turned this into a simple sorting algorithm to remove the 'table.remove' callback ( so it's not an (O)N * 2 )
    local sorted = {}
    
    for k = 1, #cache do 

        local row = cache[k]
        if ( not istable( row ) ) then continue end 

        local arrestedPlayer = row.arrestedPlayer

        if ( arrestedPlayer == ply ) then // Skip this person, they're being unarrested! NEXT ROW!!!

            networkRemove( k )

            continue 
        end 

        local index = #sorted + 1 
        sorted[index] = row
    
    end

    MBail.ArrestCache = sorted 
end

MBail.RemoveBail = function( bailIndex )

    if ( not isnumber( bailIndex ) ) then return end 

    networkRemove( bailIndex )

    table.remove( MBail.ArrestCache, bailIndex )

end

local networkBail = function( ply )

    local bailCache = MBail.ArrestCache or {}

    if ( #bailCache <= 0 ) then return end 

    local curTime = CurTime()

    net.Start( "MonkeyBail:Bail:SendBails" )

    do // Write the length of the bail cache to the buffer > all other rows of data. 

        net.WriteUInt( #bailCache, 8 )

        for k = 1, #bailCache do 

            local bailRow = bailCache[k]
            if ( not istable( bailRow ) ) then continue end // Invalid!! NEXT ROW!! 

            local arrestedPlayer, arrestTime, bailPrice = bailRow.arrestedPlayer, bailRow.arrestTime, bailRow.bailPrice 
            
            if ( not IsValid( arrestedPlayer ) or not isnumber( arrestTime ) or not isnumber( bailPrice ) ) then 

                continue 
            end

            if ( not arrestedPlayer:isArrested() ) then

                continue 
            end

            net.WriteEntity( arrestedPlayer )

            net.WriteUInt( arrestTime - curTime, 32 )

            net.WriteUInt( bailPrice, 32 )
            
        end

    end

    net.Send( ply )

end

net.Receive( "MonkeyBail:Bail:Pay", function( l, ply )

    local bailIndex = net.ReadUInt( 8 )
    local succ, err = MBail.BailPlayer( ply, bailIndex )

    if ( err == nil ) then return end 

    MonkeyLib.FancyChatMessage( L( err ), not succ, nil, ply )
    
end )

net.Receive( "MonkeyBail:Bail:Set", function( l, ply )

    local bailIndex = net.ReadUInt( 8 )
    local newPrice = net.ReadUInt( 32 )

    local succ, err = MBail.SetBail( ply, bailIndex, newPrice )

    if ( err == nil ) then return end 

    MonkeyLib.FancyChatMessage( L( err ), not succ, nil, ply )

end )

hook.Protect( "playerArrested", "MonkeyLib:Bail:AddBail", function( ply, time )

    MBail.AddBail( ply, time )
    
end )

hook.Protect( "playerUnArrested", "MonkeyLib:Bail:RemoveBail", function( ply )

    MBail.DeleteBail( ply )
    
end )

hook.Protect( "PlayerDisconnected", "MonkeyLib:Bail:RemoveBail", function( ply )
    
    if ( not IsValid(ply) or not ply:isArrested() ) then return end

    MBail.DeleteBail( ply )
    
end )

// Networking entities should be ok in this stage....
hook.Protect( "MonkeyLib:PlayerNetReady", "MonkeyBail:Bail:NetworkBail", networkBail ) // Might move this to when the GUI is first opened. 

hook.Protect( "MonkeyBail:NPC:Interaction", "MonkeyBail:Bail:HandleNPC", function( ent, ply )

    if ( not IsValid( ent ) or not IsValid( ply ) ) then return end 

    NPCCache[ply] = ent 

    if ( not MBail.InNPCRange( ply ) ) then return end 

    net.Start( "MonkeyBail:Bail:SendGUI" )
    net.Send( ply )

end )




