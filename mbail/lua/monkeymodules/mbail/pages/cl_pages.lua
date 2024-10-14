local GUITheme = MonkeyLib:GetTheme()

local bodyColor, headerColor, primaryTextColor, secondaryTextColor, greenColor, redColor = GUITheme.bodyColor, GUITheme.headerColor, GUITheme.primaryTextColor, GUITheme.secondaryTextColor, GUITheme.greenColor, GUITheme.redColor
local headerAbstract, headerSecondaryAbstract = GUITheme.headerAbstract_1, GUITheme.headerAbstract_2

local primaryFont = "MonkeyLib_Inter_15"
local primaryFontHeight = draw.GetFontHeight( primaryFont )

local gapSize = 8 
local roundedAmount = 4

local avatarOffset = gapSize / 2
local rowHeight = 40 

local bailMessages = MBail.Config.Messages

local minBailPrice, maxBailPrice = MBail.Config.MinBailPrice, MBail.Config.MaxBailPrice
local defaultBailPrice = MBail.Config.DefaultBailPrice 

local localPlayer = LocalPlayer()

local noElementText = "No one is arrested!"

local L = function( message )

    return bailMessages[message] or message 
end

local lastColorIndex = 0

local nextColor = function()

    local bodyColor = ( lastColorIndex == 0 ) and headerAbstract or headerSecondaryAbstract 

    lastColorIndex = lastColorIndex + 1

    lastColorIndex = ( lastColorIndex % 2 )

    return bodyColor
end

local team_GetInfo = function( ply )

    if ( not IsValid( ply ) ) then return end 

    local playerJob = ply:Team()

    return team.GetName( playerJob ), team.GetColor( playerJob ) // I swear there's a DarkRP function for this, can't remember the name. 
end

local playerNameCap = 12

local bailPopupButtonOffset = 4 

local popupWidth, popupHeight = 300, 150

local removeNoElementPopup = function( parent )

    local noElementPopup = parent.noElementPopup 
    if ( not IsValid( noElementPopup ) ) then return end 

    noElementPopup:Remove()

end

local noElements = function( parent )

    local noElementPopup = parent.noElementPopup 
    if ( IsValid( noElementPopup ) ) then return end 

    local noElement = parent:Add( "DLabel" )    
    noElement:Dock( TOP )
    noElement:SetFont( primaryFont )

    noElement:SetText( noElementText )
    noElement:SetTextColor( secondaryTextColor )

    noElement:SetContentAlignment( 5 )

    parent.noElementPopup = noElement

    return noElement 
end

local policeBailPopup = function( data, callback )

    if ( not istable( data ) ) then return end 

    local arrestedPlayer = data.arrestedPlayer
    if ( not IsValid( arrestedPlayer ) ) then return end 

    local arrestedPlayerName = arrestedPlayer:Name()

    if ( MonkeyLib.StringCap( arrestedPlayerName, playerNameCap ) ) then

        arrestedPlayerName = ( arrestedPlayerName:sub( 1, playerNameCap ) .. "..." )

    end

    local popupFrame = MonkeyLib:CreateDefaultFrame( popupWidth, popupHeight )
    popupFrame:DoModal()

    do  // Over-write the orignal paint function > draw a background blur 

        local oldPaint = popupFrame.Paint or function() end 

        popupFrame.Paint = function( s, w, h )
    
            Derma_DrawBackgroundBlur( s )
    
            oldPaint( s, w, h )
            
        end
    end

    local dockPanel = popupFrame:Add( "DPanel" )
    dockPanel:Dock( FILL )
    dockPanel:DockPadding( gapSize, gapSize, gapSize, gapSize )

    dockPanel:InvalidateParent( true )

    dockPanel.Paint = function( s, w, h ) end 

    do 

        local nameLabelText = L"bail_gui_set_bail"
        local nameLabelFormat = nameLabelText:format( arrestedPlayerName  )

        local nameLabel = dockPanel:Add( "DLabel" )
        nameLabel:Dock( TOP )

        nameLabel:SetTextColor( primaryTextColor )
        nameLabel:SetFont( primaryFont )

        nameLabel:SetText( nameLabelFormat )
        nameLabel:SetContentAlignment( 5 )

        nameLabel:SizeToContents()  

    end

    do 

        local elementSize = ( dockPanel:GetTall() / 2 ) - ( gapSize * 2 ) - gapSize  
    
        local priceEntry = dockPanel:Add( "DTextEntry" )
        priceEntry:Dock( TOP )
        priceEntry:DockMargin( 0, gapSize, 0, gapSize )
    
        priceEntry:SetTall( elementSize + bailPopupButtonOffset )
    
        priceEntry:SetText( defaultBailPrice )
        priceEntry:SetFont( primaryFont )
    
        priceEntry:SetTextColor( secondaryTextColor )
    
        local priceError = false 
    
        priceEntry.OnTextChanged = function( s )
            
            local price = s:GetText()
            price = tonumber( price ) or 0
    
            priceError = ( price < minBailPrice or price > maxBailPrice )  
            
        end
    
        priceEntry.Paint = function( s, w, h )
    
            s:DrawTextEntryText( priceError and redColor or greenColor, primaryTextColor, primaryTextColor )
    
            draw.RoundedBox( roundedAmount, 0, 0, w, h, headerColor )
    
        end
    
        local submitBailText = L"bail_gui_submit_bail"
    
        local submitBail = dockPanel:Add( "DButton" )
        submitBail:Dock( TOP )
        submitBail:SetTall( elementSize - bailPopupButtonOffset )
        
        submitBail:SetText( submitBailText )
        submitBail:SetTextColor( secondaryTextColor )
        submitBail:SetFont( primaryFont )
    
        submitBail.Paint = function( s, w, h )
            
            draw.RoundedBox( roundedAmount, 0, 0, w, h, headerColor )
    
        end
    
        submitBail.DoClick = function( s )
    
            if ( not IsValid( popupFrame ) ) then return end 
    
            if ( priceError ) then 
    
                local formattedMinPrice, formattedMaxPrice = MonkeyLib.FormatMoney( minBailPrice ), MonkeyLib.FormatMoney( maxBailPrice )
    
                MonkeyLib.FancyChatMessage( L"bail_gui_invalid_price", true, { formattedMinPrice, formattedMaxPrice } )
    
                return 
            end
            
            local price = priceEntry:GetText()
            price = tonumber( price )
    
            popupFrame:CloseAnimation()
    
            callback( price )
    
        end

    end
