AmmoVendor = AmmoVendor or {}

AmmoVendor.AmmoTypes = AmmoVendor.AmmoTypes or {}

local registerAmmoType = function( ammoType, data )

    if ( not istable( data ) ) then return end 

    data.ammoType = ammoType

    local index = #AmmoVendor.AmmoTypes + 1 

    AmmoVendor.AmmoTypes[index] = data 

    DarkRP.createAmmoType( ammoType, data )

end

registerAmmoType( "pistol", {
    name = "Pistol Ammo",
    model = "models/Items/BoxMRounds.mdl",
    price = 300,
    amountGiven = 30
} )

registerAmmoType( "buckshot", {
    name = "Shotgun Ammo",
    model = "models/Items/BoxMRounds.mdl",
    price = 300,
    amountGiven = 30
} )

registerAmmoType( "smg1", {
    name = "SMGs Ammo",
    model = "models/Items/BoxMRounds.mdl",
    price = 400,
    amountGiven = 60
} )

registerAmmoType( "ar2", {
    name = "Assault Ammo",
    model = "models/Items/BoxMRounds.mdl",
    price = 350,
    amountGiven = 30
} )

registerAmmoType( "SniperPenetratedRound", {
    name = "Sniper Ammo",
    model = "models/Items/BoxMRounds.mdl",
    price = 500,
    amountGiven = 30
} )

registerAmmoType( "357", {
    name = "357 Ammo",
    model = "models/Items/BoxMRounds.mdl",
    price = 310,
    amountGiven = 30
} )

