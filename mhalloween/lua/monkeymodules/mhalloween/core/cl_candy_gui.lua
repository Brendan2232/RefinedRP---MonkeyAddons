MHalloween.CandyGUI = MHalloween.CandyGUI or nil  

local CONFIG = MHalloween.CandyConfig

local localPlayer = LocalPlayer()

// Icon ID References 

local candyIconID = "m_halloween_candy"
local awardIconID = "m_halloween_award"

// Colors 

local headerText = "Candy Event"
local GUITheme = MonkeyLib:GetTheme()

local primaryTextColor = GUITheme.primaryTextColor
    
local bodyColor, headerColor = GUITheme.bodyColor, GUITheme.headerColor 

local headerAbstract, headerSecondaryAbstract = GUITheme.headerAbstract_1, GUITheme.headerAbstract_2

local orangeColor = Color(207, 93, 40)
local goldColor = Color(213, 216, 21)  

local silverColor = Color(158, 158, 158)
local bronzeColor = Color(108, 40, 24)

local bodyColorAlpha = ColorAlpha( bodyColor, 240 )

local headerAbstractAlpha = ColorAlpha( headerAbstract, 180 )

local headerSecondaryAbstractAlpha = ColorAlpha( headerSecondaryAbstract, 230 )

// Fonts

local primaryFont = "MonkeyLib_Inter_15"

// Offsets 

local gapSize = 4

local lineHeight = 2 

// Scaling 

local minimumRowSize = 26

local minimumFrameWidth = 225

local rowSizeMultiplier = .0125

local frameWidthMultipler = .13

// Don't change me! 

local playerRowAmount = CONFIG.MaxPlayerRows

local rowSize = minimumRowSize

local frameWidth = minimumFrameWidth

local createLabel, createIcon

local reScaleGUI = function()

    local scrw = ScrW()

    do // Row Scale 

        local scale = ( scrw * rowSizeMultiplier)
        
        scale = math.ceil( scale )

        rowSize = math.max( scale, minimumRowSize )

    end

    do // Frame Scale

        local scale = ( scrw * frameWidthMultipler )
        
        scale = math.ceil( scale )

        frameWidth = math.max( scale, minimumFrameWidth )

    end

end

local maxNameChar = 18

local getPlayerName = function( ply )

    if ( not IsValid( ply ) ) then 

        return "NULL"
    end
    
    local name = ply:Name() 
    
    local nameOverlap = MonkeyLib.StringCap( name, maxNameChar )

    if ( not nameOverlap ) then 

        return name 
    end

    return name:sub( 1, maxNameChar )
end

do // Small GUI Framework 

    // Possibly re-do some of the 'DLabel' work - it's a mess. 

    createLabel = function( text, parent, dockEnum, alignment )

        if ( not IsValid( parent ) ) then 
           
            return 
        end

        local label = parent:Add( "DLabel" )

        label:Dock( dockEnum )
        label:SetContentAlignment( alignment )

        label:SetFont( primaryFont )
        label:SetText( text )

        return label 
    end

    createIcon = function( parent, icon, dockEnum )

        if ( not IsValid( parent ) ) then 
           
            return 
        end

        local parentHeight = parent:GetTall()

        local iconMaterial = MonkeyLib:GetIcon( icon )

        local icon = parent:Add( "DImage" )
        icon:Dock( dockEnum )

        icon:SetWide( parentHeight - ( gapSize * 2 ) ) 
        icon:DockMargin( gapSize, gapSize, gapSize, gapSize )

        icon:SetMaterial( iconMaterial )

        return icon 
    end

end 

local createPlayerPanel

