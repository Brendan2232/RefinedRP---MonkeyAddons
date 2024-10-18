// This system needs re-working.

local entityRemoveHandler = MonkeyLib.EntityRemoveHandler

MonkeyLib.PlayerEntities = MonkeyLib.PlayerEntities or {}

local getStack = function( ply )

    return MonkeyLib.PlayerEntities[ply] or {}
end

local getEntityCache = function( ent )

    if ( not IsValid( ent ) ) then return end 

    local entBase, entClass = ent.Base or "", ent:GetClass()

    local foundEntCache = ( entityRemoveHandler[entBase] or entityRemoveHandler[entClass] )

    return foundEntCache 
end 

local shouldRemoveEnt = function( ply, ent, teamOverright )

    if ( not IsValid( ply ) or not IsValid( ent ) ) then 

        return false 
    end

    local entBase, entClass = ent.Base or "", ent:GetClass()

    local foundEntCache = getEntityCache( ent )

    if ( not foundEntCache ) then 
        
        return false 
    end 

    return not ( ply:IsJob( foundEntCache, teamOverright ) or ply:IsTeamCategory( foundEntCache, teamOverright ) )  
end

local getEntity = function( ply, ent )

    if ( not IsValid( ply ) or not IsValid( ent ) ) then return end 

    local foundStack = getStack( ply )

    return foundStack[ent]
end

local stackEntity = function( ply, ent )

    if ( not IsValid( ply ) or not IsValid( ent ) ) then return end 
    
    if ( not getEntityCache( ent ) ) then return end // So we don't sink the servers ram. 

    MonkeyLib.PlayerEntities[ply] = MonkeyLib.PlayerEntities[ply] or {}
    
    MonkeyLib.PlayerEntities[ply][ent] = true 
end

local removeEntityStack = function( ply, ent )

    if ( not IsValid( ply ) or not IsValid( ent ) ) then return end 

    local foundStack = getStack( ply )

    foundStack[ent] = nil 
end

local appendPlayerEntities = function( ply, teamOverright )

    if ( not IsValid( ply ) ) then return end 

    local foundEntities = getStack( ply )  

    for ent, _ in pairs( foundEntities ) do 

        if ( not IsValid( ent ) ) then

            foundEntities[ent] = nil 

            continue 
        end

        local removeEnt = shouldRemoveEnt( ply, ent, teamOverright )
        
        if ( not removeEnt ) then

            continue 
        end

        ent:Remove()
        
        foundEntities[ent] = nil // to garbage collection!!
    end

end 

hook.Protect( "playerBoughtCustomEntity", "MonkeyLib:MonkeyHacks:SharedEntities", function( ply, _, ent )
    
    if ( not IsValid( ply ) or not IsValid( ent ) ) then return end 

    stackEntity( ply, ent )

end )

hook.Protect( "PlayerChangedTeam", "MonkeyLib:MonkeyHacks:CheckEntTeamHash", function( ply, _, newTeam )

    if ( not IsValid( ply ) or not isnumber( newTeam ) ) then return end 

    appendPlayerEntities( ply, newTeam )

end )

hook.Protect( "onPocketItemAdded", "MonkeyLib:MonkeyHacks:RemovePocketEnt", function( ply, ent )

    if ( not IsValid( ply ) or not IsValid( ent ) ) then return end 
    
    local entOwner = ent:CPPIGetOwner()

    if ( not IsValid( entOwner )  ) then 
        
       // ent:Remove()

        return 
    end

    removeEntityStack( entOwner, ent )

end )

hook.Protect( "onPocketItemDropped", "MonkeyLib:MonkeyHacks:ReHashPocketItem", function( ply, ent, _, item )

    if ( not IsValid( ply ) or not IsValid( ent ) ) then return end 

    local dataTable = item.DT 

    if ( not istable( dataTable ) ) then 
        
       // ent:Remove() 

        return 
    end  
        
    local foundOwner = dataTable.owning_ent

    if ( not IsValid( foundOwner ) ) then 
        
        //ent:Remove()

        return 
    end 

    stackEntity( foundOwner, ent )

end )

