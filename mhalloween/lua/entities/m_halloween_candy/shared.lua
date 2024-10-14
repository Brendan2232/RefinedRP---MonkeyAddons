require( "monkeyhooks" )

AddCSLuaFile() 

ENT.Type = "anim"
ENT.PrintName = "Halloween Candy"

ENT.Author = "Brendan"
ENT.Category = "MonkeyEntities"

ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false

local particleID = "fuse01" // Might change this particle ( comes with halloween pack )

PrecacheParticleSystem( particleID )

if ( SERVER ) then 

    local eatSound = Sound( "NomNom.wav" )
        
    local popSound = "garrysmod/balloon_pop_cute.wav"

    local removeEffect = "sweetspickup"

    local baseModel = "models/zerochain/props_halloween/bonbon01.mdl"

    function ENT:Initialize()

        self:SetModel( baseModel )

        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_NONE )

        self:SetSolid( SOLID_VPHYSICS )
        self:SetUseType( SIMPLE_USE )
        
        self:SetTrigger( true )
        self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )

    end 

    function ENT:OnRemove()

        self:StopParticles()

        local isUsed = self.USED 

        if ( not isUsed ) then 

            return 
        end

        local pos = self:GetPos()

        do // Play our sounds!

            sound.Play( eatSound, pos, 75, 100, 1)
            
            sound.Play( popSound, pos, 75, 60, 0.3 )
            
        end 

        do // Create our particle! 

            local color = self:GetColor()

            local vectorColor = ( color:ToVector() * 255 )

            local effect = EffectData()
            effect:SetOrigin( pos )
            effect:SetStart( vectorColor )

            util.Effect( removeEffect, effect )

        end

    end 

    return 
end 

local rotateSpeed = 75

local colorBlack = color_black 
local primaryTextColor = color_white

local gapSize = 8 
local roundedAmount = 4

local primaryFont = "MonkeyLib_Inter_15"
local primaryFontHeight = draw.GetFontHeight( primaryFont )

local textHeader = "Collect me!"

local textFont = "MonkeyLib_Inter_100"
local textFontHeight = draw.GetFontHeight( textFont )

local textSpeed = 1.5
local textMoveOffset = 60

local textOffset = 90
local textMaxDrawDistance = 500

local outLineOffset = 4 

local squaredRenderDistance = 800 ^ 2 
local squaredRotationDistance = 2200 ^ 2 

local initParticles = function( ent )

    local hasParticles = ent.M_RENDER_PARTICLES 

    if ( hasParticles ) then 

        return 
    end

    ent:StopParticleEmission()

    do // Cache and create! 
        
        ParticleEffectAttach( particleID, PATTACH_POINT_FOLLOW, ent, 1 ) // Running this client-sided so I can tie it with render distance. 

    end

    ent.M_RENDER_PARTICLES = true 
end 

local destroyParticles = function( ent )

    local hasParticles = ent.M_RENDER_PARTICLES 

    if ( not hasParticles ) then 

        return 
    end

    ent:StopParticleEmission()
    
    ent.M_RENDER_PARTICLES = false 

end

local ply = LocalPlayer()

function ENT:Draw() 
    
    self:DrawModel()

    if ( not IsValid( ply ) ) then 

        return 
    end

    local mypos = self:GetPos()

	if ( ply:GetPos():DistToSqr( mypos ) >= squaredRenderDistance ) then 

        do // Destroy our particles!

            destroyParticles( self )

        end

        return 
    end
    
    do // Init our particles! 

        local hasParticles = self.M_RENDER_PARTICLES 

        if ( not hasParticles ) then 

            initParticles( self )

        end
        
    end

	local pos = mypos + ( self:GetUp() * 25 ) 

	local ang = ( ply:EyePos() - pos ):Angle()

    do // Angle shit 

        ang.p = 0

        ang:RotateAroundAxis( ang:Right(), 90 )
        ang:RotateAroundAxis( ang:Up(), 90 )
        ang:RotateAroundAxis( ang:Forward(), 180 )

    end

    local bodyColor = self:GetColor() // Can't cache this on Initialize - color is set later on. 

	cam.Start3D2D( pos, ang, 0.07 )

        // sin ( -1 , 1 ) abs ( 0, 1 )  
        local textSin = math.abs( math.sin( CurTime() * textSpeed ) ) * textMoveOffset 

        draw.DrawText( textHeader, textFont, outLineOffset, -textFontHeight + ( textOffset + textSin ) + outLineOffset, colorBlack, 1 )

        draw.DrawText( textHeader, textFont, 0, -textFontHeight + ( textOffset + textSin ), bodyColor, 1 )


	cam.End3D2D()

end

function ENT:Think()

    if ( not IsValid( ply ) ) then 

        return 
    end

    local mypos = self:GetPos()

    if ( ply:GetPos():DistToSqr( mypos ) >= squaredRotationDistance ) then 
        
        return 
    end
    
    local angle = Angle( 0, CurTime() * rotateSpeed, 0 )

    self:SetAngles( angle ) // Not the best idea... 

end 

hook.Protect( "InitPostEntity", "MHalloween:Candy:InitLocalPlayer", function()

    ply = LocalPlayer()
    
end )

