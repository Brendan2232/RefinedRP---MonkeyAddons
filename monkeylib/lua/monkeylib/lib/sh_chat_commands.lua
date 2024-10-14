MonkeyLib.Commands = MonkeyLib.Commands or {}

MonkeyLib.CommandExists = function( command )

    return MonkeyLib.Commands[command] or false 
end

MonkeyLib.RegisterChatCommand = function( command, callback )

    if ( not command or not isfunction( callback ) ) then return end 

    local protectCallback = ProtectFunction( callback )
    
    if ( istable( command ) ) then 
        
        for k = 1, #command do 

            local cmd = command[k]
            if ( not isstring( cmd ) ) then continue end 

            MonkeyLib.RegisterChatCommand( cmd, protectCallback )
        end 
        
        return 
    end

    MonkeyLib.Commands[command] = callback
end

local delegadeCommand = function( ply, text )

    if ( not IsValid( ply ) or not isstring( text ) ) then return end 
        
    local commandStarter = string.sub( text, 1, 1 )

    if ( commandStarter ~= "!" and commandStarter ~= "/" ) then 

        return 
    end 

    text = string.lower( text )

    text = string.sub( text, 2, #text )

    local foundCommand = MonkeyLib.CommandExists( text )

    if ( foundCommand and isfunction( foundCommand ) ) then 

        foundCommand( ply, text )

        return true 
    end

end

if ( CLIENT ) then

    hook.Add( "OnPlayerChat", "MonkeyLib:ChatCommands:RunChatCommand", function(ply, text) 

        if ( ply ~= LocalPlayer() ) then return end 

        local response = delegadeCommand( ply, text )

        return response == true and true or nil 
         
    end )
    
    return 
end

hook.Add( "PlayerSay", "MonkeyLib:ChatCommands:RunChatCommand", function(ply, text, isTeam)

    if ( not IsValid( ply ) or not isstring( text ) ) then return end 

    if ( isTeam ) then return end 
    
    local response = delegadeCommand( ply, text )

    return response == true and "" or nil 
end )

