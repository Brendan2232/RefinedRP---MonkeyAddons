// This system will 100% have sync issuses - EVERYTHING is ran on predictions ( idiot )

local floor = math.floor 
local isnumber = isnumber 
local istable = istable

local goldColor = Color(213, 216, 21)  

local silverColor = Color(158, 158, 158)

local bronzeColor = Color(108, 40, 24)

local CONFIG = MHalloween.CandyConfig

local candyEventEndTime = 0

local candyEventRunning = false 

local startEvent, endEvent, startEventTicker 

local collectedCandyStructure

do // Structures 

    collectedCandyStructure = function( ply, amount )

        local steamID64 = ply:SteamID64()

        return { ply, steamID64, amount }
    end

end

local insertPlayerIndex, getPlayerIndex, resetPlayerIndexes

do // This is so we can access the players candy index faster ( I know it's a dirty hack, either this for searching every time we collect a candy. )
    
    local candyStackIndexer = {}

    getPlayerIndex = function( playerIndex )

        local steamID64 = ( IsValid( playerIndex ) and playerIndex:SteamID64() ) or playerIndex

        return candyStackIndexer[ steamID64 ]
    end

    insertPlayerIndex = function( playerIndex, index )

        local steamID64 = ( IsValid( playerIndex ) and playerIndex:SteamID64() ) or playerIndex

        candyStackIndexer[ steamID64 ] = index

    end 

    resetPlayerIndexes = function( )
        
        table.Empty( candyStackIndexer )

    end

    MHalloween.InsertPlayerIndex = insertPlayerIndex

    MHalloween.GetPlayerIndex = getPlayerIndex

    concommand.Add( "check_player_index", function( ply )

        if ( SERVER and IsValid( ply ) ) then 

            return 
        end

        PrintTable( candyStackIndexer )

    end )

end

local arraySwap

do // Array swap

    local getPos = function( index )

        local foundPos = MHalloween.CollectedCandies[ index ] 

        return foundPos, index 
    end

    arraySwap = function( index ) 

        if ( not isnumber( index ) ) then 

            return 
        end

        local foundStructure = getPos( index )

        if ( not istable( foundStructure ) ) then 

            return 
        end

        local structurePlayer, structureSteamID64, structureCandies = unpack( foundStructure )

        local nextPos = getPos( index - 1 )
        
        if ( not istable( nextPos ) ) then 
           
            return 
        end

        local candyValue = nextPos[ 3 ]

        if ( candyValue >= structureCandies ) then 
    
            return 
        end

        local array = MHalloween.CollectedCandies

        while ( index >= 1 ) do 
    
            local structure = getPos( index )
    
            if ( not istable( structure ) ) then 

                break  
            end

            local nextStructure = getPos( index - 1 )
    
            if ( not istable( nextStructure ) ) then 
    
                break 
            end
            
            local ply, steamID64, candies = structure[ 1 ], structure[ 2 ], structure[ 3 ]

            local nextPly, nextSteamID64, nextCandies = nextStructure[ 1 ], nextStructure[ 2 ], nextStructure[ 3 ]

            if ( candies > nextCandies ) then 
   
                do 
                    
                    array[ index ] = nextStructure 

                    insertPlayerIndex( nextSteamID64, index )

                end

                do 

                    array[ index - 1 ] = structure 
                    
                    insertPlayerIndex( steamID64, index - 1 )

                end
        
            end
    
            index = index - 1 
            
        end
    
    end 
            
end

local syncNetwork, networkPlayerCandyReset, networkPlayerCandyIncrease

local calculateCandyReward

