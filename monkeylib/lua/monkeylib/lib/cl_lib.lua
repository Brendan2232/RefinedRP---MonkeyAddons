net.Receive( "MonkeyLib:SendMessage", function()

    local message = net.ReadString()

    MonkeyLib.ChatMessage( message )
    
end )

net.Receive( "MonkeyLib:SendFancyMessage", function()
    
    local message, isError = net.ReadString(), net.ReadBool()

    MonkeyLib.CreateMessage( message, isError )
end )
