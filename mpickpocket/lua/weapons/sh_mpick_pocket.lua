AddCSLuaFile()

AddCSLuaFile( "mpickpocket/sh_config.lua" )
include( "mpickpocket/sh_config.lua" )

SWEP.Slot = 5
SWEP.SlotPos = 1

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.PrintName = "PickPocket"
SWEP.Author = "Brendan"
SWEP.Instructions = "Left or right click to steal money from a player."
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model( "models/weapons/c_crowbar.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_crowbar.mdl" )

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "MonkeyWeapons"

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

local L = function( msg )

    return MPickPocket.Messages[msg] or msg 
end 

// Don't modify these! 

local pickPocketSuccessCooldown = MPickPocket.SuccessCooldown * 60 
local pickPocketFailedCooldown = MPickPocket.FailedCooldown * 60 

local soundCooldown = 1
local maxSounds = MPickPocket.MaxSounds or 1 

local soundString = MPickPocket.SoundFile or "physics/body/body_medium_impact_soft%s.wav"
local maxPickPockDistance = MPickPocket.MaxDistance 

local compileSoundString = function()

    local soundNum = math.random( 1, maxSounds )

    return soundString:format( soundNum )
end

// Cooldown system 

local pickPocketCooldownActive, setPickPocketCooldown 

do 

    local stackedCooldowns = {}

    local getPickPocketCooldown = function( ply )

        return stackedCooldowns[ply]  
    end

    pickPocketCooldownActive = function( ply )

        local pickPocketTime = getPickPocketCooldown( ply )

        local hasCooldown = isnumber( pickPocketTime ) and ( not ( CurTime() >= pickPocketTime ) ) or false  
        
        if ( not hasCooldown and isnumber( pickPocketTime ) ) then // Wipe the data!! 
            
            setPickPocketCooldown( ply ) 
        
        end 

        return hasCooldown
    end

    setPickPocketCooldown = function( ply, time )

        stackedCooldowns[ply] = ( isnumber( time ) and ( CurTime() + time ) ) or nil  

    end 

end

local getRankConfig = function( ply )

    local config = MPickPocket.Config["default"]

    local foundTime = config.pickPocketTime 

    local minTime, maxTime = foundTime[1], foundTime[2]

    return minTime, maxTime, config.pickPocketTax, config.pickPocketCap 
end

function SWEP:SetupDataTables()

    self:NetworkVar( "Float", 0, "PickPocketTime" )

    self:NetworkVar( "Float", 1, "StartPickPocketTime" )

    self:NetworkVar( "Entity", 0, "PickPocketTarget" )

    self:NetworkVar( "Bool", 0, "IsPickPocketing" )

end

function SWEP:Initialize()

    self:SetHoldType( "normal" )

end

function SWEP:GetHitTarget()

    local ply = self:GetOwner()
    if ( not IsValid( ply ) ) then return end 
    
    local hitPos = ply:GetEyeTrace()
    if ( not hitPos ) then return end 

    local target = hitPos.Entity

    return ( ( IsValid( target ) and target:IsPlayer() ) and target ) 
end

function SWEP:CheckPickPocketTarget()

    local ply, target = self:GetOwner(), self:GetPickPocketTarget()

    if ( not IsValid( ply ) or not IsValid( target ) ) then 
        
        return false 
    end 

    if ( not ply:Alive() ) then

        return false  
    end
    
    local plyPos, targetPos = ply:GetPos(), target:GetPos()

    local inDistance = plyPos:Distance( targetPos ) <= maxPickPockDistance 

    return inDistance
end

function SWEP:PrimaryAttack()

    // This is my first SWEP, is there any point in the client running this code? I assume network vars will be sent either way. 
    if ( CLIENT ) then return end 

    self:SetNextPrimaryFire( CurTime() + 0.5 )

    local ply = self:GetOwner()

    if ( self:GetIsPickPocketing() or pickPocketCooldownActive( ply ) ) then return end

    local target  
    
    do  // Use Lag compensation, and get the player we're looking at! 

        ply:LagCompensation( true )

        target = self:GetHitTarget()

        ply:LagCompensation( false )

    end

    if ( not IsValid( target ) ) then return end 

    local canPickPocket = hook.Run( "MPickPocket:CanPickPocket", self, ply, target )
    if ( canPickPocket == false ) then return end 

    local minPickPocketTime, maxPickPocketTime = getRankConfig( ply )
    if ( not isnumber( minPickPocketTime ) or not isnumber( maxPickPocketTime ) ) then return end 

    local pickPocketTime = math.random( minPickPocketTime, maxPickPocketTime )

    do // Lets handle our entity vars 

        self:SetPickPocketTarget( target )
        self:SetIsPickPocketing( true )

        self:SetPickPocketTime( pickPocketTime )
        self:SetStartPickPocketTime( CurTime() )
        
    end

    self:SetHoldType( "pistol" )

    hook.Run( "MonkeyPickPocket:PickPocketStart", self, ply, target )
