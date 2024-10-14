
include( "shared.lua" )

local primaryTextColor = color_white

local gapSize = 8 
local roundedAmount = 4

local primaryFont = "MonkeyLib_Inter_15"
local primaryFontHeight = draw.GetFontHeight( primaryFont )

local NPCText = "Bail NPC"

local NPCTextFont = "MonkeyLib_Inter_100"
local NPCTextFontHeight = draw.GetFontHeight( NPCTextFont )

local NPCTextSpeed = 1.5
local NPCTextMoveOffset = 30

local NPCTextOffset = 70
local NPCTextMaxDrawDistance = 500

local squaredRenderDistance = ( NPCTextMaxDrawDistance * NPCTextMaxDrawDistance )

local ply = LocalPlayer()

function ENT:Draw() 

    self:DrawModel()

	local mypos = self:GetPos()
	if ( ply:GetPos():DistToSqr( mypos ) >= squaredRenderDistance ) then return end

	local pos = mypos + ( self:GetUp() * 80 ) 

	local ang = ( ply:EyePos() - pos ):Angle()

	ang.p = 0

	ang:RotateAroundAxis( ang:Right(), 90 )
	ang:RotateAroundAxis( ang:Up(), 90 )
	ang:RotateAroundAxis( ang:Forward(), 180 )

	cam.Start3D2D( pos, ang, 0.04 )

        // sin ( -1 , 1 ) abs ( 0, 1 )  
        local textSin = math.abs( math.sin( CurTime() * NPCTextSpeed ) ) * NPCTextMoveOffset 
        
        draw.DrawText( NPCText, NPCTextFont, 0, -NPCTextFontHeight + ( NPCTextOffset + textSin ), primaryTextColor, 1 )

	cam.End3D2D()
end

hook.Add( "InitPostEntity", "MonkeyBail:NPC:InitLocalPlayer", function()

    ply = LocalPlayer()
    
end )
