MonkeyFlips.Flips = MonkeyFlips.Flips or {}

MonkeyFlips.GetFlips = function()

    return MonkeyFlips.Flips 
end

local function addFlip( flipID, steamID64, price )

    if ( not isnumber( flipID ) or not MonkeyLib.isSteamID64( steamID64 ) or not isnumber( price ) ) then return end 

    local constructedFlip = {
        ["flipID"] = flipID,
        ["steamID64"] = steamID64, 
        ["price"] = price, 
    }

    local flipIndex = #MonkeyFlips.Flips + 1 

    MonkeyFlips.Flips[flipIndex] = constructedFlip

    hook.Run( "MonkeyFlips:FlipCreated", flipIndex, constructedFlip )
end

local function removeFlip( id )

    local flips = MonkeyFlips.GetFlips()

    for k = 1, #flips do 

        local flipRow = flips[k]
        if ( not istable( flipRow ) ) then continue end 

        local flipID = flipRow.flipID
        if ( flipID ~= id ) then continue end 

        table.remove( MonkeyFlips.Flips, k )

        hook.Run( "MonkeyFlips:FlipDeleted", k, flipRow )

        break 
    end 
end

MonkeyNet.ReadStructure( "MonkeyFlips:Send:CreateFlip", MonkeyFlips.NetStructure.SendCreatedFlip, function ( ply, flipID, price )
    
    if ( not IsValid( ply ) or not isnumber( flipID ) or not isnumber( price ) ) then return end 
    
    local steamID64 = ply:SteamID64()

    addFlip( flipID, steamID64, price )

end )

MonkeyNet.ReadStructure( "MonkeyFlips:Send:DeleteFlip", MonkeyFlips.NetStructure.DeleteFlip, function ( flipID )
    
    if ( not isnumber( flipID ) ) then return end 
 
    removeFlip( flipID )
    
end )

hook.Add( "Initialize", "MonkeyFlips:Init:LoadIcons", function()

    MonkeyLib:LoadIcons( MonkeyFlips.Icons )
    
end )

net.Receive( "MonkeyFlips:Send:AllFlips", function()

    local flipAmount = net.ReadUInt( 11 )

    for k = 1, flipAmount do 

        local flipID, steamID64, flipPrice = net.ReadUInt(32), MonkeyLib.ReadSteamID64(), net.ReadUInt( 32 )

        addFlip( flipID, steamID64, flipPrice )

    end
    
end )