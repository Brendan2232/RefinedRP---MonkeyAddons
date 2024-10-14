require( "monkeyhooks" )

do // Just the default setting stuff 

    MonkeyLib.M_SkyBox_Sun_Default = MonkeyLib.M_SkyBox_Sun_Default or {}

end

local sunClass = "env_sun"
local skyboxClass = "env_skypaint"

local getSun = function()

    local sun = ( ents.FindByClass( sunClass ) or {} )[ 1 ]

    AssertF( IsValid( sun ), "Sun isn't valid!" )

    return sun
end

local getSkybox = function()

    local skyBox = ( ents.FindByClass( skyboxClass ) or {} )[ 1 ]

    AssertF( IsValid( skyBox ), "Skybox isn't valid!" )

    return skyBox
end 

local createSkybox = function()

    local currentSkyboxes = ents.FindByClass( skyboxClass ) or {}

    local currentSkyboxesLen = #currentSkyboxes 

    if ( currentSkyboxesLen >= 1 ) then 

        for k = 1, currentSkyboxesLen do 
        
            local skybox = currentSkyboxes[k]

            if ( not IsValid( skybox ) ) then 

                continue 
            end

            SafeRemoveEntity( skybox ) // Is this a smart idea?? I'm kinda doubting this now... ( I'll test it on other maps - see if it fucks things up. )

        end

    end 

    local skybox = ents.Create( skyboxClass )
    skybox:Spawn()
    skybox:Activate()

    return skybox 
end

MonkeyLib.ChangeSkybox = function( skyBoxEnum )

    AssertF( skyBoxEnum, "SkyBox enum is a nil reference!" )

    local skyBoxData = MonkeyLib.GetSkyBox( skyBoxEnum ) // Get the Skybox! 

    AssertF( istable( skyBoxData ), "SkyBox data isn't a table!" )

    local sun = getSun()

    local skyBox = getSkybox()

    do // Error handling

        AssertF( IsValid( sun ), "Sun isn't valid!" )
    
        AssertF( IsValid( skyBox ), "Skybox isn't valid!" )

    end 

    do // SkyBox Color Changer ( Cba error handling - if there's issues it'll throw errors. ) 

        skyBox:SetTopColor( skyBoxData.TopColor )
        skyBox:SetBottomColor( skyBoxData.BottomColor )
    
        skyBox:SetSunColor( skyBoxData.SunColor )
        skyBox:SetDuskColor( skyBoxData.DuskColor )
    
        skyBox:SetFadeBias( skyBoxData.FadeBias )
        skyBox:SetHDRScale( skyBoxData.HDRScale )

        skyBox:SetDuskScale( skyBoxData.DuskScale )
        skyBox:SetDuskIntensity( skyBoxData.DuskIntensity )
    
        skyBox:SetSunSize( skyBoxData.SunSize )
        skyBox:SetStarFade( skyBoxData.StarFade )
    
        skyBox:SetStarScale( skyBoxData.StarScale )
        skyBox:SetStarSpeed( skyBoxData.StarSpeed )

    end

    do // Sun modifications 

        local customSunSettings = skyBoxData.SunSettings 

        local defaultSunSettings = MonkeyLib.M_SkyBox_Sun_Default 

        local sunData = ( istable( customSunSettings ) and customSunSettings ) or defaultSunSettings

        AssertF( istable( sunData ), "SunData isn't a table!" )
    
        local size, color = sunData.Size, sunData.Color 

        do // Error handling 

            AssertF( isnumber( size ), "Size isn't a number!" )
    
            AssertF( IsColor( color ), "Color isn't a color!" )
    
        end 

        sun:SetKeyValue( "size", size )
    
        sun:SetKeyValue( "suncolor", string.format( "%i %i %i", color:Unpack() ) ) // This is SHIT

    end

    MonkeyLib.Debug( false, "Changed skybox to '%s'!", skyBoxEnum )

end

hook.Protect( "Initialize", "MonkeyLib:SkyBox:ChangeSkyName", function()

    RunConsoleCommand( "sv_skyname", "painted" )

end )

hook.Protect( "InitPostEntity", "MonkeyLib:SkyBox:InitSkyBox", function()

    do // Cache default sun settings  

        local sun = getSun()

        local keyValues = sun:GetKeyValues()

        local sunSize, sunColor = keyValues.size, keyValues.suncolor 

        sunSize, sunColor = ( tonumber( sunSize ) or 0 ), sunColor:ToColor()

        MonkeyLib.M_SkyBox_Sun_Default = MonkeyLib.SunStructure( sunSize, sunColor )

    end

    local createdSkyBox = createSkybox()

    AssertF( IsValid( createdSkyBox ), "Skybox isn't valid!" )

    MonkeyLib.ChangeSkybox( MonkeyLib.SKYBOX_HALLOWEEN_NIGHT )
    
end )

concommand.Add( "mlib_change_skybox", function( ply, _, args )

    if ( IsValid( ply ) ) then 

        return 
    end 

    local skyBoxEnum = args[ 1 ]

    AssertF( isstring( skyBoxEnum ), "Skybox enum needs to be a string!" )

    local foundEnum = MonkeyLib[ skyBoxEnum ]

    AssertF( isnumber( foundEnum ), "Failed to find skybox enum!" )
    
    MonkeyLib.ChangeSkybox( foundEnum )

end )