do 

    local getAwardColor = function( key )

        return ( ( ( key == 1 ) and goldColor ) or ( ( key == 2 ) and silverColor ) or ( ( key == 3 ) and bronzeColor ) ) or primaryTextColor
    end
    
    createPlayerPanel = function( parent, key, rowColor )
        
        if ( not IsValid( parent ) or not isnumber( key ) or not IsColor( rowColor ) ) then 
    
            return 
        end
    
        local playerRow = parent:Add( "DPanel" )
        playerRow:Dock( TOP )
        playerRow:SetTall( rowSize )
    
        playerRow.Paint = function( s, w, h )
    
            draw.RoundedBox( 0, 0, 0, w, h, rowColor )
    
        end
    
        local nameLabel, candyCountLabel, idCountLabel, awardIcon
    
        do // Award icon 
    
            local iconColor = getAwardColor( key ) or primaryTextColor 
    
            awardIcon = createIcon( playerRow, awardIconID, LEFT )
    
            awardIcon:SetImageColor( iconColor )
    
        end
    
        do // ID and PlayerName 
            
            idCountLabel = createLabel( key, playerRow, FILL, 4 )
                     
            nameLabel = createLabel( "NULL", playerRow, FILL, 5 )
    
        end
    
        do // Candy count 
    
            candyCountLabel = createLabel( 0, playerRow, FILL, 6 )
        
            local candyIcon = createIcon( playerRow, candyIconID, RIGHT )
    
            candyIcon:SetImageColor( ColorRand() )
    
        end

        playerRow.UpdateRow = function( self, key ) 

            key = ( isnumber( key ) and key ) or -1 
            
            local guiStructure = self.M_Panels
    
            if ( not istable( guiStructure ) ) then 
    
                return 
            end

            local playerNameRow, candyCountRow, idCountRow, avatarCountRow = unpack( guiStructure )
    
            if ( not IsValid( playerNameRow ) or not IsValid( candyCountRow ) or not IsValid( idCountRow ) or not IsValid( avatarCountRow ) ) then 
    
                return 
            end

            local candyArray = MHalloween.CollectedCandies[ key ]
            
            if ( not istable( candyArray ) ) then 

                candyCountRow:SetText( 0 ) 
        
                do // Reset the name rows! 

                    playerNameRow:SetText( "NULL" )

                    playerNameRow:SetTextColor( primaryTextColor )
    
                end
            
                return 
            end

            self.Think = nil // If the current player is valid - and the last player who allowocated this row wasn't, this think hook will still run. 
            
            local ply, steamID64, candies = unpack( candyArray )

            if ( not IsValid( ply ) ) then // Name await hack, fixes minor bugs. 

                self.Think = function( s )

                    if ( not IsValid( self ) ) then 

                        return 
                    end

                    local playerValid = IsValid( ply )

                    if ( not playerValid ) then 

                        return 
                    end

                    if ( not IsValid( playerNameRow ) ) then 

                        return 
                    end 
                    
                    local playerName = getPlayerName( ply )
                    
                    self.Think = nil 

                    playerNameRow:SetText( playerName )

                    MonkeyLib.Debug( false, "Player '%s' has finally had their name resolved.", playerName ) // Debugging 

                end

            end
  
            local playerName = getPlayerName( ply )

            local isLocalPlayer = ( ply == localPlayer )

            do // Player Name Row 

                local playerNameRowColor = ( isLocalPlayer and orangeColor ) or primaryTextColor

                playerNameRow:SetText( playerName )

                playerNameRow:SetTextColor( playerNameRowColor )

            end

            do // ID and Candy count Row  

                idCountRow:SetText( key ) // Index text! 

                candyCountRow:SetText( candies ) // How many candies?? 
            
            end

            do 

                local iconColor = getAwardColor( key )
                        
                avatarCountRow:SetImageColor( iconColor )
                
            end
    
        end
    
        playerRow.M_Panels = { nameLabel, candyCountLabel, idCountLabel, awardIcon }
    
        return playerRow
    end
    
end

