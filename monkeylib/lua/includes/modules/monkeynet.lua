AddCSLuaFile()

MonkeyNet = MonkeyNet or {}

MonkeyNet.CreateStructure = function( writerFunc, readerFunc )

    do // Error handling

        assert( isfunction( writerFunc ), "Writer Func isn't a function!" )

        assert( isfunction( readerFunc ), "Reader Func isn't a function!" )

    end
 
    return { writerFunc, readerFunc } 
end

MonkeyNet.UtilStructure = function( utilName, writerFunc, readerFunc ) 

    assert( isstring( utilName ), "Util Name isn't a string!" )

    local structure = MonkeyNet.CreateStructure( writerFunc, readerFunc )

    if ( CLIENT ) then 

        return structure
    end

    util.AddNetworkString( utilName )
    
    return structure
end 

MonkeyNet.CallWriterFunction = function( netStructure, arguments )

    assert( istable( netStructure ), "Net structure isn't a table!" )

    local writerFunc = netStructure[1]

    assert( isfunction( writerFunc ), "Writer Func isn't a function!" )

    writerFunc( unpack( arguments or {} ) )

end

MonkeyNet.CallReaderFunction = function( netStructure )

    assert( istable( netStructure ), "Net structure isn't a table!" )
    
    local readerFunc = netStructure[2]

    assert( isfunction( readerFunc ), "Reader Func isn't a function!" )
        
    return readerFunc()
end

MonkeyNet.WriteStructure = function( netMessage, netStructure, arguments, ply )
    
    do // Error handling

        assert( isstring( netMessage ), "Net message isn't a string!")

        assert( istable( netStructure ), "Net structure isn't a table!")

    end

    local writerFunction = netStructure[1]

    assert( isfunction( writerFunction ), "Writer function isn't a function!")

    local sendFunc = ( CLIENT and net.SendToServer or ( ( ( IsValid( ply ) or istable( ply ) ) and net.Send ) or net.Broadcast ) )

    net.Start( netMessage ) 

        writerFunction( unpack( arguments ) )   

    sendFunc( ply )
end

MonkeyNet.ReadStructure = function( netMessage, netStructure, callback )

    do // Error handling

        assert( isstring( netMessage ), "Net message isn't a string!" )

        assert( istable( netStructure ), "Net structure isn't a table!" )
    
        assert( isfunction( callback ), "Net callback isn't a function!" )

    end 

    local readerFunc = netStructure[2]

    assert( isfunction( readerFunc ), "Reader function isn't a function!" )

    local netCallback = net.Receive

    netCallback( netMessage, function( len, ply )

        local readerArguments = { readerFunc() } or {}

        if ( CLIENT ) then 
            
            callback( unpack( readerArguments ) ) 

            return 
        end 

        callback( len, ply, unpack( readerArguments ) )

    end )
end
