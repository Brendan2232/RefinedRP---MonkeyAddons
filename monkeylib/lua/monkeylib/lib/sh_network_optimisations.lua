local accountBits = 32

MonkeyLib.WriteSteamID = function( steamID )

    local accountID = MonkeyLib.SteamIDToAccountID( steamID )

    net.WriteUInt( accountID, accountBits )

end

MonkeyLib.WriteSteamID64 = function( steamID64 )

    local steamID = util.SteamIDFrom64( steamID64 )

    MonkeyLib.WriteSteamID( steamID )

end

MonkeyLib.ReadSteamID = function()

    local accountID = net.ReadUInt( accountBits )

    return MonkeyLib.AccountIDToSteamID( accountID )
end

MonkeyLib.ReadSteamID64 = function()

    local accountID = net.ReadUInt( accountBits )

    return MonkeyLib.AccountIDToSteamID64( accountID )
end