local createGUI = function()
    
    reScaleGUI()

    do // Does a GUI currently exist? If so - Remove it! 

        local candyGUI = MHalloween.CandyGUI

        if ( IsValid( candyGUI ) ) then 

            candyGUI:Remove()

        end

    end

    local frame = vgui.Create( "EditablePanel" ) // Create our BaseFrame 
    frame:SetWide( frameWidth )

    frame:SetAlpha( 0 )
    frame:AlphaTo( 255, .3, 0 )
    
    frame:DockPadding( gapSize, gapSize, gapSize, gapSize )

    frame.Paint = function( s, w, h )

        draw.RoundedBox( 0, 0, 0, w, h, bodyColorAlpha )

    end

    MHalloween.CandyGUI = frame // Set the GUI reference in memory! 

    local header = frame:Add( "DPanel" ) // Create our header 
    header:Dock( TOP )
    
    header:SetPaintBackground( false )

    do // Header Interface 

        local paint = function( s, w, h )

            draw.RoundedBox( 0, 0, 0, w, h, headerColor )

        end

        local primaryHeader = header:Add( "DPanel" )
        primaryHeader:Dock( TOP )
        primaryHeader:SetTall( rowSize )

        primaryHeader.Paint = paint 

        do // Header Label 
            
            createLabel( headerText, primaryHeader, FILL, 5 )

        end

        do // Time header 

            local getTimeFunc = MHalloween.GetCandyEventEndTime

            local formatTimeFunc = string.FormattedTime // Cache our TimeFormat function 

            local timeFormatPattern = "%2i:%02i" // TimeFormat pattern 
            
            local timeHeader = header:Add( "DPanel" )
            timeHeader:Dock( TOP )
            timeHeader:DockMargin( 0, gapSize, 0, 0 )
    
            timeHeader:SetTall( rowSize )
    
            timeHeader.Paint = function( s, w, h )
                
                paint( s, w, h )
                
                local time = getTimeFunc()

                local formattedTime = formatTimeFunc( time, timeFormatPattern )
    
                draw.SimpleText( formattedTime, primaryFont, ( w / 2 ), ( h / 2 ), primaryTextColor, 1, 1 )
    
            end
    
        end
       
        do // Header Scaling 
        
            header:InvalidateChildren( )
            header:SizeToChildren( false, true )

        end

    end

    local playerHolder = frame:Add( "DPanel" ) // Create our playerHolder! 
    playerHolder:Dock( TOP )
    playerHolder:DockMargin( 0, gapSize, 0, 0 )

    playerHolder:SetPaintBackground( false )

    do // Create our player rows! 
        
        local candies = MHalloween.CollectedCandies

        for k = 1, playerRowAmount do 
   
            local rowColor = ( ( k % 2 ) == 0 and headerAbstractAlpha ) or headerSecondaryAbstractAlpha // Get our row color 

            local playerRow = createPlayerPanel( playerHolder, k, rowColor ) // Create our row! 

            local structure = candies[ k ] // Find our candy structure 

            if ( not istable( structure ) ) then // No data? NEXT!!!!

                continue
            end

            playerRow:UpdateRow( k )

        end

        playerHolder:InvalidateChildren( )
        playerHolder:SizeToChildren( false, true )

    end
    
    do // Create our localPlayer row! 

        local localPlayerPanel = frame:Add( "DPanel" ) // Line Panel 
        localPlayerPanel:Dock( TOP )
        localPlayerPanel:DockMargin( 0, gapSize, 0, 0 )

        localPlayerPanel:SetTall( ( rowSize + gapSize ) + lineHeight )

        localPlayerPanel.Paint = function( s, w, h ) 

            draw.RoundedBox( 0, 0, 0, w, lineHeight, headerColor ) // Line 
            
        end

        do // LocaPlayer Row ! 
            
            // playerRowAmount ( 5 ) + 1 ( 6 ) % 2 = 0

            local localPlayerKey = MHalloween.GetPlayerIndex( localPlayer )

            local color = ( ( ( playerRowAmount + 1 ) % 2 == 0 ) and headerAbstractAlpha ) or headerSecondaryAbstractAlpha  

            local localPlayerRow = createPlayerPanel( localPlayerPanel, 128, color )
            localPlayerRow:DockMargin( 0, ( gapSize + lineHeight ), 0, 0 )

            localPlayerRow:UpdateRow( localPlayerKey ) 

            frame.LocalPlayerRow = localPlayerRow

        end
        
    end
    
    do // PlayerRow API 

        frame.PlayerHolder = playerHolder

        frame.GetPlayerRows = function( self )
    
            local playerHolder = self.PlayerHolder 
    
            if ( not IsValid( playerHolder ) ) then 
    
                return 
            end
    
            return playerHolder:GetChildren() or {}
        end

    end

    do // Scale hack 

        frame:InvalidateChildren( )
        frame:SizeToChildren( false, true )

    end

    do // Set Width / position 

        frame:SetWide( frameWidth )
        frame:SetPos( gapSize, ( ScrH() / 2 ) - ( frame:GetTall() / 2 ) )

    end

    return frame 
