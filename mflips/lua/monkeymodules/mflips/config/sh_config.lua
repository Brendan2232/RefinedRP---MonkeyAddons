MonkeyFlips = MonkeyFlips or {}

MonkeyFlips.MinimumFlipPrice = 100000 
MonkeyFlips.MaximumFlipPrice = 1000000000

MonkeyFlips.ActionCooldown = 3

MonkeyFlips.TaxRate = .95

MonkeyFlips.Icons = {
    {
        ["iconID"] = "m_coinflip_play", 
        ["iconLink"] = "https://i.imgur.com/tNriKxY.png", 
        ["iconParamaters"] = "noclamp smooth", 
    }, 
    {
        ["iconID"] = "m_coinflip_delete", 
        ["iconLink"] = "https://i.imgur.com/1RJzGjT.png", 
        ["iconParamaters"] = "noclamp smooth", 
    }, 
}

MonkeyFlips.Messages = {

    ["cant_afford"] = "You can't afford to %s this flip.", 

    ["invalid_price"] = "Invalid Price ( Minimum %s, Maximum %s )",

    ["flip_create_fail"] = "Failed to create flip", 
    ["flip_remove_fail"] = "Failed to remove flip", 
    ["flip_remove_succ"] = "Successfully deleted coinflip!", 
    
    ["flip_create_succ"] = "Successfully created coinflip!", 
    ["flip_join_fail"] = "Failed to join flip", 

    ["flip_create_global_succ"] = "{colorRed} RefinedRP {colorWhite} | {colorGreen} %s {colorWhite} Created a flip worth {colorGreen} %s.", 

    ["cooldown"] = "Cooldown, calm down!",

    ["flip_won"] = "{colorRed} RefinedRP {colorWhite} | {colorGreen} %s {colorWhite} Won against {colorRed} %s. {colorWhite} Winning {colorGreen} %s!",
    
}

MonkeyFlips.Logs = {
    
    ["flip_created"] = "%s | %s Created a flip worth %s", 
    ["flip_deleted"] = "%s | %s Deleted a flip worth %s", 
    
    ["flip_win"] = "%s | %s Won a flip worth %s", 
    ["flip_lost"] = "%s | %s Lost a flip worth %s", 

}
