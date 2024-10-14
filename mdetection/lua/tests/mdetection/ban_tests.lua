local fn = function( value )

    return function()

        return value 
    end
end

local players = {}

local createPlayer = function( steamID64, ownerSteamID64 )

    local ply = {
        
        IsValid = fn( true ),

        IsPlayer = fn( true ), 

        IsBot = fn(false), 
        
        steamID64 = steamID64, 

        ownerSteamID64 = ownerSteamID64 or steamID64, 

        OwnerSteamID64 = function( target )

            return target.ownerSteamID64
        end, 

        SteamID64 = function(target)

            return target.steamID64
        end, 

        SteamID = function( target )

            return util.SteamIDFrom64( target:SteamID64() )
        end, 

        UniqueID = function()

            return math.random( 5000, 99999 )
        end, 

        UserID = function()
        
            return 123 
        end, 

        Kick = fn( true ), 

        EntIndex = fn( 1 ), 

        Name = fn( "BrendanTests" ),  
   
    }

    table.insert( player.GetAll(), ply )

    setmetatable( ply, { MetaName = "Player" } )

    MonkeyLib.OnlinePlayers[steamID64] = ply 

    return ply  
end

local unbanPlayers = function()

    for k,v in pairs( MonkeyLib.OnlinePlayers ) do 

        sam.player.unban( util.SteamIDFrom64( k ) )

    end

end

return {
    groupName = "Ban Tests",

    beforeEach = function()

        unbanPlayers( )

        table.Empty( MonkeyLib.OnlinePlayers )

    end,

    afterEach = function()

        unbanPlayers( )

        table.Empty( MonkeyLib.OnlinePlayers )

    end,
    
    cases = {

        {
            name = "Player should be banned, ban inserted into cache and SQlite database.",

            skip = false,

            func = function()

                local banTime = 1

                local bannedPlayer = createPlayer( "76561198377463934" )

                sam.player.ban( bannedPlayer, banTime )                

                local bannedSteamID64 = bannedPlayer:SteamID64()

                do // Check the SQLite  

                    local unbanTime = MDetection.GetBan( bannedSteamID64 )

                    expect( unbanTime ).to.beA( "number" )

                end


                do // Check the cache 
                              
                    local unbanCache = MDetection.GetBanCache( bannedSteamID64 )
                    
                    expect( unbanCache ).to.beA( "number" )
                    
                end  

            end
        },
        {
            name = "Player should be banned, ban inserted into cache and SQlite database; banned player should be unbanned, ban removed from cache and SQlite database.",

            skip = false,

            func = function()

                local banTime = 1 

                local bannedPlayer = createPlayer( "76561198377463934" )

                sam.player.ban( bannedPlayer, banTime )                

                local bannedSteamID64 = bannedPlayer:SteamID64()

                do // Check the SQLite  

                    local unbanTime = MDetection.GetBan( bannedSteamID64 )

                    expect( unbanTime ).to.beA( "number" )

                end
                
                do // Check the cache 
                              
                    local unbanCache = MDetection.GetBanCache( bannedSteamID64 )
                    
                    expect( unbanCache ).to.beA( "number" )
                    
                end  

                sam.player.unban( bannedPlayer:SteamID() )

                do // Check the SQLite  

                    local unbanTime = MDetection.GetBan( bannedSteamID64 )

                    expect( unbanTime ).to.beNil( )

                end
                
                do // Check the cache 
                              
                    local unbanCache = MDetection.GetBanCache( bannedSteamID64 )
                    
                    expect( unbanCache ).to.beNil()
                    
                end  


            end
        },

        {
            name = "Player using family share should get banned due to the main account being banned.",

            skip = false,

            func = function()

                local banTime = 1

                local bannedPlayer = createPlayer( "76561198377463934" )

                sam.player.ban( bannedPlayer, banTime )                

                local bannedSteamID64 = bannedPlayer:SteamID64()

                do // Check the SQLite  

                    local unbanTime = MDetection.GetBan( bannedSteamID64 )

                    expect( unbanTime ).to.beA( "number" )

                end
        
                local familySharedPlayer = createPlayer( "76561198377463935", bannedSteamID64 )

                local ownerSid, bannedTime = MDetection.BanFamilySharedAccount( familySharedPlayer )

                expect( ownerSid ).to.equal( bannedSteamID64 )

                expect( bannedTime ).to.equal( banTime )

            end
        },

        {
            name = "Player using family share shouldn't be banned due to the main account not being banned.",

            skip = false,

            func = function()

                local banTime = 1 

                local familyShareOwner = createPlayer( "76561198377463934" )
    
                local familyShareOwnerSteamID64 = familyShareOwner:SteamID64()

                do // Check the SQLite  

                    local unbanTime = MDetection.GetBan( familyShareOwnerSteamID64 )

                    expect( unbanTime ).to.beNil( )

                end
        
                local familySharedPlayer = createPlayer( "76561198377463935", familyShareOwnerSteamID64 )

                local ownerSid, bannedTime = MDetection.BanFamilySharedAccount( familySharedPlayer )

                expect( ownerSid ).to.beNil( )
                expect( bannedTime ).to.beNil( )

        
            end
        },



    }
}