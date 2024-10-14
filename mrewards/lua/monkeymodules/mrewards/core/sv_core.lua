util.AddNetworkString("MRewards:Reward:Claimed")
util.AddNetworkString("MRewards:Reward:SendReward")

local cooldownTime = MRewards.rewardCooldown * 86400

local RewardModules = {

    ["darkrp_money"] = function( ply, value )

        if ( not IsValid( ply ) or not isnumber( value ) ) then 
            
            return 
        end 

        MonkeyLib.AddMoney( ply, value )
    end,

    ["weapons"] = function( ply, value )
        
        if ( not IsValid( ply ) or not isstring( value ) ) then 
            
            return 
        end 

        local weapon = ply:Give( value )

        if ( not IsValid( weapon ) ) then 

            return 
        end

        weapon.MonkeyLib_CanDrop = true 

    end,

    ["monkey_unbox_crates"] = function( ply, value )
        
        if ( not IsValid( ply ) or not isstring( value ) ) then 
            
            return 
        end 


        MUnbox.PurchaseCrate( ply, value, true ) // Dan didn't want player to recieve any compensation if this fails. 
        
    end,
    
}

local generateReward = function( ply )

    if ( not IsValid( ply ) ) then 
        
        return 
    end 

    local cachedRewards = MRewards.SharedRewards 

    math.random()
    math.random()

    local reward = cachedRewards[ math.random( 1, #cachedRewards ) ]    

    if ( not isnumber( reward ) ) then 
        
        return 
    end 

    ply.MRewards_WonReward = reward 

    return reward 
end

local addCooldown = function( ply )

    if ( not IsValid( ply ) ) then return end 

    local steamID64 = ply:SteamID64()

    local cooldown = ( os.time() + cooldownTime )
    
    MonkeyLib.SQL:Query( "INSERT INTO mrewards ( steamID64, cooldown ) VALUES( %s, %s );", { steamID64, cooldown } )

end

local canClaimReward = function( ply )

    if ( not IsValid( ply ) ) then 
        
        return false 
    end 
 
    local steamID64 = ply:SteamID64()

    local foundCooldown = MonkeyLib.SQL:QueryValue("SELECT cooldown FROM mrewards WHERE steamID64 = %s", { steamID64 })

    if ( not foundCooldown ) then 
        
        return true 
    end

    foundCooldown = tonumber( foundCooldown )

    if ( foundCooldown > os.time() ) then 
        
        return false 
    end 

    MonkeyLib.SQL:Query( "DELETE FROM mrewards WHERE steamID64 = %s", { steamID64 } )

    return true 
end 

local joinReward = function( ply )

    if ( not IsValid( ply ) ) then 
        
        return 
    end 

    local canClaim = canClaimReward( ply )

    if ( not canClaim ) then 
        
        return 
    end 

    local reward = generateReward( ply )

    if ( not isnumber( reward ) ) then 
        
        return 
    end 

    net.Start( "MRewards:Reward:SendReward" )
        net.WriteUInt( reward, 20 )
    net.Send( ply )

end

local claimReward = function( ply )

    if ( not IsValid( ply ) ) then 
        
        return 
    end 

    local rewardIndex = ply.MRewards_WonReward

    if ( not isnumber( rewardIndex ) ) then 
        
        return 
    end 

    local canClaim = canClaimReward( ply )

    if ( not canClaim ) then 
        
        return 
    end 

    local foundReward = MRewards.IndexToReward( rewardIndex )

    if ( not istable( foundReward ) ) then 
        
        return 
    end 

    local rewardValue = foundReward.Value

    if ( not rewardValue ) then 
        
        return 
    end 

    local rewardType = foundReward.Type

    local rewardCallback = RewardModules[rewardType]

    if ( not isfunction( rewardCallback ) ) then 
        
        return 
    end 

    ply.MRewards_WonReward = nil 
    
    rewardCallback( ply, rewardValue )

    addCooldown( ply )

end

net.Receive( "MRewards:Reward:Claimed", function( l, ply )

    claimReward( ply )

end )

do 

    hook.Protect( "MonkeyLib:PlayerNetReady", "MonkeyRewards:NetReady:SendReward", function( ply )
        
        joinReward( ply )
    
    end )
    
    hook.Protect( "Initialize", "MonkeyRewards:Init:StartDB", function()
    
        MonkeyLib.SQL:CreateTables( {
            "CREATE TABLE IF NOT EXISTS mrewards ( steamID64 VARCHAR(255) PRIMARY KEY, cooldown INT )"
        } )
    
    end )

end 


