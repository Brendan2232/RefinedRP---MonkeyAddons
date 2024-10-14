local PANEL = {}
local segmentAmount = 64

function PANEL:Init()

    self.avatar = vgui.Create( "AvatarImage", self )
    self.avatar:Dock( FILL )
    self.avatar:SetPaintedManually( true ) 

	self.cachedCircle = nil 
end

function PANEL:SetPlayer( ply, size )

	if ( not IsValid( ply ) ) then self:Remove() return end 
    if ( not size ) then size = 64 end 

	local w, h = self:GetSize()
    
    self.avatar:SetPlayer( ply, size )
    self.seg = segmentAmount 
    self.color = Color(0,0,0)

	self.cachedCircle = MonkeyLib.Circle( w / 2, h / 2, w / 2, self.seg )
    
end

function PANEL:SetSteamID(sid,size)

	if ( not sid ) then self:Remove() return false end 
    if ( not size ) then size = 64 end 

	self.avatar:SetSteamID( sid, size )

	self.seg = segmentAmount

    self.color = Color(0,0,0)

end

function PANEL:Paint( w, h )

    render.ClearStencil( )
    render.SetStencilEnable( true )
	render.SetStencilWriteMask( 1 )
	render.SetStencilTestMask( 1 )
	render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
	render.SetStencilPassOperation( STENCILOPERATION_ZERO )
	render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
	render.SetStencilReferenceValue( 1 )

		MonkeyLib.DrawCachedCirlce( self.cachedCircle, self.color )
 
	render.SetStencilFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilReferenceValue( 1 )

        self.avatar:SetPaintedManually( false )
        self.avatar:PaintManual( )
        self.avatar:SetPaintedManually( true )

	render.SetStencilEnable( false )
	render.ClearStencil()

end

function PANEL:PerformLayout( w, h ) // Should be a bit better than re-calculating the circle every frame. 

	self.cachedCircle = MonkeyLib.Circle( w / 2, h / 2, w / 2, self.seg )

end
    
vgui.Register( "MonkeyLib:CircleAvatar", PANEL )