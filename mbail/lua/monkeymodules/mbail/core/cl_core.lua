net.Receive( "MonkeyBail:Bail:Send", function()

    local arrestedPlayer = net.ReadEntity()
    local arrestedTime = net.ReadUInt( 32 )
    
    local arrestedStructure = MBail.AddBail( arrestedPlayer, arrestedTime )

    hook.Run( "MonkeyBail:GUI:Add", arrestedStructure  )

end )

net.Receive( "MonkeyBail:Bail:Remove", function()

    local bailIndex = net.ReadUInt( 8 )

    local foundBail = MBail.GetBail( bailIndex )
    if ( not istable( foundBail ) ) then return end 

    hook.Run( "MonkeyBail:GUI:Remove", bailIndex )
        
    table.remove( MBail.ArrestCache, bailIndex )

end )

net.Receive( "MonkeyBail:Bail:Set", function()

    local bailIndex = net.ReadUInt( 8 )
    local newPrice = net.ReadUInt( 32 )

    local foundBail = MBail.GetBail( bailIndex )
    if ( not istable( foundBail ) ) then return end 

    foundBail.bailPrice = newPrice 
    
    do  // Time to refresh the GUI!!!

        hook.Run( "MonkeyBail:GUI:UpdateBail", bailIndex ) // I love being a hack 

    end
    
end )

net.Receive( "MonkeyBail:Bail:SendBails", function()

    local readAmount = net.ReadUInt( 8 ) 

    for k = 1, readAmount do 

        local arrestedPlayer = net.ReadEntity()
        if ( not IsValid( arrestedPlayer ) ) then continue end 

        local arrestTime, bailPrice = net.ReadUInt( 32 ), net.ReadUInt( 32 )

        MBail.AddBail( arrestedPlayer, arrestTime, bailPrice )

    end
end )
