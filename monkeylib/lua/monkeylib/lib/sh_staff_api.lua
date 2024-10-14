require( "memoize" )

local isStaff = function( ply )

    if ( not IsValid( ply ) ) then  

        return   
    end

    return ply:HasPermission( "see_admin_chat" )
end

MonkeyLib.GetOnlineStaff = memoize( function()

    local players = player.GetAll() or {}

    local playersLen = #players 

    if ( playersLen <= 0 ) then  

        return {}
    end

    local staff = {}

    for k = 1, playersLen do 

        local ply = players[ k ]

        if ( not IsValid( ply ) ) then 

            continue 
        end 

        local playerIsStaff = isStaff( ply )

        if ( not playerIsStaff ) then 

            continue 
        end 
                   
        table.insert( staff, ply )

    end

    return staff
    
end, {}, 5 )