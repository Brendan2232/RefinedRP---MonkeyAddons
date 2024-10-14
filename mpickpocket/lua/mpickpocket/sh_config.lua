MPickPocket = MPickPocket or {}
MPickPocket.Config = MPickPocket.Config or {}

MPickPocket.Messages = {
    ["pickpocket_succ"] = "Successfully pickpocketed %s, you've earned %s!", 
    ["pickpocket_fail"] = "Pickpocketing failed", 
    ["pickpocket_wanted"] = "Pickpocketing.", 
}

MPickPocket.MaxSounds = 7 
MPickPocket.SoundFile = "physics/body/body_medium_impact_soft%s.wav"

MPickPocket.MaxDistance = 90 // Distance between pickpocketer and player. 

MPickPocket.FailedCooldown = 1 // 1 min 
MPickPocket.SuccessCooldown = 3 // 3 min 

MPickPocket.Config["default"] = {

    pickPocketTime = {
        5, // Min 
        8  // Max
    }, 

    pickPocketTax = .25,
    pickPocketCap = 25000, 

}


