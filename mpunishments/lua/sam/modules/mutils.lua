local command = sam.command 

MPunishments = MPunishments or {}

do  // Claim command 

    local messages = {
        ["ClaimsHelp"] = "Returns a staff members claims.", 
        ["claimsGet"] = "{V} Claims.",
    }

    sam.command.set_category( "Admin Claims" )

    sam.command.new( "claims" )

        :SetPermission( "claims", "admin" )

        :AddArg( "player", { optional = true , single_target = true  } )

        :GetRestArgs( )

        :Help( messages["ClaimsHelp"] )

        :OnExecute( function( ply, targets )

            local target = targets[1]
            if ( not IsValid( target ) ) then target = ply end 

            local steamID64 = target:SteamID64()

            local foundClaims = MonkeyLib.GetAdminClaimCount( steamID64 ) or 0

            sam.player.send_message( ply, messages["claimsGet"], {
                V = foundClaims,
            } )

        end )
    :End( )

end

sam.command.set_category( "MUtils" )

do // Remove Props command 

    local messages = {
        ["propRemove"] = "{A} Removed {T} props.", 
        ["propRemoveHelp"] = "Removes a players props.", 
    }

    local removedClasses = {
        
        "prop_physics", 
        "sammyservers_textscreen", 

        "bkeypad", 
        "keypad", 

        "gmod_button", 
        
    }
    
    MPunishments.RemoveProps = function( ply )

        if ( not IsValid( ply ) ) then return end 

        for k = 1, #removedClasses do 

            local className = removedClasses[k]
            if ( not isstring( className ) ) then continue end 

            local foundEnts = ents.FindByClass( className )
            if ( not istable( foundEnts ) ) then continue end 

            for i = 1, #foundEnts do 

                local ent = foundEnts[i]
                if ( not IsValid( ent ) ) then continue end 
        
                local entOwner = ent:CPPIGetOwner()
                if ( entOwner ~= ply ) then continue end 

                ent:Remove()

            end

        end 

    end

    local playerProps = MPunishments.RemoveProps

    sam.command.new( "removeprops" )

        :SetPermission( "removeprops", "admin" )

        :AddArg( "player", { single_target = true }  )

        :GetRestArgs( )

        :Help( messages["propRemoveHelp"] )

        :OnExecute( function( ply, targets, isSilent )

            local target = targets[1]
            if ( not IsValid( target ) ) then return end 

            if ( SERVER ) then 

                playerProps( target )

            end

            if ( isSilent ) then return end 

            sam.player.send_message( nil, messages["propRemove"], {
                A = ply, T = { target },
            } )

        end )
    :End( )

end

 
do 

    local messages = {
        ["unWantedHelp"] = "Sets a player as not wanted.", 
        ["unWanted"] = "{A} removed wanted from {T}", 

        ["unWarrantHelp"] = "Removes a players warrant.", 
        ["unWarrant"] = "{A} removed a warrant {T}", 
    }

    sam.command.new( "unwanted" )

        :Aliases( "unwant" )
        :Aliases( "removewanted" )
        :Aliases( "removewant" )

        :SetPermission( "unwanted", "admin" )

        :AddArg( "player" )

        :GetRestArgs( )

        :Help( messages["unWantedHelp"] )

        :OnExecute( function( ply, targets, isSilent )

            for k = 1, #targets do 

                local target = targets[k]

                if ( not IsValid( target ) ) then 

                    continue 
                end

                target:unWanted()
            end

            if ( isSilent ) then return end 

            sam.player.send_message( nil, messages["unWanted"], {
                A = ply, T = targets,
            } )

        end )
    :End( )

    sam.command.new( "unwarrant" )

        :Aliases( "removewarrant" )

        :SetPermission( "unwarrant", "admin" )

        :AddArg( "player" )

        :GetRestArgs( )

        :Help( messages["unWarrantHelp"] )

        :OnExecute( function( ply, targets, isSilent )

            for k = 1, #targets do 

                local target = targets[k]

                if ( not IsValid( target ) ) then 

                    continue 
                end

                target:unWarrant()
            end

            if ( isSilent ) then return end 

            sam.player.send_message( nil, messages["unWarrant"], {
                A = ply, T = targets,
            } )

        end )
    :End( )

end

do // Uncuff 

    local messages = {
        ["uncuffHelp"] = "Removes a targeted players handcuffs.", 
        ["uncuff"] = "{A} uncuffed {T}", 
    }

    sam.command.new( "uncuff" )

        :Aliases( "removecuffs" )

        :SetPermission( "uncuff", "admin" )

        :AddArg( "player" )

        :GetRestArgs( )

        :Help( messages["uncuffHelp"] )

        :OnExecute( function( ply, targets, isSilent )

            for k = 1, #targets do 

                local target = targets[k]

                if ( not IsValid( target ) ) then 

                    continue 
                end

                local _, foundCuffs = target:IsHandcuffed()

                if ( not IsValid( foundCuffs ) ) then 
                    
                    continue  
                end
                
                foundCuffs:Uncuff()
                
            end

            if ( isSilent ) then return end 

            sam.player.send_message( nil, messages["uncuff"], {
                A = ply, T = targets,
            } )

        end )
    :End( )

