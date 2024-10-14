local aodJob = {
    ["Admin On Duty"] = true, 
}

local isAod = function( ply )

    return ply:IsJob( aodJob ) 
end

do  // Our Hooks 

    hook.Add( "PlayerNoClip", "MonkeyLib:AOD:AODNoclip", function(ply )

        if ( not IsValid( ply ) ) then return end 
    
        return isAod( ply ) or nil
    
    end )
    
    hook.Add( "PlayerChangedTeam", "MonkeyLib:AOD:StopNoClip", function(ply)
    
        if ( not IsValid( ply ) ) then return end 
    
        if ( ply:IsSuperAdmin() ) then return end 
    
        local moveType = ply:GetMoveType()
        if ( moveType ~= MOVETYPE_NOCLIP ) then return end 
    
        ply:SetMoveType( MOVETYPE_WALK )
      
    end )
    
    hook.Add( "EntityTakeDamage", "MonkeyLib:AOD:StopDamage", function(ply )
        
        if ( not IsValid( ply ) or not ply:IsPlayer() ) then return end 
        
        return isAod( ply ) or nil  
    end )
    
    hook.Add( "canArrest", "MonkeyLib:AOD:StopArrest", function(_, ply )
    
        if ( not IsValid( ply ) ) then return end 
    
        return ( not isAod( ply ) ) == true and nil   
    end )
    
    hook.Add( "CuffsCanHandcuff", "MonkeyLib:AOD:StopHandcuff", function(_, ply)
    
        if ( not IsValid( ply ) ) then return end 
    
        return ( not isAod( ply ) ) == true and nil
    end )
    
    hook.Add( "PlayerCanTaze", "MonkeyLib:AOD:StopTaze", function( _, ply )
    
        if ( not IsValid( ply ) ) then return end 
    
        return ( not isAod( ply ) ) == true and nil
    end )
    
end
