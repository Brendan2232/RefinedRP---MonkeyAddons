local moduleName = "gag"

local command = sam.command  

command.set_category( "Chat" )

command.remove_command( "gag" )
command.remove_command( "ungag" )

command.new( "gag" )

    :SetPermission( "gag", "admin" )

    :AddArg( "player" , { single_target = true }  ) 
    :AddArg( "length", { optional = true, default = 0, min = 0 } )
    :AddArg( "text", { hint = "reason", optional = true, default = sam.language.get( "default_reason" ) } )

    :GetRestArgs( )

    :Help( "gag_help" )

    :OnExecute( function( ply, targets, length, reason, isSilent )

        local newLength = length ~= 0 and os.time() + length * 60 or 0 
        
        local target = targets[1]
        if ( not IsValid( target ) ) then return end 

        MPunishments:AddPlayerPunishment( target, moduleName, newLength )
        
        if ( isSilent ) then return end 

        sam.player.send_message( nil, "gag", {
            A = ply, T = {target}, V = sam.format_length(length), V_2 = reason
        } )
    end )
:End()

command.new( "ungag" )

    :SetPermission( "ungag", "admin" )

    :AddArg( "player", { optional = true } )
    :Help( "ungag_help" )

    :OnExecute( function( ply, targets, isSilent )

        local target = targets[1]
        if ( not IsValid( target ) ) then return end 
   
        MPunishments:RemovePlayerPunishment( target, moduleName )
     
        if ( isSilent ) then return end 

        sam.player.send_message( nil, "ungag", {
            A = ply, T = {target}
        } )
        
    end )
:End()

command.new( "gagid" )

    :SetPermission("gagid", "admin")

	:AddArg( "steamid" )

    :AddArg( "length", { optional = true, default = 0, min = 0 } )

    :AddArg( "text", { hint = "reason", optional = true, default = sam.language.get( "default_reason" ) } )

    :GetRestArgs( )

    :Help( "gag_help" )

    :OnExecute( function( ply, promise, length, reason, isSilent )

        local newLength = length ~= 0 and os.time() + length * 60 or 0 

		promise:done( function( data )

            local steamID, target = data[1], data[2]
            if ( not steamID ) then return end 

            local originalSteamID = steamID 

            if ( IsValid( target ) ) then 
      
                MPunishments:AddPlayerPunishment( target, moduleName, newLength )

            else

                steamID = util.SteamIDTo64( steamID )

                MPunishments:InsertOfflinePunishment( steamID, moduleName, newLength ) 

            end

            if ( isSilent ) then return end 

            sam.player.send_message( nil, "gag", {

                A = ply, T = IsValid(target) and {target} or originalSteamID, V = sam.format_length( length ), V_2 = reason

            } )
		end)
    end)

:End()

command.new( "ungagid" )

    :SetPermission("ungagid", "admin")

    :AddArg( "steamid" )

    :Help( "ungag_help" )

    :OnExecute( function( ply, promise, isSilent )

		promise:done( function( data )

            local steamID, target = data[1], data[2]
            
            if ( not steamID ) then return end 

            local originalSteamID = steamID 

            if ( IsValid( target ) ) then 

                MPunishments:RemovePlayerPunishment( target, moduleName )

            else

                steamID = util.SteamIDTo64( steamID )

                MPunishments:RemoveOfflinePunishment( steamID, moduleName ) 

            end

            if ( isSilent ) then return end 
            
            sam.player.send_message( nil, "ungag", {
                A = ply, T = IsValid( target ) and { target } or originalSteamID
            } )

		end )
    end )
:End()

if SERVER then

    hook.Remove( "PlayerCanHearPlayersVoice", "SAM.Chat.Gag" )
    hook.Remove( "PlayerInitialSpawn", "SAM.Gag" )
    hook.Remove( "PlayerDisconnected", "SAM.Gag" )

    hook.Add( "PlayerCanHearPlayersVoice", "SAM.Chat.Gag", function(_, ply )

        if ( not IsValid( ply ) ) then return end 
        
        local canDo = MPunishments:CanDo( ply, moduleName ) 

        if ( canDo == false ) then // I prefer this on hooks rather than 'return canDo == false and false or nil'

            return false 
        end
        
    end )
end

