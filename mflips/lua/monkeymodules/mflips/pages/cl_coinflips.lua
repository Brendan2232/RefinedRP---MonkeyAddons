local minimumFlipPrice, maximumFlipPrice = MonkeyFlips.MinimumFlipPrice, MonkeyFlips.MaximumFlipPrice

local primaryFont = "MonkeyLib_Inter_15"
local primaryFontHeight = draw.GetFontHeight( primaryFont )

local gapSize = 8 
local panelHeight = 40

local buttonHeight = 34

local GUITheme = MonkeyLib:GetTheme()

local bodyColor, headerColor, primaryTextColor, secondaryTextColor, greenColor, redColor = GUITheme.bodyColor, GUITheme.headerColor, GUITheme.primaryTextColor, GUITheme.secondaryTextColor, GUITheme.greenColor, GUITheme.redColor
local headerAbstract, headerSecondaryAbstract = GUITheme.headerAbstract_1, GUITheme.headerAbstract_2

local noFlipPanelFont = "MonkeyLib_Inter_17"
local noFlipPanelText = "No Active Flips"

local playerNameCap = 12

local iconOffset = 20

local function L( message )

    return MonkeyFlips.Messages[message] or message 
end

local noFlipPanel = function( parent )

    if ( not IsValid( parent ) ) then return end 

    local noFlips = parent:Add( "DPanel" )
    noFlips:Dock( TOP )
    noFlips:SetTall( panelHeight ) 

    noFlips.Paint = function( s, w, h )

        draw.SimpleText( noFlipPanelText, noFlipPanelFont, w / 2, h / 2, secondaryTextColor, 1, 1 )

    end

    parent.noFlips = noFlips 
end

local PANEL = {}

function PANEL:AddCoinflip( info )

    if ( not istable( info ) ) then return end 

    local ply = LocalPlayer()

    local scrollBar = self.scrollBar 
    if ( not IsValid( scrollBar ) ) then return end 

    local flipID, flipCreator, flipPrice = info.flipID, info.steamID64, info.price 
    if ( not isnumber( flipID ) or not MonkeyLib.isSteamID64( flipCreator ) or not isnumber( flipPrice ) ) then return end 

    local noFlipPanel = self.noFlips
    if ( IsValid( noFlipPanel ) ) then noFlipPanel:Remove() end 

    local creatorName, formattedMoney = "NULL", MonkeyLib.FormatMoney( flipPrice )

    local flipOwner = ( flipCreator == ply:SteamID64() and true )  
    
    MonkeyLib.GetName( flipCreator, function( name )

        creatorName = name 

        if ( MonkeyLib.StringCap( creatorName, playerNameCap ) ) then

            creatorName = ( creatorName:sub( 1, playerNameCap ) .. "..." )
    
        end
        
    end )

    local flipRow = scrollBar:Add( "DPanel" ) 
    flipRow:Dock( TOP )
    flipRow:SetTall( panelHeight )

    flipRow.colorAbstract = self.colorAbstract

    flipRow.Paint = function( s, w, h )

        draw.RoundedBox( 0, 0, 0, w, h, s.colorAbstract and headerAbstract or headerSecondaryAbstract )

        draw.SimpleText( creatorName, primaryFont, h, h / 2 - primaryFontHeight / 2, primaryTextColor, TEXT_ALIGN_LEFT, 1 )

        draw.SimpleText( formattedMoney, primaryFont, h, h / 2 + primaryFontHeight / 2, greenColor, TEXT_ALIGN_LEFT, 1 )
        
    end

    do 

        local avatarOffset = gapSize / 2

        local playerAvatar = flipRow:Add( "MonkeyLib:CircleAvatar" )
        playerAvatar:Dock( LEFT )
        playerAvatar:SetWide( flipRow:GetTall() - gapSize )
        playerAvatar:DockMargin( avatarOffset, avatarOffset, avatarOffset, avatarOffset )

        playerAvatar:SetSteamID( flipCreator )

    end

    do 

        local playFlipIcon, deleteFlipIcon = MonkeyLib:GetIcon( "m_coinflip_play" ), MonkeyLib:GetIcon( "m_coinflip_delete" )

        local actionMaterial = flipOwner and deleteFlipIcon or playFlipIcon
                
        local actionDefaultColor = flipOwner and redColor or primaryTextColor // Just so it's easier to identify. 

        local flipActionButton = flipRow:Add( "DButton" )
        flipActionButton:Dock( RIGHT )
        flipActionButton:SetWide( flipRow:GetTall() )
        flipActionButton:SetText( " " ) 

        flipActionButton.LerpColor = actionDefaultColor

        flipActionButton.DoClick = function()

            if ( flipOwner ) then

                MonkeyNet.WriteStructure( "MonkeyFlips:Send:DeleteFlip", MonkeyFlips.NetStructure.DeleteFlip, { flipID } )

                return 
            end 
       
            if ( not MonkeyLib.CanAfford( ply, flipPrice ) ) then 
                             
                MonkeyLib.FancyChatMessage( L"cant_afford", true, { "join" } )
    
                return 
            end
        
            MonkeyNet.WriteStructure( "MonkeyFlips:Send:JoinFlip", MonkeyFlips.NetStructure.JoinFlip, { flipID } )
        end

        flipActionButton.Paint = function( s, w, h )

            s.LerpColor = MonkeyLib.ColorLerp( s.LerpColor, s:IsHovered() and greenColor or actionDefaultColor ) // Not good for performance, fun though..

            surface.SetDrawColor( s.LerpColor )
                surface.SetMaterial( actionMaterial )
            surface.DrawTexturedRect( iconOffset / 2, iconOffset / 2, w - iconOffset, h - iconOffset )

        end
        
        MonkeyLib.ToolTip( flipActionButton, flipOwner and "Delete me!" or "Join me!" )

    end

    self.colorAbstract = not self.colorAbstract

    return flipRow 
