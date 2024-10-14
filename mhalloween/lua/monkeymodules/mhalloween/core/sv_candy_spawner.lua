require( "monkeyhooks" )

local CONFIG = MHalloween.CandyConfig

local candyClass = "m_halloween_candy"
    
local cooldownList = {}

local availableSpawnPoints = {}

local isOnCooldown = function( sysTime, cooldownIntervolt ) 

    local sysTimeOffset = ( SysTime() - ( sysTime or 0 ) )
    
    return ( sysTimeOffset < ( cooldownIntervolt or CONFIG.SpawnPointCooldown ) ), sysTimeOffset 
end

local getVar, pushTo, popTo 

do // Simple Push - Pop system

    getVar = function( array, index, structureIndex )
       
        local value = array[ index ] // Get our structure from the stack 

        if ( not istable( value ) ) then // NAHHHHHHHHH

            return 
        end
        
        return ( isnumber( structureIndex ) and value[ structureIndex ] ) or value // Return either the indexed structure value or just the structure. 
    end
    
    popTo = function( array, index )

        local value = array[ index ] // Get our structure from the stack 
    
        if ( not istable( value ) ) then // NAHHHHHHHHH
    
            return 
        end
    
        table.remove( array, index ) // Bye bye! 
    
        return value, index // Return our values. 
    end
    
    pushTo = function( array, values )
    
        local arrayIndex = #array + 1 // Next index 
    
        array[ arrayIndex ] = values
    
    end

end

local cooldownStructure, spawnPointStructure 

do // Structures 

    cooldownStructure = function( vector, sysTime )

        return { vector, sysTime }
    end

    spawnPointStructure = function( vector )

        return { vector } 
    end

end

local spawnPointCopy, deepReset

do // Copy / Reset API 

    spawnPointCopy = function()
        
        table.Empty( availableSpawnPoints )

        local spawnPoints = CONFIG.SpawnPoints // Get our spawnpoints! 

        local spawnPointsLen = #spawnPoints 

        AssertF( ( spawnPointsLen >= 1 ), "There's no spawnpoints!" ) // No spawnpoints, what the fuck!?!?

        for k = 1, spawnPointsLen do 

            local vector = spawnPoints[ k ]

            AssertF( isvector( vector ), "Index '%d' doesn't have a vector value!", k ) // If this ever gets fired - fire the person who did the config. 

            local structure = spawnPointStructure( Vector( vector:Unpack() ) ) // Dump the vectors values into a new vector! 

            table.insert( availableSpawnPoints, structure )
            
        end
        
    end 

    deepReset = function() // Resets everything! 

        do // Dump everything in the stack 

            table.Empty( cooldownList )

            table.Empty( availableSpawnPoints )

        end

        local candies = ents.FindByClass( "m_halloween_candy" ) // Get our candies! 

        local candiesLen = #candies // Length of our candies 

        if ( candiesLen <= 0 ) then // No candies? 
            
            return 
        end

        for k = 1, candiesLen do 

            local ent = candies[ k ] // Get our entity! 

            if ( not IsValid( ent ) ) then // What happened to our entity!?!? 

                continue  
            end

            SafeRemoveEntity( ent ) // Bye Bye! 

        end

    end

end

local spawnCandy 

do // Candy Spawner interface 

    local getRandomSpawnPoint = function() // NOTE: Calling this will remove a spawnpoint from an avaiable slot! 

        local availableSpawnPointsLen = #availableSpawnPoints // Available SpawnPoints Length 
    
        if ( availableSpawnPointsLen <= 0 ) then // No Available SpawnPoints? 
    
            return 
        end
    
        local index = math.random( 1, availableSpawnPointsLen ) // Get a random value! 
    
        return popTo( availableSpawnPoints, index ), index // Pop our value and return our index! 
    end
    
    local getCandyModel = function()

        local foundModels = CONFIG.Models // Get our models 

        local foundModelsLen = #foundModels // Models length 

        AssertF( ( foundModelsLen >= 1 ), "There's no models!" ) // What?? 

        local index = math.random( 1, foundModelsLen ) // Get a random model 

        local foundModelStructure = foundModels[ index ] // Get our model from the model array. 

        if ( not istable( foundModelStructure ) ) then 

            return 
        end

        return unpack( foundModelStructure ) // Return our model data. 
    end

    spawnCandy = function()
    
        local structure = getRandomSpawnPoint() // Get a random spawnpoint! 

        if ( not istable( structure ) ) then // Not a table? More than likely no points - RETURN 

            return 
        end

        local spawnVector = structure[ 1 ] // Get our spawnVector! 

        if ( not isvector( spawnVector ) ) then // Internal error? Mad. 

            return 
        end
        
        local model, useRandomColors = getCandyModel() // Get our candy model! 

        if ( not isstring( model ) ) then 

            return 
        end

        local ent = ents.Create( candyClass ) // Create our entity  
        ent:SetModel( model )
        ent:SetPos( spawnVector + ( ent:GetUp() * 25 ) ) // Set our position + ( Increase the vector upwards position )

        if ( useRandomColors ) then 

            ent:SetColor( ColorRand() ) // Returns a random color 

        end

        ent.StartTouch = function( ent, ply ) // I'm initalizing our StartTouch function here ( so super-admins don't spawn these ents in to higher their count )

            if ( not IsValid( ent ) or not IsValid( ply ) ) then 

                return 
            end

            local isUsed = ent.USED // has the entity been used?  

            if ( isUsed ) then 
               
                return 
            end

            local canUse = hook.Run( "MHalloween:Candy:CanCollect", ent, ply ) // An API hook 

            if ( canUse == false ) then 

                return 
            end

            ent.USED = true  
    
            do // Debug

                local playerName, playerSteamID64, entIndex = ply:Name(), ply:SteamID64(), ent:EntIndex()
            
                MonkeyLib.Debug( false, "%s | %s - Has collected a candy, entity index '%d'", playerName, playerSteamID64, entIndex )

            end

            hook.Run( "MHalloween:Candy:OnCollect", ent, ply )

            SafeRemoveEntity( ent ) // Bye Bye! 

        end

        ent.M_ORIGIN_SPAWN = spawnVector // An absolute hack 

        ent:Spawn()

        return ent 
    end

