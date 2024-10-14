// GUI Colors 

local GUITheme = MonkeyLib:GetTheme()

local bodyColor, headerColor, primaryTextColor, secondaryTextColor, greenColor, redColor = GUITheme.bodyColor, GUITheme.headerColor, GUITheme.primaryTextColor, GUITheme.secondaryTextColor, GUITheme.greenColor, GUITheme.redColor
local headerAbstract, headerSecondaryAbstract = GUITheme.headerAbstract_1, GUITheme.headerAbstract_2

// Cached functions 

local string = string 
local format = string.format 

local draw = draw 
local RoundedBox = draw.RoundedBox
local SimpleText = draw.SimpleText

local GetFontHeight = draw.GetFontHeight

local DrawText = draw.DrawText 

local surface = surface
local SetFont = surface.SetFont 

local GetTextSize = surface.GetTextSize

local SetMaterial = surface.SetMaterial 
local SetDrawColor = surface.SetDrawColor

local DrawTexturedRect = surface.DrawTexturedRect

local ScreenScale = ScreenScale 

local math = math 
local max = math.max 
local floor = math.floor

local ScrW = ScrW 
local ScrH = ScrH 

local DrawCachedCirlce = MonkeyLib.DrawCachedCirlce

local scrw, scrh = ScrW(), ScrH()

local hideHUDElements = MonkeyHud.Config.DisabledHuds

// Font Stuff

local primaryFont = "MonkeyLib_Inter_15"

local safeZoneFont = primaryFont 

local safeZoneFontSize = 12
 
local primaryFontWidth = draw.GetFontHeight( primaryFont )

// Don't modify these variables, they're editied in runtime 

local iconSize = primaryFontWidth + 1
local avatarSize = 50



local lawHideBind = KEY_F2
local lawHideText = "Press (%s) to hide" // %s is the lawHideBind key name 

// Our scale definitions 

local avatarScaleSize = 20

local minimumLineWidthSize = 100 

local minAvatarSize = 50 

local lawHeaderHeight = 30 

local lineHeight = 4

local minimumAmmoLineWidth = 20

local minimumLawWidth = 100

// Font Scale 

local fontScaleSize = 6

local minFontSize = 14 

local safeZoneFontScale = 4

// Offsets 

local avatarOffset = 8

local lawSizeOffset = 8 

local hudElementOffset = 8

local hudOffsetPos = 24 

local iconXOffset, iconYOffset = 4, 4
    
local safeZoneXOffset, safeZoneYOffset = 2, 16

// Misc definitions 

local lawLerpSpeed = 10 

//local cachedCircle = MonkeyLib.Circle( hudOffsetPos + ( avatarSize / 2 ), ( scrh - hudOffsetPos ) - ( avatarSize / 2 ), ( avatarSize / 2 ) )

// Monkey

local playerAvatar 

local ply = LocalPlayer()

local createPlayerAvatar = function()

    if ( IsValid( playerAvatar ) ) then playerAvatar:Remove() end

    local playerAvatarSize = avatarSize - avatarOffset

    playerAvatar = vgui.Create( "MonkeyLib:CircleAvatar" )
    playerAvatar:SetSize( playerAvatarSize, playerAvatarSize )
    playerAvatar:SetPos( hudOffsetPos + ( avatarOffset / 2 ), scrh - avatarSize - hudOffsetPos + ( avatarOffset / 2 )  )
    playerAvatar:SetPlayer( ply )
    
end

// Cached info for the drawAmmo function

local playerWeapon 

local weaponName = "NULL"
local weaponNameWidth = 0

local weaponMaxClip = 0
local weaponPrimaryAmmo = "NULL"

local cacheWeaponInfo = function( newWeapon )

    SetFont( primaryFont )

    playerWeapon = newWeapon

    weaponName = playerWeapon:GetPrintName() 
    
    weaponNameWidth = GetTextSize( weaponName )

    weaponPrimaryAmmo = playerWeapon:GetPrimaryAmmoType()

end

local lawHud, formatLawString

