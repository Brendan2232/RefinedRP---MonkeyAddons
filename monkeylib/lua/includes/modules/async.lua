AddCSLuaFile()

// This is a replacement for the old system, old system caused issues :(
// I highly don't recommend using this - I've replaced it with timer.Simple due to too many systems using this function 
    
function async( callback, ... )

    local packedArguments = { ... }

    timer.Simple( 0, function()

        callback( unpack( packedArguments ) )

    end )
end 
