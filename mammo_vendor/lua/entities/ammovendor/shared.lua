AddCSLuaFile() 
AddCSLuaFile( "sh_config.lua" )

include( "sh_config.lua" )

ENT.Type = "anim"
ENT.PrintName = "Ammo Vendor"

ENT.Author = "Brendan"
ENT.Category = "MonkeyEntities"

ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true

local ammoTypes = AmmoVendor.AmmoTypes or {}

local L = function( message )

    return AmmoVendor.Messages[message] or message
end 

local inDistance = function( ply, ent )

    if ( not IsValid( ply ) or not IsValid( ent ) ) then return false end 

    local playerPos = ply:GetPos()
    local entPos = ent:GetPos()

    return playerPos:Distance( entPos ) < AmmoVendor.DistanceToVendor 
end

if ( SERVER ) then 

    util.AddNetworkString("MonkeyVendor:Ammo:Purchase")

    function ENT:Initialize()
  
        self:SetModel( "models/props_interiors/VendingMachineSoda01a.mdl" )
    
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
        self:SetUseType( SIMPLE_USE )
        
        self:GetPhysicsObject():EnableMotion( false )
    
    end 

    local purchaseAmmo = function( ply, foundAmmo )

        if ( not IsValid( ply ) or not istable( foundAmmo ) ) then
            
            return false, "purchase_fail"
        end
        
        local ammoType, ammoGiveAmount, ammoPrice = foundAmmo.ammoType, foundAmmo.amountGiven, foundAmmo.price 

        if ( not isstring( ammoType ) or not isnumber( ammoGiveAmount ) or not isnumber( ammoPrice ) ) then

            return false, "purchase_fail"
        end

        local canAfford = MonkeyLib.CanAfford( ply, ammoPrice )

        if ( not canAfford ) then

            return false, "cant_afford" 
        end

        MonkeyLib.AddMoney( ply, -ammoPrice )

        ply:GiveAmmo( ammoGiveAmount, ammoType )
    
        return true, "purchase_succ"
    end 

    net.Receive( "MonkeyVendor:Ammo:Purchase", function( l, ply )
    
        local ent, key = net.ReadEntity(), net.ReadUInt( 16 )
        if ( not IsValid( ent ) or not isnumber( key ) ) then return end 

        if ( ent:GetClass() ~= "ammovendor" ) then return end 
    
        if ( not inDistance( ply, ent ) ) then return end 
            
        local foundAmmoType = ammoTypes[key]
        if ( not istable( foundAmmoType ) ) then return end 

        local succ, err = purchaseAmmo( ply, foundAmmoType )

        if ( not err ) then return end 

        MonkeyLib.FancyChatMessage( L( err ), not succ, nil, ply )

    end )


    return 
end 

// Cached functions / Enums 

local CurTime = CurTime 

local istable = istable 
local isnumber = isnumber 

local IsValid = IsValid 
local isstring = isstring 

local ColorAlpha = ColorAlpha

local util = util 
local IntersectRayWithPlane = util.IntersectRayWithPlane

local KEY_E = KEY_E

local TEXT_ALIGN_LEFT = TEXT_ALIGN_LEFT
local TEXT_ALIGN_RIGHT = TEXT_ALIGN_RIGHT 

local surface = surface
local SetFont = surface.SetFont  

local draw = draw

local RoundedBox = draw.RoundedBox
local GetFontHeight = draw.GetFontHeight  

local DrawText = draw.DrawText 
local SimpleText = draw.SimpleText

local cam = cam 

local End3D2D = cam.End3D2D
local Start3D2D = cam.Start3D2D

local math = math 
local floor = math.floor 

local input = input 
local IsKeyDown = input.IsKeyDown 

// Colors 

local GUITheme = istable( MonkeyLib ) and MonkeyLib:GetTheme() or {}
 
local bodyColor = GUITheme.bodyColor or color_white 
local headerColor = GUITheme.headerColor or color_white 

local headerAbstract, headerSecondaryAbstract = GUITheme.headerAbstract_1 or color_white, GUITheme.headerAbstract_2 or color_white

local alphaAmount = 240
local headerAbstractAlpha, headerSecondaryAbstractAlpha = ColorAlpha( headerAbstract, alphaAmount + 5 ),  ColorAlpha( headerSecondaryAbstract, alphaAmount + 1 )

