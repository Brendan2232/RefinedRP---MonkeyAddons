require( "memoize" )
require( "monkeyhooks" )

if ( SERVER ) then

    util.AddNetworkString( "MonkeyPOI:Put:OnTeamChanged" )

    hook.Add( "PlayerChangedTeam", "MonkeyPOI:Core:OnTeamChanged", function(ply, _, newTeam )

        net.Start( "MonkeyPOI:Put:OnTeamChanged" )
            net.WriteUInt( newTeam, 16 )
        net.Send( ply )
        
    end )

    return 
end

local isnumber = isnumber 
local isstring = isstring

local istable = istable 
local isvector = isvector 

local IsValid = IsValid 

local TEXT_ALIGN_CENTER  = TEXT_ALIGN_CENTER  

local team = team 
local team_GetName = team.GetName

local draw = draw 
local SimpleText = draw.SimpleText

local surface = surface 

local SetDrawColor = surface.SetDrawColor
local SetMaterial = surface.SetMaterial 
local DrawTexturedRect = surface.DrawTexturedRect 

local PLAYER = FindMetaTable( "Player" )
local VECTOR = FindMetaTable( "Vector" ) 

local PLAYER_BASE = PLAYER.MetaBaseClass
local ply_GetPos = PLAYER_BASE.GetPos

local Vector_Distance = VECTOR.DistToSqr 
local Vector_ToScreen = VECTOR.ToScreen 

local ply = LocalPlayer()

local maxRenderDistance = MonkeyPOI.MaxRenderDistance 

local getPOIS = function( teamOverright )

    if ( not IsValid( ply ) ) then return end 
    
    local playerTeam = isnumber( teamOverright ) and teamOverright or ply:Team()

    local teamName = team_GetName( playerTeam ) or ""

    return MonkeyPOI.POI[teamName] 
end

local cachedPOIS = getPOIS()


local shouldRenderPOI, getClosestVector

do 
    local squaredRenderDistance = ( maxRenderDistance * maxRenderDistance ) 

    // Using memoize should help with performance a tiny bit... Might make it worse as Memoize is a O(N) on it's worse complexity. 

    shouldRenderPOI = function( POIPos )

        if ( not IsValid( ply ) or not isvector( POIPos ) ) then return end 
    
        local playerPos = ply_GetPos( ply )
    
        local inDistance = Vector_Distance( playerPos, POIPos ) >= squaredRenderDistance 
    
        return inDistance 
    
    end
    
    getClosestVector = memoize( function( foundPositions )
    
        if ( not IsValid( ply ) or not istable( foundPositions ) ) then return end 
    
        local playerPos = ply_GetPos( ply )
    
        local foundVector
    
        local lastSquaredDistance 
    
        for k = 1, #foundPositions do 
            
            local position = foundPositions[k]
    
            if ( not isvector( position ) ) then 
                
                continue 
            end 
   
            local distanceFromPlayer = Vector_Distance( playerPos, position )
    
            if ( distanceFromPlayer < squaredRenderDistance ) then

                foundVector = nil

                break 
            end

            if ( not lastSquaredDistance or ( distanceFromPlayer < lastSquaredDistance ) ) then 
    
                foundVector = position
    
                lastSquaredDistance = distanceFromPlayer
    
            end 
        end
       
        return foundVector
    
    end, {}, 1 )

end

local renderPOIS

