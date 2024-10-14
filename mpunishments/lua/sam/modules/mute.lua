local moduleName = "mute"

local command = sam.command

command.set_category( "Chat" )

command.remove_command( "mute" )
command.remove_command( "unmute" )

command.remove_command( "pm" )

command.new( "mute" )
    :SetPermission( "mute", "admin" )

    :AddArg( "player", { single_target = true }  )
    :AddArg( "length", { optional = true, default = 0, min = 0 } )
    :AddArg( "text", { hint = "reason", optional = true, default = sam.language.get("default_reason") } ) 

    :GetRestArgs()

    :Help( "mute_help" )

    :OnExecute( function( ply, targets, length, reason, isSilent )

        local newLength = length ~= 0 and os.time() + length * 60 or 0 

        local target = targets[1]
        if ( not IsValid( target ) ) then return end 

        MPunishments:AddPlayerPunishment( target, moduleName, newLength )
   
        if ( isSilent ) then return end 

        sam.player.send_message( nil, "mute", {
            A = ply, T = { target }, V = sam.format_length( length ), V_2 = reason
        } )

    end )

:End()

command.new( "unmute" )

    :SetPermission( "unmute", "admin" )

    :AddArg( "player", { optional = true } )

    :Help( "unmute_help" )

    :OnExecute( function( ply, targets, isSilent )

        local target = targets[1]
        if ( not IsValid( target ) ) then return end 

        MPunishments:RemovePlayerPunishment( target, moduleName )
 
        if ( isSilent ) then return end 

        sam.player.send_message( nil, "unmute", {
            A = ply, T = {target}
        } )

    end )
:End()

command.new( "muteid" )

    :SetPermission( "muteid", "admin" )

	:AddArg( "steamid" )

    :AddArg( "length", { optional = true, default = 0, min = 0 } )

    :AddArg( "text", { hint = "reason", optional = true, default = sam.language.get( "default_reason" ) } )

    :GetRestArgs( )

    :Help( "mute_help" )

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

            sam.player.send_message(nil, "mute", {

                A = ply, T = IsValid( target ) and {target} or originalSteamID, V = sam.format_length(length), V_2 = reason

            })
		end)
    end)
:End()

command.new( "unmuteid" )

    :SetPermission( "unmuteid", "admin" )

    :AddArg( "steamid" )

    :Help( "unmute_help" )

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

            sam.player.send_message( nil, "unmute", {
                A = ply, T = IsValid(target) and {target} or originalSteamID
            } )
		end )
    end )
:End()

command.new( "pm" )
	:SetPermission( "pm", "user" )

	:AddArg( "player", {allow_higher_target = true, single_target = true, cant_target_self = true})
	:AddArg( "text", { hint = "message", check = function(str)
		return str:match("%S") ~= nil
	end } )

	:GetRestArgs()

	:Help("pm_help")

	:OnExecute(function(ply, targets, message)
		
        local canSpeak = MPunishments:CanDo( ply, moduleName )

        if ( canSpeak == false ) then 
            
			return ply:sam_send_message("you_muted")
		end

		local target = targets[1]

		ply:sam_send_message("pm_to", {
			T = targets, V = message
		})

		if ply ~= target then
			target:sam_send_message("pm_from", {
				A = ply, V = message
			})
		end
	end)
:End()

if SERVER then

    hook.Remove( "PlayerSay", "SAM.Chat.Mute" )
    
    sam.hook_first( "PlayerSay", "SAM.Chat.Mute", function( ply, text )

        if ( not IsValid( ply ) ) then return end

        if ( text:sub( 1, 1 ) == "!" and text:sub( 2, 2 ):match("%S") ~= nil ) then

            local args = sam.parse_args( text:sub( 2 ) )

            local cmd_name = args[1]
            if not cmd_name then return end

            local cmd = command.get_command( cmd_name )

            if cmd then return end  
        end

        local canSpeak = MPunishments:CanDo( ply, moduleName )

        if ( canSpeak == false ) then 

            return ""
        end

    end )
end

