// Possibly re-code some parts of this loader, some low quality work. ( everything works, just some flaws. )

require( "monkeyhooks" )
require( "monkeynet" )
require( "async" )
require( "memoize" )

MonkeyLib = MonkeyLib or {}

local mainDir = "monkeylib/"
local moduleDir = "monkeymodules"

local SERVER = SERVER 
local CLIENT = CLIENT 

local include = include 
local AddCSLuaFile = AddCSLuaFile 

local istable = istable 
local isstring = isstring 

local lower = string.lower  
local left =  string.Left 

local file = file 
local Find = file.Find 

local function loadFile( directory, foundFile )

    if ( not isstring( directory ) or not isstring( foundFile ) ) then return false end 

    local prefix = lower( left( foundFile, 3 ) )

	if ( SERVER ) and ( prefix == "sv_" ) then

		include( directory .. foundFile )

	elseif ( prefix == "sh_" ) then

		if ( SERVER ) then AddCSLuaFile( directory .. foundFile ) end 

		include( directory .. foundFile )

	elseif ( prefix == "cl_" ) then

		if ( SERVER ) then

			AddCSLuaFile( directory .. foundFile )

		elseif ( CLIENT ) then

			include( directory .. foundFile )

		end
	end
end

local function loadDirectory( firstDirectory, directory )

    if ( not isstring( directory ) ) then 
        
        return false 
    end 

    directory = firstDirectory .. directory .. "/"

    local files, _ = Find( directory .. "*", "LUA" )

    if ( istable( files ) and #files >= 1 ) then    

        for k = 1, #files do 

            local foundFile = files[k]
     
            if ( not foundFile ) then 
                
                continue 
            end 
             
            local succ, err = pcall( loadFile, directory, foundFile )
            
            if ( not succ and err ) then 
                
                ErrorNoHaltWithStack( err )

            end 
           
        end 
    end 
end

local defaultLoadingStructure = {
    ["config"] = 1,
    ["net"] = 2,
    ["lib"] = 3,
    ["core"] = 4,
    ["pages"] = 5, 
}

local getLoadingFileOutput = ProtectFunction( function( directory ) 

    if ( not isstring( directory ) ) then 
        
        return 
    end 

    if ( SERVER ) then 

        AddCSLuaFile( directory )

    end

    local output = include( directory )

    return output 
end )

// I want to re-code this system - rather than using 'table.sort' I'd like to use the 'loading_order' file to have folder priority.      
local function loadModules( directory, hasFoundDir ) 

    directory = directory .. "/"

    local files, folders = Find( directory .. "*" , "LUA" )

    if ( #folders < 1 ) then return end 

    local abstractRules = defaultLoadingStructure

    local loadingOrderFile = files[1]

    if ( loadingOrderFile and ( loadingOrderFile == "loading_order.lua" ) ) then 
    
        local succ, returnedOrder = getLoadingFileOutput( directory .. loadingOrderFile )

        if ( istable( returnedOrder ) ) then abstractRules = returnedOrder end

    end

    table.sort( folders, function( a, b )

        local firstRule, secondRule = abstractRules[a], abstractRules[b]

        if ( not firstRule or not secondRule ) then return end 
        
        return secondRule > firstRule 
    end )

    for k = 1, #folders do 

        local foundDir = folders[k]

        if ( not foundDir ) then 
            
            continue 
        end 

        loadDirectory( directory, foundDir )
    end
end 

local function findModules( directory )

    directory = directory .. "/"

    local files, folders = file.Find( directory .. "*", "LUA" )

    for k = 1, #folders do 

        local foundFolder = folders[k]

        if ( not isstring( foundFolder ) ) then 
            
            continue 
        end 

        local isDisabled = MonkeyLib.DisabledModules[foundFolder]

        if ( isDisabled ) then 

            continue 
        end 

        loadModules( directory .. folders[k] ) 

    end
end

loadDirectory( mainDir, "config" )

loadDirectory( mainDir, "lib" )

loadDirectory( mainDir, "sql" )

loadDirectory( mainDir, "vgui" )

findModules( moduleDir )