end

local addRow = function( parent, bodyColor, row )

    if ( not IsValid( parent ) or not istable( row ) ) then return end 

    local arrestedPlayer, bailPrice = row.arrestedPlayer, row.bailPrice 
    if ( not IsValid( arrestedPlayer ) or not isnumber( bailPrice ) ) then return end 

    local isCP = localPlayer:isCP()

    local playerName = arrestedPlayer:Name()

    local jobName, jobColor = team_GetInfo( arrestedPlayer ) 

    local formattedBailPrice = MonkeyLib.FormatMoney( bailPrice )

    local playerRow = parent:Add( "DButton" )
    playerRow:Dock( TOP )
    playerRow:SetTall( rowHeight )
    playerRow:SetText( " " )

    // I am not formatting money in a think hook. You refresh the data if you want it updated. 

    playerRow.RefreshData = function() 
        
        if ( not IsValid( arrestedPlayer ) ) then return end 

        bailPrice = row.bailPrice 

        jobName, jobColor = team_GetInfo( arrestedPlayer ) 

        formattedBailPrice = MonkeyLib.FormatMoney( bailPrice )

    end

    local playerAvatar = playerRow:Add( "MonkeyLib:CircleAvatar" )
    playerAvatar:Dock( LEFT )
    playerAvatar:DockMargin( avatarOffset, avatarOffset, 0, avatarOffset, 0 )
    playerAvatar:SetWide( playerRow:GetTall() - ( avatarOffset * 2 ) )
    playerAvatar:SetPlayer( arrestedPlayer )

    MonkeyLib.ToolTip( playerRow, isCP and "Press to set bail" or "Press to bail me out" )

    playerRow.bodyColor = bodyColor

    local avatarPos = ( playerRow:GetTall() - avatarOffset ) + gapSize / 2

    local cachedArrestTime = row.arrestTime 
    
    playerRow.Paint = function( s, w, h )
    
        local arrestTime = math.ceil( cachedArrestTime - CurTime() ) 
        arrestTime = arrestTime < 1 and "Unarresting..." or arrestTime .. "s Left"
        
        draw.RoundedBox( 0, 0, 0, w, h, s.bodyColor or primaryTextColor )

        draw.SimpleText( playerName, primaryFont, avatarPos, h / 2 - primaryFontHeight / 2, primaryTextColor, TEXT_ALIGN_LEFT, 1 )
        draw.SimpleText( jobName, primaryFont, avatarPos, h / 2 + primaryFontHeight / 2, jobColor, TEXT_ALIGN_LEFT, 1 )

        draw.SimpleText( arrestTime, primaryFont, w - gapSize, h / 2 - primaryFontHeight / 2, secondaryTextColor, TEXT_ALIGN_RIGHT, 1 )
        draw.SimpleText( formattedBailPrice, primaryFont, w - gapSize, h / 2 + primaryFontHeight / 2, greenColor, TEXT_ALIGN_RIGHT, 1 )

    end

    playerRow.DoClick = function( s )

        if ( isCP ) then 

            policeBailPopup( row, function( price )

                if ( not isnumber( price ) or not IsValid( s ) ) then return end

                local arrestKey = s.ArrestIndex

                net.Start( "MonkeyBail:Bail:Set" )
                    net.WriteUInt( arrestKey, 8 )
                    net.WriteUInt( price, 32 )
                net.SendToServer()

            end )
                
            return 
        end

        local arrestKey = s.ArrestIndex

        net.Start( "MonkeyBail:Bail:Pay" )
            net.WriteUInt( arrestKey, 8 )
        net.SendToServer()
    end 

    return playerRow 
