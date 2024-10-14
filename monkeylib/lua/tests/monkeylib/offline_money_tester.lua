local fn = function( value )

    return function()

        return value 
    end
end

local players = {}

local createPlayer = function( steamID64 )

    local ply = {
        Money = 0, 
        
        IsValid = fn( true ),

        IsPlayer = fn( true ), 
        
        steamID64 = steamID64, 

        canAfford = function( target, amount )

            return target.Money >= amount 
        end, 
        
        addMoney = function( target, amount )

            
            target.Money = target.Money + amount 
        end,

        setMoney = function( target, amount )

            target.Money = amount
        end,

        getMoney = function(target)

            return target.Money
        end,

        SteamID64 = function(target)

            return target.steamID64
        end, 

        EntIndex = function()

            return 1 
        end, 

        Name = function()

            return "Tester"
        end
    }

    MonkeyLib.OnlinePlayers[steamID64] = ply 

    return ply  
end

return {
    groupName = "Offline Money",

    beforeEach = function()


        table.Empty( MonkeyLib.OnlinePlayers )

        MonkeyLib.SQL:Query("DELETE FROM mlib_offline_money")

    end,

    afterEach = function()

        table.Empty( MonkeyLib.OnlinePlayers )

        MonkeyLib.SQL:Query("DELETE FROM mlib_offline_money")
        
    end,
    
    cases = {
        {
            name = "Insert money into an offline account.",
            skip = false,
            func = function()

                local steamID64 = "76561198998938274"

                local moneyAmount = 100 

                MonkeyLib.addToOfflineAccount( steamID64, moneyAmount )
                
                do 

                    local money = MonkeyLib.getOfflineAccount( steamID64 )
                
                    expect( money ).to.equal( moneyAmount )

                end

            end
        },
        {
            name = "Insert money into an online account, expect the money to be added to the players account.",
            skip = false,
            func = function()

                local steamID64 = "76561198998938274"

                local ply = createPlayer(steamID64)
              
                local moneyAmount = 100 

                MonkeyLib.addToOfflineAccount( steamID64, moneyAmount )

                do 

                    expect( ply:getMoney() ).to.equal( moneyAmount )

                end
    
            end
        },
        {
            name = "Insert money into an offline account, expect the offline account to recieve their money on connect.",
            skip = false,
            func = function()

                local steamID64 = "76561198998938274"

                local moneyAmount = 100 

                MonkeyLib.addToOfflineAccount( steamID64, moneyAmount )

                local ply = createPlayer( steamID64 )

                MonkeyLib.addMoneyToAccount( ply )

                do 
                    
                    expect( ply:getMoney() ).to.equal( moneyAmount )
                    
                end

                do 
                    local money = MonkeyLib.getOfflineAccount( steamID64 )

                    expect( money ).to.equal( 0 )
                end
    
            end
        },

        {
            name = "Insert money into two offline accounts, expect both accounts to not interfere with eachother.",
            skip = false,
            func = function()

                local steamID64 = "76561198998938274"

                local secondarySteamID64 = "76561198998938275"

                local moneyAmount = math.random( 100, 500 )

                local secondaryMoneyAmount = math.random( 100, 500 )

                MonkeyLib.addToOfflineAccount( steamID64, moneyAmount )
                MonkeyLib.addToOfflineAccount( secondarySteamID64, secondaryMoneyAmount )
                
                do 

                    local money = MonkeyLib.getOfflineAccount( steamID64 )
                
                    expect( money ).to.equal( moneyAmount )

                end

                do 

                    local money = MonkeyLib.getOfflineAccount( secondarySteamID64 )
                
                    expect( money ).to.equal( secondaryMoneyAmount )

                end

            end
        },

        {
            name = "Insert money into two offline accounts, expect both accounts to come online and recieve their money.",
            skip = false,
            func = function()

                local steamID64 = "76561198998938274"

                local secondarySteamID64 = "76561198998938275"

                local moneyAmount = math.random( 100, 500 )

                local secondaryMoneyAmount = math.random( 100, 500 )

                MonkeyLib.addToOfflineAccount( steamID64, moneyAmount )
                MonkeyLib.addToOfflineAccount( secondarySteamID64, secondaryMoneyAmount )
                
                do 

                    local money = MonkeyLib.getOfflineAccount( steamID64 )
                
                    expect( money ).to.equal( moneyAmount )

                end

                do 

                    local money = MonkeyLib.getOfflineAccount( secondarySteamID64 )
                
                    expect( money ).to.equal( secondaryMoneyAmount )

                end

                local ply = createPlayer( steamID64 )
              
                local secondaryPly = createPlayer( secondarySteamID64 )
              
                do 

                    MonkeyLib.addMoneyToAccount( ply )
                    MonkeyLib.addMoneyToAccount( secondaryPly )

                    expect( ply:getMoney() ).to.equal( moneyAmount )
                    expect( secondaryPly:getMoney() ).to.equal( secondaryMoneyAmount )

                end

                do 

                    local money = MonkeyLib.getOfflineAccount( steamID64 )
                
                    expect( money ).to.equal( 0 )

                    money = MonkeyLib.getOfflineAccount( secondarySteamID64 )
                
                    expect( money ).to.equal( 0 )

                end
            
            
            end
        },
    }
}