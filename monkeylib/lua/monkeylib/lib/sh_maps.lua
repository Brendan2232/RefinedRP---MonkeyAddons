local mapBits = 9 

MonkeyLib.MapCache = MonkeyLib.MapCache or {}

MonkeyLib.GetMaps = function()

    return MonkeyLib.MapCache 
end

if ( CLIENT ) then 

    net.Receive( "MonkeyLib:Maps:Put", function()
        
        local mapLen = net.ReadUInt( mapBits )

        for k = 1, mapLen do 

            local foundMap = net.ReadString()
            
            if ( not isstring( foundMap ) ) then 
                
                continue 
            end 

            local index = #MonkeyLib.MapCache + 1

            MonkeyLib.MapCache[index] = foundMap 
        end

        hook.Call( "MonkeyLib:Maps:Refreshed" )
    end )

    return 
end 

util.AddNetworkString( "MonkeyLib:Maps:Put" )

MonkeyLib.SortMaps = function() // Don't call this function often. 

    local sortedMaps = {}

    local foundMaps = file.Find( "maps/*.bsp", "GAME" )

    if ( istable( foundMaps ) and #foundMaps >= 1 ) then

        local mapFlags = MonkeyLib.MapFlags 

        for k = 1, #foundMaps do 

            local mapString = foundMaps[k]
            if ( not isstring( mapString ) ) then continue end 

            mapString = string.lower( mapString )
            mapString = string.sub( mapString, 1, -5 ) 

            local flag 

            for k = 1, #mapFlags do 
                local mapFlag = mapFlags[k]
                if ( not isstring( mapFlag ) ) then continue end 

                mapFlag = string.lower( mapFlag )

                local foundFlag = string.sub( mapString, 1, #mapFlag )
    
                if ( foundFlag ~= mapFlag ) then continue end // Could use a goto statement honestly. 

                flag = foundFlag

                break 
            end

            if ( not flag ) then continue end 
        
            local index = #sortedMaps + 1 
            
            sortedMaps[index] = mapString 
        end
    end

    return sortedMaps
end 

// These two endpoints below aren't used anymore. 

--[[
hook.Protect( "Initialize", "MonkeyLib:Maps:CacheMaps", function()

    MonkeyLib.MapCache = MonkeyLib.SortMaps()

end )

hook.Protect( "MonkeyLib:PlayerNetReady", "MonkeyLib:Maps:NetworkMaps", function ( ply )

    if ( not IsValid( ply ) ) then return end 

    local mapCache = MonkeyLib.MapCache

    net.Start( "MonkeyLib:Maps:Put" )

        net.WriteUInt( #mapCache, mapBits ) // Come the fuck on, when are we going to have more than 500 maps...
    
        for k = 1, #mapCache do 

            local mapString = mapCache[k]
            if ( not isstring( mapString ) ) then continue end 

            net.WriteString( mapString )
        end 
    
    net.Send( ply )
    
end )

]]