end

do // Candy spawner interface 

    local candySpawnTicker 

    do // Spawn Ticker 

        local candySpawnCooldown = 0 

        local tickCooldown = CONFIG.SpawnIntervolt

        candySpawnTicker = function()
    
            local onCooldown = isOnCooldown( candySpawnCooldown, tickCooldown ) // Are we on a cooldown? 
            
            if ( onCooldown ) then 
    
                return 
            end

            local debugkey = 0 // Not important - just for debugging! 
            
            local spawnAmount = CONFIG.SpawnAmount // How many should we spawn? 
    
            for k = 1, spawnAmount do 
    
                local ent = spawnCandy()
    
                if ( not IsValid( ent ) ) then // More than likely means there's no slots! 
    
                    break 
                end
            
                debugkey = k // Debug key - ignore this. 

            end

            if ( debugkey >= 1 ) then // Debug!  

                MonkeyLib.Debug( false, "%d Candies has been spawned in!", debugkey )

            end
    
            candySpawnCooldown = SysTime() // Re-instate our cooldown! 
        
        end
    
    end

    local resolveCooldown = function()
        
        local structure = cooldownList[ 1 ] // The first one has been in the stack for the longest! 
        
        if ( not istable( structure ) ) then 

            return 
        end

        local sysTime = structure[ 2 ] // Lets get our cooldown time! 

        if ( not isnumber( sysTime ) ) then 

            return 
        end

        local onCooldown = isOnCooldown( sysTime ) // Are we on a cooldown! 
        
        if ( onCooldown ) then 

            return 
        end 

        do // Push onto the AvailableSpawnPoints Stack! 
    
            local vector = structure[ 1 ] // Get our vector! 

            local pointStructure = spawnPointStructure( vector ) // create a vector structure!  

            pushTo( availableSpawnPoints, pointStructure )

        end 
    
        do // Debug 
            
            MonkeyLib.Debug( false, "Cooldown index '%d' has been resolved, pushing down the stack.", 1 )
 
        end

        table.remove( cooldownList, 1 ) // Remove from our cooldown stack! 

    end

    local tick = function() // Tick function 
    
        do // Cooldown ticker 
        
            resolveCooldown()

        end 

        do // Spawn Ticker 

            candySpawnTicker()

        end

    end

    local tickHookID = "MHalloween:Candy:TickEngine"

    local startCandySpawner = function() // Event start function 

        deepReset() // Reset EVERYTHING!!!!!

        spawnPointCopy() // Copy our spawnpoints!

        hook.Protect( "Tick", tickHookID, tick ) // Create our tick hook 
        
    end

    local endCandySpawner = function() // Event end function
    
        deepReset() // Reset EVERYTHING!!!!!
        
        hook.Remove( "Tick", tickHookID ) // Remove our tick hook

    end 
    
    MHalloween.StartCandySpawner = startCandySpawner
    MHalloween.EndCandySpawner = endCandySpawner

end

do // Candy incrementer interface! 

    hook.Protect( "MHalloween:Candy:OnCollect", "MHalloween:Candy:CandyCollect", function( ent, ply )    

        if ( not IsValid( ent ) or not IsValid( ply ) ) then 

            return 
        end

        local spawnPointVector = ent.M_ORIGIN_SPAWN
    
        if ( not isvector( spawnPointVector ) ) then 
    
            return 
        end
    
        do // Push to our cooldown stack! 
    
            local structure = cooldownStructure( spawnPointVector, SysTime() )
        
            pushTo( cooldownList, structure )
    
        end
    
    end )

end

do  // Debug stuff 

    concommand.Add( "mhalloween_debug", function( ply )

        if ( IsValid( ply ) ) then 

            return 
        end

        PrintTable({
            cooldownList, 
            availableSpawnPoints, 
        })

    end )

end


--[[

timer.Create("test_candies", .5, 0, function()

    local isRun = MHalloween.IsCandyEventRunning()

    if ( not isRun ) then 

        return 
    end

    for k,v in pairs(player.GetAll()) do 

        local increaseOrNot = math.random( 0, 2 )


        if ( increaseOrNot == 0 ) then 

            continue 
        end


        if ( increaseOrNot == 2 ) then 
        
            MHalloween.ResetPlayerCandies(v)
    
            continue 
        end

        MHalloween.IncreasePlayerCandies( v )
    end
end)

]]