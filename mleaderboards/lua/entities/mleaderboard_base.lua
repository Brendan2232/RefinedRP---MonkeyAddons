require( "memoize" )

local defaultFetchTime = ( ( 1 ) * 60 ) * 60

AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName = "Default_Leaderboard"
ENT.Category = "MonkeyEntities"

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.HeaderTitle = "NULL"

ENT.FetchTime = defaultFetchTime

ENT.GetLeaderBoardData = function()

end

ENT.WriteLeaderBoardData = function( s, ply, data )

    if ( not IsValid( s ) or not IsValid( ply ) or not istable( data ) ) then return end 

    net.Start( "MonkeyLeaderBoards:Put:Data" )

        net.WriteEntity( s )

        net.WriteUInt( #data, 10 )

        for k = 1, #data do 
            
            local row = data[k]
            if ( not istable( row ) ) then continue end 

            local steamID64, value = row["steamID64"], row["value"]
        
            if ( not MonkeyLib.isSteamID64( steamID64 ) or not isnumber( value ) ) then continue end 

            MonkeyLib.WriteSteamID64( steamID64 )

            net.WriteUInt( value, 32 ) 
        end

    net.Send( ply )
end

if ( SERVER ) then
    
    require( "mqueue" )

    util.AddNetworkString( "MonkeyLeaderBoards:Get:Data" )
    util.AddNetworkString( "MonkeyLeaderBoards:Put:Data" )

    function ENT:Initialize()
        
        self:SetModel( "models/props/cs_assault/Billboard.mdl" )

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

        self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
        
        self:DrawShadow( false )
        
        self:SetMaterial( "debug/env_cubemap_model" )

    end

    ENT.FetchCooldown = {}

    net.Receive( "MonkeyLeaderBoards:Get:Data", function( l, ply )

        if ( not IsValid( ply ) ) then return end 

        local foundEntity = net.ReadEntity()
        if ( not IsValid( foundEntity ) ) then return end 

        local fetchCooldown = foundEntity.FetchCooldown or {}

        local fetchTime = foundEntity.FetchTime or defaultFetchTime 
        
        local cooldown = fetchCooldown[ply]
        if ( isnumber( cooldown ) and cooldown >= CurTime() ) then return end 

        local getData = foundEntity.GetLeaderBoardData 
        if ( not isfunction( getData ) ) then return end 

        local writer = foundEntity.WriteLeaderBoardData 
        if ( not isfunction( writer ) ) then return end 

        do // Get the data, and send it to the client! 

            local data = getData( foundEntity )

            writer( foundEntity, ply, data )

        end
    
        foundEntity.FetchCooldown[ply] = CurTime() + fetchTime
    end )

    return 
end

ENT.FormatValue = function( s, value )

    return value 
end

ENT.ReadLeaderBoardData = function( s )

    if ( not IsValid( s ) ) then return end

    local sortedData = {}

    local dataAmount = net.ReadUInt( 10 )

    for k = 1, dataAmount do 
    
        local steamID64, value = MonkeyLib.ReadSteamID64(), net.ReadUInt( 32 )

        if ( not MonkeyLib.isSteamID64( steamID64 ) ) then continue end 

        value = s:FormatValue( value ) or value 

        sortedData[k] = {
            ["steamID64"] = steamID64, 
            ["value"] = value, 

        }
    end

    s.M_DataVars = sortedData 

    return sortedData 
end

local draw = draw 
local RoundedBox = draw.RoundedBox
local SimpleText = draw.SimpleText

local cam = cam 
local Start3D2D = cam.Start3D2D
local End3D2D = cam.End3D2D

local string = string 
local format = string.format

local IsValid = IsValid 

local ply = LocalPlayer()

local primaryFont = "MonkeyLib_Inter_50"
local primaryFontHeight = draw.GetFontHeight( primaryFont )

local GUITheme = istable( MonkeyLib ) and MonkeyLib:GetTheme() or {}

local bodyColor, primaryTextColor, secondaryTextColor = GUITheme.bodyColor or color_white, GUITheme.primaryTextColor or color_white, GUITheme.secondaryTextColor or color_white
local headerAbstract, headerSecondaryAbstract = GUITheme.headerAbstract_1 or color_white, GUITheme.headerAbstract_2 or color_white

local panelAmount = 10
local camScale = 0.1 

local modelWidth = 2400 - 200
local modelHeight = 1200 - 80

local gapSize = 8
local lineSize = 2 

local panelWidth = modelWidth / 2 

local headerSize = 100

local playerNameCap = 25

local panelHeight = ( ( modelHeight - headerSize ) / ( panelAmount / 2 ) ) 
panelHeight = math.floor( panelHeight )

local nextFetchTime = 0 

local offsetVec = Vector( 1, -110, 58 )

local maxRenderDistance = 2000

local squaredDistance = maxRenderDistance * maxRenderDistance // Leave this here! 

function ENT:Initialize()


    self.HeaderTitle = format( self.HeaderTitle, panelAmount  )

end

function ENT:Draw()

    if ( not IsValid( ply ) ) then ply = LocalPlayer() return end 

    local mypos = self:GetPos()

    if ( ply:GetPos():DistToSqr( mypos ) >= squaredDistance ) then return end

    self:DrawModel()

    do 
        
        if ( CurTime() >= ( self.nextFetchTime or 0 ) ) then 

            net.Start( "MonkeyLeaderBoards:Get:Data" )
                net.WriteEntity( self )
            net.SendToServer()
    
            self.nextFetchTime = CurTime() + self.FetchTime or defaultFetchTime

        end 
    
    end

    local pos = self:LocalToWorld( offsetVec )

    local DrawAngles = self:GetAngles()

    do 

        DrawAngles:RotateAroundAxis( self:GetAngles():Forward(), 90 )
        DrawAngles:RotateAroundAxis( self:GetAngles():Up(), 90 )
    
    end

    local entData = self.M_DataVars or {}

    local headerTitle = self.HeaderTitle or "NULL" 

    local headerColor = self.HeaderColor or color_white

	Start3D2D( pos, DrawAngles, camScale )

        RoundedBox( 0, 0, 0, modelWidth, modelHeight, headerAbstract )

        RoundedBox( 0, modelWidth / 2, 0, lineSize, modelHeight, bodyColor )

        do // Header 

            RoundedBox( 0, 0, 0, modelWidth, headerSize, headerColor )
    
            SimpleText( headerTitle, primaryFont, modelWidth / 2, headerSize / 2, primaryTextColor, 1, 1 )

        end
    
        do // Stupid math

            local yPos = headerSize

            local rows = math.min( #entData, panelAmount )

            local valueTextColor = self.ValueTextColor or primaryTextColor

            for k = 1, rows do 
    
                local dataRow = entData[k] or {}
                
                local playerName, steamID64, value = dataRow.playerName, dataRow.steamID64, dataRow.value 

                if ( not steamID64 ) then 
                    
                    continue 
                end 

                do // Name Fetching 

                    local playerNameFetchCooldown = dataRow.playerNameCooldown 
             
                    if ( ( playerName == nil or playerName == "NULL" ) and ( playerNameFetchCooldown == nil or ( isnumber( playerNameFetchCooldown ) and ( CurTime() - playerNameFetchCooldown >= 60 ) ) ) ) then 

                        local s = self 

                        MonkeyLib.GetName( steamID64, function( name )
            
                            if ( not IsValid( s ) or not istable( dataRow ) ) then return end 

                            if ( not name or name == "NULL" ) then  

                                dataRow.playerName = nil 

                                dataRow.playerNameCooldown = CurTime()

                                return 
                            end
    
                            if ( MonkeyLib.StringCap( name, playerNameCap ) ) then

                                name = ( name:sub( 1, playerNameCap ) .. "..." )
                        
                            end

                            dataRow.playerName = name 

                            dataRow.playerNameCooldown = false  
                            
                        end )


                        dataRow.playerNameCooldown = CurTime()
                    
                    end

                end
              

                local keyOffset = k - 1 
                local offsetSize = ( keyOffset % 2 ) 
    
                local panelWidthOffset = offsetSize * panelWidth
    
                RoundedBox( 0, panelWidthOffset, yPos, panelWidth, lineSize, bodyColor )
    
                do // Draw our text! 

                    local textXPos = panelWidthOffset + ( gapSize + ( lineSize * offsetSize  ) )

                    local formattedRow = format( "%s | %s", k, playerName or "NULL" )

                    local textYPos = ( yPos + panelHeight / 2 )

                    SimpleText( formattedRow, primaryFont, textXPos, textYPos - ( primaryFontHeight / 2 ), primaryTextColor, TEXT_ALIGN_LEFT, 1 )
                
                    SimpleText( value, primaryFont, textXPos, textYPos + ( primaryFontHeight / 2 ), valueTextColor, TEXT_ALIGN_LEFT, 1 )
                    
                end
  
                yPos = yPos + ( offsetSize * panelHeight )
           
            end
        end

	End3D2D()
end

net.Receive( "MonkeyLeaderBoards:Put:Data", function()

    local ent = net.ReadEntity()
    if ( not IsValid( ent ) ) then return end 

    local reader = ent.ReadLeaderBoardData
    if ( not isfunction( reader ) ) then return end 

    reader( ent )

end )

hook.Add( "MonkeyLib:ThemeReload", "MonkeyLeaderboard:Paint:LoadTheme", function()

    GUITheme = MonkeyLib:GetTheme()

    bodyColor, primaryTextColor, secondaryTextColor = GUITheme.bodyColor or color_white, GUITheme.primaryTextColor or color_white, GUITheme.secondaryTextColor or color_white
    headerAbstract, headerSecondaryAbstract = GUITheme.headerAbstract_1 or color_white, GUITheme.headerAbstract_2 or color_white

end )


