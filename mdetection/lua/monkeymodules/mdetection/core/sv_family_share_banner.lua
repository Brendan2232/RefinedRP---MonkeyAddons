require( "monkeyhooks" )

local L = function( message )

    return MDetection.Messages[ message ] or message 
end

local formatKickMessage = function( message, ... )

    local foundMessage = L( message )
    
    return foundMessage:format( ... )
end

MDetection.IsFamilyOwnerBanned = function( ply )

    if ( not IsValid( ply ) ) then 
    
        return 
    end

    local steamID64 = ply:SteamID64()

    local usingFamilyShare, ownerSteamID64 = MDetection.isUsingFamilyAccount( ply )

    if ( not usingFamilyShare ) then 

        return  
    end

    local banID, banTime = MDetection.GetBan( ownerSteamID64 )

    return ownerSteamID64, banID, banTime     
end

MDetection.BanFamilySharedAccount = function( ply )

    if ( not IsValid( ply ) ) then 
    
        return 
    end

    local ownerSteamID64, banTime = MDetection.IsFamilyOwnerBanned( ply )

    if ( not isnumber( banTime ) ) then 

        return  
    end

    do // chat / debug messages 

        MonkeyLib.ChatMessage( L"family_share_main_banned", { ply:Name() } )

    end

    local formattedKickMessage = formatKickMessage( "ban_message_share_main_banned", ply:SteamID64(), ownerSteamID64 )

    local formattedBanTime = MDetection.SamDateToSeconds( banTime )

    sam.player.ban( ply, formattedBanTime, formattedKickMessage )

    return ownerSteamID64, formattedBanTime 
end

do 

    hook.Protect( "MDetection:Auth:PlayerFullyAuthed", "MDetection:FamilyShare:CheckBannedAccounts", function( ply )

        if ( not IsValid( ply ) ) then 
    
            return 
        end
        
        MDetection.BanFamilySharedAccount( ply )
    
    end )
    
end