do

    calculateCandyReward = function()

        local staticRewardAmount = CONFIG.RewardAmount 

        local placementMultipliers = CONFIG.PlacementRewardMultiplier

        local candies = MHalloween.CollectedCandies

        for k = 1, #placementMultipliers do 

            local multiplier = placementMultipliers[ k ]

            if ( not isnumber( multiplier ) ) then 

                continue 
            end

            local structure = candies[ k ]

            if ( not istable( structure ) ) then 

                break // No structure here > no structure infront of it. 
            end

            local ply, steamID64, candies = unpack( structure )
            
            if ( not IsValid( ply ) or not isnumber( candies ) ) then // Not valid? No money for you :( 

                continue 
            end

            local candyReward = ( ( staticRewardAmount * candies ) * multiplier )

            do // Calculate the reward amount 

                candyReward = math.max( candyReward, 0 )

                candyReward = math.floor( candyReward )
    
            end 

            do 

                MonkeyLib.AddMoney( ply, candyReward )

                MonkeyLib.ChatMessage( MHalloween.CandyConfig.RewardNotifier, { ply:Name(), k, ( ( k == 1 ) and "st" or "nd" ), MonkeyLib.FormatMoney( candyReward ) } )

            end

        end

    end

    local getPlayerCandies = function( ply )

        if ( not IsValid( ply ) ) then 

            return 
        end

        local stackIndex = getPlayerIndex( ply )
    
        if ( not isnumber( stackIndex ) ) then 
    
            return 
        end
    
        local foundStructure = MHalloween.CollectedCandies[ stackIndex ]
    
        if ( not istable( foundStructure ) ) then 
    
            return 
        end
        
        return foundStructure, stackIndex
    end
    
    local resetPlayerCandies = function( playerIndex ) 

        local candyArray = MHalloween.CollectedCandies

        local candyArrayLen = #candyArray
    
        if ( candyArrayLen <= 0 ) then 
    
            return 
        end

        // This entire hack is for disconnected players. Server < > Client array Id's should match - if not there's a bigger issue...
        
        local steamID64 = ( ( IsValid( playerIndex ) and playerIndex:SteamID64() ) or playerIndex )

        local stackIndex = getPlayerIndex( steamID64 )
    
        if ( not isnumber( stackIndex ) ) then 
    
            return 
        end

        insertPlayerIndex( steamID64, nil ) // RESET!!!!

        candyArray[ stackIndex ] = nil 

        for k = stackIndex + 1, candyArrayLen do 
    
            local structure = candyArray[ k ]

            if ( not istable( structure ) ) then 

                break  
            end 
    
            local structuredSteamID64 = structure[ 2 ]

            insertPlayerIndex( structuredSteamID64, k - 1 )
    
            do // Swapping memory addresses 
    
                candyArray[ k ] = nil 
    
                candyArray[ k - 1 ] = structure
    
            end 
    
        end

        if ( SERVER ) then 

            networkPlayerCandyReset( steamID64 ) // Network the reset! 

        end

        return stackIndex
    end
    
    local increaseCandyCount = function( ply )
    
        if ( not IsValid( ply ) ) then 
    
            return 
        end
    
        local playerCandies, candyIndex = getPlayerCandies( ply )
    
        if ( istable( playerCandies ) ) then 
                
            local count = playerCandies[ 3 ]
        
            do // Increment the count! 
        
                count = count + 1 
        
                playerCandies[ 3 ] = count 

            end 
        
            arraySwap( candyIndex )

            if ( SERVER ) then 

                networkPlayerCandyIncrease( ply )

            end

            return 
        end

        local index = #MHalloween.CollectedCandies + 1 

        do // insert and network! 

            local candyStructure = collectedCandyStructure( ply,  1 )

            MHalloween.CollectedCandies[index] = candyStructure
        
        end

        insertPlayerIndex( ply, index )

        arraySwap( index )

        if ( SERVER ) then 

            networkPlayerCandyIncrease( ply )

        end

    end
    
    MHalloween.GetPlayerCandies = getPlayerCandies

    MHalloween.ResetPlayerCandies = resetPlayerCandies

    MHalloween.IncreasePlayerCandies = increaseCandyCount

    MHalloween.WipePlayerCandies = function()

        resetPlayerIndexes()

        table.Empty( MHalloween.CollectedCandies )

    end
    
end

local timerID = "MHalloween:Candy:EventTimer"

