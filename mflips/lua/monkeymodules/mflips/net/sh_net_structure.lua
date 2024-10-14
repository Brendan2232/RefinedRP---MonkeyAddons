MonkeyFlips.NetStructure = MonkeyFlips.NetStructure or {}

MonkeyFlips.NetStructure.DeleteFlip = MonkeyNet.CreateStructure(

    function ( flipID )

        net.WriteUInt( flipID, 32 )

    end, 
    
    function ()

        return net.ReadUInt( 32 )
    end
)

MonkeyFlips.NetStructure.CreateFlip = MonkeyNet.CreateStructure(

    function ( price )

        if ( not isnumber( price ) ) then return end 

        net.WriteUInt( price, 32 )

    end, 
    
    function ()

        return net.ReadUInt( 32 )
    end
)

MonkeyFlips.NetStructure.JoinFlip = MonkeyNet.CreateStructure(

    function ( id )

        if ( not isnumber( id ) ) then return end 

        net.WriteUInt( id, 32 )

    end, 
    
    function ()

        return net.ReadUInt( 32 )
    end
)

MonkeyFlips.NetStructure.SendCreatedFlip = MonkeyNet.CreateStructure(

    function ( ply, flipID, price )

        net.WriteEntity( ply )
        
        net.WriteUInt( flipID, 32 )

        net.WriteUInt( price, 32 )

    end, 
    
    function ()

        return net.ReadEntity(), net.ReadUInt( 32 ), net.ReadUInt( 32 )
    end
)