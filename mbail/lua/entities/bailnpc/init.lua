
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include( "shared.lua" )

local useCooldown = .2 

function ENT:Initialize()
  
	self:SetModel( MBail.Config.NPCModel )
	self:SetHullType( HULL_HUMAN )

	self:SetHullSizeNormal( )

	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid( SOLID_BBOX )

	self:CapabilitiesAdd( CAP_ANIMATEDFACE )
	self:CapabilitiesAdd( CAP_TURN_HEAD )

	self:SetUseType( SIMPLE_USE )
	self:DropToFloor()
end

function ENT:Use( ply ) 

    if ( not IsValid( ply ) ) then return end 

    if ( ( ply.Ent_NextUseTime or 0 ) > CurTime() ) then return end 

    hook.Run( "MonkeyBail:NPC:Interaction", self, ply )

    ply.Ent_NextUseTime = CurTime() + useCooldown
end
