local GUITheme = MonkeyLib:GetTheme()

local greenColor, redColor = GUITheme.greenColor, GUITheme.redColor
local primaryTextColor, secondaryTextColor = GUITheme.primaryTextColor, GUITheme.secondaryTextColor 

local primaryFont = "MonkeyLib_Inter_15"

local closeLerpSpeed = 10 

local gapSize = 4
local toolTipAlphaSpeed = .3 

local currentToolTip 

local messageAnimationTime = .3 
local messageRemoveDelay = 2 

local messageGapSize = 8

local messageHeight = 30 + messageGapSize
local messageYOffset = messageGapSize * 2

local messageRoundedAmount = 4
local messageFont = "MonkeyLib_Inter_20"

local removeMessagePanel = function( s, delay )

    local panelHeight = s:GetTall()

    s:MoveTo( s:GetX(), -( panelHeight + messageYOffset ), messageAnimationTime, delay and messageRemoveDelay or .25, -1, function( _, pnl )
        
        if ( not IsValid( pnl ) ) then return end 

        pnl:Remove()

    end )
end

local messagePanel

MonkeyLib.CreateMessage = function( message, isError )

    if ( not isstring( message ) ) then return end 

    surface.SetFont( messageFont )

    local messageWidth = surface.GetTextSize( message ) + ( messageGapSize * 2 )

    local scrw, scrh = ScrW(), ScrH()

    if ( IsValid( messagePanel ) ) then 

        messagePanel:Stop( )

        removeMessagePanel( messagePanel, false, true )

    end

    local newMessage = vgui.Create( "DPanel" )
    newMessage:SetSize( messageWidth, messageHeight )
    newMessage:SetPos( ( scrw / 2 ) - ( newMessage:GetWide() / 2 ), -newMessage:GetTall() )

    newMessage:SetAlpha( 0 )
    newMessage:AlphaTo( 255, messageAnimationTime, 0 )

    newMessage:SetDrawOnTop( true )
    newMessage:MoveTo( newMessage:GetX(), messageYOffset, messageAnimationTime, 0, -1 )

    local panelColor = isError and redColor or greenColor
    
    newMessage.Paint = function( s, w, h )

        draw.RoundedBox( messageRoundedAmount, 0, 0, w, h, panelColor )

        draw.SimpleText( message, messageFont, w / 2, h / 2, primaryTextColor, 1, 1 )

    end

    messagePanel = newMessage 

    removeMessagePanel( newMessage, true, true )
    
end

// Replace this function either with a meta-method, or use the new gmod function. 

MonkeyLib.ColorLerp = function( lerpColor, colorTo, lerpSpeed ) // This function isn't good for performance, shouldn't be used a lot.
    
    if ( not IsColor( lerpColor ) or not IsColor( colorTo ) ) then return color_white end
    
    local frameTimeSpeed = ( FrameTime() * ( lerpSpeed or closeLerpSpeed ) ) 

    local r = Lerp( frameTimeSpeed, lerpColor.r, colorTo.r )
        
    local g = Lerp( frameTimeSpeed, lerpColor.g, colorTo.g )
        
    local b = Lerp( frameTimeSpeed, lerpColor.b, colorTo.b )

    return Color( r, g, b, 255 )
end

MonkeyLib.Circle = function( x, y, radius, seg, percent )

    if ( not isnumber( x ) or not isnumber( y ) or not isnumber( radius ) ) then return false end

    seg = isnumber( seg ) and seg or 64  

    percent = isnumber( percent ) and percent or -360  

    local circle = {}

    for k = 0, seg do

        local t = math.rad( k / seg * percent )
        
        table.insert( circle, { x = math.sin( t ) * radius + x, y = math.cos( t ) * radius + y } )

    end

    return circle 
end

MonkeyLib.DrawCachedCirlce = function( cachedCircle, color )
    
    if ( not cachedCircle or not color ) then return end 

    surface.SetDrawColor( color )

        draw.NoTexture()

    surface.DrawPoly( cachedCircle )

end

