require( "monkeyhooks" )

local os_time = os.time 

local function isSteamID64( id )

    if ( not id ) then return false end 

    if ( isstring( id ) and tonumber( id ) and id:sub( 1, 7 ) == "7656119" and #id == 17 or #id == 18 ) then return true end 
end 

function MPunishments:AddPlayerPunishment( ply, punishmentType, punishmentTime )

    if ( not IsValid( ply ) or not isstring( punishmentType ) or not isnumber( punishmentTime ) ) then return false end 

    local steamID64 = ply:SteamID64()
    
    MPunishments:InsertOfflinePunishment( steamID64, punishmentType, punishmentTime ) 

    ply[punishmentType] = punishmentTime // Insert into the players cache, makes accessing the punishment faster!  
end

function MPunishments:RemovePlayerPunishment( ply, punishmentType )

    if ( not IsValid( ply ) or not isstring( punishmentType ) ) then return false end
    
    local steamID64 = ply:SteamID64()
    
    MPunishments:RemoveOfflinePunishment( steamID64, punishmentType ) 

    ply[punishmentType] = nil 
end

function MPunishments:InsertOfflinePunishment( steamID64, punishmentType, punishmentTime ) 

    if ( not isSteamID64( steamID64 ) or not isstring( punishmentType ) or not isnumber( punishmentTime ) ) then return false end

    MPunishments:RemoveOfflinePunishment( steamID64, punishmentType ) 

    sql.Query( "INSERT INTO mlib_punishments (steamID64, punishmentType, removeTime) VALUES( " ..  sql.SQLStr( steamID64 ) .. "," .. sql.SQLStr( punishmentType ) .. "," .. sql.SQLStr( punishmentTime ) ..");" )
end

function MPunishments:RemoveOfflinePunishment( steamID64, punishmentType ) 

    if ( not isSteamID64( steamID64 ) or not isstring( punishmentType ) ) then return false end
    
    sql.Query( "DELETE FROM mlib_punishments WHERE steamID64 = " .. sql.SQLStr( steamID64 ) .. " AND punishmentType = " .. sql.SQLStr( punishmentType ) .. ";" )
end

do 

    MPunishments.isShadowBanned = function( ply )

        local shadowBannedTime = ply["shadowbanned"]

        if ( isnumber( shadowBannedTime ) ) then 

            return true, shadowBannedTime
        end

        return false 
    end 

end

function MPunishments:CanDo( ply, punishmentType ) 

    if ( not IsValid( ply ) or not isstring( punishmentType ) ) then return end

    local shadowBannedTime = ply["shadowbanned"]

    local isShadowBanned = isnumber( shadowBannedTime )

    local playerPunishmentTime = ( isShadowBanned and shadowBannedTime ) or ply[punishmentType] 
    if ( not isnumber( playerPunishmentTime ) ) then return end
    
    if ( playerPunishmentTime ~= 0 and os_time() >= playerPunishmentTime ) then 
        
        MPunishments:RemovePlayerPunishment( ply, isShadowBanned and "shadowbanned" or punishmentType ) 
        
        return 
    end

    return false 
end

hook.Add( "Initialize", "MPunishments:InitPunishmentDB", function()

    sql.Query( "CREATE TABLE IF NOT EXISTS mlib_punishments ( steamID64 VARCHAR( 255 ), punishmentType VARCHAR( 255 ), removeTime INT )" )

end )

hook.Protect( "PlayerAuthed", "MPunishments:LoadPlayerPunishment", function( ply ) // Might be too early, if the players metadata has been initialized we should be fine, right??

    if ( not IsValid( ply ) ) then return end 

    local steamID64 = ply:SteamID64()

    local playerPunishments = sql.Query( "SELECT punishmentType, removeTime FROM mlib_punishments WHERE steamID64 = " .. sql.SQLStr( steamID64 ) .. ";" )

    if ( istable( playerPunishments ) and #playerPunishments >= 1 ) then 

        for k = 1, #playerPunishments do

            local row = playerPunishments[k]
            if ( not istable( row ) ) then continue end 
            
            local punishmentType, punishmentTime = row["punishmentType"], row["removeTime"]

            if ( not punishmentType or not punishmentTime ) then continue end 

            punishmentTime = tonumber( punishmentTime )
 
            if ( punishmentTime ~= 0 and os_time() >= punishmentTime ) then MPunishments:RemoveOfflinePunishment( steamID64, punishmentType ) continue end // If it's equal to 0 it's a perm punishment
            
            ply[punishmentType] = punishmentTime
        end
    end
end )