do // Event API

    local networkStart = function()

        net.Start( "MHalloween:Candy:EventStart" )
    
        net.Broadcast()
    
    end

    local networkEnd = function()
        
        net.Start( "MHalloween:Candy:EventEnd" )
    
        net.Broadcast()
    
    end
    
    startEvent = function()
            
        do // Wipe our candies and start the candy spawner! 

            MHalloween.WipePlayerCandies() 

            MHalloween.StartCandySpawner() // Reference - 'sv_candy_spawner'
                            
        end

        networkStart() // Tell everyone on the network that the candy event has started! 

        MonkeyLib.ChangeSkybox( MonkeyLib.SKYBOX_NIGHT ) // Change the skybox. Reference - 'monkeylib/lua/monkeylib/core/sv_skybox.lua'

        MonkeyLib.Debug( false, "Candy event has been started!" )

        hook.Run( "MHalloween:Candy:EventStart" )

    end
    
    endEvent = function()

        calculateCandyReward() // Calculate the rewards for players! 

        do // Wipe our candies and stop the candy spawner! 

            MHalloween.EndCandySpawner() // Reference - 'sv_candy_spawner'

            MHalloween.WipePlayerCandies() 
    
        end

        networkEnd() // Tell everyone on the network that the candy event has ended! 

        MonkeyLib.ChangeSkybox( MonkeyLib.SKYBOX_HALLOWEEN_NIGHT ) // Change the skybox. Reference - 'monkeylib/lua/monkeylib/core/sv_skybox.lua'
    
        MonkeyLib.Debug( false, "Candy event has been ended!" )

        hook.Run( "MHalloween:Candy:EventEnd" )


    end
    
    local getRandomStartTime = function()

        local startTimes = CONFIG.EventStartIntervolts
    
        local startTime, endTime = unpack( startTimes )
    
        return math.random( startTime, endTime )
    end
    
    startEventTicker = function( )
    
        local randomStartTime = getRandomStartTime()

        MonkeyLib.Debug(false, "Candy event is starting in '%d'", randomStartTime)

        timer.Create( timerID, randomStartTime, 0, function()

            local startCallback, endCallback = startEvent, endEvent 

            local wasRunning = candyEventRunning
    
            candyEventRunning = not candyEventRunning
    
            do // Callback 
                
                local callback = ( ( wasRunning and endCallback ) or startCallback )
    
                callback()
    
            end
    
            do // EndTime  
        
                local nextTime = ( ( wasRunning and getRandomStartTime() ) or CONFIG.EventTime ) 
    
                timer.Adjust( timerID, nextTime )
    
            end
                
        end )
    
    end

    MHalloween.GetCandyEventEndTime = function()

        if ( not candyEventRunning ) then 
           
            return 0 
        end
    
        local time = ( ( SERVER and timer.TimeLeft( timerID ) ) or ( candyEventEndTime - CurTime() ) ) 
    
        return math.max( time, 0 )
    end
    
    MHalloween.IsCandyEventRunning = function()
    
        return candyEventRunning 
    end

end

if ( SERVER ) then // Server interface  

    do // Net interface 

        util.AddNetworkString( "MHalloween:Candy:EventStart" )

        util.AddNetworkString( "MHalloween:Candy:EventEnd" )
        
        util.AddNetworkString( "MHalloween:Candy:EventSync" )

        util.AddNetworkString( "MHalloween:CandyCounter:ResetCounter" )

        util.AddNetworkString( "MHalloween:CandyCounter:IncreaseCounter" )
    
        syncNetwork = function( ply )
    
            if ( not IsValid( ply ) ) then 
        
                return 
            end 
        
            local eventTime = MHalloween.GetCandyEventEndTime()
        
            if ( not candyEventRunning ) then
               
                return 
            end
        
            if ( eventTime <= 1 ) then 
        
                return 
            end
                
            net.Start( "MHalloween:Candy:EventSync" )
        
                do // Event C-RON Sync  
        
                    net.WriteUInt( eventTime, 16 )
            
                end
        
                do // Candies Sync 
        
                    local candies = MHalloween.CollectedCandies
        
                    local candiesLen = #candies 
            
                    net.WriteUInt( candiesLen, 8 )
            
                    for k = 1, candiesLen do    
            
                        local structure = candies[ k ]
            
                        if ( not istable( structure ) ) then 
            
                            continue 
                        end 
            
                        local sendPlayer, steamID64, candies = unpack( structure )

                        if ( not IsValid( sendPlayer ) ) then 

                            continue 
                        end
            
                        net.WriteEntity( sendPlayer )
            
                        net.WriteUInt( candies, 12 )
            
                    end 
        
                end
         
            net.Send( ply ) 
        
        end
    
        networkPlayerCandyIncrease = function( ply )
    
            if ( not IsValid( ply ) ) then 
    
                return 
            end
    
            net.Start( "MHalloween:CandyCounter:IncreaseCounter" )
                net.WriteEntity( ply )
            net.Broadcast()
        
        end 
    
        // This is typically used as a method to reset disconnected players candies - I forget if it's bad practice to send players through the net after they've left ( even if their object is valid )

        networkPlayerCandyReset = function( steamID64 )
            
            net.Start( "MHalloween:CandyCounter:ResetCounter" )
                net.WriteString( steamID64 )
            net.Broadcast()
        
        end 

    end
    
    do // Hook interface 
    
        hook.Protect( "MHalloween:Candy:OnCollect", "MHalloween:CandyCounter:Update", function( _, ply )
        
            if ( not IsValid( ply ) ) then 
    
                return 
            end
    
            MHalloween.IncreasePlayerCandies( ply )
    
        end )
    
        hook.Protect( "MonkeyLib:PlayerNetReady", "MHalloween:Candy:SyncEvent", function( ply )
    
            timer.Remove("test_candies")
 
            if ( not IsValid( ply ) ) then 
        
                return 
            end
        
            syncNetwork( ply )
        
        end )
    
        hook.Protect( "PlayerDisconnected", "MHalloween:Candy:ResetPlayerCandies", function( ply )
        
            if ( not IsValid( ply ) ) then 

                return 
            end

            MHalloween.ResetPlayerCandies( ply )
            
        end )

        hook.Protect( "InitPostEntity", "MHalloween:Candy:StartEventTicker", function()

            local shouldStart = CONFIG.EventEnabled
            
            if ( shouldStart == false ) then 
               
                return 
            end

            startEventTicker( startEvent, endEvent )
    
        end )

    end
    
    do // Debug interface 

        concommand.Add( "mhalloween_event_start", function( ply )
    
            if ( IsValid( ply ) ) then 
    
                return 
            end
    
            if ( timer.Exists( timerID ) ) then 
    
                return 
            end

            MHalloween.EndCandySpawner()
                
            MHalloween.WipePlayerCandies() // Wipe first > No rewards. 
    
            startEventTicker( )
            
        end )
    
        concommand.Add( "mhalloween_event_stop", function( ply )

            if ( IsValid( ply ) ) then 
    
                return 
            end
            
            timer.Remove( timerID )
    
            MHalloween.EndCandySpawner()

            MHalloween.WipePlayerCandies() // Wipe first > No rewards. 
    
            endEvent()
            
        end )

        concommand.Add( "reset_highest_player", function( ply )

            if ( IsValid( ply ) ) then 
    
                return 
            end

            print( "RESSETTING ", MHalloween.CollectedCandies[1][1] )

            MHalloween.ResetPlayerCandies( MHalloween.CollectedCandies[1][1] )
                    
            print( "HIGHEST PLAYER IS ", MHalloween.CollectedCandies[1][1] )
            
        end )

        concommand.Add( "increase_candies", function( ply, _, arr )

            if ( IsValid( ply ) ) then 
               
                return 
            end
    
            MHalloween.IncreasePlayerCandies( player.GetAll()[ tonumber( arr[ 1 ] ) ] )
    
        end )
    
        concommand.Add( "reset_candies", function( ply, _, arr )
    
            if ( IsValid( ply ) ) then 
               
                return 
            end
            
            MHalloween.ResetPlayerCandies( player.GetAll()[ tonumber( arr[ 1 ] ) ] )
    
        end )

    end
    
    return 