local createToolTip = function( toolPanel, toolTipTable )

    if ( not IsValid( toolPanel ) or not istable( toolTipTable ) ) then return end 
    
    if ( IsValid( currentToolTip ) ) then 
    
        currentToolTip:Stop( )

        currentToolTip:AlphaTo( 0, toolTipAlphaSpeed, 0, function( _, s )

            if ( not IsValid( s ) ) then return end 

            s:Remove()
        
        end )

    end 

    local text, showDelay, font, textColor, bodyColor = toolTipTable.text, toolTipTable.showDelay or 0, toolTipTable.font or "MonkeyLib_Inter_15", toolTipTable.textColor, toolTipTable.bodyColor 
    if ( not isstring( text ) or not IsColor( textColor ) or not IsColor( bodyColor ) ) then return end 

    local showTime = toolPanel.EnterTime or 0 
    
    local toolTip = vgui.Create( "DPanel" )
    toolTip:SetDrawOnTop( true )

    toolTip:SetAlpha( 0 )
    toolTip:AlphaTo( 255, toolTipAlphaSpeed, showDelay )

    toolTip.Paint = function( s, w, h )

        draw.RoundedBox( 4, 0, 0, w, h, bodyColor )

    end

    toolTip.Think = function( s )

        if ( not IsValid( toolPanel ) ) then s:Remove() return end 

        s:SetPos( gui.MouseX() - ( s:GetWide() / 2 ),  gui.MouseY() - ( s:GetTall() ) - 8  )

    end

    local textLabel = toolTip:Add("DLabel")
    textLabel:SetContentAlignment( 5 )
    textLabel:SetText( text )
    textLabel:SetFont( font )
    textLabel:SetTextColor( textColor )
    textLabel:SizeToContents()

    toolTip:InvalidateLayout( true )
    toolTip:SizeToChildren( true, true )

    local toolTipWidth, toolTipHeight = toolTip:GetSize()

    toolTip:SetSize( toolTipWidth + gapSize, toolTipHeight + gapSize )
    textLabel:Center()

    currentToolTip = toolTip 

    return toolTip 
end

MonkeyLib.ToolTip = function( panel, text )

    if ( not IsValid( panel ) or ( not isstring( text ) and not istable( text ) ) ) then return end 

    if ( isstring( text ) ) then  

        local newTextStruct = {

            text = text, 
            font = primaryFont, 

            showDelay = .5, 

            textColor = color_white, 
            bodyColor = Color(50, 170, 39)
            
        }

        text = newTextStruct
    end
    
    local oldCursorEnter = panel.OnCursorEntered
    local oldCursorExit = panel.OnCursorExited

    panel.OnCursorEntered = function( s )

        if ( not IsValid( s ) ) then return end 

        createToolTip( s, text )

        if ( isfunction( oldCursorEnter ) ) then 
            
            oldCursorEnter( s )
             
        end 
    end 

    panel.OnCursorExited = function( s )
    
        if ( not IsValid( s ) ) then return end 

        if ( IsValid( currentToolTip ) ) then 

            currentToolTip:Stop()

            currentToolTip:AlphaTo( 0, toolTipAlphaSpeed, 0, function( _, toolTip )

                if ( IsValid( toolTip ) ) then toolTip:Remove() end 

            end )    
        end 

        if ( isfunction( oldCursorExit ) ) then oldCursorExit( s ) end 
    end 
end

MonkeyLib.DermaMenu = function( options, optionInfo )

    if ( not istable( options ) or not optionInfo ) then return end 

    local newMenu = DermaMenu( false )

    local ply = LocalPlayer()

    for k = 1, #options do 

        local option = options[k]
        if ( not istable( option ) ) then continue end 
        
        local Name, Callback, canSee = option.Name, option.Callback, option.CanSee
   
        if ( not isstring( Name ) or not isfunction( Callback ) ) then continue end 
        
        if ( isfunction ( canSee ) ) then
            
            local succ, err = pcall( canSee, ply, optionInfo )

            if ( not succ and err ) then ErrorNoHaltWithStack( err ) continue end 

            if ( not err ) then continue end // Error also returns the output  

        end

        if ( k ~= 1 ) then newMenu:AddSpacer() end 

        local newOption = newMenu:AddOption( Name, function()
           
            local succ, err = pcall( Callback, optionInfo )

            if ( not succ and err ) then 

                ErrorNoHaltWithStack( err )

                return 
            end
        end )

    end 

    return newMenu
end

hook.Add( "MonkeyLib:ThemeReload", "MonkeyLib:VGUI:ReloadTheme", function( themeIndex )
    
    GUITheme = MonkeyLib:GetTheme()

    primaryTextColor, secondaryTextColor, greenColor, redColor = GUITheme.primaryTextColor, GUITheme.secondaryTextColor, GUITheme.greenColor, GUITheme.redColor

end )