require( "memoize" )

local categoryName = "MUtils"
local moduleName = "damageban"

local messages = {

    ["punishment"] = "{A} Damage banned {T} for {V}.",
    
    ["punishmentHelp"] = "Prevents user from damaging other users.",

    ["removePunishment"] = "{A} Undamage banned {T}", 
    
    ["removePunishmentHelp"] = "Removes damage ban.",

}


if ( SERVER ) then
     
    local blacklistedWeapons = {

        "m9k", 
        "stunstick",
        "notgdeagle", 
        "clt_m4a4_asim", 
        "weapon_crowbar", 
        "weapon_cat", 
        "bb_dualelites_alt", 
        "m4a4_howl_original", 
        "clt_m4a4_asim", 
        "csgo_", 
        "awpdragon", 
        
    }
    
    local memoizeCache = {}
    
    local isDamageBanned = function( ply )

        return ( MPunishments:CanDo( ply, "damageban" ) == false ) and true 
    end

    local weaponIsBlacklisted = memoize( function( class )
    
        if ( not isstring( class ) or not istable( blacklistedWeapons ) ) then 

            return false 
        end 
        
        if ( #blacklistedWeapons <= 0 ) then 
            
            return false 
        end 
        
        for k = 1, #blacklistedWeapons do 
    
            local row = blacklistedWeapons[k]
            if ( not isstring( row ) ) then continue end 
    
            if ( ( class == row ) or string.StartsWith( class, row ) ) then 
    
                return true 
            end 
    
        end 
    
        return false

    end, memoizeCache )

    local canSwitchWeapon = function( ply, weaponClass )

        local playerDamageBanned = isDamageBanned( ply )
        if ( not playerDamageBanned ) then return end 
        
        local isBlacklisted = weaponIsBlacklisted( weaponClass )  

        return ( not isBlacklisted ) 
    end

    hook.Add( "PlayerSwitchWeapon", "MonkeyPunishments:DamageBan:StopTheSwitch", function(ply, _, newWeapon)
    
        if ( not IsValid( ply ) or not IsValid( newWeapon ) ) then return end 

        local weaponClass = newWeapon:GetClass()

        local canSwitch = canSwitchWeapon( ply, weaponClass )

        if ( canSwitch == false ) then 

            ply:SwitchToDefaultWeapon()

            return true 
        end 

    end )

end

  

sam.command.set_category( categoryName )

sam.command.new( moduleName )

    :SetCategory( categoryName )
    :SetPermission( moduleName, "admin" )

    :Aliases("dmgban")

    :AddArg( "player", { single_target = true }  )
    :AddArg( "length", { optional = true, default = 0, min = 0 } )

    :GetRestArgs( )

    :Help( messages["punishmentHelp"] )

    :OnExecute( function( ply, targets, length, isSilent )

        local newLength = length ~= 0 and os.time() + length * 60 or 0 

        local target = targets[1]
        if ( not IsValid( target ) ) then return end 

        MPunishments:AddPlayerPunishment( target, moduleName, newLength )
   
        target:SwitchToDefaultWeapon()

        if ( isSilent ) then return end 

        sam.player.send_message( nil, messages["punishment"], {
            A = ply, T = {target}, V = sam.format_length(length)
        } )
    end )
:End( )

sam.command.new( "un" .. moduleName )
    :SetCategory( categoryName )
    :SetPermission( "un" .. moduleName, "admin" )

    :Aliases("undmgban")

    :AddArg( "player" )
    :GetRestArgs( )

    :Help( messages["removePunishmentHelp"] )

    :OnExecute( function( ply, targets, isSilent )

        local target = targets[1]
        if ( not IsValid( target ) ) then return end 

        MPunishments:RemovePlayerPunishment( target, moduleName )
     
        if ( isSilent ) then return end 

        sam.player.send_message( nil, messages["removePunishment"], {
            A = ply, T = {target}
        } )
    end )
:End( )

sam.command.new( moduleName .. "id" )

    :SetPermission( moduleName .. "id", "admin" )

    :Aliases("dmgbanid")

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

            else

                steamID = util.SteamIDTo64( steamID )

                MPunishments:InsertOfflinePunishment( steamID, moduleName, newLength ) 

            
            end

            if ( isSilent ) then return end 

            sam.player.send_message( nil, messages["punishment"], {
                A = ply, T = IsValid(target) and {target} or originalSteamID, V = sam.format_length(length)
            } )

		end )
    end )
:End( )

sam.command.new( "un" .. moduleName .. "id" )

    :SetPermission( "un" .. moduleName .. "id", "admin" )

    :Aliases("undmgbanid")

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

hook.Add( "PlayerShouldTakeDamage", "MPunishment:StopPlayerDamage", function( ply, attacker )

    if not IsValid( attacker ) then return end 

    if ( not attacker:IsPlayer() ) then return end 

    local canDo = MPunishments:CanDo( attacker, moduleName )  

    if ( canDo == false ) then 

        return false 
    end

end )