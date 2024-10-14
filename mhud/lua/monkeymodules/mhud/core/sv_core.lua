local respawnTimerID = "MonkeyLib_RespawnTime"

util.AddNetworkString( "MonkeyLib:DeathScreen:SendDeath" )
util.AddNetworkString( "MonkeyHud:SafeZone:StateChanged" )

hook.Protect( "PlayerDeath", "MonkeyHud:DeathScreen:SendDeath", function( ply, _, attacker )

    if ( not IsValid( ply ) ) then return end

    local shouldShowDeathscreen = hook.Run( "MonkeyHud:DeathScreen:ShouldShow", ply )

    if ( shouldShowDeathscreen == false ) then 

        return 
    end

    ply[respawnTimerID] = CurTime() + MonkeyHud.Config.RespawnTime

    local wasSuicide = IsValid( attacker ) and ( attacker == ply ) 

    net.Start( "MonkeyLib:DeathScreen:SendDeath" )
        net.WriteBool( wasSuicide ) // Was it suicide??

        // If the players primary weapon isn't valid, I have no fucking clue on how they killed you haha.
        if ( not wasSuicide and ( IsValid( attacker ) and attacker:IsPlayer() ) and IsValid( attacker:GetActiveWeapon() ) ) then 

            net.WriteEntity( attacker )

        end
        
    net.Send( ply )

end )

hook.Add( "PlayerDeathThink", "MonkeyHud:DeathScreen:RespawnPlayer", function( ply )

    if ( not IsValid( ply ) ) then return end 

    local respawnTime = ply[respawnTimerID]
    if ( not isnumber( respawnTime ) ) then return end 

    if ( CurTime() < respawnTime ) then return false end 
        
    if ( not ply:Alive() ) then ply:Spawn() end 

    return nil    
end )

hook.Add( "PlayerExitArea", "MonkeyHud:SafeZone:PlayerLeft", function( ply )

    if ( not IsValid( ply ) ) then return end 
    
    net.Start( "MonkeyHud:SafeZone:StateChanged" )
        net.WriteBool( false )
    net.Send( ply )

end )

hook.Add( "PlayerChangedArea", "MonkeyHud:SafeZone:PlayerEnter", function( ply, area )

    if ( not IsValid( ply ) or not istable( area ) ) then return end 

    local isSafeZone = area.godmode or false  

    net.Start( "MonkeyHud:SafeZone:StateChanged" )
        net.WriteBool( isSafeZone )
    net.Send( ply )

end )

