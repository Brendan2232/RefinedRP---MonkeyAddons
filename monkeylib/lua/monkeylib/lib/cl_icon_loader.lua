MonkeyLib.downloadCache = MonkeyLib.downloadCache or {}

local downloadLocation = "monkeylib"

local deleteTime = 2 * ( 86400 )

file.CreateDir( downloadLocation )

local function getExtension( link )

    return string.match( link, "//.-/.+(%..*)$" ) or "" 
end

local function findIcon( iconID, extension )

    if ( not isstring( iconID ) ) then return false end 

    if ( not file.Exists( downloadLocation .. "/" .. iconID .. extension, "DATA" ) ) then return false end 
    
    if ( os.time() >= ( file.Time( downloadLocation .. "/" .. iconID .. extension, "DATA" ) + deleteTime ) ) then 

        file.Delete( downloadLocation .. "/" .. iconID .. extension, "DATA" )

        return false 
    end

    return true 
end

function MonkeyLib:LoadIcon( iconID, iconInfo )

    if ( not isstring( iconID ) or not istable( iconInfo ) ) then 
    
        ErrorNoHaltWithStack("Failed to Load HTTP icon, malformed arguments.")

        return 
    end 

    local iconLink, iconParams = iconInfo["iconLink"], iconInfo["iconParamaters"]

    if ( not isstring( iconLink ) ) then 
 
        ErrorNoHaltWithStack( "Failed to Load HTTP icon ", iconID, " no link." )

        return 
    end 

    if ( MonkeyLib.downloadCache[iconID] ) then return end 

    local linkExtension = getExtension( iconLink ) 

    local fullExtension = downloadLocation .. "/" .. iconID .. linkExtension

    if ( findIcon( iconID, linkExtension ) ) then

        local loadMaterial = Material( "data/" .. fullExtension, iconParams or ""  )
        
        if ( not loadMaterial ) then 

            ErrorNoHaltWithStack( "Found icon ", iconID, " however the material failed to load." )

            return 
        end // Possibly re-try, though I don't want a stack overflow error. Could insert a try - exception amount inside the iconInfo cache. Ever heard of 'memoize'

        MonkeyLib.downloadCache[iconID] = loadMaterial 
        
        MonkeyLib.Print( "Sucessfully loaded MonkeyIcon: ", iconID )

        return 
    end

    http.Fetch( iconLink, function( body )

        file.Write( fullExtension, body )
        
        local loadMaterial = Material( "data/" .. fullExtension, iconParams or "" )

        MonkeyLib.downloadCache[iconID] = loadMaterial 

        MonkeyLib.Print( "Sucessfully downloaded MonkeyIcon: '%s'", iconID )

    end, function( httpErr )

        ErrorNoHaltWithStack( "Failed to download icon ", iconID, ", reason: ", httpErr )

    end )
end

function MonkeyLib:GetIcon( iconID )

    return MonkeyLib.downloadCache[iconID] or Material( " " )
end

function MonkeyLib:LoadIcons( iconTable )

    if ( not istable( iconTable ) ) then return end 

    for k = 1, #iconTable do 
        local iconRow = iconTable[k]
        if ( not istable( iconRow ) ) then continue end 

        local iconID = iconRow.iconID
    
        MonkeyLib:LoadIcon( iconID, iconRow )
       
    end
end

hook.Protect( "Initialize", "MonkeyLib:DownloadIcons", function()

    MonkeyLib:LoadIcon( "m_close", {

        ["iconLink"] = "https://i.imgur.com/vwPMRg7.png", 
        ["iconParamaters"] = "noclamp smooth", 
        
    } )
    
end )