local redColor = GUITheme.redColor or color_white
local greenColor = GUITheme.greenColor or color_white 

local primaryTextColor = GUITheme.primaryTextColor or color_white 
local secondaryTextColor = GUITheme.secondaryTextColor or color_white 

local lineColor = bodyColor

// Offset values 

local gapSize = 8 
local roundedAmount = 4

// Font Stuff

local headerFont = "MonkeyLib_Inter_50"
local primaryFont = "MonkeyLib_Inter_30"

local primaryFontHeight = GetFontHeight( primaryFont )
local primaryFontHeightDivider = primaryFontHeight / 2 

// Text Cache 

local headerTitle = "Ammo Vendor"
local purchaseButtonText = "Purchase!"

// Static sizes 

local camScale = .1 
local lineHeight = 2 

local headerHeight = 70
local modelWidth, modelHeight = 500, 925 

local elementWidth = modelWidth 
local elementHeight = ( ( modelHeight - headerHeight ) / #ammoTypes  )

elementHeight = floor( elementHeight )

// Don't modify these values 

local cooldown = 0 
local purchaseCooldown = .4                     

local ply = LocalPlayer()

local vectorDrawPos = Vector( 22, -25, 48 )

// Functions 

local preCacheEntityData = function()

    local data = ammoTypes or {}

    if ( #data <= 0 ) then 
        return 
    end 
    
    local preCacheData = {}

    for k = 1, #data do 

        local row = data[k]
        if ( not istable( row ) ) then continue end 

        local ammoName, ammoPrice = row.name, row.price 
        if ( not isstring( ammoName ) or not isnumber( ammoPrice ) ) then continue end 

        local formattedPrice = MonkeyLib.FormatMoney( ammoPrice ) or "NULL"

        local rowColor = ( k % 2 ) == 0 and headerAbstractAlpha or headerSecondaryAbstractAlpha

        preCacheData[k] = {
            ["ammoName"] = ammoName, 
            ["rowColor"] = rowColor, 
            ["formattedPrice"] = formattedPrice
        }

    end

    do // Lets do our math! 

        elementHeight = ( ( modelHeight - headerHeight ) / #ammoTypes  )

        elementHeight = floor( elementHeight )

    end

    return preCacheData
end

local getMousePos = function( self, vectorPos, vectorAngle )

    if ( not IsValid( self ) or not IsValid( ply ) ) then return end 
    
    local shootPos, aimPos = ply:GetShootPos(), ply:GetAimVector()
    
    local upwardsAngle = vectorAngle:Up()

	local hitPos = IntersectRayWithPlane( 
		shootPos, aimPos,
		vectorPos, upwardsAngle
	)

	if ( not hitPos ) then return 0, 0, false end 

    local diff = vectorPos - hitPos

    local x = diff:Dot( -vectorAngle:Forward() ) / camScale
    local y = diff:Dot( -vectorAngle:Right() ) / camScale

    self.mouseX = x 
    self.mouseY = y 

    self.mouseActive = true  

    return x, y, true  
end

local isHovering = function( self, x, y, w, h )

    if ( not isnumber( x ) or not isnumber( y ) or not isnumber( w ) or not isnumber( h ) ) then return end 

    local mouseX, mouseY, mouseActive = self.mouseX or 0, self.mouseY or 0, self.mouseActive or false  

    return mouseActive and mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h 
end 

local getCachedRow = function( ent, key )

    return ent.preCachedData[key]
end

local purchaseAmmo = ProtectFunction( function( ent, key )

    if ( not IsValid( ent ) or not isnumber( key ) ) then return end 
    
    net.Start( "MonkeyVendor:Ammo:Purchase" )
        net.WriteEntity( ent )
        net.WriteUInt( key, 16 )
    net.SendToServer()

end )

local createAmmoRow = function( self, key, x, y, w, h )

    if ( not IsValid( self ) or not isnumber( x ) or not isnumber( y ) or not isnumber( w ) or not isnumber( h ) ) then return end 
 
    local preCachedRow = getCachedRow( self, key )
    if ( not istable( preCachedRow ) ) then return end 

    local rowColor = preCachedRow.rowColor or color_white 
    
    local isUsed, isActive = self.UsedBind, isHovering( self, x, y, w, h )

    local primaryYPos = ( y + ( h / 2 ) )
    local textYPos = ( primaryYPos - primaryFontHeightDivider )

    local ammoName, formattedPrice = preCachedRow.ammoName, preCachedRow.formattedPrice 

    do // Draw our row! 

        RoundedBox( 0, x, y, w, h, rowColor )
    
    end

    do  // Lets draw our Ammo text / price 
        
        DrawText( ammoName, primaryFont, gapSize, textYPos - primaryFontHeightDivider, primaryTextColor, TEXT_ALIGN_LEFT )
 
        DrawText( formattedPrice, primaryFont, gapSize, textYPos + primaryFontHeightDivider, greenColor, TEXT_ALIGN_LEFT )

    end

    do  // Lets draw our button! 

        local yOffset = ( gapSize )

        local buttonYPos = y + yOffset 
        
        DrawText( purchaseButtonText, primaryFont, w - gapSize, primaryYPos - primaryFontHeightDivider, isActive and greenColor or primaryTextColor, TEXT_ALIGN_RIGHT )       
        
    end

    if ( ( isActive and isUsed ) and ( CurTime() - cooldown ) > purchaseCooldown ) then 

        self.UsedBind = false 

        purchaseAmmo( self, key )

        cooldown = CurTime()
    end
end 

function ENT:Draw() 

    self:DrawModel()

    if ( not IsValid( ply ) ) then 

        ply = LocalPlayer()

        return 
    end

	local mypos = self:GetPos()
	if ( ply:GetPos():Distance( mypos ) >= 300 ) then return end

    local pos, ang = self:LocalToWorld( vectorDrawPos ), self:GetAngles()

    do

        ang:RotateAroundAxis( ang:Up(), 90 )
        ang:RotateAroundAxis( ang:Forward(), 90 )

    end

    if ( #ammoTypes <= 0 ) then

        return 
    end

    if ( not istable( self.preCachedData ) ) then 
        
        self.preCachedData = preCacheEntityData()
        
        return 
    end

    getMousePos( self, pos, ang )

	Start3D2D( pos, ang, camScale )

        SetFont( primaryFont )

        do // Lets draw our header! 

            RoundedBox( 0, 0, 0, elementWidth, headerHeight, headerColor )
            SimpleText( headerTitle, headerFont, elementWidth / 2, headerHeight / 2, secondaryTextColor, 1, 1 )

        end

        for k = 1, #ammoTypes do 
        
            local row = ammoTypes[k]
            if ( not istable( row ) ) then continue end 
            
            local keyRow = ( k - 1 )

            local yPos = headerHeight + ( keyRow * elementHeight ) 

            do // Seperation line

                RoundedBox( 0, 0, yPos, elementWidth, lineHeight, lineColor )

            end

            createAmmoRow( self, k, 0, yPos, elementWidth, elementHeight )
       
        end         
    
	End3D2D()

end

hook.Add( "PlayerBindPress", "MAmmoVendor:BindPress:Use", function( ply, bind, pressed )
    
    if ( bind ~= "+use" or not pressed ) then return end 

    local eyeTarget = ply:GetEyeTrace()
    if ( not eyeTarget ) then return end 

    local eyeEnt = eyeTarget.Entity 
    if ( not IsValid( eyeEnt ) ) then return end

    if ( eyeEnt:GetClass() ~= "ammovendor" ) then return end 

    if ( not inDistance( ply, eyeEnt ) ) then return end 

    eyeEnt.UsedBind = true 

    return true
end )

hook.Add( "MonkeyLib:ThemeReload", "MonkeyVendor:Ammo:ReloadTheme", function()

    GUITheme = istable( MonkeyLib ) and MonkeyLib:GetTheme() or {}
 
    bodyColor = GUITheme.bodyColor or color_white 
    headerColor = GUITheme.headerColor or color_white 
    
    headerAbstract, headerSecondaryAbstract = GUITheme.headerAbstract_1 or color_white, GUITheme.headerAbstract_2 or color_white
    
    alphaAmount = 253
    headerAbstractAlpha, headerSecondaryAbstractAlpha = ColorAlpha( headerAbstract, alphaAmount - 1 ),  ColorAlpha( headerSecondaryAbstract, alphaAmount + 1 )
    
    redColor = GUITheme.redColor or color_white 
    primaryTextColor = GUITheme.primaryTextColor or color_white 
    
    secondaryTextColor = GUITheme.secondaryTextColor or color_white 
    
    greenColor = GUITheme.greenColor or color_white 
    
end )