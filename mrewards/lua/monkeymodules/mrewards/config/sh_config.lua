MRewards = MRewards or {}
MRewards.SharedRewards = MRewards.SharedRewards or {}

MRewards.rewardAmount = 3 
MRewards.rewardCooldown = 1 // 1 Day 

MRewards.Icons = { 
    --[[
    { // Icon Structure
        ["iconID"] = "m_discord", 
        ["iconLink"] = "https://i.imgur.com/kO1l3j9.png", 
        ["iconParamaters"] = "noclamp smooth", 
    }, 
    ]]
}

MRewards.Rewards = {
    {
        ["Name"] = "Nothing, Loser!",
        ["Type"] = "darkrp_money",
        ["Value"] = 0,  
        ["Model"] = "models/props/cs_assault/Dollar.mdl", 
        ["Amount"] = 120,  
    },
    {
        ["Name"] = "Crossbow",
        ["Type"] = "weapons",
        ["Value"] = "weapon_crossbow",  
        ["Model"] = "models/weapons/w_crossbow.mdl", 
        ["Amount"] = 50,  
    },
    {
        ["Name"] = "$50000",
        ["Type"] = "darkrp_money",
        ["Value"] = 50000,  
        ["Model"] = "models/props/cs_assault/Dollar.mdl", 
        ["Amount"] = 65,  
    },
    {
        ["Name"] = "$100000",
        ["Type"] = "darkrp_money",
        ["Value"] = 100000,  
        ["Model"] = "models/props/cs_assault/Dollar.mdl", 
        ["Amount"] = 55,  
    },
    {
        ["Name"] = "Machete",
        ["Type"] = "weapons",
        ["Value"] = "m9k_machete",  
        ["Model"] = "models/weapons/w_machete.mdl", 
        ["Amount"] = 40,  
    },
    {
        ["Name"] = "Minigun",
        ["Type"] = "weapons",
        ["Value"] = "m9k_minigun",  
        ["Model"] = "models/weapons/w_m134_minigun.mdl", 
        ["Amount"] = 20,  
    },
    {
        ["Name"] = "$500000",
        ["Type"] = "darkrp_money",
        ["Value"] = 500000,  
        ["Model"] = "models/props/cs_assault/Dollar.mdl", 
        ["Amount"] = 5,  
    },
    {
        ["Name"] = "Nitro Glycerine",
        ["Type"] = "weapons",
        ["Value"] = "m9k_nitro",  
        ["Model"] = "models/weapons/w_nitro.mdl", 
        ["Amount"] = 5,  
    },
    {
        ["Name"] = "Common Knife Crate",
        ["Type"] = "monkey_unbox_crates",
        ["Value"] = "m_crate_common",  
        ["Icon"] = "m_unbox_crate_2", 
        ["Amount"] = 50,  
    },
    {
        ["Name"] = "Rare Knife Crate",
        ["Type"] = "monkey_unbox_crates",
        ["Value"] = "m_crate_rare",  
        ["Icon"] = "m_unbox_crate_2", 
        ["Amount"] = 50,  
    },
    {
        ["Name"] = "Epic Knife Crate",
        ["Type"] = "monkey_unbox_crates",
        ["Value"] = "m_crate_epic",  
        ["Icon"] = "m_unbox_crate_2", 
        ["Amount"] = 20,  
    },
    {
        ["Name"] = "Legendary Knife Crate",
        ["Type"] = "monkey_unbox_crates",
        ["Value"] = "m_crate_legendary",  
        ["Icon"] = "m_unbox_crate_2", 
        ["Amount"] = 10,  
    },
    {
        ["Name"] = "Low Tier Weapons Crate",
        ["Type"] = "monkey_unbox_crates",
        ["Value"] = "m_crate_temp_low",  
        ["Icon"] = "m_unbox_crate_2", 
        ["Amount"] = 100,  
    },
    {
        ["Name"] = "High Tier Weapons Crate",
        ["Type"] = "monkey_unbox_crates",
        ["Value"] = "m_crate_temp_rare",  
        ["Icon"] = "m_unbox_crate_2", 
        ["Amount"] = 40,  
    },
    {
        ["Name"] = "Cat Gun",
        ["Type"] = "weapons",
        ["Value"] = "weapon_catgun",  
        ["Model"] = "models/weapons/w_catgun.mdl", 
        ["Amount"] = 35,  
    },
    {
        ["Name"] = "Damascus Sword",
        ["Type"] = "weapons",
        ["Value"] = "m9k_damascus",  
        ["Model"] = "models/weapons/w_damascus_sword.mdl", 
        ["Amount"] = 55,  
    },
}

