// This deathscreen needs to be tested properly. 

local scrw, scrh = ScrW(), ScrH()

local ply = LocalPlayer()

local viewPosMoveSpeed = .95
local viewPosDistance = 25 // Make sure this isn't set to high, else the camera will go through the floor ( possibly add an offset )

local removeDeathscreenTime = 0

local backdropLerp = scrh
local backdropLerpSpeed = 4 

local GUITheme = MonkeyLib:GetTheme()

local bodyColor, redColor = GUITheme.bodyColor, GUITheme.redColor

local backdropColor = ColorAlpha( bodyColor, 252 )
 
local colorWhite = Color(230, 230, 230)
local colorBlack = color_black 

local deathscreenHookID = "MonkeyHud:Utils:Deathscreen"

local primaryFont = "MonkeyLib_Inter_30"
local secondaryFont = "MonkeyLib_Inter_20"

local primaryFontHeight = 0 
local secondaryFontHeight = 0 

local deathTextColor = colorWhite
local deathTextLerpOffset = 10 

local respawnTextOffset = 8

local playerNameLenCap = 12
 
local cachedDeathMessage

local colorLerpSpeed = 1.5

local removeDeathscreen = function() // Time to reset everything!!

    deathscreenDrawing = false 

    deathTextColor = colorWhite 
    backdropLerp = scrh

    hook.Remove( "HUDPaint", deathscreenHookID )
    hook.Remove( "CalcView", deathscreenHookID )
    hook.Remove( "HUDShouldDraw", deathscreenHookID )

    hook.Run( "MonkeyHud:DeathscreenRemoved" )

end

local shadowText = function( text, font, x, y, offset, primaryTextColor, secondaryTextColor )

    draw.DrawText( text, font, x + offset, y + offset, secondaryTextColor, 1 )

    draw.DrawText( text, font, x, y, primaryTextColor, 1 )

end

local playerAlive = function() // This fixed 'Alive' being set too late, little hacky though. Though, why is 'health' being set earlier? 

    return ply:Health() > 0 and ply:Alive()
end

local drawDeathscreen = function( wasSuicide, attacker )

    // Player will more than likely respawn before the deathscreen is removed, however I don't want multiple useless server-messages. 

    if ( CurTime() >= removeDeathscreenTime or ( playerAlive() ) ) then removeDeathscreen() return end 

    backdropLerp = Lerp( FrameTime() * backdropLerpSpeed, backdropLerp, 0 )

    local roundedLerp = math.Round( backdropLerp )

    if ( deathTextLerpOffset >= roundedLerp  ) then 

        deathTextColor = MonkeyLib.ColorLerp( deathTextColor, redColor, colorLerpSpeed ) // Not good for performance, it's fun though!!

    end

    draw.RoundedBox( 0, 0, roundedLerp, scrw, scrh, backdropColor )
    
    do

        shadowText( cachedDeathMessage, primaryFont, scrw / 2, backdropLerp + ( scrh / 2 ) - primaryFontHeight / 2, 2, deathTextColor, colorBlack, 1 )

        local offset = ( wasSuicide or ( not IsValid( attacker ) or not attacker:IsPlayer() ) ) and primaryFontHeight or ( primaryFontHeight * 3 + respawnTextOffset )
        
        shadowText( "Respawning in " .. math.Round( removeDeathscreenTime - CurTime() ) .. "s" , secondaryFont, scrw / 2, backdropLerp + ( scrh / 2 ) + offset / 2, 2, colorWhite, colorBlack, 1 )

    end

end

local calculateViewPos = function( targetPlayer, pos, angles, fov )

    local sinGraph = math.sin( CurTime() * viewPosMoveSpeed ) * viewPosDistance // Might change this calculation. 

    local view = {
        origin = ( pos ) - ( angles:Forward() * sinGraph ),
        angles = angles,
        fov = fov,
        drawviewer = true
    }

    return view 
end

net.Receive( "MonkeyLib:DeathScreen:SendDeath", function( )

    ply = LocalPlayer() // I am unsure as to when the LocalPlayer state is initialized. 

    local wasSuicide = net.ReadBool()

    local attackerEnt 
  
    if ( not wasSuicide ) then attackerEnt = net.ReadEntity() end 

    if ( not wasSuicide and IsValid( attackerEnt ) and attackerEnt:IsPlayer() and IsValid( attackerEnt:GetActiveWeapon() ) ) then 

        local attackerWeapon = attackerEnt:GetActiveWeapon()
        local weaponName = attackerWeapon:GetPrintName()

        local attackerName = attackerEnt:Name()

        attackerName = string.len( attackerName ) > playerNameLenCap and string.sub( attackerName, 1, playerNameLenCap ) or attackerName
    
        cachedDeathMessage = string.format( MonkeyHud.Config.AttackMessage, attackerName, weaponName )

    else 

        cachedDeathMessage = wasSuicide and MonkeyHud.Config.SuicideMessage or MonkeyHud.Config.DeathMessage

    end

    removeDeathscreenTime = CurTime() + MonkeyHud.Config.RespawnTime

    hook.Run( "MonkeyHud:DeathscreenShown" ) // So we can do some funky stuff in the background. 

    hook.Add( "HUDPaint", deathscreenHookID, function() 

        drawDeathscreen( wasSuicide, attackerEnt )
        
    end )

    hook.Add( "CalcView", deathscreenHookID, calculateViewPos )

end )

hook.Add( "OnScreenSizeChanged", "MonkeyLib:DeathScreen:Rescale", function()

    scrw, scrh = ScrW(), ScrH()

end )

hook.Add( "Initialize", "MonkeyHud:DeathScreen:Init", function()

    scrw, scrh = ScrW(), ScrH()

    primaryFontHeight = draw.GetFontHeight( primaryFont )

    secondaryFontHeight = draw.GetFontHeight( secondaryFont )

end )


