// This system requires 'https://steamcommunity.com/sharedfiles/filedetails/?id=784597026' for the content pack 

require( "monkeyhooks" )

MHalloween = MHalloween or {}

MHalloween.CollectedCandies = {}

MHalloween.CandyConfig = MHalloween.CandyConfig or {} 

local secondsToMinutes = function( time )

    return time * 60 
end 

local secondsToHours = function( time )

    return secondsToMinutes( time ) * 60 
end 

do 

    MHalloween.CandyConfig.MaxPlayerRows = 5

    MHalloween.CandyConfig.EventEnabled = true  

end

// reward_amount = 10 

// Placement multipler ( placement = 1, collected_candies = 5, ( ( reward_amount * collected_candies ) * placement_multipler ) ) = ( 50 )

do // Reward stuff 

    MHalloween.CandyConfig.RewardAmount = 60000

    MHalloween.CandyConfig.RewardNotifier = "{colorRed} RefinedRP {colorWhite} | {colorGreen} %s {colorWhite} Was {colorGreen} %d%s {colorWhite} Place in the candy event, they've recieved {colorGreen} %s!"

    MHalloween.CandyConfig.PlacementRewardMultiplier = {

        1, // First place 

        .75, // Second Place 

        .5, // Third Place 
        
    }

end

do // Event Config 

    MHalloween.CandyConfig.EventTime = secondsToMinutes( 5 ) // How long will the event last? 

    MHalloween.CandyConfig.EventStartIntervolts = { secondsToHours( 2 ), secondsToHours( 3 ) } // How long till the next event? Between 2 - 4 hours. 

end

do // Spawn Config  

    MHalloween.CandyConfig.SpawnIntervolt = 16 // How long till another candy can spawn in?

    MHalloween.CandyConfig.SpawnPointCooldown = 30 // How long till a candy spawn_vector is on cooldoown. 
    
    MHalloween.CandyConfig.SpawnAmount = 4 // Every 'SpawnIntervolt' seconds it'll ATTEMPT to spawn in 2 ents. 

    MHalloween.CandyConfig.SpawnPoints = {
        Vector(2853, 671, -196),
        Vector(2637, 1683, -203),
        Vector(4708, 1154, -64),
        Vector(5418, 1687, -205),
        Vector(3895, 2747, -204),
        Vector(4418, 3955, -204),
        Vector(2696, 3410, -204),
        Vector(1739, 3940, -204),
        Vector(2369, 5426, -204),
        Vector(2366, 7045, -204),
        Vector(503, 7391, -204),
        Vector(1316, 5720, -194),
        Vector(1787, 4734, -192),
        Vector(709, 4699, -180),
        Vector(269, 5733, -204),
        Vector(303, 4079, -204),
        Vector(253, 2161, -204),
        Vector(1463, 765, -204),
        Vector(-170, 722, -204),
        Vector(-1193, 292, -204),
        Vector(-1224, -2235, -204),
        Vector(-2647, -1971, -204),
        Vector(-2047, -907, -204),
        Vector(-2695, 410, -204),
        Vector(-3331, 1337, -204),
        Vector(-3587, 2547, -204),
        Vector(-4244, 3918, -204),
        Vector(-4953, 2828, -204),
        Vector(-4895, 1668, -204),

        Vector(-2654, -3932, -204),
        Vector(-3298, -4848, -177),
        Vector(-4091, -6813, -163),
        Vector(-2639, -6493, -204),
        Vector(-285, -7040, -204),
        Vector(-1054, -6124, -196),
        Vector(167, -5333, -204),
        Vector(4589, -6383, -308),
        Vector(4231, -4511, -308),
        Vector(3233, -3782, -204),
        Vector(3940, -2810, -296),
        Vector(5286, -2392, -292),
        Vector(3747, -892, -301),
        Vector(3090, -1518, -204),
        Vector(1446, -823, -204),
        Vector(117, -1361, -204),
        Vector(124, -3296, -204),
    }
    
end

do // Candy model stuff  

    local modelStructure = function( model, useRandomColors )

        AssertF( isstring( model ), "Model isn't a string!" )

        return { model, useRandomColors }    
    end

    MHalloween.CandyConfig.Models = {

        modelStructure( "models/zerochain/props_halloween/bonbon01.mdl", true ), 

    }

end

