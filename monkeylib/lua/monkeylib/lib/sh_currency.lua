MonkeyLib.CanAfford = function( ply, amount )

    if ( not IsValid( ply ) or not isnumber( amount ) ) then 
        
        return false 
    end 
    
    return ply:canAfford( amount )
end

MonkeyLib.GetMoney = function( ply )

    if ( not IsValid( ply ) ) then 
        
        return 0 
    end 
    
    return ply:getDarkRPVar( "money" )
end

MonkeyLib.FormatMoney = function( amount )

    return "$" .. string.Comma( amount or 0, "," )
end

if ( CLIENT ) then return end 

MonkeyLib.SetMoney = function( ply, amount )

    assert( IsValid( ply ), "Failed to set money, player isn't valid!" )

    assert( isnumber( amount ), "Failed to set money, amount isn't a number!" )

    ply:setMoney( amount )
end

MonkeyLib.AddMoney = function( ply, amount )

    assert( IsValid( ply ), "Failed to add money, player isn't valid!" )

    assert( isnumber( amount ), "Failed to add money, amount isn't a number!" )

    ply:addMoney( amount )
end
