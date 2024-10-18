require( "memoize" )
require( "monkeyhooks" )

local PLAYER = FindMetaTable( "Player" )

do // Spawnpoint handler! 
        
    local spawnPoints = {

        {
            spawnPoint = Vector(3066.4072265625,683.37841796875,-195.96875),
            spawnAngle = Angle(-0.35750070214272,-179.56015014648,0), 
        },

        {
            spawnPoint = Vector(3221.2827148438,684.56756591797,-195.96875), 
            spawnAngle = Angle(-0.35750070214272,-179.56015014648,0),
        },

        {
            spawnPoint = Vector(3286.5825195313,685.06884765625,-195.96875),
            spawnAngle = Angle(-0.35750070214272,-179.56015014648,0),
        },

        {
            spawnPoint = Vector(3368.2687988281,885.68096923828,-195.96875),
            spawnAngle = Angle(-0.35750070214272,-179.56015014648,0),
        },

        {
            spawnPoint = Vector(3391.3020019531,1109.3092041016,-195.96875),
            spawnAngle = Angle(-0.35750070214272,-179.56015014648,0),
        },

        {
            spawnPoint = Vector(3212.716796875,1253.298828125,-195.96875),
            spawnAngle = Angle(-0.35750070214272,-179.56015014648,0),
        },
        
        {
            spawnPoint = Vector(3053.7126464844,1122.8061523438,-195.96875),
            spawnAngle = Angle(-0.35750070214272,-179.56015014648,0),
        },

        {
            spawnPoint = Vector(3017.1281738281,843.98876953125,-195.96875),
            spawnAngle = Angle(-0.35750070214272,-179.56015014648,0),
        },

        {
            spawnPoint = Vector(3121.9892578125,929.33770751953,-195.96875),
            spawnAngle = Angle(-0.35750070214272,-179.56015014648,0),
        },
        
        {
            spawnPoint = Vector(3117.7993164063,741.53332519531,-195.96875),
            spawnAngle = Angle(-0.35750070214272,-179.56015014648,0),
        },
        
    }

    local removeCurrentSpawns = function()

        local curSpawns = ents.FindByClass( "info_player_start" )
    
        if ( #curSpawns <= 0 ) then return end 
    
        for k = 1, #curSpawns do 
    
            local ent = curSpawns[k]
            if ( not IsValid( ent ) ) then continue end 
    
            ent.BeingRemoved = true 
            ent:Remove()
    
        end
    end
    
    local createNewSpawn = function( obj )
    
        if ( not istable( obj ) ) then
    
            MonkeyLib.Debug( false, "Failed to create spawnpoint, object isn't a table." )
    
            return 
        end
    
        local vec, ang = obj.spawnPoint, ( obj.spawnAngle or Angle() )
    
        if ( not isvector( vec ) ) then
    
            MonkeyLib.Debug( false, "Failed to create spawnpoint, vector isn't valid." )
    
            return 
        end
    
        local spawnEnt = ents.Create( "info_player_start" )
        spawnEnt:SetPos( vec )
        spawnEnt:SetAngles( ang )
    
        return spawnEnt 
    end
    
    local loadSpawnPoints = function()
        
        MonkeyLib.Debug( false, "Over-writing spawn points!" )
    
        local spawns = spawnPoints 
    
        if ( #spawns <= 0 ) then
    
            MonkeyLib.Debug( false, "Failed to load new spawn points, there's no spawn vectors!" )
    
            return 
        end
    
        removeCurrentSpawns()
    
        for k = 1, #spawns do 
            
            local spawnObj = spawnPoints[k]
    
            createNewSpawn( spawnObj )
    
        end
    end
    
    hook.Protect( "InitPostEntity", "MonkeyLib:MonkeyHacks:CreateSpawns", function()
    
        loadSpawnPoints()
    
    end )

end

do // Stop the demote! 

    hook.Add( "canDemote", "MonkeyLib:MonkeyHacks:StopDemote", function()
    
        return false 
    end )

end

do // Arrest batton cooldown 
    
    local arrestCooldown = 8 

    local arrestCooldowns = {}

    local arrestFailedStamp = "You can't arrest for another %d's"

    hook.Add( "canArrest", "MonkeyLib:MonkeyHacks:ArrestCooldown", function( ply )
    
        if ( not IsValid( ply ) ) then 

            return 
        end 

        local cooldown = arrestCooldowns[ply] or 0 

        do 

            cooldown = ( cooldown - CurTime() ) 
            cooldown = math.floor( cooldown )

        end

        if ( cooldown < 0 ) then
           
            return 
        end

        local errorMessage = arrestFailedStamp:format( cooldown )

        return false, errorMessage
    end )

    hook.Protect( "playerArrested", "MonkeyLib:MonkeyHacks:InitArrestCooldown", function(_, __, ply) 

        if ( not IsValid( ply ) ) then
            
            return 
        end

        arrestCooldowns[ply] = ( CurTime() + arrestCooldown )

    end )   

end

do // Stop ramming chairs! 

    local canRam = {

        ["prop_vehicle_prisoner_pod"] = false, 
    
    }
    
    hook.Add( "canDoorRam", "MonkeyLib:MonkeyHacks:StopTheRam", function( ply, _, chair )
    
        if ( not IsValid( ply ) or not IsValid( chair ) ) then 
            
            return  
        end 
    
        local class = chair:GetClass()

        return canRam[ class ]
    end )
end 

do // Hard block on the Give function 

    local oldGive 

    local giveFunc = function( ply, weaponID, noAmmo )

        assert( isfunction( oldGive ), "Old give function hasn't been instated!" )

        local succ = hook.Run( "MonkeyLib:CanGiveWeapon", ply, weaponID, noAmmo )

        if ( succ == false ) then 

            return 
        end

        return oldGive( ply, weaponID, noAmmo )
    end 

    hook.Protect( "Initialize", "MonkeyLib:MonkeyHacks:StopTheGive", function()
    
        oldGive = PLAYER.Give 

        PLAYER.Give = giveFunc 

    end )
    
end

do // Entity Blacklist 

    local blacklistedEntities = {
        ["gmod_contr_spawner"] = true,  
    }

    local entIsBlacklisted = function( ent )

        return ( IsValid( ent ) and ( blacklistedEntities[ ent:GetClass() ] == true ) )
    end

    hook.Protect( "OnEntityCreated", "MonkeyLib:MonkeyHacks:StopSpawningWeirdEnts", function( ent )
    
        if ( not IsValid( ent ) ) then 

            return 
        end

        local isBlacklisted = entIsBlacklisted( ent )

        if ( not isBlacklisted ) then 

            return 
        end

        timer.Simple( 0, function()

            if ( not IsValid( ent ) ) then 

                return 
            end

            SafeRemoveEntity( ent )

        end )

    end )
    
end

do // Weapon drop limiter 

    local canDrop = {}

    local setDrop = function( weapon )

        if ( not IsValid( weapon ) ) then 
            
            return 
        end 

        weapon.MonkeyLib_CanDrop = true 

    end 

    hook.Add( "canDropWeapon", "MonkeyLib:MonkeyHacks:CanDropWeapon", function( ply, weapon )

        if ( not IsValid( ply ) or not IsValid( weapon ) ) then 
            
            return 
        end 

        local foundClass = weapon:GetClass()

        local canDropWeapon = weapon.MonkeyLib_CanDrop

        do 

            canDropWeapon = ( ( canDrop[foundClass] == true ) and true ) or canDropWeapon 
  
        end

        if ( not canDropWeapon ) then 
            
            return false 
        end 
          
    end )

    hook.Add( "playerPickedUpWeapon", "MonkeyLib:MonkeyHacks:StoreDarkRPWeapon", function( ply, _, weapon ) 

        setDrop( weapon )

    end )

    hook.Add( "ItemStoreItemUsed", "MonkeyLib:MonkeyHacks:StoreInventorWeapon", function( ply, _, data )

        local itemData = data.Data 

        if ( not istable( itemData ) ) then 
            
            return 
        end 
        
        local weaponClass = itemData.Class 

        if ( not isstring( weaponClass ) ) then 
            
            return 
        end 

        local foundWeapon = ply:GetWeapon( weaponClass ) 
        
        if ( not IsValid( foundWeapon ) ) then 
            
            return 
        end 

        setDrop( foundWeapon )
       
    end )    

end

do // Stop frozen handcuffing / arresting / tazing 

    local canDo = function( ply )

        if ( not IsValid( ply ) ) then 
        
            return 
        end

        local isFrozen = ply:IsFrozen()

        if ( isFrozen ) then 
    
            return false 
        end
        
    end

    do // Interface 

        hook.Add( "PlayerCanTaze", "MonkeyLib:MonkeyHacks:CanTazeFrozen", function( _, frozenTarget )
    
            return canDo( frozenTarget )
        end )        
    
        hook.Add( "CuffsCanHandcuff", "MonkeyLib:MonkeyHacks:CanHandcuffFrozen", function( _, frozenTarget )

            return canDo( frozenTarget )
        end ) 
    
        hook.Add( "CanPlayerSuicide", "MonkeyLib:MonkeyHacks:CanFrozenSuicide", function( frozenTarget )
        
            return canDo( frozenTarget )
        end ) 

        hook.Add( "MPickPocket:CanPickPocket", "MonkeyLib:MonkeyHacks:CanFrozenSuicide", function( _, _, frozenTarget )
               
            return canDo( frozenTarget )
        end )

        hook.Add( "canArrest", "MonkeyLib:MonkeyHacks:CanArrestFrozen", function( _, frozenTarget )	
            
            if ( not IsValid( frozenTarget ) ) then return end 
    
            if ( frozenTarget:IsFrozen() and not frozenTarget:GetNWBool( "tazefrozen" ) ) then 
                
                return false 
            end 
    
        end )
    
    end

end

do // Prop Motion Disabler ( I hate this )

    local modelWhitelist = {}

    local shouldDisableMotion = function( ent )

        local entClass = ent:GetClass()
        
        if ( entClass ~= "prop_physics" ) then
            
            return false  
        end

        local owner = gProtect.GetOwner( ent )

        if ( not IsValid( owner ) ) then 

            return false 
        end

        local model = ent:GetModel() 

        local modelIsWhitelisted = modelWhitelist[model] or false 

        if ( modelIsWhitelisted ) then 

            return false 
        end

        return true 
    end

    local disableMotion = function( ent )
    
        if ( not IsValid( ent ) ) then 

            return 
        end

        local shouldDisable = shouldDisableMotion( ent )

        if ( not shouldDisable ) then 

            return 
        end 

        local phys = ent:GetPhysicsObject()
        
        if ( not IsValid( phys ) ) then 

            return 
        end

        phys:EnableMotion( false )

    end

    hook.Protect( "OnEntityCreated", "MonkeyLib:MonkeyHacks:DisableEntMotion", function( ent )
    
        local entClass = ent:GetClass()

        if ( entClass ~= "prop_physics" ) then 

            return 
        end

        timer.Simple( 0, function()

            disableMotion( ent )
            
        end )
        
    end )

    hook.Add( "PhysgunDrop", "MonkeyLib:MonkeyHacks:StopTheReEnableMotion", function( ply, ent  )

        if ( not IsValid( ply ) or not IsValid( ent ) ) then 

            return 
        end

        disableMotion( ent )

    end )

end

do // Unbreakable perma props!

    local filterDamage 

    local MakeFilterDamage = function() // Stolen from the Unbreakable tool, no clue if there's a better method. 
   
        local FilterDamage = ents.Create( "filter_activator_name" )
       
        FilterDamage:SetKeyValue( "TargetName", "FilterDamage" )
        FilterDamage:SetKeyValue( "negated", "1" )
        FilterDamage:Spawn()
       
        return FilterDamage
    end

    hook.Protect( "PermaProps.OnEntityCreated", "MonkeyLib:MonkeyHacks:UnbreakableEnts", function(ent)
    
        if ( not IsValid( ent ) ) then 
            
            return 
        end 

        if ( not IsValid( filterDamage ) ) then 
            
            filterDamage = MakeFilterDamage() 
        
        end 

        ent:Fire( "SetDamageFilter", "FilterDamage", 0 )

    end )
    
end

do // Stop prop damage 

    hook.Add( "EntityTakeDamage", "MonkeyLib:MonkeyHacks:StopEntKilling", function(ply, dmgInfo )

        if ( not IsValid( ply ) or not ply:IsPlayer() ) then return end 

        local inflictor = dmgInfo:GetInflictor()

        if ( not IsValid( inflictor ) ) then return end 

        if ( inflictor:IsPlayer() ) then return end 

        local isType = dmgInfo:IsDamageType( DMG_CRUSH + DMG_PREVENT_PHYSICS_FORCE )

        if ( isType ) then  

            return true 
        end
        
    end )
    
end

do // Share health between jobs 

    local oldTeamFunc = function()
        
        error( "Old Team function hasn't been Initialize." )
            
    end 

    // I prefer function overloading to modifying DarkRP. Especially for simple systems like this here. 
    local changeTeam = function( ply, ... ) 

        if ( not ply:Alive() ) then 
            
            oldTeamFunc( ply, ... )

            return 
        end 

        // Store our current Health / Armor 
        local currentHealth, currentArmor = ply:Health(), ply:Armor()

        oldTeamFunc( ply, ... )

        do // Sort our health / armor, make sure jobs that had 100 + hp are correctly formatted to the new jobs max hp. 

            local maxHealth, maxArmor = ply:GetMaxHealth(), ply:GetMaxArmor()

            currentHealth = math.Clamp( currentHealth, 0, maxHealth )      
    
            currentArmor = math.Clamp( currentArmor, 0, maxArmor )

        end
 
        // Set our Health / Armor.

        ply:SetHealth( currentHealth )

        ply:SetArmor( currentArmor )

    end 

    hook.Add( "DarkRPFinishedLoading", "MonkeyLib:MonkeyHacks:TeamHealthShare", function()

        oldTeamFunc = PLAYER.changeTeam

        PLAYER.changeTeam = changeTeam

    end )

end

do // God zone restrictions 
    
    local depotArea = function( ply )

        local foundArea = ply:GetArea() or "none"

        if ( foundArea == "none" ) then 

            return 
        end

        return AreaManager.areas[foundArea] or nil 
    end

    local zoneIsGod = function( zone )

        if ( not istable( zone ) ) then 

            return false 
        end 

        return zone.godmode or false 
    end 

    local isInSafeZone = function( ply )

        if ( not istable( AreaManager ) ) then 

            ErrorNoHaltWithStack( "Can't find area manager global table!" )

            return false 
        end

        local foundZone = depotArea( ply )

        return zoneIsGod( foundZone )
    end

    do // Interface 

        local canDo = function( ply, target )

            if ( ( not IsValid( ply ) or not IsValid( target ) ) or ( not ply:IsPlayer() or not target:IsPlayer() ) ) then 

                return 
            end
            
            local playersInZone = isInSafeZone( ply ) or isInSafeZone( target )

            if ( playersInZone ) then 

                return false
            end 

        end
 
        hook.Add( "canArrest", "MonkeyLib:SafeZone:CanArrest", canDo ) 

        hook.Add( "CuffsCanHandcuff", "MonkeyLib:SafeZone:CanCuff", canDo ) 

        hook.Add( "PlayerCanTaze", "MonkeyLib:SafeZone:CanTaze", canDo )

        hook.Add( "CanPlayerSuicide", "MonkeyLib:SafeZone:CanSuicide", function(ply )
        
            local safeZone = isInSafeZone( ply )

            if ( safeZone ) then 
                
                return false 
            end

        end )

        hook.Add( "ABT:CanShootBullet", "MonkeyLib:SafeZone:CanUseAdvancedBullets", function( ply, tr )
        
            if ( not IsValid( ply ) or not tr ) then 

                return 
            end

            local target = tr.Entity 

            if ( not IsValid( target ) or not target:IsPlayer() ) then 

                return 
            end 

            local applyBullet = canDo( ply, target )
            
            if ( applyBullet == false ) then 

                return false 
            end
            
        end )

    end
    
    do // MonkeyLib Wrapper 

        MonkeyLib.IsGodZone = zoneIsGod

        MonkeyLib.GetZone = depotArea 
    
        MonkeyLib.IsInSafeZone = isInSafeZone

    end
    
    do 

        local restrictedRankBypass = {

            ["Senior-Admin"] = true, 

            ["superadmin"] = true, 
            
            ["Head-Admin"] = true, 
            
        } 

        local restrictedZoneTag = "leaveusalonenoobs"

        local isRestrictedZone = function( zone )

            if ( not istable( zone ) ) then 

                return 
            end 

            local zoneTag = ( zone.uniquename or "" )

            return ( zoneTag:match( restrictedZoneTag ) == restrictedZoneTag )
        end

        hook.Protect( "PlayerChangedArea", "MonkeyLib:MonkeyHacks:LeaveUsAlone", function( ply, zone )
        
            if ( not IsValid( ply ) or not istable( zone ) ) then 

                return 
            end

            local isRestricted = isRestrictedZone( zone )
            
            if ( not isRestricted ) then 

                return 
            end

            local canEnter = restrictedRankBypass[ ply:GetUserGroup() ] or false
        
            if ( canEnter ) then 
               
                return 
            end

            ply:Spawn()

        end )

    end

end
