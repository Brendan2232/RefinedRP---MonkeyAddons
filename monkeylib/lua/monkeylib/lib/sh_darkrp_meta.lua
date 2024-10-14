local PLAYER = FindMetaTable( "Player" )

local checkTeam = function( ply, categoryTable, teamOverright )

    if ( not IsValid( ply ) or not categoryTable ) then 

        return false 
    end 
    
    local playerTeam = isnumber( teamOverright ) and teamOverright or ply:Team() // For hooks that don't have ply:Team() set yet! 

    local foundTeam = RPExtraTeams[playerTeam]

    if ( not istable( foundTeam ) ) then 

        return false 
    end 

    local teamCategory = foundTeam.category or ""
    
    return ( ( istable( categoryTable ) and categoryTable[teamCategory] ) or ( teamCategory == categoryTable ) ) or false 
end 

local checkJob = function( ply, jobTable, teamOverright )

    if ( not IsValid( ply ) or not jobTable ) then

        return false 
    end

    local playerTeam = isnumber( teamOverright ) and teamOverright or ply:Team() // For hooks that don't have ply:Team() set yet! 

    local jobName = team.GetName( playerTeam ) 

    if ( not isstring( jobName ) ) then

        return false 
    end

    if ( istable( jobTable ) ) then 

        return ( jobTable[playerTeam] or jobTable[jobName] ) or false 
    end 

    return ( playerTeam == jobTable or jobName == jobTable ) or false 
end

function PLAYER:IsJob( jobTable, teamOverright )

    local ply = self 

    return checkJob( ply, jobTable, teamOverright )
end

function PLAYER:IsTeamCategory( categoryTable, teamOverright )

    local ply = self 

    return checkTeam( ply, categoryTable, teamOverright )
end 

function PLAYER:IsCriminal()

    local ply = self 

    return checkTeam( ply, "Criminals" )
end

function PLAYER:IsCitizen()

    local ply = self 
    
    return checkTeam( ply, "Citizens" )
end


