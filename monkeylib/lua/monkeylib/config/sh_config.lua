MonkeyLib.MessageColors = {

    ["colorWhite"] = color_white, 

    ["colorRed"] = Color(234, 77, 60), 

    ["colorGreen"] = Color(66, 195, 66), 

    ["colorYellow"] = Color(189, 187, 65), 
}

MonkeyLib.DisabledModules = {
 
}

// Keep this in order of what ranks should have higher priority. For example, {"VIP", "VIP+", "VIP+++"} VIP has the lowest priority. 

MonkeyLib.SecondaryRanks = { 
    "VIP",  
}

MonkeyLib.EntityRemoveHandler = {

    ["sprinter_base"] = {
        ["Criminals"] = true, 
        
        ["Gun Dealer"] = true, 
        
        ["Advanced Gun Dealer"] = true, 
    }, 
    ["sprinter_rack"] = {
        ["Criminals"] = true, 
        
        ["Gun Dealer"] = true, 

        ["Advanced Gun Dealer"] = true, 
    },

    ["bp_base"] = true, 

    ["wms_tank"] = true,
    ["wms_bucket"] = true, 

    ["wms_barrel"] = true,
    ["wms_press"] = true, 

    ["wms_container"] = true, 

    ["zmlab_aluminium"] = true,
    ["zmlab_collectcrate"] = true,

    ["zmlab_combiner"] = true,
    ["zmlab_filter"] = true,

    ["zmlab_frezzer"] = true,
    ["zmlab_frezzingtray"] = true,

    ["zmlab_methylamin"] = true,
    ["zmlab_palette"] = true, 

    ["wms_bottle"] = true, 

}

MonkeyLib.MapFlags = {
    "darkrp", 
}

MonkeyLib.GUIColors = {
    --[[
    {
        ["themeName"] = "Monkey Blue", 

        ["bodyColor"] = Color(17, 23, 40 ),
        ["headerColor"] = Color(32, 42, 69 ), 

        ["headerAbstract_1"] = Color(28, 37, 61),
        ["headerAbstract_2"] = Color(30, 39, 64), 
    
        ["dMenuOutlineColor"] = Color(42, 54, 88), 

        ["primaryTextColor"] = Color(235, 235, 235),
        ["secondaryTextColor"] = Color(215,215, 215), 
    
        ["greenColor"] = Color(50, 189, 68),
        ["redColor"] = Color(180, 49, 49), 
    }, 
    ]]
    {
        ["themeName"] = "Monkey Black", 

        ["bodyColor"] =  Color(14, 16, 22),
        ["headerColor"] = Color(23, 26, 33), 

        ["headerAbstract_1"] = Color(18, 20, 26), 
        ["headerAbstract_2"] = Color(19, 21, 28),   

        ["dMenuOutlineColor"] = Color(48, 48, 48), 
        
        ["primaryTextColor"] = Color(235, 235, 235),
        ["secondaryTextColor"] = Color(215,215, 215), 
    
        ["greenColor"] = Color(50, 189, 68),
        ["redColor"] = Color(180, 49, 49), 
    },
    --[[
    {
        ["themeName"] = "Monkey Purple", 

        ["bodyColor"] = Color(13, 0, 30),
        ["headerColor"] =  Color(31, 0, 69), 
    
        ["headerAbstract_1"] = Color(26, 1, 56), 
        ["headerAbstract_2"] = Color(30, 4, 60),        

        ["dMenuOutlineColor"] = Color(42, 7, 85), 
        
        ["primaryTextColor"] = Color(223, 223, 223),
        ["secondaryTextColor"] = Color(209,209, 209), 
    
        ["greenColor"] = Color(50, 189, 68),
        ["redColor"] = Color(180, 49, 49), 
    }
        ]]
}


