MonkeyHud = MonkeyHud or {}

MonkeyHud.Config = MonkeyHud.Config or {}

MonkeyHud.Config.RespawnTime = 5

// This system isn't very dynamic, only the attack message supports new lines, and it only supports one new line. 

MonkeyHud.Config.SuicideMessage = "You suicided." 

MonkeyHud.Config.DeathMessage = "You died!"

MonkeyHud.Config.AttackMessage = "You were killed by %s\nusing an %s"

MonkeyHud.Config.DisabledHuds = {
    ["DarkRP_LocalPlayerHUD"] = true,

    ["DarkRP_Hungermod"] = true,

    ["DarkRP_Agenda"] = true,

    ["DarkRP_LockdownHUD"] = true,

    ["DarkRP_ArrestedHUD"] = false,

    ["CHudDamageIndicator"] = true, 
    
    ["CHudAmmo"] = true, 

    ["CHudSecondaryAmmo"] = true, 
}




MonkeyHud.Config.Icons = {

    {
        ["iconID"] = "MonkeyHud_Circle", 
        ["iconLink"] = "https://i.imgur.com/OxHOPCW.png",
        ["iconParamaters"] = "noclamp smooth", 
    }, 

    
    {
        ["iconID"] = "MonkeyHud_WantedIcon", 
        ["iconLink"] = "https://i.imgur.com/RJ0eJ26.png",
        ["iconParamaters"] = "noclamp smooth", 
    }, 

    {
        ["iconID"] = "MonkeyHud_HeartIcon", 
        ["iconLink"] = "https://i.imgur.com/iqrYR2t.png",
        ["iconParamaters"] = "noclamp smooth", 
    }, 
    
    {
        ["iconID"] = "MonkeyHud_PropIcon", 
        ["iconLink"] = "https://i.imgur.com/YIlvvCG.png",
        ["iconParamaters"] = "noclamp smooth", 
    }, 

    {
        ["iconID"] = "MonkeyHud_ArmorIcon", 
        ["iconLink"] = "https://i.imgur.com/MHbLTAE.png", 
        ["iconParamaters"] = "noclamp smooth", 
    }, 
    {
        ["iconID"] = "MonkeyHud_PlayerIcon", 
        ["iconLink"] = "https://i.imgur.com/Ocp0Xvg.png", 
        ["iconParamaters"] = "noclamp smooth", 
    }, 

    {
        ["iconID"] = "MonkeyHud_WalletIcon", 
        ["iconLink"] = "https://i.imgur.com/84jBVjV.png", 
        ["iconParamaters"] = "noclamp smooth", 
    }, 

    {
        ["iconID"] = "MonkeyHud_DollarIcon", 
        ["iconLink"] = "https://i.imgur.com/Fg6C0wb.png", 
        ["iconParamaters"] = "noclamp smooth", 
    }, 
    
    {
        ["iconID"] = "MonkeyHud_Licence", 
        ["iconLink"] = "https://i.imgur.com/GtF6ito.png", 
        ["iconParamaters"] = "noclamp smooth", 
    }, 
}