end

if ( CLIENT ) then // Client interface 

    // These are defined at the top of the file - locally. 
    
    candyEventEndTime = 0 

    candyEventRunning = false  
    
    local clientEventHandler = function( running, timeOverright )

        if ( not running ) then 
    
            MHalloween.WipePlayerCandies()        
    
        end
    
        candyEventRunning = running
    
        candyEventEndTime = ( running and ( CurTime() + ( ( isnumber( timeOverright ) and timeOverright ) or CONFIG.EventTime ) ) ) or 0  
    
        local hookID = ( running and "MHalloween:Candy:EventStart" or "MHalloween:Candy:EventEnd" ) 
    
        hook.Run( hookID )
    
    end 
    
    do // Client Networking
    
        net.Receive( "MHalloween:CandyCounter:IncreaseCounter", function()
    
            local ply = net.ReadEntity()
        
            if ( not IsValid( ply ) ) then 
        
                return 
            end
            
            MHalloween.IncreasePlayerCandies( ply )
        
            hook.Run( "MHalloween:CandyCounter:IncreaseCounter", ply )
        
        end )
        
        net.Receive( "MHalloween:CandyCounter:ResetCounter", function()
        
            local steamID64 = net.ReadString()
            
            local index = MHalloween.ResetPlayerCandies( steamID64 ) 
        
            hook.Run( "MHalloween:CandyCounter:ResetCounter", index, steamID64 )
        
        end ) 
           
        net.Receive( "MHalloween:Candy:EventStart", function()
        
            clientEventHandler( true )
    
        end )
    
        net.Receive( "MHalloween:Candy:EventEnd", function() 
    
            clientEventHandler( false )
    
        end )
         
        net.Receive( "MHalloween:Candy:EventSync", function()

            MHalloween.WipePlayerCandies()

            local array = MHalloween.CollectedCandies
    
            local time = net.ReadUInt( 16 )
    
            local candiesLen = net.ReadUInt( 8 )
    
            if ( candiesLen >= 1 ) then 
    
                for k = 1, candiesLen do 
                
                    local ply, candies = net.ReadEntity(), net.ReadUInt( 12 )
    
                    if ( not IsValid( ply ) ) then 
    
                        continue 
                    end

                    local index = #array + 1
    
                    array[ index ] = collectedCandyStructure( ply, candies )
    
                    MHalloween.InsertPlayerIndex( ply, index )

                end
        
            end 
        
            clientEventHandler( true, time )
    
        end )
     
    end
    
end

