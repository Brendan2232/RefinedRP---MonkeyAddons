require( "memoize" )

local maxRows = 10 

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "mleaderboard_base"

ENT.PrintName = "Money Leaderboard"
ENT.Category = "MonkeyEntities"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.HeaderTitle = "Top %s Richest players"

ENT.HeaderColor = Color(50, 37, 164)
ENT.ValueTextColor = Color(30, 177, 79)

ENT.FormatValue = function( s, value )

    return MonkeyLib.FormatMoney( value ) 
end

local getData = memoize( function()

    local richestPlayer = sql.Query( "SELECT uid, wallet FROM darkrp_player WHERE uid LIKE'7656119%' ORDER BY wallet DESC LIMIT 10;" ) or {}

    local sortedTable = {}

    for k = 1, #richestPlayer do 

        local row = richestPlayer[k]
        if ( not istable( row ) ) then continue end 

        local uid = row.uid 
        if ( not MonkeyLib.isSteamID64( uid ) ) then continue end 

        local wallet = row.wallet or 0 
        wallet = tonumber( wallet )

        local index = #sortedTable + 1

        sortedTable[index] = {
            ["steamID64"] = uid, 
            ["value"] =  wallet, 
        }

    end

    return sortedTable
        
end, {}, 1 * (60 * 60) ) 

ENT.GetLeaderBoardData = function( )

    local data = getData() 

    return data 
end 

