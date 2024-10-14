// Possibly improve the scaling, it's fine honestly; just could be better.

// Colors 

local guiColors = MonkeyLib.GUIColors[1]
local bodyColor, headerColor, primaryTextColor, secondaryTextColor, redColor, greenColor = guiColors["bodyColor"], guiColors["headerColor"], guiColors["primaryTextColor"], guiColors["secondaryTextColor"], guiColors["redColor"], guiColors["greenColor"]

// Fonts 

local primaryFont = "MonkeyLib_Inter_30"
local secondaryFont = "MonkeyLib_Inter_15"

// Lerp settings 

local moveSpeed = .5
local moveDelay = .15

// Offsets and other random values 

local gapSize = 8 
local roundedAmount = 4  

local iconOffset = 60
local rewardAmount = MRewards.rewardAmount 

local outLineOffset = 4
local outLineOffsetDivider = ( outLineOffset / 2 )

// Scaling

local headerHeight = 30 
local textLineHeight = 2

local textHeaderHeight = 30 

local rewardPanelScale = .1
local minRewardPanelSize = 150

local scaleRewardPanel = function()

    local scrw = ScrW() 

    local rewardPanelSize = math.max( ( scrw * rewardPanelScale ), minRewardPanelSize )

    return rewardPanelSize 
end

local scaleGUI = function()

    local rewardPanelSize = scaleRewardPanel()

    local guiWidth = ( ( rewardPanelSize + gapSize ) * rewardAmount ) 

    return ( guiWidth + gapSize ), ( ( rewardPanelSize + headerHeight ) + ( gapSize * 2 ) )  
end

local unpackReward = function( rewardID )

    local reward = MRewards.IndexToReward( rewardID )

    assert( istable( reward ), "Failed to generate fake reward, malformed reward." )

    local name, model, icon = reward.Name, reward.Model, reward.Icon 

    local useModelPanel, modelType = isstring( model ), ( isstring( model ) and model ) or icon
    
    return name, modelType, useModelPanel
end

local generateFakeReward = function()

    local rewards = MRewards.SharedRewards 

    local rewardIndex = rewards[ math.random( 1, #rewards ) ]

    return unpackReward( rewardIndex )
end

MRewards.CreateGUI = function( foundReward ) 

    if ( not isnumber( foundReward ) ) then 

        return 
    end

    local frameWidth, frameHeight = scaleGUI()

    local frame = MonkeyLib:CreateDefaultFrame( frameWidth, frameHeight )

    assert( IsValid( frame ), "MonkeyLib frame isn't valid!" )  

    local rewardPanelWidth = scaleRewardPanel()

    local createRewardPanel 
 
    do 
  
        local rewardPanels = {}

        local activateRewardPanels = function( selectedIndex )
        
            for k = 1, #rewardPanels do 
                
                local rewardPanel = rewardPanels[k]

                assert( IsValid( rewardPanel ), "Reward panel isn't valid!" ) 

                rewardPanel:DockPadding( outLineOffsetDivider, outLineOffsetDivider, outLineOffsetDivider, outLineOffsetDivider )

                do // Remove the old 'DoClick' func 
                      
                    rewardPanel:SetText( " " )

                    rewardPanel:SetEnabled( false )

                end
           
                local isSelectedPanel = ( selectedIndex == k )
    
                local rewardName, rewardModel, useModelPanel = generateFakeReward()

                if ( isSelectedPanel ) then 

                    rewardName, rewardModel, useModelPanel = unpackReward( foundReward )
                    
                end

                local animDelay = ( ( k - 1 ) * moveDelay )
            
                local modelHolder 

                do 

                    modelHolder = rewardPanel:Add( "DPanel" )
                    modelHolder:Dock( FILL )
                    modelHolder:InvalidateParent( true )
    
                    modelHolder.Paint = function() end 
        
                end
      
                local rewardPanelName

                do
                    
                    rewardPanelName = rewardPanel:Add( "DPanel" )
                    rewardPanelName:Dock( BOTTOM )
                    rewardPanelName:SetTall( textHeaderHeight )
        
                    rewardPanelName.Paint = function( s, w, h )
    
                        draw.RoundedBox( 0, ( gapSize / 2 ), 0, ( w - gapSize ), textLineHeight, headerColor )
    
                        draw.SimpleText( rewardName, secondaryFont, ( w / 2 ), ( h / 2 ), secondaryTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    
                    end 

                end
           
                do // Our model function 

                    local modelPanelType = ( useModelPanel and "MonkeyLib:WeaponBox" or "DImage" )
                    
                    local width, height = modelHolder:GetSize()

                    do // Add our type offset 

                        width = ( useModelPanel and width or ( width - iconOffset ) ) 

                        height = ( useModelPanel and height or ( height - iconOffset ) ) 

                    end

                    local modelPanel = modelHolder:Add( modelPanelType )
                    modelPanel:SetSize( width, height )
            
                    local xPos, yPos = 0, 0 

                    if ( not useModelPanel ) then 

                        xPos = ( ( modelHolder:GetWide() / 2 ) - ( width / 2 ) )

                        yPos = ( ( modelHolder:GetTall() / 2 ) - ( height / 2 ) ) - ( textHeaderHeight / 2 ) 

                    end

                    modelPanel:SetPos( xPos, -modelPanel:GetTall() )

                    do // Little hack 

                        local setModelFunc = ( useModelPanel and modelPanel.WeaponModel ) or modelPanel.SetMaterial 

                        assert( isfunction( setModelFunc ), "Invalid model func!" )
                    
                        rewardModel = useModelPanel and rewardModel or MonkeyLib:GetIcon( rewardModel )

                        setModelFunc( modelPanel, rewardModel )

                    end 

                    modelPanel:MoveTo( xPos, yPos, moveSpeed, animDelay, -1 ) 

                end
    
                do 

                    rewardPanelName:SetAlpha( 0 )

                    rewardPanelName:AlphaTo( 255, moveSpeed, animDelay )
                    
                end

            end
    
        end
    
        local selectedIndex 

        createRewardPanel = function()
    
            local rewardPanel = frame:Add( "DButton" )
            rewardPanel:Dock( LEFT )
            rewardPanel:SetWide( rewardPanelWidth )
            rewardPanel:DockMargin( gapSize, gapSize, 0, gapSize )

            do 
    
                rewardPanel:SetText( "?" )
                rewardPanel:SetFont( primaryFont )
                rewardPanel:SetTextColor( primaryTextColor )
    
            end

            local index = table.insert( rewardPanels, rewardPanel )

            local lerpColor = headerColor 
            
            rewardPanel.Paint = function( s, w, h )

                local hoverColor = ( ( s:IsHovered() and greenColor ) or headerColor ) 

                local isSelectedPanelColor = ( ( selectedIndex == index ) and greenColor or redColor ) 

                local conditionColor = ( ( s:IsEnabled() and hoverColor ) or isSelectedPanelColor )
                
                lerpColor = MonkeyLib.ColorLerp( lerpColor, conditionColor )

                draw.RoundedBox( roundedAmount, 0, 0, w, h, lerpColor )

                draw.RoundedBox( roundedAmount, outLineOffsetDivider, outLineOffsetDivider, w - outLineOffset, h - outLineOffset, bodyColor )

            end 

            rewardPanel.DoClick = function()
    
                do 

                    net.Start( "MRewards:Reward:Claimed" )
                    net.SendToServer()

                end 

                selectedIndex = index 

                activateRewardPanels( index )

            end
    
        end
        
    end
  
    for k = 1, rewardAmount do 

        createRewardPanel()

    end

end 