end

function SWEP:SecondaryAttack()

    self:PrimaryAttack()

end

if ( SERVER ) then     

    local calculateFail = function()

        do  // Flush math.random 

            math.random()
            math.random()
            math.random()
    
        end 

        local randomNumber = math.random( 1, 100 )

        if ( randomNumber < 20 ) then

            return true, true 
        end 

        if ( randomNumber >= 20 and randomNumber < 50 ) then 
            
            return true, false 
        end

        return false, false 
    end

    function SWEP:GetPickPocketAmount()

        local target = self:GetPickPocketTarget()
        if ( not IsValid( target ) ) then return end  

        local targetMoney = MonkeyLib.GetMoney( target ) or 0

        local _, _, pickPocketTakeRate, pickPocketTakeMax = getRankConfig( ply )
        if ( not isnumber( pickPocketTakeRate ) or not isnumber( pickPocketTakeMax ) ) then return end 

        local taxedMoney = ( targetMoney * pickPocketTakeRate )

        taxedMoney = math.floor( taxedMoney )
        taxedMoney = math.Clamp( taxedMoney, 0, pickPocketTakeMax ) 
        
        return taxedMoney
    end

    function SWEP:PickPocketFinished()

        local ply, target = self:GetOwner(), self:GetPickPocketTarget() 
        
        if ( not IsValid( ply ) or not IsValid( target ) ) then 
    
            self:PickPocketFailed()
            
            return 
        end 

        local pickPocketAmount = self:GetPickPocketAmount()

        if ( not isnumber( pickPocketAmount ) ) then 
        
            self:PickPocketFailed()

            return 
        end 

        local shouldFail, shouldWant = calculateFail()

        if ( shouldWant ) then

            ply:wanted( nil, L"pickpocket_wanted" )

        end

        if ( shouldFail ) then 

            self:PickPocketFailed()

            return 
        end

        do // Reset our vars 

            self:SetIsPickPocketing( false ) 

            self:SetPickPocketTarget( nil )

        end

        do // Handle the money 

            MonkeyLib.AddMoney( target, -pickPocketAmount )
            MonkeyLib.AddMoney( ply, pickPocketAmount )
        
        end

        do // Send our MonkeyLib Alert! 

            local targetName, formattedMoney = target:Name(), MonkeyLib.FormatMoney( pickPocketAmount )

            MonkeyLib.FancyChatMessage( L"pickpocket_succ", false, { targetName, formattedMoney }, ply )
            
        end

        hook.Run( "MonkeyPickPocket:PickPocketSuccess", self, ply, target, pickPocketAmount )

        setPickPocketCooldown( ply, pickPocketSuccessCooldown )
        
    end

    function SWEP:PickPocketFailed()

        if ( not self:GetIsPickPocketing() ) then return end 

        local ply, target = self:GetOwner(), self:GetPickPocketTarget()
        if ( not IsValid( ply ) ) then return end 
        
        do // Send message to the player 

            MonkeyLib.FancyChatMessage( L"pickpocket_fail", true, nil, ply )
        
        end
        
        do  // Reset our primary vars 

            self:SetIsPickPocketing( false )

            self:SetPickPocketTarget( nil )

        end

        hook.Run( "MonkeyPickPocket:PickPocketFail", self, ply, target )
    
        setPickPocketCooldown( ply, pickPocketFailedCooldown )
        
    end
    
    function SWEP:Holster()

        self:PickPocketFailed()

        return true
    end

    function SWEP:Think()

        local isPickPocketing = self:GetIsPickPocketing()
        if ( not isPickPocketing ) then return end  
        
        local ply = self:GetOwner()
        if ( not IsValid( ply ) ) then return end 

        if ( not ply:Alive() ) then
             
            self:PickPocketFailed()

            return 
        end

        local checkTarget = self:CheckPickPocketTarget()

        if ( not checkTarget ) then

            self:PickPocketFailed()

            return 
        end

        // Handle our sounds! 
        if ( CurTime() - ( self.M_NextSoundQueue or 0 ) >= soundCooldown ) then 

            local foundSound = compileSoundString()

            ply:EmitSound( foundSound )

            self.M_NextSoundQueue = CurTime()

        end

        local isFinished = ( CurTime() - self:GetStartPickPocketTime() ) >= self:GetPickPocketTime()
        if ( not isFinished ) then return end 
    
        self:PickPocketFinished()
     
    end

    return 
end 

// Static Sizes 

local scrw, scrh = ScrW(), ScrH()

local minBarWidth = 300
local minBarHeight = 25 

local barWidthScale = 250
local barHeightScale = 12

local getScale = function()

    local width, height = ScreenScale( barWidthScale ), ScreenScale( barHeightScale )

    width, height = math.floor( width ), math.floor( height )

    width, height = math.max( minBarWidth, width ), math.max( minBarHeight, height )

    return width, height 
