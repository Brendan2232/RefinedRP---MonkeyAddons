local globalThemes = MonkeyLib.GUIColors

local databaseCookieID = "monkeythemes"

local themeIndex = 1 

function MonkeyLib:SelectTheme( index )

    if ( index == themeIndex ) then 
        
        return false 
    end

    if ( not globalThemes[index] ) then 
        
        themeIndex = 1 
        
        return false 
    end 

    themeIndex = index 

    cookie.Set( databaseCookieID, index )

    hook.Run( "MonkeyLib:ThemeReload", themeIndex )

end

function MonkeyLib:LoadTheme()

    local cookieValue = cookie.GetNumber( databaseCookieID )

    if ( not isnumber( cookieValue ) ) then 
        
        MonkeyLib:SelectTheme( 1 ) 

        return  
    end 

    if ( not globalThemes[cookieValue] ) then 
        
        MonkeyLib:SelectTheme( 1 ) 
        
        return false 
    end 

    themeIndex = cookieValue 
    
    hook.Run( "MonkeyLib:ThemeReload", themeIndex )

end

function MonkeyLib:GetTheme()
    
    return globalThemes[themeIndex] or globalThemes[1]   
end

function MonkeyLib:GetThemeIndex()

    return themeIndex or 1 
end

hook.Protect( "Initialize", "MonkeyLib:loadTheme", function()

    MonkeyLib:LoadTheme()

end )