local reScaleHud = function()

    scrw, scrh = ScrW(), ScrH()

    local fontName = format( "MonkeyHud_HudFontCache_%s_%s", scrw, scrh )

    local fontScale = max( minFontSize, ScreenScale( fontScaleSize ) )

    do // Our Primary font!  

        surface.CreateFont( fontName, {
            font = "Inter Medium", 
            extended = false,
            size = fontScale,
            weight = 100,
        } )
    
    end

    
    do // Our safezone font 

        local safeZoneFontName = format( "MonkeyHud_HudFontCache_SafeZone_%s_%s", scrw, scrh )

        local safeZoneFontScale = max( safeZoneFontSize, ScreenScale( safeZoneFontScale ) )

        surface.CreateFont( safeZoneFontName, {
            font = "Inter Medium", 
            extended = false,
            size = safeZoneFontScale,
            weight = 100,
        } )

        safeZoneFont = safeZoneFontName
    end

    do // Handle our font - width 
        
        primaryFont = fontName

        primaryFontWidth = GetFontHeight( primaryFont )
        
    end

    do // Re-scale our avatar! 

        avatarSize = max( minAvatarSize, ScreenScale( avatarScaleSize ) )
        avatarSize = math.ceil( avatarSize )

    end

    do // Cache our circle and iconSize

        //  cachedCircle = MonkeyLib.Circle( hudOffsetPos + ( avatarSize / 2 ), ( scrh - hudOffsetPos ) - ( avatarSize / 2 ), ( avatarSize / 2 ) )

        iconSize = primaryFontWidth + 1

    end

    if ( IsValid( playerAvatar ) ) then 

        playerAvatar:Remove() 

        createPlayerAvatar()

    end

    if ( DarkRP and isfunction( formatLawString ) ) then 

        formatLawString()

    end 
end

do 
    // Don't modify these! 
    
    local lawLerpPos = 0 

    local showLaws = true 

    local lawString = ""

    local lawWidth, yPos = 0, 0  

    local lawHideCooldown = 0 

    formatLawString = function()

        if ( not istable( DarkRP ) ) then

            return 
        end

        SetFont( primaryFont )

        do  // Lets reset our variables 

            lawWidth = minimumLawWidth

            yPos = 0 
        
            lawString = ""

        end

        local laws = DarkRP.getLaws()

        for k = 1, #laws do 

            local lawRow = laws[k]

            if ( not isstring( lawRow ) ) then

                continue 
            end

            local formattedString = format( "%s. %s\n", k, lawRow )

            local stringWidth = GetTextSize( formattedString )

            lawWidth = max( lawWidth, stringWidth ) 
        
            // Thanks DarkRP! 
            yPos = yPos + ( fn.ReverseArgs( string.gsub( lawRow, "\n", "" ) ) + 1) * primaryFontWidth

            lawString = lawString .. formattedString 

        end
        
    end
 
    lawHud = function()

        local lawSizeMultiplier = ( lawSizeOffset * 2 )

        local elementWidth = lawWidth + lawSizeMultiplier

        local elementHeight = ( ( lawHeaderHeight + yPos ) + lawSizeMultiplier ) + lawSizeOffset

        lawLerpPos = Lerp( FrameTime() * lawLerpSpeed, lawLerpPos, showLaws and 0 or -elementHeight )

        do // Body  

            RoundedBox( 0, 0, lawLerpPos, elementWidth, ( lawHeaderHeight + yPos ) + ( lawSizeMultiplier ), bodyColor )

        end

        do  // Header 

        
            RoundedBox( 0, 0, lawLerpPos, elementWidth, lawHeaderHeight, headerColor )

            DrawText( lawHideText, primaryFont, lawSizeOffset, lawLerpPos + lawSizeOffset, secondaryTextColor, TEXT_ALIGN_LEFT ) 

        end
    
        DrawText( lawString, primaryFont, lawSizeOffset, lawLerpPos + ( lawHeaderHeight + lawSizeOffset ), primaryTextColor, TEXT_ALIGN_LEFT )

    end

    do // Law Hooks! 

        hook.Protect( "addLaw", "MonkeyHud:LawHud:ResetLaws", formatLawString ) 

        hook.Protect( "removeLaw", "MonkeyHud:LawHud:ResetLaws", formatLawString )
    
        hook.Protect( "resetLaws", "MonkeyHud:LawHud:ResetLaws", formatLawString ) 
        
        hook.Protect( "PlayerButtonDown", "MonkeyHud:LawHud:Toggle", function( _, btn )
    
            if ( btn ~= lawHideBind ) then return end
    
            if ( CurTime() < lawHideCooldown ) then return end
            
            showLaws = not showLaws
    
            lawHideCooldown = CurTime() + .2

        end ) 

    end

end

