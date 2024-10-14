require( "async" )

require( "monkeyhooks" )
 
MonkeyLogs = MonkeyLogs or {}

// Very basic logging system, only so I have proof of actions. 
// Log identifer is os.date( "_%d-%m-%Y" ), you can't change this, it's supposed to be like this. 

local logDir = "mlogs"
local format = string.format 

local safeFormatLogs = ProtectFunction( function( messageFormat, ... )

    local logDate = os.date( "%d/%m/%Y - %H:%M:%S" )

    local logDateFormat = "%s | %s"
    
    messageFormat = logDateFormat:format( logDate, messageFormat )

    return messageFormat:format( ... )  
end )

local logError = function( err, format )

    if ( not isstring( err ) ) then return end 

    local success, message = safeFormatLogs( err, format )
    message = ( success and message or format )

    ErrorNoHaltWithStack( "MonkeyLogs | ", message )
end 

local logMeta = {}

AccessorFunc( logMeta, "set_title", "Title", FORCE_STRING )

logMeta.Log = function( s, logString, ... )

    s.Heap = s.Heap or {}

    local logFormat = logString

    local success, logString = safeFormatLogs( logFormat, ... )
    logString = ( success and logString or logFormat )

    local heapIndex = #s.Heap + 1 or 1 

    s.Heap[heapIndex] = logString 

    return logString 
end

logMeta.SetLogDirectory = function( s, logDirectory )

    file.CreateDir( logDir )

    s.logFileDirectory = logDir .. "/" .. logDirectory 
    
end 

logMeta.IsValid = function( s )

    return ( getmetatable( s ) == logMeta )
end

logMeta.Commit = function( s )

    local currentLogFile = s.logFileDirectory 

    if ( not isstring( currentLogFile ) ) then 

        logError("Failed to commit logs, no log file set.")
        
        return 
    end

    local unstructuredLog = "\n%s\n%s\n"

    if ( not IsValid( s ) ) then return end 
    
    local logHeap, title = s.Heap or {}, s:GetTitle() or "MLogs"

    local structuredLog = string.format( unstructuredLog, os.date( "%d/%m/%Y - %H:%M:%S" ), title )

    if ( #logHeap <= 0 ) then return end 

    for k = 1, #logHeap do 

        local logRow = logHeap[k]
        if ( not isstring( logRow ) ) then continue end 

        structuredLog = ( structuredLog .. ":" .. logRow .. "\n" )
    end 

    local format = string.format( "%s%s%s", currentLogFile, os.date( "_%d-%m-%Y" ), ".txt" )

    file.Append( format, structuredLog )

    table.Empty( logHeap )

end 

logMeta.__index = logMeta 

MonkeyLogs.NewLog = function()
    
    local logTable = {}

    setmetatable( logTable, logMeta )

    logTable:SetLogDirectory( logDir )

    return logTable 
end



