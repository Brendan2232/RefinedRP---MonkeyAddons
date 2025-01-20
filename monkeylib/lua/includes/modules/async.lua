AddCSLuaFile()

// Please don't use this function, it's deprecated. This function replaces an old async / await hack that I made with couroutines 
// I've replaced it with a 'timer.Simple' callback as I was too lazy to remove all traces of this function ( could've just used a callback... )

function async( callback, ... )

    local packedArguments = { ... }

    timer.Simple( 0, function()

        callback( unpack( packedArguments ) )

    end )
end 
