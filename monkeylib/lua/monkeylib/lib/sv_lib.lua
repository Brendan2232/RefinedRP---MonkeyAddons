resource.AddWorkshop("3453800550")

resource.AddSingleFile( "resource/fonts/Inter-Black.ttf" )
resource.AddSingleFile( "resource/fonts/Inter-Medium.ttf" )

util.AddNetworkString( "MonkeyLib:SendMessage" )
util.AddNetworkString( "MonkeyLib:SendFancyMessage" )

hook.Protect( "Initialize", "MonkeyLib:Init", function()

    RunConsoleCommand( "sbox_maxtextscreens", 3 ) // Replace this with a command manager. 
    RunConsoleCommand( "sv_allowcslua", 0 )

    RunConsoleCommand( "sitting_can_damage_players_sitting", 1 )

    RunConsoleCommand( "chess_wagers", 0 )

    MonkeyLib.SQL:CreateTables( {
        "CREATE TABLE IF NOT EXISTS mlib_offline_money ( steamID64 VARCHAR( 255 ) PRIMARY KEY, storedMoney INT );", 
        "CREATE TABLE IF NOT EXISTS monkeylib_playtime_limit ( steamID64 VARCHAR( 255 ) PRIMARY KEY, expireTime INT, lastPlayTime INT );"
    } )

    MonkeyLib.SQL:Query( [[
        
        CREATE TABLE IF NOT EXISTS monkeylib_claims ( 

            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            adminSteamID64 VARCHAR( 255 ),

            targetSteamID64 VARCHAR( 255 ), 
            claimTime INT 

        );
    
    ]] )
     
end )






