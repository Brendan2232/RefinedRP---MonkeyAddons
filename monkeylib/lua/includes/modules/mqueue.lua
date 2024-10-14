AddCSLuaFile()

local pcall = pcall 
local isfunction = isfunction 

local ErrorNoHaltWithStack = ErrorNoHaltWithStack

local async = async

local getmetatable = getmetatable 
local setmetatable = setmetatable

MQueue = MQueue or {}

local queueMeta = {}

queueMeta.Insert = function( s, key, callback )

    if ( not key or not isfunction( callback ) ) then 

        ErrorNoHaltWithStack( "Failed to insert new queue stack, malformed arguments." )

        return  
    end
    
    s.Queue[key] = s.Queue[key] or {} 

    local queueTable = s.Queue[key]

    local index = #queueTable + 1 
    queueTable[index] = callback 

    return index 
end

queueMeta.KeyExists = function( key )
    
    return s.Queue[key]
end

queueMeta.ResolveQueue = function( s, key, ... )

    local arguments = {...} // Stinky language 

    if ( not key ) then

        ErrorNoHaltWithStack( "Failed to resolve queue stack, malformed arguments." )

        return  
    end

    local foundQueueStack = s.Queue[key]

    if ( istable( foundQueueStack ) and #foundQueueStack >= 1 ) then

        for k = 1, #foundQueueStack do 

            local queueCallback = foundQueueStack[k]

            if ( not isfunction( queueCallback ) ) then 

                ErrorNoHaltWithStack( "Failed to resolve queue index ", k, ", malformed callback." )

                continue  
            end

            local succ, err = pcall( queueCallback, unpack( arguments ) )

            if ( not succ and err ) then 

                ErrorNoHaltWithStack( err )

            end

        end
        
        s.Queue[key] = nil 

    end
end

queueMeta.__index = queueMeta 

MQueue.isQueue = function( s )

    return getmetatable( s ) == queueMeta
end

MQueue.CreateQueue = function()

    local newQueue = {}
    newQueue.Queue = newQueue.Queue or {}
    
    setmetatable( newQueue, queueMeta )

    return newQueue 
end


