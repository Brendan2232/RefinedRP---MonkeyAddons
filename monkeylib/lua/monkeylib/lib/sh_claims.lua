require( "memoize" )

if ( CLIENT ) then // For some minor commands.  

    local message = "\n%s | %s | %d Claims"

    local isPrinting = false 

    local raceConditionStack = {}

    local formattedPrint = function(...)

        print( message:format( ... ) )

    end

    local printBuffer = function()

        if ( isPrinting ) then 
            
            return 
        end 

        timer.Remove( "MonkeyLib:Claims:PrintBuffer" )

        isPrinting = true 

        for k = 1, #raceConditionStack do 

            local row = raceConditionStack[k]

            if ( not istable( row ) ) then 
                
                continue 
            end 

            local adminName, adminSteamID64, claimAmount = row.adminName, row.adminSteamID64, row.claimAmount 
            
            do 
         
                MonkeyLib.ChatMessage( message, {adminName, adminSteamID64, claimAmount} )

            end
            
        end 

        raceConditionStack = {}

        isPrinting = false 

    end

    net.Receive( "MonkeyLib:Claims:Get", function() // What a PAIN!!!
    
        timer.Remove( "MonkeyLib:Claims:PrintBuffer" )
                
        // What a fucking annoying race condition........

        // Welcome to Async coding!!!

        raceConditionStack = {} 

        local readBufferAmount = net.ReadUInt( 30 )

        for k = 1, readBufferAmount do 

            local adminSteamID64, claimAmount = MonkeyLib.ReadSteamID64(), net.ReadUInt( 32 )
            
            MonkeyLib.GetName( adminSteamID64, function( name )

                if ( isPrinting ) then return end // Too late! 
                
                raceConditionStack[k] = {

                    ["adminSteamID64"] = adminSteamID64, 

                    ["claimAmount"] = claimAmount,

                    ["adminName"] = name, 

                }   

                if ( #raceConditionStack < readBufferAmount ) then return end // Too early! 

                printBuffer()
                
            end )
        end

        timer.Create( "MonkeyLib:Claims:PrintBuffer", 5, 1, printBuffer ) // Just in-case a name wasn't fetched! 

    end )

    return 
end

do 

    util.AddNetworkString( "MonkeyLib:Claims:Get" )

    local whitelisteduserGroups = {
        
        ["superadmin"] = true, 
        
        ["Senior-Admin"] = true,

        ["Head-Admin"] = true, 
        
        ["Community-Manager"] = true,

    }

    local hasPerms = function( ply )

        if ( not IsValid( ply ) ) then 

            return false 
        end

        if ( ply:IsSuperAdmin() ) then 

            return true 
        end

        local rank = ply:GetUserGroup()

        return whitelisteduserGroups[rank]
    end

    local networkHighestClaims = function( ply )

        if ( not IsValid( ply ) ) then return end 

        local shouldNetworkClaims = hasPerms( ply )

        if ( not shouldNetworkClaims ) then 
            
            return 
        end 

        local foundClaims = MonkeyLib.GetHighestClaims()

        if ( not istable( foundClaims ) ) then 
            
            return 
        end 

        local foundClaimLen = #foundClaims 

        if ( foundClaimLen <= 0 ) then 
            
            return 
        end 

        net.Start( "MonkeyLib:Claims:Get" ) 

            net.WriteUInt( foundClaimLen, 30 )

            for k = 1, foundClaimLen do 

                local row = foundClaims[k]
                if ( not istable( row ) ) then continue end 

                local adminSteamID64, claimAmount = row.adminSteamID64, row.claimCount 
                if ( not MonkeyLib.isSteamID64( adminSteamID64 ) or not claimAmount ) then continue end

                claimAmount = tonumber( claimAmount )

                if ( claimAmount <= 0 ) then continue end

                MonkeyLib.WriteSteamID64( adminSteamID64 )
                net.WriteUInt( claimAmount, 32 )

            end

        net.Send( ply )

    end

    MonkeyLib.RegisterChatCommand( { "weeklyclaims" }, function( ply )
    
        if ( not IsValid( ply ) ) then 

            return 
        end

        networkHighestClaims( ply )

    end )

end
 
MonkeyLib.GetHighestClaims = memoize( function( limit )

    // Issues with the MonkeyLib.SQL system make this query invalid. strftime('%s') causes issues with string.format :( 

    local query = [[

		SELECT adminSteamID64, COUNT(adminSteamID64) AS claimCount

		FROM monkeylib_claims

		WHERE claimTime >= strftime('%s', DATETIME('now', '-7 days'))

		GROUP BY adminSteamID64

		ORDER BY claimCount DESC

    ]]

    if ( isnumber( limit ) ) then 

        local limitFormat = "%s LIMIT %s"

        query = limitFormat:format( query, limit )

    end

    local allClaims = sql.Query( query )	

    if ( allClaims == false ) then 

        error( allClaims )

    end

    return allClaims or {}

end, {}, 30 )

MonkeyLib.GetAdminClaimCount = memoize( function( adminSteamID64 )

    if ( not MonkeyLib.isSteamID64( adminSteamID64 ) ) then 
        
        return 
    end 

    local foundClaims = MonkeyLib.SQL:QueryValue( "SELECT COUNT( adminSteamID64 ) as claimCount FROM monkeylib_claims WHERE adminSteamID64 = %s;", {
        adminSteamID64,
    } )
    
    return foundClaims
    
end, {}, 30 ) 

MonkeyLib.GetAdminClaims = memoize( function( adminSteamID64 )

    if ( not MonkeyLib.isSteamID64( adminSteamID64 ) ) then 
        
        return 
    end 

    local foundClaims = MonkeyLib.SQL:Query( "SELECT id, adminSteamID64, targetSteamID64, claimTime FROM monkeylib_claims WHERE adminSteamID64 = %s;", {
        adminSteamID64,
    } )

    return foundClaims 

end, {}, 30 )

MonkeyLib.InsertClaim = ProtectFunction( function( adminSteamID64, targetSteamID64 )
    
    if ( not MonkeyLib.isSteamID64( adminSteamID64 ) or not MonkeyLib.isSteamID64( targetSteamID64 ) ) then 
        
        return 
    end 

    if ( adminSteamID64 == targetSteamID64 ) then
        
        return 
    end 

    local currentTime = os.time()

    MonkeyLib.SQL:Query( "INSERT INTO monkeylib_claims ( adminSteamID64, targetSteamID64, claimTime ) VALUES( %s, %s, %s );", {

        adminSteamID64, 

        targetSteamID64, 

        currentTime,

    } )

end )

hook.Protect( "Sam:AdminClaimedTicket", "MonkeyLib:Claims:AppendClaims", function( admin, reporter )
 
    if ( not IsValid( admin ) or not IsValid( reporter ) ) then 

        return 
    end

    local adminSteamID64, reporterSteamID64 = admin:SteamID64(), reporter:SteamID64()

    MonkeyLib.InsertClaim( adminSteamID64, reporterSteamID64 )
    
end )


