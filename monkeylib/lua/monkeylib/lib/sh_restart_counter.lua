// Network stuff

require( "monkeyhooks" )

local restartTime

local restartBytes = 30 

local setRestartTimeNetworkVar = "MonkeyLib:RestartCounter:SendTime"

local destroyRestartTimeNetworVar = "MonkeyLib:RestartCounter:DestroyTime"

local setRestartTime = function( time )

    assert( isnumber( time ), "Restart time isn't a number!" ) 

    restartTime = ( SysTime() + time )  

end

if ( CLIENT ) then 

    local formatTime 

    local restartTimerHookID = "MonkeyLib:RestartTimer:Hud" 

    do // Time format interface 

        local timeStructure = {

            {
                1, 
                "s", 
            },
        
            {
                60, 
                "m", 
            },
        
            {
                3600, 
                "h", 
            },
        
            {
                86400, 
                "d", 
            },
        
        }

        local restartTitle = "Server restarting in %s"

        local restartSoonMessage = "Restarting Soon!"

        local formattedTimeString = "%d%s"
    
        local calculateTime = function( currentTime, timePreset )

            return math.floor( currentTime / timePreset ), ( currentTime % timePreset )
        end
        
        local formattedTime = function( timeString, timeChar, time )
        
            local timeFormat = formattedTimeString:format( time, timeChar )
        
            return ( ( timeString == "" and timeFormat ) or string.format( "%s, %s", timeString, timeFormat ) )
        end 
        
        formatTime = function( time )
        
            local timeString = ""
        
            if ( time <= 1 ) then 
    
                return restartSoonMessage
            end
            
            for k = #timeStructure, 1, -1 do 
        
                local row = timeStructure[k]
        
                if ( not istable( row ) ) then 
        
                    continue 
                end
        
                local timePresent, timeCharacter = unpack( row )
        
                local calculatedFormat, newTime = calculateTime( time, timePresent )
              
                if ( calculatedFormat <= 0 ) then 
        
                    continue 
                end
       
                time = newTime
    
                timeString = formattedTime( timeString, timeCharacter, calculatedFormat )
            
            end
    
            return restartTitle:format( timeString ) 
        end

    end
    
    local drawRestartCounter, destroyRestartCounter

    do 

        // Colors 

        local colorBlack = color_black 

        local primaryTextColor = Color(226, 226, 226)

        // Offsets 

        local gapSize = 4 

        local outlineOffset = 2 

        // Scale shit 

        local scrw, scrh = ScrW(), ScrH()

        local screenCenter = ( scrw / 2 ) 

        local screenBottom = ( scrh - gapSize )

        // Font

        local restartTitleFont = "MonkeyLib_Inter_20"

        destroyRestartCounter = function()

            restartTime = nil 
    
            hook.Remove( "HUDPaint", restartTimerHookID )
    
        end 
    
        drawRestartCounter = function()
    
            if ( not isnumber( restartTime ) )  then 
    
                destroyRestartCounter()
    
                return 
            end
    
            local timeOffset = restartTime - SysTime() 
            
            local formattedTime = formatTime( timeOffset )
    
            do // Draw our text! 

                draw.SimpleText( formattedTime, restartTitleFont, screenCenter, screenBottom, colorBlack, 1, TEXT_ALIGN_BOTTOM )

                draw.SimpleText( formattedTime, restartTitleFont, ( screenCenter - outlineOffset ), ( screenBottom - outlineOffset ), primaryTextColor, 1, TEXT_ALIGN_BOTTOM )

            end
    
        end 
    
        hook.Protect( "OnScreenSizeChanged", "MonkeyLib:RestartCounter:ReScale", function()
        
            scrw, scrh = ScrW(), ScrH()

            screenCenter = ( scrw / 2 ) 

            screenBottom = ( scrh - gapSize )

        end )
    
    end
  
    net.Receive( setRestartTimeNetworkVar, function()

        do // Read and setup the time!  

            local time = net.ReadUInt( restartBytes )

            setRestartTime( time )
    
        end

        hook.Add( "HUDPaint", restartTimerHookID, drawRestartCounter ) // Draw our counter! 
        
    end )

    net.Receive( destroyRestartTimeNetworVar, destroyRestartCounter ) 

    return 
end 

util.AddNetworkString( setRestartTimeNetworkVar )
util.AddNetworkString( destroyRestartTimeNetworVar )

local networkRestartTime = function( ply, time )

    local sendFunc = ( IsValid( ply ) and net.Send or net.Broadcast )

    if ( not isnumber( time ) ) then 

        net.Start( destroyRestartTimeNetworVar )

        sendFunc( ply )
        
        return 
    end 

    net.Start( setRestartTimeNetworkVar )

        net.WriteUInt( time, restartBytes )

    sendFunc( ply )

end 

hook.Add( "MonkeyLib:PlayerNetReady", "MonkeyLib:RestartCounter:Network", function( ply ) 

    if ( not isnumber( restartTime ) ) then 

        return 
    end

    local restartTimeOffset = ( restartTime - SysTime() )  

    if ( restartTimeOffset <= 0 ) then 

        return 
    end

    networkRestartTime( ply, restartTimeOffset )

    do // Debugging 

        local playerName = ply:Name()

        MonkeyLib.Debug( false, "Networking restart counter to %s.", playerName )

    end

end )

do // Command interface 

    concommand.Add( "mlib_restart_set_time", function( ply, _, args )

        if ( IsValid( ply ) ) then 
    
            return 
        end
        
        local time = args[1]

        time = tonumber( time )
    
        do // Set and network the updated time! 

            setRestartTime( time ) // This function throws an error if the time isn't a number!
    
            networkRestartTime( nil, time )

        end

        MonkeyLib.Debug( true, "Restart counter set and networked!" )

    end )
    

    concommand.Add( "mlib_restart_gmc_hack", function( ply, _, args )

        if ( IsValid( ply ) ) then 
    
            return 
        end
        
        local time = 3600 

        do // Set and network the updated time! 

            setRestartTime( time ) // This function throws an error if the time isn't a number!
    
            networkRestartTime( nil, time )

        end

        MonkeyLib.Debug( true, "Restart counter set and networked!" )

    end )
    

    concommand.Add( "mlib_restart_stop", function( ply )
    
        if ( IsValid( ply ) ) then 
    
            return 
        end
    
        restartTime = nil // Set our time as nil! 
        
        networkRestartTime( )

        MonkeyLib.Debug( true, "Restart counter has been stopped!" )
    
    end )

end
