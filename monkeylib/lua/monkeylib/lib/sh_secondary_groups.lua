require( "memoize" )

local bypassRanks = {
    
    ["Head-Admin"] = true, 
    ["Admin"] = true, 

    ["Community-Manager"] = true,

    ["Senior-Admin"] = true, 
    ["superadmin"] = true 
    
}

local PLAYER = FindMetaTable( "Player" )


function PLAYER:UserGroupAccess( group ) // This function replaces my old rank system

    local ply = self
    
    if ( not isstring( group ) and not istable( group ) ) then 

        return true 
    end
    
    if ( istable( group ) and ( next( group ) == nil ) ) then 

        return true 
    end

    local rank = ply:GetUserGroup()
    if ( bypassRanks[rank] ) then return true end 

    local playerGroups = OpenPermissions:GetUserGroups( ply )
    if ( not istable( playerGroups ) ) then return false end 

    if ( isstring( group ) ) then 
    
        return playerGroups[group] or false 
    end

    for k, v in pairs( group ) do 

        local firstRow, secondRow = playerGroups[k], playerGroups[v]

        if ( firstRow or secondRow ) then 
            
            return true
        end
    end

    return false 
end

do 

    local getPrioritizedRank = memoize( function( ply ) // Use memoize for caching! 

        if ( not IsValid( ply ) ) then return end 
              
        local foundRanks = MonkeyLib.SecondaryRanks

        local foundRanksLength = #foundRanks

        do  // Check if the player has a bypass rank! 

            local primaryUserGroup = ply:GetUserGroup()

            if ( bypassRanks[primaryUserGroup] ) then 
    
                return foundRanks[foundRanksLength]
            end 

        end
 
        local lastRank 

        local userRanks = OpenPermissions:GetUserGroups( ply ) // Get the players GAS rank.  

        for k = 1, foundRanksLength do 

            local rank = foundRanks[k]
            
            if ( not isstring( rank ) ) then 
                
                continue 
            end

            if ( not userRanks[rank] ) then // Check if the user has the prioritized rank. 
                
                continue 
            end 

            lastRank = rank // The last rank found will always have the highest priority over the other ranks. 
        end 

        return lastRank
        
    end, {}, 45 )

    function PLAYER:GetSecondaryUserGroup()

        return getPrioritizedRank( self )
    end

end

if ( CLIENT ) then
    
    local getTag = memoize( function( ply )

        local tags = scb.tags or {} // Find our tags! 

        local primaryUserGroup, secondaryUserGroup = ply:GetUserGroup(), ply:GetSecondaryUserGroup() // Get our usergroups 

        return ( tags[ply:SteamID64()] or tags[ply:SteamID()] ) or ( tags[primaryUserGroup] or tags[secondaryUserGroup] ) or false

    end, {}, 30 )

    hook.Add( "Initialize", "MonkeyLib:SecondaryUserGroups:LoadTagFunc", function() 

        PLAYER.SCB_GetTag = getTag

    end )

end

do 

    local oldLimitFunc = function() return 0 end 

    // This is also cached for performance, GetConVar isn't great for performance...

    local defaultLimit = memoize( function( limit ) // Get our default limits! 

        if ( not limit ) then return 0 end 

        local formattedLimit = "sbox_max%s"
        formattedLimit = formattedLimit:format( limit )
        
        local foundVar = GetConVar( formattedLimit ) or 0 

        return fondVar
    end, {} )

    local findHighestLimit = memoize( function( ply, limitType )
    
        if ( not IsValid( ply ) or not limitType ) then return end 

        local foundRanks = OpenPermissions:GetUserGroups( ply ) // Lets get our player usergroups! 
        if ( not istable( foundRanks ) ) then return end 

        // Compare our limits ( We're using memoize to cache the results for performance. )

        local defaultUserGroup = ply:GetUserGroup()

        local highestFound = sam.ranks.get_limit( defaultUserGroup, limitType ) or defaultLimit( limitType )

        if ( highestFound <= 0 ) then 

            return highestFound
        end 

        for k, v in pairs( foundRanks ) do 

            local foundRankLimit = sam.ranks.get_limit( k, limitType ) 

            local rankLimit = ( isnumber( foundRankLimit ) and foundRankLimit ) or defaultLimit( limitType )

            if ( rankLimit < highestFound ) then continue end 
                
            highestFound = rankLimit 
        
        end

        return highestFound 

    end, {}, 60 ) 

    local checkPlayerLimits = function( ply, limitType )

        if ( not IsValid( ply ) ) then return defaultLimit( limitType ) end  

        local subLimit = findHighestLimit( ply, limitType )

        if ( isnumber( subLimit ) ) then
    
            return subLimit 
        end

        return oldLimitFunc( ply, limitType )
    end

    hook.Add( "SAM.LoadedRestrictions", "MonkeyLib:SecondaryUserGroups:LoadLimitFunc", function()

        oldLimitFunc = PLAYER.GetLimit

        PLAYER.GetLimit = checkPlayerLimits

    end )

end 


