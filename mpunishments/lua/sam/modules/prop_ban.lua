local categoryName = "MUtils"
local moduleName = "propban"

local messages = {

    ["punishment"] = "{A} propbanned {T} for {V}.",
    ["punishmentHelp"] = "Stops players from spawning entities and props.",

    ["removePunishment"] = "{A} Un propbanned {T}.", 
    ["removePunishmentHelp"] = "Removes propban.",

    ["punishmentTimeLeft"] = "You're propbanned for {V}."
}

sam.command.set_category( "MUtils" )

sam.command.new( moduleName )

    :SetPermission( moduleName, "admin" )

    :AddArg( "player", { single_target = true }  )
    :AddArg( "length", { optional = true, default = 0, min = 0 } )

    :GetRestArgs( )

    :Help( messages["punishmentHelp"] )

    :OnExecute( function( ply, targets, length, isSilent )

        local newLength = length ~= 0 and os.time() + length * 60 or 0 
           
        local target = targets[1]
        if ( not IsValid( target ) ) then return end 

        MPunishments:AddPlayerPunishment( target, moduleName, newLength )

        MPunishments.RemoveProps( target )

        if ( isSilent ) then return end 

        sam.player.send_message( nil, messages["punishment"], {
            A = ply, T = { target }, V = sam.format_length( length )
        } )

    end )
:End( )

sam.command.new( "un" .. moduleName )

    :SetPermission( "un" .. moduleName, "admin" )

    :AddArg( "player", { single_target = true }  )
    :GetRestArgs( )

    :Help( messages["removePunishmentHelp"] )

    :OnExecute( function( ply, targets, isSilent )

        local target = targets[1]
        if ( not IsValid( target ) ) then return end 

        MPunishments:RemovePlayerPunishment( target, moduleName )

        if ( isSilent ) then return end 
 
        sam.player.send_message( nil, messages["removePunishment"], {
            A = ply, T = { target }
        } )

    end )

:End()

sam.command.new( moduleName .. "id" )

    :SetPermission( moduleName .. "id", "admin" )

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
    
                MPunishments:AddPlayerPunishment( target, moduleName, newLength )

                MPunishments.RemoveProps( target )
                
            else

                steamID = util.SteamIDTo64( steamID )

                MPunishments:InsertOfflinePunishment( steamID, moduleName, newLength ) 

            end

            if ( isSilent ) then return end 

            sam.player.send_message( nil, messages["punishment"], {
                A = ply, T = IsValid( target ) and { target } or originalSteamID, V = sam.format_length(length)
            } )

		end )
    end )
:End( )

sam.command.new( "un" .. moduleName .. "id" )

    :SetPermission( "un" .. moduleName .. "id", "admin" )

    :AddArg( "steamid" )

    :Help( messages["removePunishmentHelp"] )

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

            sam.player.send_message( nil, messages["removePunishment"], {
                A = ply, T = IsValid( target ) and { target } or originalSteamID
            } )

		end )
    end )
:End()


if ( SERVER ) then

    sam.hook_first( "PlayerSpawnProp", "MPunishments:PropBan:StopPropSpawning", function(ply)
    
        local canDo = MPunishments:CanDo( ply, moduleName ) 

        if ( canDo == false ) then 

            return false 
        end
    end )
    

    sam.hook_first( "PlayerSpawnObject", "MPunishments:PropBan:StopSpawningRandomCrap", function( ply )
    
        local canDo = MPunishments:CanDo( ply, moduleName ) 

        if ( canDo == false ) then 

            return false 
        end
        
    end )

    sam.hook_first( "CanTool", "MPunishments:PropBan:StopSpawningToolgun", function( ply, _, toolName )
    
        toolName = string.lower( toolName )
        
        if ( not MPunishments.BlacklistedTools[toolName] ) then return end 
    
        local canDo = MPunishments:CanDo( ply, moduleName )

        if ( canDo == false ) then 

            return false 
        end

    end )
    
end