do 

    local iconScale = 40

    local iconScaleDivider = ( iconScale / 2 )

    local primaryFont = "MonkeyLib_Inter_14"

    local textOutlineSize = 1

    local colorBlack = color_black
    
    local primaryFontHeight = draw.GetFontHeight( primaryFont )

    local primaryFontDivider = primaryFontHeight / 2 
    
    // Might want to re-do the math, brain wasn't braining. 

    local drawPOI = function( poiRow, poiPos ) 

        if ( not istable( poiRow ) or not isvector( poiPos ) ) then return end 

        local poiName, poiNameColor, poiIconColor, poiIcon = poiRow.Name, poiRow.NameColor or color_white, poiRow.IconColor or color_white, poiRow.Icon 
    
        local posToScreen = Vector_ToScreen( poiPos )
        
        local isOnScreen = posToScreen.visible  
        if ( not isOnScreen ) then return end 
    
        local x, y = posToScreen.x, posToScreen.y 

        local fontDivider = isstring( poiName ) and primaryFontDivider or 0 

        local iconDivider = isstring( poiIcon ) and iconScaleDivider or 0 
        
        local iconXPos, iconYPos = x - iconDivider, ( ( y - iconDivider ) - fontDivider )

        local textXPos, textYPos = x, ( ( y + fontDivider ) + iconDivider )  

        if ( isstring( poiIcon ) ) then 
    
            local poiMaterial = MonkeyLib:GetIcon( poiIcon )

            SetMaterial( poiMaterial )
                SetDrawColor( poiIconColor )
            DrawTexturedRect( iconXPos, iconYPos, iconScale, iconScale )

        end 
    
        if ( isstring( poiName ) ) then 
        
                    
            SimpleText( poiName, primaryFont, textXPos + textOutlineSize, textYPos + textOutlineSize, colorBlack, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            SimpleText( poiName, primaryFont, textXPos, textYPos, poiNameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )


        end

    end

    renderPOIS = function()

        if ( not istable( cachedPOIS ) ) then return end

        for k = 1, #cachedPOIS do 

            local poiRow = cachedPOIS[k]
            
            if ( not istable( poiRow ) ) then continue end 

            local positions = poiRow.Positions 
            if ( not istable( positions ) ) then continue end 

            local prioritizeClosest = poiRow.PrioritizeClosest

            if ( prioritizeClosest ) then
        
                local closestVector = getClosestVector( positions )

                if ( not isvector( closestVector ) ) then 
        
                    continue  
                end 
        
                drawPOI( poiRow, closestVector )
                
                continue 
            end

            for i = 1, #positions do 

                local foundVector = positions[i]

                if ( not shouldRenderPOI( foundVector ) ) then // Means the player is around the area of the vector.  

                    continue 
                end

                drawPOI( poiRow, foundVector )

            end

        end

    end
end

do  // Render optimisations 

    local poiRenderID = "MonkeyPOI:Core:RenderPOIS"

    local destroyPOIRenderer = function()

        hook.Remove( "HUDPaint", poiRenderID ) // Destroy our rendering hook

    end
    
    local createPOIRenderer = function()
    
        destroyPOIRenderer() 

        hook.Add( "HUDPaint", poiRenderID, function()

            renderPOIS()
        
        end )

    end

    net.Receive( "MonkeyPOI:Put:OnTeamChanged", function()
    
        local newTeam = net.ReadUInt( 16 )

        cachedPOIS = getPOIS( newTeam )
        
        if ( not istable( cachedPOIS ) ) then // Destroy the rendering hook, it's no longer being used. 
             
            destroyPOIRenderer()
             
            return 
        end

        createPOIRenderer() // Re-implement the rendering hook, just in-case it's been destroyed. 

    end )

    
    createPOIRenderer()

end

do // Boring stuff. 

    hook.Protect( "InitPostEntity", "MonkeyPOI:Core:LoadPlayer", function()

        ply = LocalPlayer()
    
    end )

    hook.Protect( "Initialize", "MonkeyPOI:Core:LoadCache", function()

        local defaultTeam = GAMEMODE.DefaultTeam
        
        cachedPOIS = getPOIS( defaultTeam )

        MonkeyLib:LoadIcons( MonkeyPOI.Icons )

    end )
    
    concommand.Add( "mpoi_get_pos",  function()

        local playerPos = ply:GetPos()

        local vectorFormat = "Vector(%d, %d, %d),"

        vectorFormat = vectorFormat:format( playerPos:Unpack() )

        print( vectorFormat )

    end )

end
