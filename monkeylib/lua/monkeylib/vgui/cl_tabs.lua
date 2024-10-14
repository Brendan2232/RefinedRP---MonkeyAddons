// needs re-coding.. 

local PANEL = {}

function PANEL:Init()
    
    self.Panels = {}

    self.Buttons = {}

    self.ActivePanel = 0 

end 

function PANEL:ActivateTab( tabIndex )
    
    if ( not isnumber( tabIndex ) ) then return false end 

    self.ActivePanel = tabIndex 

    local panels = self.Panels 

    if ( istable( panels ) and #panels >= 1 ) then 

        for k = 1, #panels do 

            local pnl = panels[k]

            if ( not IsValid( pnl ) ) then continue end 

            pnl:SetVisible( ( pnl.TabIndex == tabIndex ) )
        end
    end     
end

function PANEL:RegisterButton( isActive, panelParent, callback, panelType )

    if ( not isstring( panelType ) ) then 
        
        panelType = "DPanel"

    end  

    if ( not IsValid( panelParent ) ) then 
        
        panelParent = self:GetParent() 
    
    end 
    
    local buttonIndex, panelIndex = #self.Buttons + 1, #self.Panels + 1 
    
    local panel = vgui.Create( panelType, panelParent )
    panel.TabIndex = panelIndex 

    panel:SetVisible( isActive )

    self.Panels[panelIndex] = panel

    local button = vgui.Create( "DButton", self )
    button.TabIndex = buttonIndex
    button.TabPanel = panel 
    
    panel.TabButton = button 

    button.DoClick = function( s )

        if ( panelIndex == self.ActivePanel ) then return end 

        self:ActivateTab( panelIndex )

        if ( isfunction( callback ) ) then 
            
            callback( panel, button ) 
        
        end 
    end

    self.Buttons[buttonIndex] = button 

    if ( isActive ) then 

        self:ActivateTab( panelIndex )  

        if ( isfunction( callback ) ) then 
            
            callback( panel, button ) 
        
        end 
        
    end 

    return panel, button 
end

derma.DefineControl("MonkeyLib:Tabs", "Simple Tab system", PANEL, "DPanel")
