local logs = {
    ["started_pick_pocket"] = "{1} Started Pick Pocketing {2}", 
    ["pick_pocket_succ"] = "{1} Successfully Pick Pocketed {2}", 
    ["pick_pocket_fail"] = "{1} Failed to Pick Pocket {2}", 
}

local MODULE = GAS.Logging:MODULE()

MODULE.Category = "DarkRP"
MODULE.Name = "PickPocket"
MODULE.Colour = Color(255,0,0)

MODULE:Setup( function()

    MODULE:Hook( "MonkeyPickPocket:PickPocketStart", "MonkeyLib:GASLogging:PickPocketLogs", function( _, ply, target )

        MODULE:Log( logs["started_pick_pocket"], GAS.Logging:FormatPlayer( ply ), GAS.Logging:FormatPlayer( target ) )

    end )

    MODULE:Hook( "MonkeyPickPocket:PickPocketSuccess", "MonkeyLib:GASLogging:PickPocketLogs", function( _, ply, target )

        MODULE:Log( logs["pick_pocket_succ"], GAS.Logging:FormatPlayer( ply ), GAS.Logging:FormatPlayer( target ) )

    end )

    MODULE:Hook( "MonkeyPickPocket:PickPocketFail", "MonkeyLib:GASLogging:PickPocketLogs", function( _, ply, target )

        MODULE:Log( logs["pick_pocket_fail"], GAS.Logging:FormatPlayer( ply ), GAS.Logging:FormatPlayer( target ) )

    end )

end )

GAS.Logging:AddModule( MODULE )