end

do

    local messages = {
        ["shadowBanned"] = "{A} Shadow Banned {T} for {V}.", 
        ["shadowBanHelp"] = "Bans a user from most server features.", 
        ["unShadowBanHelp"] = "Unshaowbans a user.", 
        ["unShadowBan"] = "{A} Un Shadow Banned {T}",
    }

    local resetPlayerVars = function( ply )

        local runSpeed = ply:GetWalkSpeed() * .75

        ply:StripWeapons()

        do 

            ply:SetMaxSpeed( runSpeed )

            ply:SetRunSpeed( runSpeed )
    
            ply:SetWalkSpeed( runSpeed )

            ply:SetJumpPower( 0 )

        end

    end

    local isShadowBanned = function( ply )

        return ( MPunishments:CanDo( ply, "shadowbanned" ) == false ) and true or nil 
    end
    
    local shadowBanUser = function( ply, time )

        if ( not IsValid( ply ) or not isnumber( time ) ) then 

            return 
        end

        do // Sell their doors / remove their props!

            MPunishments.RemoveProps( ply )
        
            ply:keysUnOwnAll()

        end
        
        do // Change their team! 
            
            local defaultTeam = GAMEMODE.DefaultTeam 

            ply:changeTeam( defaultTeam, true )

        end

        do 

            resetPlayerVars( ply )

        end

        MPunishments:AddPlayerPunishment( ply, "shadowbanned", time )
    end

    local unShadowBanUser = function( ply )

        if ( not IsValid( ply ) ) then 

            return 
        end

        MPunishments:RemovePlayerPunishment( ply, "shadowbanned" )

    end
    
    sam.command.new( "shadowban" )

        :SetPermission( "shadowban", "admin" )

        :AddArg( "player", { single_target = true } )
        :AddArg( "length", { optional = true, default = 1, min = 1 } )

        :GetRestArgs( )

        :Help( messages["shadowBanHelp"] )

        :OnExecute( function( ply, targets, length, isSilent )

            local newLength = length ~= 0 and os.time() + length * 60 or 0 

            local target = targets[1]
            if ( not IsValid( target ) ) then return end 

            shadowBanUser( target, newLength )

            if ( isSilent ) then return end 

            sam.player.send_message( nil, messages["shadowBanned"], {
                A = ply, T = { target }, V = sam.format_length( length ) 
            } )

        end )
    :End( )

    sam.command.new( "unshadowban" )

        :SetPermission( "unshadowban", "admin" )

        :AddArg( "player", { single_target = true } )

        :GetRestArgs( )

        :Help( messages["unShadowBanHelp"] )

        :OnExecute( function( ply, targets, isSilent )

            local target = targets[1]
            if ( not IsValid( target ) ) then return end 

            unShadowBanUser( target )

            if ( isSilent ) then return end 

            sam.player.send_message( nil, messages["unShadowBan"], {
                A = ply, T = { target }
            } )

        end )
    :End( )

    local moduleName = "shadowbanned"

    command.new( "shadowbanid" )

        :SetPermission( "shadowbanid", "admin" )

        :AddArg( "steamid" )

        :AddArg( "length", { optional = true, default = 0, min = 0 } )

        :AddArg( "text", { hint = "reason", optional = true, default = sam.language.get( "default_reason" ) } )

        :GetRestArgs( )

        :Help( messages["shadowBanHelp"]  )

        :OnExecute( function( ply, promise, length, reason, isSilent )

            local newLength = length ~= 0 and os.time() + length * 60 or 0 

            promise:done( function( data )

                local steamID, target = data[1], data[2]
                if ( not steamID ) then return end 

                local originalSteamID = steamID 

                if ( IsValid( target ) ) then 
        
                    shadowBanUser( target, newLength )

                else

                    steamID = util.SteamIDTo64( steamID )

                    MPunishments:InsertOfflinePunishment( steamID, moduleName, newLength ) 

                end

                if ( isSilent ) then return end 

                sam.player.send_message(nil, messages["shadowBanned"], {

                    A = ply, T = IsValid( target ) and {target} or originalSteamID, V = sam.format_length(length), V_2 = reason

                })
            end)
        end)
    :End()

    command.new( "unshadowbanid" )

        :SetPermission( "unshadowbanid", "admin" )

        :AddArg( "steamid" )

        :Help( messages["unShadowBanHelp"]  )

        :OnExecute( function( ply, promise, isSilent )

            promise:done( function( data )

                local steamID, target = data[1], data[2]
                
                if ( not steamID ) then return end 

                local originalSteamID = steamID 

                if ( IsValid( target ) ) then 

                    unShadowBanUser( target )

                else

                    steamID = util.SteamIDTo64( steamID )

                    MPunishments:RemoveOfflinePunishment( steamID, moduleName ) 

                end

                if ( isSilent ) then return end 

                sam.player.send_message( nil, messages["unShadowBan"], {
                    A = ply, T = IsValid(target) and {target} or originalSteamID
                } )
            end )
        end )
    :End()

    local canUse = function( ply )

        if ( not IsValid( ply ) ) then 

            return 
        end

        local isBanned = isShadowBanned( ply ) or nil 
        
        if ( isBanned ) then 

            return false  
        end
    
    end

    if ( SERVER ) then 

        do 
    
            local utils = {

                "CanPlayerEnterVehicle", 

                "OnPlayerSit", 
                "playerCanChangeTeam", 

                "PlayerUse", 
                "PlayerCanPickupWeapon", 

                "MonkeyLib:CanGiveWeapon", 
                
            }
    
            local utilTag = "MonkeyPunishments:ShadowBan:UtilRunner:%s"
    
            for k = 1, #utils do 
    
                local utilString = utils[k] or ""
    
                local hookID = utilTag:format( utilString )
    
                sam.hook_first( utilString, hookID, canUse )
                
            end
    
        end
    
        hook.Protect( "OnEntityWaterLevelChanged", "MonkeyLib:ShadowBan:StopTheSwim", function( ply, old, new )
        
            if ( not IsValid( ply ) or not ply:IsPlayer() ) then 
    
                return 
            end
    
            local isBanned = isShadowBanned( ply )
    
            if ( new > 1 and isBanned and ply:Alive() ) then 
    
                ply:Kill()
    
            end
            
        end )

    end
    
    local ticketBanTag = "ticketbanned"

    do 

        local messages = {

            ["ticketBan"] = "{A} Ticket banned {T} for {V}.", 
            ["unTicketBan"] = "{A} Un-Ticket Banned {T}",

            ["ticketBanHelp"] = "Stops a user from creating tickets.", 
            ["unTicketBanHelp"] = "Unticket bans a user.", 

        }

        sam.command.new( "ticketban" )

            :SetPermission( "ticketban", "admin" )

            :AddArg( "player", { single_target = true } )
            :AddArg( "length", { optional = false } )

            :GetRestArgs( )

            :Help( messages["ticketBanHelp"] )

            :OnExecute( function( ply, targets, length, isSilent )

                local newLength = length ~= 0 and os.time() + length * 60 or 0 

                local target = targets[1]
                if ( not IsValid( target ) ) then return end 

                MPunishments:AddPlayerPunishment( target, ticketBanTag, newLength )

                if ( isSilent ) then return end 

                sam.player.send_message( nil, messages["ticketBan"], {
                    A = ply, T = { target }, V = sam.format_length( length ) 
                } )

            end )
        :End( )

        sam.command.new( "unticketban" )

            :SetPermission( "unticketban", "admin" )

            :AddArg( "player", { single_target = true } )

            :GetRestArgs( )

            :Help( messages["unTicketBanHelp"] )

            :OnExecute( function( ply, targets, length, isSilent )

                local target = targets[1]
                if ( not IsValid( target ) ) then return end 

                MPunishments:RemovePlayerPunishment( target, ticketBanTag )

                if ( isSilent ) then return end 

                sam.player.send_message( nil, messages["unTicketBan"], {
                    A = ply, T = { target }
                } )

            end )
        :End( )

    end

    if ( SERVER ) then 

        local oldLoadoutFunc

        GLOBAL_SAM_OLD_TICKET = function() end 

        local loadoutFunc = function( s, ply )

            if ( not IsValid( ply ) ) then 

                return 
            end 

            assert( isfunction( oldLoadoutFunc ), "Old Loadout function doesn't exists!!!!" )

            oldLoadoutFunc( s, ply )

            local shouldResetVars = isShadowBanned( ply )

            if ( not shouldResetVars ) then 
    
                return 
            end
    
            resetPlayerVars( ply )

        end

        local oldReportFunc  
        
        local reportPlayer = function( ply, message )

            if ( not IsValid( ply ) or not isstring( message ) ) then 

                return 
            end 
            
            assert( isfunction( oldReportFunc ), "Old Report function doesn't exist!!!" )

            local canDo = canUse( ply ) or MPunishments:CanDo( ply, ticketBanTag ) 

            if ( canDo == false ) then 

                sam.player.send_message( ply, "You've been banned from making reports!" )
        
                return false 
            end

            return oldReportFunc( ply, message )
        end 

        hook.Protect( "OnGamemodeLoaded", "MonkeyPunishments:ShadowBan:StopTheWeapons", function()

            oldLoadoutFunc = GAMEMODE.PlayerLoadout

            GAMEMODE.PlayerLoadout = loadoutFunc
    
        end )

        hook.Protect( "Initialize", "MonkeyPunishments:ShadowBan:StopTheReport", function()
        
            oldReportFunc = sam.player.report

            GLOBAL_SAM_OLD_TICKET = oldReportFunc

            sam.player.report = reportPlayer

        end )

    end

end 


