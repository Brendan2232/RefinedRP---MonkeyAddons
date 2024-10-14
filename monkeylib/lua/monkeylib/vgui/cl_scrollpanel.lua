local GUITheme = MonkeyLib:GetTheme()
 
local bodyColor = GUITheme.bodyColor 
local headerColor = GUITheme.headerColor 

local PANEL = {}

function PANEL:Init()

	self.CurrentOffset, self.TargetOffset, self.StartTime, self.EndTime = 0, 0, 0, 0 

    local VBar = self.VBar 
	VBar:SetWide(12)
	
	VBar.CurrentY = 0
	VBar.TargetY = 0

    VBar.Paint = function(s, w, h)
        draw.RoundedBox( self.roundedAmount or 4, 4, 0, w - 4 , h, headerColor) 

    end 

    VBar.btnGrip.Paint = function(s, w, h)
        draw.RoundedBox( self.roundedAmount or 4, 5, 2, w - 6 , h - 5, bodyColor) 
    end
    
    VBar.PerformLayout = function(s)
		local Wide = s:GetWide()
		local Scroll = s:GetScroll() / s.CanvasSize
		local BarSize = math.max( s:BarScale() * s:GetTall(), 10 )

		local Track = s:GetTall() - BarSize
		Track = Track + 1

		Scroll = Scroll * Track
		s.TargetY = Scroll

		s.btnGrip:SetSize( Wide, BarSize )
		s.btnUp:SetVisible( false )
		s.btnDown:SetVisible( false )
	end

	VBar.Think = function(s)
		s.CurrentY = Lerp(FrameTime() * 20, s.CurrentY, s.TargetY)

		s.btnGrip:SetPos(0, math.Round(s.CurrentY))
	end

	self.pnlCanvas.CurrentOffset = 0
	self.pnlCanvas.TargetOffset = 0

	self.pnlCanvas.Think = function(s)
		s.CurrentOffset = Lerp(FrameTime() * 20, s.CurrentOffset, s.TargetOffset)

		s:SetPos(0, math.Round(s.CurrentOffset))
	end
end

function PANEL:OnVScroll(offset)
	self.pnlCanvas.TargetOffset = offset
end

function PANEL:PerformLayoutInternal()
	local Tall = self.pnlCanvas:GetTall()
	local Wide = self:GetWide()
	local YPos = 0

	self:Rebuild()

	self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
	YPos = self.VBar:GetOffset()

	if self.VBar.Enabled then Wide = Wide - self.VBar:GetWide() - (self.VBarSizeOffset or 0) end

	self.pnlCanvas:SetPos( 0, YPos )
	self.pnlCanvas:SetWide( Wide )

	self:Rebuild()

	if ( Tall != self.pnlCanvas:GetTall() ) then
		self.VBar:SetScroll( self.VBar:GetScroll() ) 
	end
end

derma.DefineControl("MonkeyLib:ScrollPanel", nil, PANEL, "DScrollPanel")

hook.Add( "MonkeyLib:ThemeReload", "MonkeyLib:ScrollPanel:ReloadTheme", function()
    
    GUITheme = MonkeyLib:GetTheme()
 
    bodyColor = GUITheme.bodyColor 
    headerColor = GUITheme.headerColor 
    
end )