local drawAmmo = function()
    
    local playerNewWeapon = ply:GetActiveWeapon()
    if ( not IsValid( playerNewWeapon ) ) then return end 
    
    /// I hate this, unfortunatly there's no hooks on the client that can provide an actual weapon switch. ( There are hooks that claim to do this, however they don't always properly update on the client )
    if ( playerWeapon == nil or playerWeapon ~= playerNewWeapon ) then 
        
        cacheWeaponInfo( playerNewWeapon ) 
    
    end

    if ( not IsValid( playerWeapon ) ) then return end 

    local weaponMaxClip = ply:GetAmmoCount( weaponPrimaryAmmo ) or 0 
    
    local weaponAmmo = playerWeapon:Clip1()

    if ( weaponAmmo <= 0 and ( weaponMaxClip <= 0 ) ) then return end 

    SetFont( primaryFont )
 
    local clipString = format( "%s / %s", weaponAmmo, weaponMaxClip )

    local clipLengthWidth = GetTextSize( clipString )
 
    local ammoLineWidth

    do 

        ammoLineWidth = ( weaponNameWidth > clipLengthWidth ) and weaponNameWidth or clipLengthWidth

        ammoLineWidth = ( ( ammoLineWidth > minimumAmmoLineWidth ) and ammoLineWidth or minimumAmmoLineWidth ) + hudElementOffset 

    end

    do // Draw our ammo box 

        local avatarSizeDivider = ( avatarSize / 2 )
        local lineSizeDivider = ( lineHeight / 2 )

        local textXPos = ( scrw - ammoLineWidth ) + ( ammoLineWidth / 2 ) - hudOffsetPos  

        local scrhOffset = ( scrh - hudOffsetPos )
    
        DrawText( clipString, primaryFont, textXPos, scrhOffset - lineSizeDivider - avatarSizeDivider - primaryFontWidth , primaryTextColor, 1 )
    
        DrawText( weaponName, primaryFont, textXPos, scrhOffset + lineSizeDivider - avatarSizeDivider, primaryTextColor, 1 )
    
        RoundedBox( 0, ( scrw - ammoLineWidth ) - hudOffsetPos, scrhOffset - lineSizeDivider - avatarSizeDivider, ammoLineWidth, lineHeight, bodyColor )

    end


end

local drawSafeZone 

do // Draw our safe zone text
    
    local outlinedTextOffset = 1

    local outlinedTextColor = color_black 
    
    local safeZoneGreenColor = Color(0, 255, 60)
    local safeZone = false

    local safeZoneText = "Safe Zone"

    local drawOutlinedText = function( text, font, x, y, color )

        SimpleText( text, font, x + outlinedTextOffset, y + outlinedTextOffset, outlinedTextColor, TEXT_ALIGN_LEFT, 1 )

        SimpleText( text, font, x, y, color, TEXT_ALIGN_LEFT, 1 )

    end

    drawSafeZone = function()
        
        if ( not safeZone ) then return end  

        drawOutlinedText( safeZoneText, safeZoneFont, safeZoneXOffset, ( scrh / 2 ) + safeZoneYOffset, safeZoneGreenColor )
    end 

    net.Receive( "MonkeyHud:SafeZone:StateChanged", function()
    
        safeZone = net.ReadBool()

    end )

end