end

// Colors 

local colorBlack = color_black 

local GUITheme = istable( MonkeyLib ) and MonkeyLib:GetTheme() or {}
local bodyColor, headerColor, primaryTextColor, secondaryTextColor, greenColor, redColor = GUITheme.bodyColor or color_white, GUITheme.headerColor or color_white, GUITheme.primaryTextColor or color_white, GUITheme.secondaryTextColor or color_white, GUITheme.greenColor or color_white, GUITheme.redColor or color_white

local alphaValue = 240
local bodyColorAlpha = ColorAlpha( bodyColor, alphaValue ) 

local barColor = redColor
local primaryTextColor = primaryTextColor 

// Fonts 

local primaryFont = "MonkeyLib_Inter_15"

// Text stuff 

local hudText = "Stealing players money%s"

// Don't change this here!

local barWidth, barHeight = getScale()

// Offsets 

local barOffset = 8

local shadowTextOffset = 1

// Don't change this here! 

local nextFrame 

do // Frame functions 

    local cooldown, frameCooldown = 0, .5

    local index = 0 

    local frames = {
        "",
        ".",
        "..",
        "...",
    }

    nextFrame = function()

        if ( CurTime() - cooldown < frameCooldown ) then return frames[index] or "." end 

        index = index + 1 

        index = ( ( index - 1 ) % #frames ) + 1 

        cooldown = CurTime()

        return frames[index] or "."
    end
end

local drawShadowText = function( x, y )

    local dotFrame = nextFrame() or "."

    local formattedText = string.format( hudText, dotFrame )

    draw.SimpleText( formattedText, primaryFont, x + shadowTextOffset, y + shadowTextOffset, colorBlack, 1, 1 )

    draw.SimpleText( formattedText, primaryFont, x, y, primaryTextColor, 1, 1 )

end

local screenCenterX, screenCenterY = scrw / 2, scrh / 2 

local barXPos, barYPos = screenCenterX - barWidth / 2, screenCenterY - barHeight / 2

local textYPos = barYPos + barHeight / 2

local barOffsetDivider = ( barOffset / 2 )

local barHeightOffset = barHeight - barOffset

local cachedElements = function()

    scrw, scrh = ScrW(), ScrH()

    barWidth, barHeight = getScale()
 
    screenCenterX, screenCenterY = scrw / 2, scrh / 2 
    screenCenterX, screenCenterY = math.floor( screenCenterX ), math.floor( screenCenterY )

    barOffsetDivider = ( barOffset / 2 )
    barOffsetDivider = math.floor( barOffsetDivider )

    barHeightOffset = barHeight - barOffset
    barHeightOffset = math.floor( barHeightOffset )

    barXPos, barYPos = screenCenterX - ( barWidth / 2 ), screenCenterY - ( barHeight / 2 ) 
    barXPos, barYPos = math.floor( barXPos ), math.floor( barYPos )

    textYPos = barYPos + barHeight / 2
    textYPos = math.floor( textYPos )
    
end


function SWEP:DrawHUD()

    if ( not self:GetIsPickPocketing() or not IsValid( self:GetPickPocketTarget() ) ) then return end 

    local pickPocketStartTime, pickPocketTime = self:GetStartPickPocketTime(), self:GetPickPocketTime()
    if ( not isnumber( pickPocketStartTime ) or not isnumber( pickPocketTime ) ) then return end 

    local fracTime = ( CurTime() - pickPocketStartTime ) / pickPocketTime 

    local fracWidth = barWidth * fracTime
    fracWidth = math.min( barWidth, fracWidth )

    do // Lets draw our HUD! 
        
        draw.RoundedBox( 0, barXPos, barYPos, barWidth, barHeight, bodyColorAlpha )

        draw.RoundedBox( 0, barXPos + barOffsetDivider, barYPos + barOffsetDivider, ( fracWidth - barOffset ), barHeightOffset, barColor )  

    end

    do  // Draw our text 

        drawShadowText( screenCenterX, textYPos  )

    end

end

hook.Add( "OnScreenSizeChanged", "MonkeyPickPocket:SWEP:Scale", function()

    cachedElements()

end )

cachedElements()

hook.Add( "MonkeyLib:ThemeReload", "MonkeyPickPocket:SWEP:ReloadTheme", function()

    GUITheme = istable( MonkeyLib ) and MonkeyLib:GetTheme() or {}

    bodyColor, headerColor, primaryTextColor, secondaryTextColor, greenColor, redColor = GUITheme.bodyColor or color_white, GUITheme.headerColor or color_white, GUITheme.primaryTextColor or color_white, GUITheme.secondaryTextColor or color_white, GUITheme.greenColor or color_white, GUITheme.redColor or color_white
    
    bodyColorAlpha = ColorAlpha( bodyColor, alphaValue ) 
    
end )