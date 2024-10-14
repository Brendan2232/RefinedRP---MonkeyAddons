include( "sh_config.lua" )
include( "shared.lua" )

local GUITheme = istable( MonkeyLib ) and MonkeyLib:GetTheme() or {}
 
local bodyColor = GUITheme.bodyColor or color_white  
local headerColor = GUITheme.headerColor or color_white 

local redColor = GUITheme.redColor or color_white 
local primaryTextColor = GUITheme.primaryTextColor or color_white 

local greenColor = GUITheme.greenColor or color_white 
local blueColor = Color(43, 23, 128)

local gapSize = 8 
local roundedAmount = 4

local primaryFont = "MonkeyLib_Inter_15"
local primaryFontHeight = draw.GetFontHeight( primaryFont )

local NPCText = HealthVendor.VendorText

local NPCTextFont = "MonkeyLib_Inter_100"
local NPCTextFontHeight = draw.GetFontHeight( NPCTextFont )

local NPCTextSpeed = 1.5
local NPCTextMoveOffset = 30

local NPCTextOffset = 70
local NPCTextMaxDrawDistance = 500

local squaredMaxDistance = NPCTextMaxDrawDistance * NPCTextMaxDrawDistance

local L = function( msg )

    return HealthVendor.Messages[msg] or msg 
end

local ply = LocalPlayer()

function ENT:Draw() 

    self:DrawModel()

	local mypos = self:GetPos()
	if ( ply:GetPos():DistToSqr( mypos ) >= squaredMaxDistance ) then return end

	local pos = mypos + ( self:GetUp() * 80 ) 

	local ang = ( ply:EyePos() - pos ):Angle()

	ang.p = 0

	ang:RotateAroundAxis( ang:Right(), 90 )
	ang:RotateAroundAxis( ang:Up(), 90 )
	ang:RotateAroundAxis( ang:Forward(), 180 )

	cam.Start3D2D( pos, ang, 0.04 )

        local textSin = math.abs( math.sin( CurTime() * NPCTextSpeed ) ) * NPCTextMoveOffset 
        
        draw.DrawText( NPCText, NPCTextFont, 0, -NPCTextFontHeight + ( NPCTextOffset + textSin ) , primaryTextColor, 1 )

	cam.End3D2D()
end

local createButton = function( parent, type, color )

    if ( not IsValid( parent ) or not isnumber( type ) ) then return end 

    local text = ( type == 1 ) and L"health_text" or L"armor_text"
 
    local price = ( type == 1 ) and HealthVendor.HealthPrice or HealthVendor.ArmorPrice

    local formattedPrice = MonkeyLib.FormatMoney( price )

    local button = parent:Add("DButton")
    button:SetText( "" )
    button:DockMargin( gapSize, gapSize, gapSize, 0 )

    local colorLerp = headerColor

    button.Paint = function( s, w, h )

        colorLerp = MonkeyLib.ColorLerp( colorLerp, s:IsHovered() and color or headerColor )

        draw.RoundedBox( roundedAmount, 0, 0, w, h, colorLerp )

        do // Draw our text 

            draw.DrawText( text, primaryFont, w / 2, h / 2 - primaryFontHeight, primaryTextColor, 1 )

            draw.DrawText( formattedPrice, primaryFont, w / 2, h / 2, greenColor, 1 )

        end

    end

    button.DoClick = function()

        if ( not MonkeyLib.CanAfford( ply, price ) ) then 

            MonkeyLib.FancyChatMessage( L"cant_afford", true, nil, ply )

            return 
        end

        net.Start( "MonkeyHealthVendor:PurchaseItem" )
            net.WriteUInt( type, 2 )
        net.SendToServer()

    end

    return button 
end

local minGUIWidth, minGUIHeight = 250, 150

local healthVendorGUI = function()

    local scrw, scrh = ScrW() * .15, ScrH() * .175

    local guiWidth = math.max( minGUIWidth, scrw )
    local guiHeight =  math.max( minGUIHeight, scrh )

    local frame = MonkeyLib:CreateDefaultFrame( guiWidth, guiHeight )

    local oldPaint = frame.Paint or function() end 

    frame.Paint = function( s, w, h )

		Derma_DrawBackgroundBlur( s )

        oldPaint( s, w, h )
    end

    local dockPanel = frame:Add( "DPanel" )
    dockPanel:Dock( FILL )
    dockPanel:InvalidateParent( true )

    dockPanel.Paint = function( s, w, h ) end 
    
    local height = dockPanel:GetTall() / 2 - ( gapSize * 2 - ( gapSize / 2 ) ) // I forgot the better method with docking, I am a SHIT CODER :(

    do 
        local healthButton = createButton( frame, 1, redColor )
        healthButton:Dock( TOP )
        healthButton:SetTall( height )

    end

    do 
        local armorButton = createButton( frame, 2, blueColor )
        armorButton:Dock( TOP )
        armorButton:SetTall( height )

    end
end

net.Receive( "MonkeyHealthVendor:SendGUI", healthVendorGUI )

hook.Add( "InitPostEntity", "MonkeyHealthVendor:InitLocalPlayer", function()

    ply = LocalPlayer()
    
end )


hook.Add( "MonkeyLib:ThemeReload", "MonkeyVendor:Health:ReloadTheme", function()

    GUITheme = MonkeyLib:GetTheme() or {}
 
    bodyColor = GUITheme.bodyColor or color_white  
    headerColor = GUITheme.headerColor or color_white 
    
    redColor = GUITheme.redColor or color_white 
    primaryTextColor = GUITheme.primaryTextColor or color_white 
    
    greenColor = GUITheme.greenColor or color_white 
    
end )