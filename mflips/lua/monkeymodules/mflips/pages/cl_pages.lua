local elementRoundedAmount = 4

local gapSize = 8 

local flipPage = false 

local minCoinflipSize, maxCoinflipSize = 325, 425

local createCoinflipPage = function()

    if ( IsValid( flipPage ) ) then return end 

    local scrw, scrh = ScrW(), ScrH()
    scrw, scrh = math.max( scrw * .20, minCoinflipSize ), math.max( scrh * .45, maxCoinflipSize )

    local frame = MonkeyLib:CreateDefaultFrame( scrw, scrh )

    flipPage = frame 

    local coinflipElements = frame:Add("MonkeyFlips:CoinflipPanel")
    coinflipElements:DockMargin( 0, gapSize, 0, 0 )

    coinflipElements.roundedAmount = elementRoundedAmount

    local scrollBar = coinflipElements.scrollBar 
    if ( not IsValid( scrollBar ) ) then return end 

    scrollBar.roundedAmount = elementRoundedAmount

end

MonkeyLib.RegisterChatCommand( {"coinflip", "coinflips", "flip", "flips" }, createCoinflipPage )
