local mouseXFunc, mouseYFunc = gui.MouseX, gui.MouseY

local headerHeight = 30 

local gapSize = 8 

local animationTime = .3 

local defaultRoundedAmount = 8 

local closeButtonOffset = 12

local headerFont = "MonkeyLib_Inter_17"

local GUITheme = MonkeyLib:GetTheme()
 
local bodyColor = GUITheme.bodyColor 
local headerColor = GUITheme.headerColor 

local redColor = GUITheme.redColor 
local primaryTextColor = GUITheme.primaryTextColor

local PANEL = {}

AccessorFunc( PANEL, "header_title", "HeaderTitle", FORCE_STRING )

function PANEL:Init()

    local frame = self 
    
    frame.roundedAmount = defaultRoundedAmount 

    local headerTitleFunc = self.GetHeaderTitle

    frame.OpenAnimation = function( s )

        if ( not IsValid( s ) ) then return end 
  
        s:Stop()

        s:SetAlpha( 0 )

        s:AlphaTo( 255, animationTime, 0 )

    end

    frame.CloseAnimation = function( s )

        if ( not IsValid( s ) ) then return end 

        s:Stop()

        s:AlphaTo( 0, animationTime, 0, function( )
        
            if ( not IsValid( s ) ) then return end 

            s:Remove()
        end )
  
    end

    local header = frame:Add( "DPanel" )
    header:Dock( TOP )
    header:SetHeight( headerHeight )

    frame.header = header 
    
    header.Paint = function( s, w, h )
        
        draw.RoundedBoxEx( frame.roundedAmount or defaultRoundedAmount, 0, 0, w, h, headerColor, true, true, false, false )

        draw.SimpleText( headerTitleFunc( self ) or "MonkeyLib", headerFont, gapSize, h / 2, primaryTextColor, TEXT_ALIGN_LEFT, 1 )

        if ( s:IsHovered() ) then s:SetCursor( "sizeall" ) else s:SetCursor( "arrow" ) end 

    end

    header.OnMousePressed = function()

        frame.Dragging = { mouseXFunc() - frame.x, mouseYFunc() - frame.y }

    end
    
    header.OnMouseReleased = function()

        frame.Dragging = nil 

    end
    
    local colorLerp = MonkeyLib.ColorLerp
    local closeButtonMaterial = MonkeyLib:GetIcon( "m_close" )

    local closeButton = header:Add( "DButton" )
    closeButton:Dock( RIGHT )
    closeButton:SetWide( header:GetTall() )
    closeButton:SetText( " " )

    closeButton.DoClick = function( s )

        if ( not IsValid( frame ) ) then return end 

        frame:CloseAnimation()
    end

    closeButton.ColorLerp = 0  

    closeButton.Paint = function( s, w, h )

        s.ColorLerp = colorLerp( s.ColorLerp, s:IsHovered() and redColor or color_white )

        surface.SetMaterial( closeButtonMaterial )
            surface.SetDrawColor( s.ColorLerp  )
        surface.DrawTexturedRect( w / 2 - closeButtonOffset / 2, h / 2 - closeButtonOffset / 2, closeButtonOffset, closeButtonOffset )

    end
end

function PANEL:Paint( w, h )

    draw.RoundedBox( self.roundedAmount or defaultRoundedAmount, 0, 0, w, h, bodyColor )

end

function PANEL:Think()

    if ( not self.Dragging ) then return end 

    local mouseX = mouseXFunc()
    local mouseY = mouseYFunc()

    local x = mouseX - self.Dragging[1]
    local y = mouseY - self.Dragging[2]

    self:SetPos( x, y )

end

derma.DefineControl( "MonkeyLib:Frame", "MonkeyLib", PANEL, "EditablePanel" )

function MonkeyLib:CreateDefaultFrame( width, height )

    local frame = vgui.Create( "MonkeyLib:Frame" )
    frame:SetSize( width or 500, height or 500 )
    frame:Center()
    frame:MakePopup()
    frame:SetHeaderTitle( "RefinedRP" )

    if ( isfunction( frame.OpenAnimation ) ) then frame:OpenAnimation() end 

    return frame 
end

hook.Add( "MonkeyLib:ThemeReload", "MonkeyLib:Frame:ReloadTheme", function()
    
    GUITheme = MonkeyLib:GetTheme()
 
    bodyColor = GUITheme.bodyColor 
    headerColor = GUITheme.headerColor 
    
    redColor = GUITheme.redColor 
    primaryTextColor = GUITheme.primaryTextColor

end )