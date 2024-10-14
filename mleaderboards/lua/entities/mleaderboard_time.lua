require("memoize")

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "mleaderboard_base"

ENT.PrintName = "Playtime Leaderboard"
ENT.Category = "MonkeyEntities"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.HeaderTitle = "Top %s Play Time"

ENT.HeaderColor = Color(84, 164, 37)
ENT.ValueTextColor = Color(195, 183, 21)

ENT.FormatValue = function( s, value )

    return sam.format_length( value )
end

local memoizeRefreshTime = 1 * ( 60 * 60 )

local getData = memoize(function()

    local playerTime = MonkeyLib.SQL:Query( "SELECT steamid, play_time FROM sam_players ORDER BY play_time DESC LIMIT %s;", { 10 } ) or {}
    
    local sortedTable = {}

    for k = 1, #playerTime do 

        local row = playerTime[k]
        if ( not istable( row ) ) then continue end 

        local steamID = row.steamid 
        if ( not MonkeyLib.isSteamID( steamID ) ) then continue end 

        local steamID64 = util.SteamIDTo64( steamID )

        local playTime = row.play_time or 0 
        playTime = tonumber( playTime )

        local index = #sortedTable + 1

        sortedTable[index] = {

            ["steamID64"] = steamID64,
            ["value"] = ( playTime / 60 ), 

        }

    end

    return sortedTable

end, {}, memoizeRefreshTime)

ENT.GetLeaderBoardData = function( s )

    local data = getData()

    return data 

end 