end

local loadBails = function( frame )

    if ( not IsValid( frame ) ) then return end 

    local scrollBar = frame.scrollBar 
    if ( not IsValid( scrollBar ) ) then return end
    
    local bailCache = MBail.ArrestCache

    if ( istable( bailCache ) and #bailCache >= 1 ) then 

        removeNoElementPopup( scrollBar )
    
        for k = 1, #MBail.ArrestCache do 

            local bodyColor = nextColor()

            local playerRow = addRow( scrollBar, bodyColor, bailCache[k] )
            if ( not IsValid( playerRow ) ) then continue end 

            playerRow.ArrestIndex = k // I do not like this at all. Either this or an o(N) operation on the server

        end

        return  
    end

    noElements( scrollBar )

end

local destroyGUIHooks = function()
              
    hook.Remove( "MonkeyBail:GUI:Add", "MonkeyBail:GUI:AddRow" )

    hook.Remove( "MonkeyBail:GUI:Remove", "MonkeyBail:GUI:RemoveRow" )

end

local bailGUI = false 

local minGUIWidth, minGUIHeight = 350, 450   

local createBailGUI = function()

    lastColorIndex = 0

    if ( IsValid( bailGUI ) ) then bailGUI:Remove() end

    local scrw, scrh = ScrW() * .2, ScrH() * .48

    scrw = math.max( scrw, minGUIWidth )
    scrh = math.max( scrh, minGUIHeight )

    local frame = MonkeyLib:CreateDefaultFrame( scrw, scrh )
    bailGUI = frame 

    local scrollBar = frame:Add( "MonkeyLib:ScrollPanel" )
    scrollBar:Dock( FILL )
    scrollBar:DockMargin( gapSize, gapSize, gapSize, gapSize )

    scrollBar.roundedAmount = 0

    scrollBar.VBarSizeOffset = gapSize / 2 // Custom 

    frame.scrollBar = scrollBar 
    
    loadBails( frame )

    hook.Add( "MonkeyBail:GUI:Add", "MonkeyBail:GUI:AddRow", function( arrestedStructure )
        
        if ( not IsValid( scrollBar ) ) then 
            
            destroyGUIHooks()

            return 
        end

        removeNoElementPopup( scrollBar )

        local bodyColor = nextColor()
        
        local row = addRow( scrollBar, bodyColor, arrestedStructure )
        row.ArrestIndex = #MBail.ArrestCache

    end )

    hook.Add( "MonkeyBail:GUI:Remove", "MonkeyBail:GUI:RemoveRow", function( index )
    
        if ( not IsValid( scrollBar ) ) then 

            destroyGUIHooks()

            return 
        end

        local children = scrollBar:GetChildren()[1]:GetChildren()

        local foundChild = children[index] 
        if ( not IsValid( foundChild ) ) then return end

        foundChild:Remove() // Bye bye

        if ( ( #children - 1 ) >= 1 )  then 

            for k = index, #children do // No need to loop around every single child!
    
                local foundChild = children[k]
                if ( not IsValid( foundChild ) ) then continue end 
    
                local color = nextColor()
    
                foundChild.bodyColor = color
                foundChild.ArrestIndex = k - 1
            end
    
            return 
        end
         
        noElements( scrollBar )

    end )
    
    hook.Add( "MonkeyBail:GUI:UpdateBail", "MonkeyBail:GUI:RefreshData", function( index )

        if ( not IsValid( scrollBar ) ) then 
            
            destroyGUIHooks()
    
            return 
        end 

        local children = scrollBar:GetChildren()[1]:GetChildren()

        local foundChild = children[index] 
        if ( not IsValid( foundChild ) ) then return end

        local refreshFunction = foundChild.RefreshData
        if ( not isfunction( refreshFunction ) )  then return end 

        refreshFunction()
    end )
end

hook.Add( "InitPostEntity", "MonkeyBail:Pages:RefreshPlayer", function()

    localPlayer = LocalPlayer()

end )


if ( not MBail.Config.RequiresNPCInteraction ) then 

    MonkeyLib.RegisterChatCommand( { "bail", "arrestedplayers", "setbail" }, function()
        createBailGUI()
    end )

end

net.Receive( "MonkeyBail:Bail:SendGUI", function()

    createBailGUI()

end )