end

function PANEL:RemoveCoinflip( index )

    if ( not isnumber( index ) ) then return end 

    local scrollBar = self.scrollBar 
    if ( not IsValid( scrollBar ) ) then return end 

    local children = scrollBar:GetChildren()[1]:GetChildren()
    
    local foundChild = children[index]
    if ( not IsValid( foundChild ) ) then return end 

    foundChild:Remove()

    if ( ( #children - 1 ) >= 1 ) then 

        self.colorAbstract = false 
    
        for k = 1, #children do 
    
            local childRow = children[k]
            if ( not IsValid( childRow ) ) then continue end 
    
            childRow.colorAbstract = self.colorAbstract
            
            self.colorAbstract = not self.colorAbstract
        end

    else 
        
        noFlipPanel( self )
        
    end
end

function PANEL:Init()

    local ply = LocalPlayer()

    self.colorAbstract = false 

    self:Dock( FILL )

    self:InvalidateParent( true )
    self:DockPadding( gapSize, 0, gapSize, gapSize )

    local toolBar = self:Add("DPanel") 
    toolBar:Dock( TOP )
    toolBar:SetTall( buttonHeight )

    toolBar.Paint = function() end 

    self.toolBar = toolBar  

    do 

        local priceError = false 

        local priceBar = toolBar:Add( "DTextEntry" )
        priceBar:Dock( FILL )
        priceBar:DockMargin( 0, 0, gapSize, 0 )

        priceBar:SetTextColor( primaryTextColor )
        priceBar:SetFont( primaryFont )
        priceBar:SetNumeric( true )

        priceBar.Paint = function( s, w, h )

            draw.RoundedBox( self.roundedAmount or 0 , 0, 0, w, h, headerColor )
            
            s:DrawTextEntryText( s.entryTextColor, primaryTextColor, primaryTextColor )
        
            draw.SimpleText( s:GetValue() == "" and "Price" or "", primaryFont, 2, h / 2, primaryTextColor, TEXT_ALIGN_LEFT, 1 )

        end

        priceBar.OnChange = function( s )
       
            local flipPrice = s:GetValue()
            if ( not flipPrice ) then return end 
 
            flipPrice = tonumber( flipPrice ) or 0 

            local entryTextColor = ( MonkeyLib.CanAfford( ply, flipPrice ) ) and greenColor or redColor
            entryTextColor = ( flipPrice >= minimumFlipPrice and flipPrice <= maximumFlipPrice ) and entryTextColor or redColor
            
            s.entryTextColor = entryTextColor
            
        end


        MonkeyLib.ToolTip( priceBar, "Enter a price!" )
        
        local createFlip = toolBar:Add( "DButton" )
        createFlip:Dock( RIGHT )
        createFlip:SetWide( self:GetWide() / 2 - ( gapSize * 2 ) )
        createFlip:SetFont( primaryFont ) 
        createFlip:SetTextColor( primaryTextColor )
        createFlip:SetText( "Create Flip" )

        createFlip.DoClick = function( s )

            local flipPrice = priceBar:GetValue()
            if ( not flipPrice ) then return end 

            flipPrice = tonumber( flipPrice ) or 0

            if ( flipPrice < minimumFlipPrice or flipPrice > maximumFlipPrice ) then 

                MonkeyLib.FancyChatMessage( L"invalid_price", true, { MonkeyLib.FormatMoney( minimumFlipPrice ), MonkeyLib.FormatMoney( maximumFlipPrice ) } )
    
                return 
            end

            if ( not MonkeyLib.CanAfford( ply, flipPrice ) ) then 
                             
                MonkeyLib.FancyChatMessage( L"cant_afford", true, { "create" } )
    
                return 
            end

            MonkeyNet.WriteStructure( "MonkeyFlips:Send:CreateFlip", MonkeyFlips.NetStructure.CreateFlip, { flipPrice } )
        end
        
        createFlip.Paint = function( s, w, h )

            draw.RoundedBox( self.roundedAmount or 0, 0, 0, w, h, headerColor )

        end

        MonkeyLib.ToolTip( createFlip, "Create a flip!" )

    end

    local scrollBar = self:Add( "MonkeyLib:ScrollPanel" )
    scrollBar:Dock( FILL )
    scrollBar:DockMargin( 0, gapSize, 0, 0 )

    scrollBar.roundedAmount = 0

    scrollBar.VBarSizeOffset = gapSize / 2 // Custom 

    self.scrollBar = scrollBar 

    do 

        local flips = MonkeyFlips.GetFlips()

        if ( istable( flips ) and #flips >= 1 ) then 

            for k = 1, #flips do 

                local flipRow = flips[k]
                if ( not istable( flipRow ) ) then continue end 
                
                self:AddCoinflip( flipRow )
    
            end 

        else 

            noFlipPanel( self )
            
        end
    end

    hook.Add( "MonkeyFlips:FlipCreated", "MonkeyFlips:GUI:AddFlip", function( _, tbl )

        if ( not IsValid( self ) ) then hook.Remove( "MonkeyFlips:FlipCreated", "MonkeyFlips:GUI:AddFlip" ) return end 
        
        self:AddCoinflip( tbl )

    end )

    hook.Add( "MonkeyFlips:FlipDeleted", "MonkeyFlips:GUI:RemoveFlip", function ( index )

        if ( not IsValid( self ) ) then hook.Remove( "MonkeyFlips:FlipDeleted", "MonkeyFlips:GUI:RemoveFlip" ) return end 
        
        self:RemoveCoinflip( index )

    end )
end

function PANEL:Paint() end 

vgui.Register("MonkeyFlips:CoinflipPanel", PANEL, "DPanel")

hook.Add( "MonkeyLib:ThemeReload", "MonkeyFlips:GUI:ReloadTheme", function( themeIndex )
    
    GUITheme = MonkeyLib:GetTheme()

    bodyColor, headerColor, primaryTextColor, secondaryTextColor, greenColor = GUITheme.bodyColor, GUITheme.headerColor, GUITheme.primaryTextColor, GUITheme.secondaryTextColor, GUITheme.greenColor

    headerAbstract, headerSecondaryAbstract = GUITheme.headerAbstract_1, GUITheme.headerAbstract_2

end )
