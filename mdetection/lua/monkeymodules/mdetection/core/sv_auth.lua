// #5988 garrysmod-issues 

require( "monkeyhooks" )

local isAuthed = function( ply )

    return ply:IsFullyAuthenticated()
end

local authVerification = function( ply )

    if ( not IsValid( ply ) ) then

        return 
    end

    local authed = isAuthed( ply )

    if ( authed ) then 

        do 

            local name, steamID64 = ply:Name(), ply:SteamID64()

            MonkeyLib.Debug( false, "%s | %s - Was marked as authed by BrendanAuth!", name, steamID64 )

        end

        hook.Run( "MDetection:Auth:PlayerFullyAuthed", ply )

        return   
    end

    timer.Simple( 1, function()
    
        authVerification( ply )

    end )
    
end 

do // Interface 

    hook.Protect( "PlayerAuthed", "MDetection:Auth:RunAuth", function(ply)

        if ( not IsValid( ply ) ) then 
    
            return 
        end
    
        authVerification( ply )
    
    end )

end 
