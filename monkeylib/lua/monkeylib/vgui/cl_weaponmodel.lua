// Needs re-coding, ripped from OG MonkeyNetworks 

local PANEL = {}

function PANEL:Init()
    self.ModelPanel = vgui.Create("DModelPanel",self)

    self.ModelPanel:Dock(FILL)
    
    self.ModelPanel.MinFOV = 25 
    self.ModelPanel.MaxFOV = 55  
    self.ModelPanel.ShouldZoom = true 
    self.ModelPanel.IsPressed = false 
    self.ModelPanel.CamPos = self.ModelPanel:GetCamPos()

    self.ModelPanel.OnMouseWheeled = function (self,NewFOV)
        if not self.ShouldZoom then return false end   

        if NewFOV == 1 then
            self:SetFOV(self:GetFOV() - 5)
        else 
            self:SetFOV(self:GetFOV() + 5)
        end

        if self:GetFOV() <= self.MinFOV then
            
            self:SetFOV(self.MinFOV)

        elseif self:GetFOV() >= self.MaxFOV then
            
            self:SetFOV(self.MaxFOV)
            
        end
    end

    self.ModelPanel.LayoutEntity = function (self,ent) 

    end
end

function PANEL:Paint(w,h)
    //draw.RoundedBox(8,0,0,w,h,self.PaintColor)
end

function PANEL:WeaponModel(mdl)
    local mdl = mdl 
    if not isstring(mdl) then mdl = "/models/error.mdl" end 

    self.ModelPanel:SetModel(mdl)
end

function PANEL:SetCamPlace(vector)  
    local camera = self.PlayerBox:GetCamPos()

    self.ModelPanel:SetCamPos(camera + vector)
end

function PANEL:SetFOV(fov)  
    self.ModelPanel:SetFOV(fov)

    self.BaseFOV = fov 
end

function PANEL:FOVSettings(min,max)
    self.ModelPanel.MinFOV = min   
    self.ModelPanel.MaxFOV = max   
end

function PANEL:Zoom(bool)
    self.ModelPanel.ShouldZoom = bool 
end

function PANEL:PerformLayout()
    if not IsValid(self.ModelPanel.Entity) then return false end 
    
    local mn, mx = self.ModelPanel.Entity:GetRenderBounds()

    local size = 0
    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

    self.ModelPanel:SetFOV( self.BaseFOV or 45 )
    self.ModelPanel:SetCamPos( Vector( size, size, size ) )
    self.ModelPanel:SetLookAt( (mn + mx) * 0.5 ) 
end

derma.DefineControl( "MonkeyLib:WeaponBox",nil,PANEL,"DPanel")