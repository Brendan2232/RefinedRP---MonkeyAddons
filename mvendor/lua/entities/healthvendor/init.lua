AddCSLuaFile( "sh_config.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "sh_config.lua" )
include( "shared.lua" )

util.AddNetworkString( "MonkeyHealthVendor:PurchaseItem" )
util.AddNetworkString( "MonkeyHealthVendor:SendGUI" )

function ENT:Initialize()
  
	self:SetModel( HealthVendor.VendorModel )
	self:SetHullType( HULL_HUMAN )

	self:SetHullSizeNormal( )

	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid( SOLID_BBOX )

	self:CapabilitiesAdd( CAP_ANIMATEDFACE )
	self:CapabilitiesAdd( CAP_TURN_HEAD )

	self:SetUseType( SIMPLE_USE )
	self:DropToFloor()
end

local L = function( message )

    return HealthVendor.Messages[message] or message 
end 

// ItemType: 1 for health, 2 for armor
local purchaseItem = function( ply, itemType )

    if ( not IsValid( ply ) or not isnumber( itemType ) ) then return false, "purchase_fail" end 

    local price = ( itemType == 1 ) and HealthVendor.HealthPrice or HealthVendor.ArmorPrice

    if ( not MonkeyLib.CanAfford( ply, price ) ) then return false, "cant_afford" end 

    if ( itemType == 1 ) then 

        local currentHealth, maxHealth = ply:Health(), ply:GetMaxHealth()
        if ( currentHealth >= maxHealth ) then return false, "max_hp" end

        ply:SetHealth( maxHealth )
        
    else

        local currentArmor, maxArmor = ply:Armor(), ply:GetMaxArmor()
        if ( currentArmor >= maxArmor ) then return false, "max_armor" end

        ply:SetArmor( maxArmor )

    end

    MonkeyLib.AddMoney( ply, -price )

    return true, "purchase_succ"
end

local inDistance = function( ply, ent )

    if ( not IsValid( ply ) or not IsValid( ent ) ) then return false end 

    local playerPos = ply:GetPos()
    local entPos = ent:GetPos()

    return playerPos:Distance( entPos ) < HealthVendor.DistanceToNPC
end

function ENT:Use( ply ) 

    if ( not IsValid( ply ) ) then return end 

    if ( ( ply.HealthVendor_UseTime or 0 ) > CurTime() ) then return end 

    if ( not inDistance( ply, self ) ) then return end 

    ply.HealthVender_UsingEnt = self 

    net.Start( "MonkeyHealthVendor:SendGUI" )
    net.Send( ply )

    ply.HealthVendor_UseTime = CurTime() + ( HealthVendor.UseCooldown or 0 ) 
end

net.Receive( "MonkeyHealthVendor:PurchaseItem", function( l, ply )

    local targetEnt = ply.HealthVender_UsingEnt 
    if ( not IsValid( targetEnt ) ) then return end 

    if ( not inDistance( ply, targetEnt ) ) then return end 

    local itemID = net.ReadUInt( 2 )

    local succ, err = purchaseItem( ply, itemID )

    MonkeyLib.FancyChatMessage( L( err ), not succ, nil, ply )

end )