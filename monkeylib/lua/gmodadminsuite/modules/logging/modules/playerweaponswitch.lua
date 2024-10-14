local MODULE = GAS.Logging:MODULE()

MODULE.Category = "DarkRP"
MODULE.Name = "Weapon Switch"
MODULE.Colour = Color(255,0,0)

local logText = "{1} Switched from {2} To {3}"

MODULE:Setup( function()

    MODULE:Hook( "PlayerSwitchWeapon", "MonkeyLib:GASLogging:WeaponSwitchLogs", function( target, oldWeapon, newWeapon )

        MODULE:Log( logText, GAS.Logging:FormatPlayer( target ), GAS.Logging:FormatEntity( oldWeapon ), GAS.Logging:FormatEntity( newWeapon ) )

    end )

end )

GAS.Logging:AddModule( MODULE )

