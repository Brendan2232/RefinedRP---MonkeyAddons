MBail = MBail or {}
MBail.ArrestCache = {}  
MBail.Config = {}

MBail.Config.DefaultBailPrice = 50000
MBail.Config.MinBailPrice = 10000
MBail.Config.MaxBailPrice = 250000

MBail.Config.RequiresNPCInteraction = true // if the player needs to interact with the bail NPC to bail someone out. 
MBail.Config.MaxNPCRange = 80 
MBail.Config.NPCModel = "models/Barney.mdl"

MBail.Config.Messages = {

    ["bail_gui_set_bail"] = "Set %s's bail", 

    ["bail_gui_invalid_price"] = "Invalid price ( Minimum bail price %s, Maximum bail price %s)", 

    ["bail_gui_submit_bail"] = "Submit bail",  

    ["player_arrested"] = "You can't bail people out whilst being arrested", 

    ["bail_pay_succ"] = "Successfully bailed player.", 

    ["bail_pay_fail"] = "Failed to bail out player.",

    ["bail_set_succ"] = "Successfully set bail!", 

    ["bail_set_fail"] = "Failed to set bail", 

    ["cant_afford"] = "You can't afford to pay this bail.", 

}

