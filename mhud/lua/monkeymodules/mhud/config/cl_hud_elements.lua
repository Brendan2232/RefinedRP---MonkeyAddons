
local GUITheme = MonkeyLib:GetTheme()

local primaryTextColor, greenColor, redColor = GUITheme.primaryTextColor, GUITheme.greenColor, GUITheme.redColor

MonkeyHud = MonkeyHud or {}

MonkeyHud.RegisteredHudElements = MonkeyHud.RegisteredHudElements or {}

MonkeyHud.RegisterHudElement = function( drawOnTop, iconID, iconDrawColor, dataFunction, modifyFunc )

    if ( not isstring( iconID ) or not IsColor( iconDrawColor ) or not isfunction( dataFunction ) ) then 

        ErrorNoHaltWithStack( "Failed to register hud element, malformed arguments." )

        return 
    end
    
    local index = #MonkeyHud.RegisteredHudElements + 1

    MonkeyHud.RegisteredHudElements[index] = {

        ["HudPosition"] = drawOnTop, 
        ["IconID"] = iconID, 

        ["iconDrawColor"] = iconDrawColor, 
        ["Callback"] = dataFunction, 

        ["ModifyCallback"] = modifyFunc, 

    }
end

table.Empty( MonkeyHud.RegisteredHudElements )

do // I hate this, however it's cool. 

    local heartBeatSpeed = 8

    local redColor = redColor
    local lerpColor = primaryTextColor 
 
    local colorLerp = function( lerpSpeed, colorFrom, colorTo )

        local r = Lerp( lerpSpeed, colorFrom.r, colorTo.r )
            
        local g = Lerp( lerpSpeed , colorFrom.g, colorTo.g )
            
        local b = Lerp( lerpSpeed , colorFrom.b, colorTo.b )
    
        return Color( r, g, b, 255 )
    end

    MonkeyHud.RegisterHudElement( false, "MonkeyHud_HeartIcon", redColor, function( ply )
    
        local plyHealth = ply:Health()
     
        return math.max( plyHealth, 0 )

    end, function( ply, iconScale ) 

        local minIconScale = iconScale - 4

        local plyHealth, maxHealth = ply:Health(), ply:GetMaxHealth()

        local healthFrac = ( plyHealth / maxHealth )

        local sizeCur = iconScale
        
        do 

            local heartBeatFrac = ( maxHealth - plyHealth ) - ( maxHealth / 2 ) 

            heartBeatFrac = heartBeatFrac / maxHealth
            heartBeatFrac = math.max( heartBeatFrac, 0 ) 

            if ( heartBeatFrac > 0 ) then 

                sizeCur = math.sin( CurTime() * ( (heartBeatFrac + .125 ) * heartBeatSpeed ) ) * iconScale

                sizeCur = math.abs( sizeCur )
        
                sizeCur = math.Clamp( sizeCur, minIconScale, iconScale )

            end        
    
        end

        return nil, sizeCur, colorLerp( healthFrac, redColor, lerpColor)
    end )

end

MonkeyHud.RegisterHudElement( false, "MonkeyHud_ArmorIcon", Color(43, 53, 188), function( ply )
    
    local plyArmor = ply:Armor()

    return math.max( plyArmor, 0 )
end )

MonkeyHud.RegisterHudElement( true, "MonkeyHud_PlayerIcon", Color(200, 200, 200), function( ply )
    
    return team.GetName( ply:Team() ) or "NULL"
end )

MonkeyHud.RegisterHudElement( true, "MonkeyHud_WalletIcon", Color(200, 200, 200), function( ply )
    
    local playerMoney = MonkeyLib.GetMoney( ply ) or 0 

    return MonkeyLib.FormatMoney( playerMoney )
end )

MonkeyHud.RegisterHudElement( true, "MonkeyHud_DollarIcon", Color(45, 155, 18), function( ply )

    local salary = ply:getDarkRPVar("salary") or 0 

    return MonkeyLib.FormatMoney( salary )
end )


do
        
    local getLimtFunc 

    local propVar = "props"

    local formatProps = "%d / %s Props"

    MonkeyHud.RegisterHudElement( false, "MonkeyHud_PropIcon", Color(65, 118, 180), function( ply )

        if ( not isfunction( getLimtFunc ) ) then 

            getLimtFunc = ply.GetLimit  

            return 
        end 
        
        local propCount, maxProps = ( ply:GetCount( propVar ) or 0 ), ( getLimtFunc( ply, propVar ) or 0 )
    
        maxProps = ( maxProps == -1 and "Unlimited" ) or maxProps 

        return formatProps:format( propCount, maxProps )
    end )

end

MonkeyHud.RegisterHudElement( false, "MonkeyHud_Licence", Color(220, 110, 50), function( ply )
    
    local gunLicence = ply:getDarkRPVar( "HasGunlicense" )

    return gunLicence and "Gun Licence"
end )

MonkeyHud.RegisterHudElement( true, "MonkeyHud_WantedIcon", Color(206, 188, 55), function( ply )
    
    local isWanted = ply:isWanted()
    
    return isWanted and "Wanted" 
end )


