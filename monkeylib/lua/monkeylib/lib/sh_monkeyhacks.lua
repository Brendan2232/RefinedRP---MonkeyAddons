if ( CLIENT ) then // Stops drawing accessories when spectating someone 

    local oldAccessoryFunc = function() end 

    local getSpectatorEnt = function()

        if ( not istable( FSpectate ) ) then 

            return nil 
        end

        local ent = FSpectate.getSpecEnt()

        return ( IsValid( ent ) and ent ) or nil  
    end

    local overLoadFunc = function()

        if ( not istable( SH_ACC ) or not istable( FSpectate ) ) then 

            return 
        end 

        local accessoryFunc = SH_ACC.DrawAccessories
        
        assert( isfunction( accessoryFunc ), "Failed to overload accessory draw function!" )
        
        oldAccessoryFunc = accessoryFunc 
        
        SH_ACC.DrawAccessories = function( ... )

            local spectatorEnt = getSpectatorEnt()

            if ( IsValid( spectatorEnt ) ) then 

                return 
            end

            return oldAccessoryFunc( ... )
        end 

    end

    hook.Protect( "Initialize", "MonkeyLib:MonkeyHacks:StopSpectateAccessories", overLoadFunc ) 
    
end

do  // PD Unarrest Distance 

    local netUtil = "MonkeyLib:MonkeyHacks:PDUnarrest"

    local wantReason = "Escaped Prison!"

    local maxDistance = 1400

    maxDistance = ( maxDistance * maxDistance ) // Don't modify this here! 

    local PDVec = Vector( -2437, 742, -160 )

    local playerOutOfRange = memoize( function( ply )

        if ( not IsValid( ply ) ) then 
            
            return 
        end

        local playerPos = ply:GetPos() or Vector()

        return ( playerPos:DistToSqr( PDVec ) > maxDistance )
        
    end, {}, .5 )
    
    if ( SERVER ) then 

        util.AddNetworkString( netUtil )

        local handleUnarrest = function( ply )

            if ( not IsValid( ply ) or not ply:isArrested() ) then 
            
                return 
            end 

            local isOutOfRange = playerOutOfRange( ply )

            if ( not isOutOfRange ) then
                
                return 
            end

            local playerPos = ply:GetPos()

            ply:unArrest( nil, playerPos )

            ply:wanted( nil, wantReason )

        end 

        net.Receive( netUtil, function( l, ply ) 
        
            if ( not IsValid( ply ) ) then

                return 
            end

            handleUnarrest( ply )
        
        end )

        return 
    end
        
    local ply = LocalPlayer()
    
    local cooldown = 0 

    local sendCooldown = .5 

    hook.Add( "Think", "MonkeyLib:MonkeyHacks:CheckArrestPos", function()
    
        if ( not IsValid( ply ) or not ply:isArrested() ) then 

            return 
        end
        
        local isOutOfRange = playerOutOfRange( ply )

        if ( not isOutOfRange ) then 

            return 
        end

        if ( ( CurTime() - cooldown ) < sendCooldown ) then 
            
            return 
        end 

        do // Tell the server! 

            net.Start( netUtil )

            net.SendToServer()
    
        end

        cooldown = CurTime()

    end )
    
    hook.Add( "InitPostEntity", "MonkeyLib:MonkeyHacks:InitPlayer", function()
        
        ply = LocalPlayer()

    end )

end