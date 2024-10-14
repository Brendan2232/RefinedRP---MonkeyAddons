return {
    groupName = "SteamID / AccountID Converter",

    cases = {
        {
            name = "Convert a SteamID to an accountID.",
            skip = false,
            func = function()

                local steamID = "STEAM_0:1:206450682"
                local rawAccountID = 412901365

                local accountID = MonkeyLib.SteamIDToAccountID( steamID )
                
                expect( accountID ).to.equal( rawAccountID )

            end
        },
        {
            name = "Convert a SteamID to an account ID, and back to a SteamID.",
            skip = false,
            func = function()

                local rawSteamID = "STEAM_0:1:206450682"
                local rawAccountID = 412901365

                local accountID = MonkeyLib.SteamIDToAccountID( rawSteamID )
                
                expect( accountID ).to.equal( rawAccountID )

                local steamID = MonkeyLib.AccountIDToSteamID( accountID )

                expect( steamID ).to.equal( rawSteamID )

            end
        },
        {
            name = "Convert a SteamID64 to an accountID.",
            skip = false,
            func = function()

                local rawSteamID = "STEAM_0:1:206450682"
                local rawSteamID64 = util.SteamIDTo64( rawSteamID )

                local rawAccountID = 412901365

                local accountID = MonkeyLib.SteamID64ToAccountID( rawSteamID64 )

                expect( accountID ).to.equal( rawAccountID )

            end
        },
        {
            name = "Convert a SteamID64 to an accountID, and back to a SteamID64.",
            skip = false,
            func = function()

                local rawSteamID = "STEAM_0:1:206450682"
                local rawSteamID64 = util.SteamIDTo64( rawSteamID )

                local rawAccountID = 412901365

                local accountID = MonkeyLib.SteamID64ToAccountID( rawSteamID64 )

                expect( accountID ).to.equal( rawAccountID )
                
                local steamID64 = MonkeyLib.AccountIDToSteamID64( accountID )

                expect( steamID64 ).to.equal( rawSteamID64 )
            end
        },
    }
}