end


local candyEventGUI = function()
 
    local frame = createGUI()

    AssertF( IsValid( frame ), "Frame isn't valid!" )

    local shiftLocalPlayerCandies = function( )

        if ( not IsValid( frame ) ) then 

            return 
        end

        local localPlayerRow = frame.LocalPlayerRow

        if ( not IsValid( localPlayerRow ) ) then 

            return 
        end

        local localPlayerKey = MHalloween.GetPlayerIndex(localPlayer)

        localPlayerRow:UpdateRow( localPlayerKey )

    end

    local shiftElements = function( index )

        if ( not IsValid( frame ) or not isnumber( index ) ) then 
        
            return 
        end
 
        if ( index > playerRowAmount ) then 

            return 
        end

        local playerRows = frame:GetPlayerRows()

        local collectedCandies = MHalloween.CollectedCandies

        for k = index, #playerRows do 

            local playerRow = playerRows[ k ]

            if ( not IsValid( playerRow ) ) then 

                continue 
            end

            playerRow:UpdateRow( k )

        end 

    end

    local hookID = "MHalloween:CandyGUI:UpdateGUI"

    hook.Protect( "MHalloween:CandyCounter:IncreaseCounter", hookID, function( ply )

        if ( not IsValid( frame ) ) then 

            hook.Remove( "MHalloween:CandyCounter:IncreaseCounter", hookID )

            return 
        end

        if ( not IsValid( ply ) ) then 

            return 
        end

        local structure, index = MHalloween.GetPlayerCandies( ply )

        if ( not istable( structure ) or not isnumber( index ) ) then 

            return 
        end
                
        shiftLocalPlayerCandies(  )

        shiftElements( index )

    end )
    
    hook.Protect( "MHalloween:CandyCounter:ResetCounter", hookID, function( index )

        if ( not IsValid( frame ) ) then 

            hook.Remove( "MHalloween:CandyCounter:ResetCounter", hookID )

            return 
        end

        if ( not isnumber( index ) ) then 
           
            return 
        end

        shiftLocalPlayerCandies(  )

        shiftElements( index )

    end )

end

local guiCreateEvents = function()

    hook.Protect( "MHalloween:Candy:EventStart", "MHalloween:CandyGUI:EventStart", function()

        reScaleGUI()

        candyEventGUI()

    end )

    hook.Protect( "MHalloween:Candy:EventEnd", "MHalloween:CandyGUI:EventEnd", function()

        local frame = MHalloween.CandyGUI

        if ( not IsValid( frame ) ) then 

            return 
        end

        frame:Stop()
        
        frame:AlphaTo( 0, .3, 0, function()

            if ( not IsValid( frame ) ) then 
                
                return 
            end

            frame:Remove()

        end )

    end )

end

do // Client hook interface 

    hook.Protect( "InitPostEntity", "MHalloween:CandyGUI:StartCreate", function()

        localPlayer = LocalPlayer()

        guiCreateEvents()

    end )

    hook.Protect( "OnScreenSizeChanged", "MHalloween:CandyGUI:OnScreenSizeChanged", function()

        reScaleGUI()

    end )

    hook.Protect( "Initialize", "MHalloween:CandyGUI:LoadIcons", function()
            
        reScaleGUI()
        
        MonkeyLib:LoadIcon( candyIconID, {

            ["iconLink"] = "https://i.imgur.com/iEaQcJR.png", 
            ["iconParamaters"] = "noclamp smooth", 
            
        } )
        
        MonkeyLib:LoadIcon( awardIconID, {

            ["iconLink"] = "https://i.imgur.com/7pbE3BU.png", 
            ["iconParamaters"] = "noclamp smooth", 
            
        } )
        
    end )

end 