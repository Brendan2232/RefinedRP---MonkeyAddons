
local colorTable = MonkeyLib.MessageColors 

local colorWhite = colorTable.colorWhite
local colorRed = colorTable.colorRed

local headerTitle = "[MonkeyLib]"

local function headerPrint( message )

    MsgC( colorRed, headerTitle .. " ", colorWhite, message .. "\n" )
    
end

local function safeFormat( unformattedString, argumentTable )
    
    if ( not isstring( unformattedString ) ) then return end 

    if ( not istable( argumentTable ) ) then return unformattedString end 

    local success, result = pcall( string.format, unformattedString, unpack( argumentTable ) )
    if ( not success ) then return unformattedString end

    return result 
end

MonkeyLib.isSteamID = function( steamID )

    if ( not isstring( steamID ) ) then return end 
    
    return ( steamID:match( "^STEAM_[0:5]:[0-1]:[0-9]+$" ) ) == steamID and true  
end

MonkeyLib.Print = function( message, ... )

    if ( not isstring( message ) ) then return end 
    
    message = safeFormat( message, { ... } )

    headerPrint( message )
end

MonkeyLib.isSteamID64 = function( id ) -- Thanks to Sam! 
    
    if ( not isstring( id ) ) then return end 

    if ( isstring( id ) and tonumber( id ) and id:sub( 1, 7 ) == "7656119" and #id == 17 or #id == 18 ) then return true end 
end

MonkeyLib.SafeError = function( err, ... )

    if ( not isstring( err ) ) then return end 

    err = safeFormat( err, { ... } )

    ErrorNoHaltWithStack( err )
end

MonkeyLib.SteamIDToAccountID = function( steamID )

    if ( not MonkeyLib.isSteamID( steamID ) ) then return end 
     
    local accountID = string.sub( steamID, 11 )
    accountID = tonumber( accountID )

    local yID = string.sub( steamID, 9, 9 )
    yID = tonumber( yID )

    return ( accountID * 2 ) + yID
end

MonkeyLib.AccountIDToSteamID = function( accountID )

    if ( not isnumber( accountID ) ) then return end

    local frontID = "STEAM_0:%s:%s"

    accountID = ( accountID / 2 ) 
    
    local yID = ( accountID % 1 > 0 and 1 or 0 )

    accountID = math.floor( accountID )

    return string.format( frontID, yID, accountID )
end

MonkeyLib.SteamID64ToAccountID = function( steamID64 )

    if ( not MonkeyLib.isSteamID64( steamID64 ) ) then return end 

    local steamID = util.SteamIDFrom64( steamID64 )

    local accountID = MonkeyLib.SteamIDToAccountID( steamID )

    return accountID
end

MonkeyLib.AccountIDToSteamID64 = function( accountID )

    if ( not isnumber( accountID ) ) then return end 

    local steamID = MonkeyLib.AccountIDToSteamID( accountID )

    return util.SteamIDTo64( steamID )
end

MonkeyLib.StringCap = function( str, cap )

    return str:len() >= cap 
end

MonkeyLib.ColorFormat = function( unformattedString, colors )

    if ( not isstring( unformattedString ) ) then return {} end 

    colors = istable( colors ) and colors or colorTable 

    local explodedString = string.Explode( " ", unformattedString ) // I would like a better solution, for now it's fine...

    local formattedTable = { colorWhite }

    if ( istable( explodedString ) and #explodedString >= 1 ) then 
        
        local index = #formattedTable + 1

        for k = 1, #explodedString do 

            local row = explodedString[k]
            if ( not row ) then continue end 
            
            local startColorPos, endColorPos = string.find( row, "{(%w+)}" )
    
            if ( startColorPos and endColorPos ) then 
    
                local subbedColor = string.sub( row, startColorPos + 1, endColorPos - 1 )
                if ( not subbedColor ) then continue end 
    
                local foundColor = colors[subbedColor]
                if ( not IsColor( foundColor ) ) then continue end
    
                formattedTable[ index + 1 ] = foundColor
    
                index = index + 2 
    
                continue 
            end
    
            formattedTable[index] = ( formattedTable[index] or "" ) .. row .. " "
        end 
    end
   
    return formattedTable
end

MonkeyLib.ChatMessage = function( message, format, ply )

    if ( not isstring( message ) ) then return end 

    local formattedMessage = safeFormat( message, format )
    if ( not formattedMessage ) then return end 

    if ( CLIENT ) then 
        
        local colorMessage = MonkeyLib.ColorFormat( formattedMessage )
        if ( not istable( colorMessage ) ) then return end 

        chat.AddText( unpack( colorMessage ) )

        return 
    end

    net.Start( "MonkeyLib:SendMessage" )
            
    net.WriteString( formattedMessage )

    if ( IsValid( ply ) or istable( ply ) ) then net.Send( ply ) return end 

    net.Broadcast()
end

MonkeyLib.FancyChatMessage = function( message, isError, format, ply )

    if ( not isstring( message ) ) then return end 

    local formattedMessage = safeFormat( message, format )
    
    if ( CLIENT ) then MonkeyLib.CreateMessage( formattedMessage, isError ) return end 

    net.Start( "MonkeyLib:SendFancyMessage" )

    net.WriteString( formattedMessage )

    net.WriteBool( isError or false )
    
    if ( IsValid( ply ) ) then net.Send( ply ) return end 

    net.Broadcast()
end

do   // Debugger 

    local debugVar = CreateConVar("monkeylib_debug", "1", FCVAR_ARCHIVE, "Enables - Disables MonkeyLib Message debugger.", 0, 1 )

    MonkeyLib.Debug = ProtectFunction( function( bypass, message, ... )

        if ( not bypass and ( not debugVar:GetBool() ) ) then return end 
    
        local logTime = os.date( "%d/%m/%Y - %H:%M:%S" )

        local formattedMessage = "%s | %s"

        message = formattedMessage:format( logTime, message )
        
        MonkeyLib.Print( message, ... )

    end )

end

do 

    MonkeyLib.GetNetFunction = function( netUtil )
        
        if ( not isstring( netUtil ) ) then 
 
            return 
        end
        
        netUtil = netUtil:lower()

        return net.Receivers[netUtil] 
    end 

end

do 

    do 

        local timeCharMap = {

            ["s"] = 1,  
    
            ["m"] = 60, 
    
            ["h"] = 3600, 
            
            ["d"] = 86400, 
    
        }
    
        local getMappedTime = function( char )
    
            return timeCharMap[ char ]
        end
    
        MonkeyLib.StringToTime = function( timeString )
    
            if ( not isstring( timeString ) ) then 
    
                return 
            end
    
            local calculatedTime = 0 
    
            timeString:gsub( "(%d+%w)", function( foundTimeString )
    
                local endTimeChar = foundTimeString:sub(-1) or ""
            
                foundTimeString = foundTimeString:sub(1, -2) or ""
            
                local mappedTime = getMappedTime( endTimeChar )
    
                if ( not isnumber( mappedTime ) ) then 
    
                    return  
                end
    
                local timeNumber = tonumber( foundTimeString )
    
                if ( not isnumber( timeNumber ) ) then 
    
                    return 
                end
    
                timeNumber = ( timeNumber * mappedTime )
    
                calculatedTime = ( calculatedTime + timeNumber )
    
                
            end )
    
            return calculatedTime 
        end

    end

    do 

        local defaultTimeStructure = {

            {
                1, 
                "s", 
            },
        
            {
                60, 
                "m", 
            },
        
            {
                3600, 
                "h", 
            },
        
            {
                86400, 
                "d", 
            },
        
        }
    
        local formattedTimeString = "%d%s"

        local calculateTime = function( currentTime, timePreset )

            return math.floor( currentTime / timePreset ), ( currentTime % timePreset )
        end
        
        local formattedTime = function( timeString, timeChar, time )
        
            local timeFormat = formattedTimeString:format( time, timeChar )
        
            return ( ( timeString == "" and timeFormat ) or string.format( "%s, %s", timeString, timeFormat ) )
        end 
        
        MonkeyLib.NumberToFormattedTime = function( unformattedTime, timeStructure )

            timeStructure = ( istable( timeStructure ) and timeStructure ) or defaultTimeStructure

            local timeString = ""
        
            if ( unformattedTime <= 0 ) then 
    
                return "N/A"
            end
            
            for k = #timeStructure, 1, -1 do 
        
                local row = timeStructure[k]
        
                if ( not istable( row ) ) then 
        
                    continue 
                end
        
                local timePresent, timeCharacter = unpack( row )
        
                local calculatedFormat, newTime = calculateTime( unformattedTime, timePresent )
              
                if ( calculatedFormat <= 0 ) then 
        
                    continue 
                end
       
                unformattedTime = newTime
    
                timeString = formattedTime( timeString, timeCharacter, calculatedFormat )
            
            end
    
            return timeString  

        end

    end
 
end 

do // Simple message formatter 

    local interpolationMethods = {

        ["any"] = function( any )
            
            return any 
        end, 

        ["money"] = function( int )

            AssertF( isnumber( int ), "Type isn't a number!" )

            return MonkeyLib.FormatMoney( int )
        end,

        ["time"] = function( int ) 

            AssertF( isnumber( int ), "Type isn't a number!" )

            return MonkeyLib.NumberToFormattedTime( int )
        end, 

        ["string"] = function( str )

            AssertF( isstring( str ), "Type isn't a string!" )

            return str 
        end,  

        ["int"] = function( int )

            AssertF( isnumber( int ), "Type isn't a number!" )

            return int 
        end

    }

    local interpolationParser = function( parserID, data )

        local foundParser = interpolationMethods[ parserID ]

        if ( not isfunction( foundParser ) ) then 

            return data 
        end

        return foundParser( data ) 
    end

    MonkeyLib.Interpolate = function( str, ... ) // Very simple formatter - I prefer it over '%s'

        local index = 1

        local packedArgs = { ... }

        local formattedString = str:gsub( "{(%a+)}", function( parserType )

            do // Lower our parser value! 

                parserType = parserType:lower()

            end

            local nextValue 
            
            do // Return our next value and increment 

                nextValue = packedArgs[ index ]

                index = index + 1 
                
                AssertF( nextValue, "Can't find the next value!" )
        
            end

            local parsedValue = interpolationParser( parserType, nextValue )

            return parsedValue
        end )

        return formattedString
    end 

end
