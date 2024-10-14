require( "memoize" )

AddCSLuaFile()

local maxRows = 10 

ENT.Type = "anim"
ENT.Base = "mleaderboard_base"

ENT.PrintName = "Claims Leaderboard"
ENT.Category = "MonkeyEntities"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.HeaderTitle = "Top %s Sits"

ENT.HeaderColor = Color(164, 48, 37)
ENT.ValueTextColor = Color(109, 66, 184)

local claimFormat = "%d Claims"

ENT.FormatValue = function( s, value )

    return claimFormat:format( value )
end

local getData = memoize( function()

    local highestClaims = MonkeyLib.GetHighestClaims( maxRows )
    
    if ( ( #highestClaims or 0 ) <= 0 ) then return end 
    
    local sortedTable = {}
    
    for k = 1, #highestClaims do 

        local row = highestClaims[k]
        if ( not istable( row ) ) then continue end 

        local adminSteamID64, claims = row.adminSteamID64, row.claimCount 
        if ( not MonkeyLib.isSteamID64( adminSteamID64 ) or not claims ) then continue end 

        claims = tonumber( claims )
        if ( claims <= 0 ) then continue end

        local index = #sortedTable + 1

        sortedTable[index] = {
            ["steamID64"] = adminSteamID64, 
            ["value"] =  claims, 
        }

    end

    return sortedTable

end, {}, 1 * ( 15 * 60 ) ) 

ENT.GetLeaderBoardData = function( )

    local data = getData() 

    return data 
end 