local drawHud = function()

    if ( not IsValid( ply ) ) then ply = LocalPlayer() return end 

    if ( not IsValid( playerAvatar ) ) then createPlayerAvatar() end
    
    if ( not ply:Alive() ) then return end 

    do // Draw the cirle backdrop  

        local circleMaterial = MonkeyLib:GetIcon( "MonkeyHud_Circle" )

        local avatarX, avatarY = hudOffsetPos, ( scrh - hudOffsetPos ) - ( avatarSize )

        surface.SetMaterial( circleMaterial )
            surface.SetDrawColor( bodyColor )
        surface.DrawTexturedRect( avatarX, avatarY, avatarSize, avatarSize )

    end

    local firstXPos, secondXPos = 0, 0

    do // I know this entire calculation isn't good for performance, however it just makes adding elements to the hud soo much easier. 

        local hudElements = MonkeyHud.RegisteredHudElements or {}

        for k = 1, #hudElements do 
    
            local hudRow = hudElements[k]
            if ( not hudRow ) then continue end 
    
            local dataFunction, modifyFunction, iconID, hudPosition = hudRow.Callback, hudRow.ModifyCallback, hudRow.IconID, hudRow.HudPosition or false 
            if ( not isfunction( dataFunction ) ) then continue end 

            local data = dataFunction( ply )
            if ( not data ) then continue end 
                        
            local iconRowColor = hudRow.iconDrawColor or primaryTextColor 

            local iconScaleOffset, iconColor, iconScale, textColor = 0, iconRowColor, iconSize, primaryTextColor

            if ( isfunction( modifyFunction ) ) then 

                iconColor, iconScale, textColor = modifyFunction( ply, iconSize, data )

                iconScale = math.Clamp( iconScale or 0, 0, iconSize )
                
                local xPos = iconSize - iconScale 

                iconScaleOffset = xPos / 2 

            end
            // I am so so sorry to anyone that has to maintain this code. I have no clue on what's going on either.  

            local foundIcon = MonkeyLib:GetIcon( iconID )

            local textXPos = ( hudOffsetPos + avatarSize ) + ( hudPosition and firstXPos or secondXPos ) + ( hudElementOffset )

            local iconPositionOffset = ( ( iconSize + lineHeight ) + iconYOffset ) / 2

            local elementOffset = ( scrh - hudOffsetPos ) - ( avatarSize / 2 )
            
            local iconYPos = elementOffset + ( ( hudPosition and -iconPositionOffset or iconPositionOffset ) ) 
            local textYPos =  elementOffset + ( ( hudPosition and -iconPositionOffset  or iconPositionOffset  ) ) 

            do  // Draw our icon 

                SetMaterial( foundIcon )
                    SetDrawColor( iconColor or iconRowColor )
                DrawTexturedRect( textXPos + iconScaleOffset , iconYPos - iconScale / 2, iconScale or iconSize, iconScale or iconSize )

            end

            do  // Calculate the rows X position, and draw the text...

                local dataWidth = SimpleText( data, primaryFont, textXPos + iconSize + iconXOffset, textYPos, textColor or primaryTextColor, TEXT_ALIGN_LEFT, 1 ) or 0 

                dataWidth = dataWidth + ( hudElementOffset ) + ( iconSize + iconXOffset )
        
                if ( hudPosition ) then 
        
                    firstXPos = firstXPos + dataWidth 
        
                    continue 
                end
        
                secondXPos = secondXPos + dataWidth  

            end

        end 

    end

    do 
        // These calculations are AWFUL to perform every frame, could possibly implement some cache - reset system.

        local lineWidth = firstXPos > secondXPos and firstXPos or secondXPos
        lineWidth = ( ( lineWidth < minimumLineWidthSize ) and minimumLineWidthSize or lineWidth ) + ( hudElementOffset )

        RoundedBox( 0, hudOffsetPos + avatarSize, ( scrh - hudOffsetPos ) - ( lineHeight / 2 ) - ( avatarSize / 2 ), lineWidth, lineHeight, bodyColor )

    end

    do  // Lets draw our other elements! 

        drawSafeZone()

        drawAmmo()

        lawHud()

    end

end

do // Our hooks! 

    hook.Add( "MonkeyHud:DeathscreenShown", "MonkeyHud:Hud:ShowHud", function()

        if ( not IsValid( playerAvatar ) ) then return end 
    
        playerAvatar:SetVisible( false )
    
    end )
    
    hook.Add( "MonkeyHud:DeathscreenRemoved", "MonkeyHud:Hud:RemoveHud", function()
    
        if ( not IsValid( playerAvatar ) ) then return end 
    
        playerAvatar:SetVisible( true )
    
    end )
    
    hook.Add( "HUDPaint", "MonkeyHud:Hud:Paint", function()

        drawHud()
    end )

    hook.Add( "OnScreenSizeChanged", "MonkeyHud:Hud:RescaleElements", function()
    
        reScaleHud()
    
    end )
    
    hook.Add( "Initialize", "MonkeyHud:Hud:InitScale", function()
    
        reScaleHud()
    
        do  // Format our law text, moved it down here to make the code a tad bit cleaner. 
        
            local lawHideKeyName = input.GetKeyName( lawHideBind )
        
            lawHideText = lawHideText:format( lawHideKeyName )
    
        end 
    
    end )
    
    hook.Add( "HUDShouldDraw", "MonkeyHud:Hud:DisableHuds", function(name )
    
        if hideHUDElements[name] then return false end
    
    end )
        
end
