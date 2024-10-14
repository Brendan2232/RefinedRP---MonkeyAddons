local defaultBailPrice = MBail.Config.DefaultBailPrice 

MBail.GetBail = function( bailIndex )

    return MBail.ArrestCache[bailIndex] or false 
end

MBail.AddBail = function( ply, arrestTime, bailPrice )

    if ( not IsValid( ply ) or not isnumber( arrestTime ) ) then 

        return 
    end

    if ( SERVER and ply:isArrested() ) then return end 

    local arrestedStructure = {

        ["arrestedPlayer"] = ply, 

        ["bailPrice"] = bailPrice or defaultBailPrice, 

        ["arrestTime"] = CurTime() + arrestTime, 
        
    }

    local cache = MBail.ArrestCache
    
    local index = #cache + 1 

    cache[index] = arrestedStructure
     
    if ( SERVER ) then 

        net.Start( "MonkeyBail:Bail:Send" )
            net.WriteEntity( ply )
            net.WriteUInt( arrestTime, 32 )
        net.Broadcast()

    end

    return arrestedStructure, index 
end