do // SkyBox Registry

    MonkeyLib.SkyboxRegistry = {}

    MonkeyLib.SkyBoxColor = function( color )

        AssertF( IsColor( color ), "Color isn't a color!" )

        return color:ToVector()
    end

    MonkeyLib.GetSkyBox = function( skyBoxEnum )

        AssertF( skyBoxEnum, "Skybox enum reference is nil!" )

        local skyBoxIndex = skyBoxEnum
        
        if ( isstring( skyBoxEnum ) ) then 

            skyBoxIndex = MonkeyLib[ skyBoxEnum ] // I like accessing things like 'MonkeyLib.SKYBOX_DAY' Bit hacky though.. 
            
        end

        AssertF( isnumber( skyBoxIndex ), "Skybox enum doesn't exist!" )

        return MonkeyLib.SkyboxRegistry[ skyBoxIndex ]
    end 

    MonkeyLib.RegisterSkybox = function( skyBoxName, skyBoxData )

        local enumIndex = #MonkeyLib.SkyboxRegistry + 1

        MonkeyLib.SkyboxRegistry[ enumIndex ] = skyBoxData 

        MonkeyLib[ skyBoxName ] = enumIndex
        
    end

    MonkeyLib.SunStructure = function( sunSize, sunColor )

        return { Size = sunSize or 0, Color = sunColor or color_white }
    end

    local SkyBoxColor = MonkeyLib.SkyBoxColor

    local registerSkybox = MonkeyLib.RegisterSkybox  

    local SunStructure = MonkeyLib.SunStructure

    do 
    
        local topColor = Color( 0, 25.5, 102 )
        local bottomColor = Color( 229.5, 102, 25.5 )

        local duskColor = Color(0, 51, 0 )
        local sunColor = Color( 51, 25.5, 0 )

        registerSkybox( "SKYBOX_DAY", {

            TopColor = MonkeyLib.SkyBoxColor( topColor ),
            BottomColor = MonkeyLib.SkyBoxColor( bottomColor ),
    
            FadeBias = 0.5,
            HDRScale = 0.26,
    
            StarScale = 1.84,
            StarFade = 0.0,
    
            StarSpeed = 0.02,
            DuskScale = 0.3,
    
            DuskIntensity = 1.0,
    
            DuskColor = MonkeyLib.SkyBoxColor( duskColor ),
            SunColor = MonkeyLib.SkyBoxColor( sunColor ),
    
            SunSize = 0,
    
        } )

    end

    do 

        local topColor = Color(0, 0, 0)
        local bottomColor = Color(0, 2, 6)

        local duskColor = Color(1, 25, 0)
        local sunColor = Color(0, 0, 0)

        registerSkybox( "SKYBOX_NIGHT", {

            TopColor = MonkeyLib.SkyBoxColor( topColor ),
            BottomColor = MonkeyLib.SkyBoxColor( bottomColor ),
    
            FadeBias = .5,
            HDRScale = 0.26,
    
            StarScale = 1.84,
            StarFade = 1,
    
            StarSpeed = 0.02,
            DuskScale = 0.3,
    
            DuskIntensity = 0,
    
            DuskColor = MonkeyLib.SkyBoxColor( duskColor ),
            SunColor = MonkeyLib.SkyBoxColor( sunColor ),
    
            SunSize = 0,
    
    
        } )
        
    end 

    do 

        local topColor = Color(8, 0, 12)
        local bottomColor = Color(4, 1, 20)

        local duskColor = Color(14, 0, 2)
        local sunColor = Color(19, 12, 46)

        local secondarySunColor = Color(19, 12, 46 )

        registerSkybox( "SKYBOX_HALLOWEEN_NIGHT", {

            TopColor = MonkeyLib.SkyBoxColor( topColor ),
            BottomColor = MonkeyLib.SkyBoxColor( bottomColor ),
    
            FadeBias = .5,
            HDRScale = 0.26,
    
            StarScale = 1.84,
            StarFade = 1,
    
            StarSpeed = 0.02,
            DuskScale = 0.3,
    
            DuskIntensity = 0,
    
            DuskColor = MonkeyLib.SkyBoxColor( duskColor ),
            SunColor = MonkeyLib.SkyBoxColor( sunColor ),
    
            SunSize = 2,
            SunSettings = SunStructure( 25, secondarySunColor ),
    
        } )

    end

end
