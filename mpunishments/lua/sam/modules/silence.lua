local categoryName = "Chat"
local moduleName = "silence"

local messages = {

    ["punishment"] = "{A} Silenced {T} for {V}.",
    ["punishmentHelp"] = "Mutes and gags a player.",

    ["removePunishment"] = "{A} Un Silenced {T}.", 
    ["removePunishmentHelp"] = "Removes a mute and gag.",

    ["punishmentTimeLeft"] = "You're Silenced for {V}."
}

sam.command.set_category( categoryName )

sam.command.new( moduleName )

    :SetCategory( categoryName )
    :SetPermission( moduleName, "admin" )

    :AddArg( "player", { single_target = true }  )
    :AddArg( "length", { optional = true, default = 0, min = 0 } )

    :GetRestArgs( )

    :Help( messages["punishmentHelp"] )

    :OnExecute( function( ply, targets, length, isSilent )

        local newLength = length ~= 0 and os.time() + length * 60 or 0 
           
        local target = targets[1]
        if ( not IsValid( target ) ) then return end 

        MPunishments:AddPlayerPunishment( target, "mute", newLength )
        MPunishments:AddPlayerPunishment( target, "gag", newLength )

        if ( isSilent ) then return end 

        sam.player.send_message( nil, messages["punishment"], {
            A = ply, T = { target }, V = sam.format_length( length )
        } )

    end )
:End( )

sam.command.new( "un" .. moduleName )

    :SetCategory( categoryName )
    :SetPermission( "un" .. moduleName, "admin" )

    :AddArg( "player" )
    :GetRestArgs( )

    :Help( messages["removePunishmentHelp"] )

    :OnExecute( function( ply, targets, isSilent )

        local target = targets[1]
        if ( not IsValid( target ) ) then return end 

        MPunishments:RemovePlayerPunishment( target, "mute" )
        MPunishments:RemovePlayerPunishment( target, "gag" )
 
        if ( isSilent ) then return end 

        sam.player.send_message( nil, messages["removePunishment"], {
            A = ply, T = { target }
        } )

    end )

:End()

sam.command.new( moduleName .. "id" )

    :SetPermission(  moduleName .. "id", "admin" )

	:AddArg( "steamid" )

    :AddArg( "length", { optional = true, default = 0, min = 0 } )

    :AddArg( "text", { hint = "reason", optional = true, default = sam.language.get( "default_reason" ) } )

    :GetRestArgs( )

    :Help( messages["punishmentHelp"] )

    :OnExecute( function( ply, promise, length, reason, isSilent )

        local newLength = length ~= 0 and os.time() + length * 60 or 0 

		promise:done( function( data )

            local steamID, target = data[1], data[2]
            if ( not steamID ) then return end 

            local originalSteamID = steamID 

            if ( IsValid( target ) ) then
    
                MPunishments:AddPlayerPunishment( target, "mute", newLength )
                MPunishments:AddPlayerPunishment( target, "gag", newLength )

            else

                steamID = util.SteamIDTo64( steamID )

                MPunishments:InsertOfflinePunishment( steamID, "mute", newLength ) 
                MPunishments:InsertOfflinePunishment( steamID, "gag", newLength ) 

            end
            
            if ( isSilent ) then return end 

            sam.player.send_message( nil, messages["punishment"], {
                A = ply, T = IsValid( target ) and { target } or steamID, V = sam.format_length( length )
            } )

		end )
    end )
:End( )

sam.command.new( "un" .. moduleName .. "id" )

    :SetPermission(  "un" .. moduleName .. "id", "admin" )

    :AddArg( "steamid" )

    :Help( messages["removePunishmentHelp"] )

    :OnExecute( function( ply, promise, isSilent )

		promise:done( function( data )

            local steamID, target = data[1], data[2]
            
            if ( not steamID ) then return end 

            local originalSteamID = steamID 

            if ( IsValid( target ) ) then 

                MPunishments:RemovePlayerPunishment( target, "mute" )
                MPunishments:RemovePlayerPunishment( target, "gag" )

            else

                steamID = util.SteamIDTo64( steamID )

                MPunishments:RemoveOfflinePunishment( steamID, "mute" ) 
                MPunishments:RemoveOfflinePunishment( steamID, "gag" ) 

            end

            if ( isSilent ) then return end 

            sam.player.send_message( nil, messages["removePunishment"], {
                A = ply, T = IsValid( target ) and { target } or steamID
            } )
		end )
    end )
:End()
