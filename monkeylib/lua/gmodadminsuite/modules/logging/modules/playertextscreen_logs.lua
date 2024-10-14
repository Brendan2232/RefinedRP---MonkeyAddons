local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Sandbox"
MODULE.Name = "3D 2D Textscreens"
MODULE.Colour = Color(25,187,46)

local logText = {

    ["textscreen_placed"] = "{1} Placed down a textscreen with the text {2}",

    ["textscreen_modified"] = "{1} Modified a textscreens text, new text {2}", 

}

local L = function( message )

    return logText[message] or message 
end

MODULE:Setup( function()

    MODULE:Hook( "PlayerSpawnedTextscreen", "MonkeyLib:GASLogging:TextScreenCreated", function( target, textScreenText )

        MODULE:Log( L"textscreen_placed", GAS.Logging:FormatPlayer( target ), GAS.Logging:Highlight( textScreenText ) )

    end )

    --[[
    MODULE:Hook( "PlayerModifiedTextscreen", "MonkeyLib:GASLogging:TextScreenModified", function( target, textScreenText )

        MODULE:Log( L"textscreen_modified", GAS.Logging:FormatPlayer( target ), GAS.Logging:Highlight( textScreenText ) )

    end )

    ]]
end )

GAS.Logging:AddModule( MODULE )

