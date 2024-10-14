MonkeyPOI = MonkeyPOI or {}

MonkeyPOI.MaxRenderDistance = 750

MonkeyPOI.Icons = {

    {
        ["iconID"] = "m_poi_trash_bag",
        ["iconLink"] = "https://i.imgur.com/8xYoNj1.png", 
        ["iconParamaters"] = "noclamp smooth", 
    },

    {
        ["iconID"] = "m_poi_oil_drum",
        ["iconLink"] = "https://i.imgur.com/R5A24lv.png", 
        ["iconParamaters"] = "noclamp smooth", 
    },
    {
        ["iconID"] = "m_poi_oil_refiner",
        ["iconLink"] = "https://i.imgur.com/o6qiB27.png", 
        ["iconParamaters"] = "noclamp smooth", 
    }, 
    {
        ["iconID"] = "m_poi_grape",
        ["iconLink"] = "https://i.imgur.com/NuhqCfn.png", 
        ["iconParamaters"] = "noclamp smooth", 
    }, 
    {
        ["iconID"] = "m_poi_pharmacy_bottle",
        ["iconLink"] = "https://i.imgur.com/lWmiwhy.png", 
        ["iconParamaters"] = "noclamp smooth", 
    }, 
    {
        ["iconID"] = "m_poi_meth_bag",
        ["iconLink"] = "https://i.imgur.com/fINnsCx.png", 
        ["iconParamaters"] = "noclamp smooth", 
    },
    {
        ["iconID"] = "m_poi_cocaine_line",
        ["iconLink"] = "https://i.imgur.com/x1wZPVa.png", 
        ["iconParamaters"] = "noclamp smooth", 
    },
    {
        ["iconID"] = "m_poi_weed_leaf",
        ["iconLink"] = "https://i.imgur.com/qYInJc1.png", 
        ["iconParamaters"] = "noclamp smooth", 
    },
    {
        ["iconID"] = "m_poi_gem_rocks",
        ["iconLink"] = "https://i.imgur.com/fXs6UND.png", 
        ["iconParamaters"] = "noclamp smooth", 
    }
}


local colorWhite = Color(235, 235, 235)

MonkeyPOI.POI = {

    ["Council Worker"] = {

        {

            Name = "Trashman Seller", 
            NameColor = colorWhite,

            Icon = "m_poi_trash_bag", 
            IconColor =  Color(32,32,32), 

            PrioritizeClosest = true, 

            Positions = {

                Vector(-1913, -5396, -196),

                Vector(2675, -2716, -204),

                Vector(-2266, -664, -204),

            },    
        }, 

    }, 

    ["Fuel Refiner"] = {

        {
                   
            Name = "Oil Seller", 
            NameColor = colorWhite,

            Icon = "m_poi_oil_drum", 
            IconColor =  Color(211,190,255), 

            PrioritizeClosest = true, 

            Positions = {

                Vector(6639, -8649, -67),
                Vector(-1390, -7675, -127),
                
            }, 
    
        }, 

        {
            Name = "Oil Spots", 
            NameColor = colorWhite,

            Icon = "m_poi_oil_refiner", 
            IconColor =  Color(211,190,255), 

            PrioritizeClosest = false, 

            Positions = {

                Vector(3996, -2049, -132),
         

            }, 
        }
    }, 

    ["Wine Maker"] = {

        {
                   
            Name = "Grape Farm", 
            NameColor = colorWhite,

            Icon = "m_poi_grape", 
            IconColor =  Color(110,68,201), 

            PrioritizeClosest = false, 

            Positions = {

                Vector(5704, -9131, -7),

            }, 
    
        },    

    },

    ["Pharmacist"] = {

        {
                    
            Name = "Pharmacist", 
            NameColor = colorWhite,

            Icon = "m_poi_pharmacy_bottle", 
            IconColor =  Color(171,147,221), 

            PrioritizeClosest = true, 

            Positions = {

                Vector(-893, -6807, -141),
                Vector(-2472, 1148, -134),
                Vector(19, 1971, -116),

            }, 
        },    

    },

    ["Meth Cook"] = {

        {
                    
            Name = "Meth Dealer", 
            NameColor = colorWhite,

            Icon = "m_poi_meth_bag", 
            IconColor =  Color(211,190,255), 

            PrioritizeClosest = true, 

            Positions = {

                Vector(-2924, -4362, -119),
                Vector(-1011, 2018, -118),
                Vector(1278, 6424, -104),

            }, 
    
        },    

    },

    ["Cocaine Manufacturer"] = {

        {
                    
            Name = "Cocaine Dealer", 
            NameColor = colorWhite,

            Icon = "m_poi_cocaine_line", 
            IconColor =  Color(91,136,187), 

            PrioritizeClosest = true, 

            Positions = {

                Vector(3387, 6467, -111),
                Vector(2760, -4319, -129),
                Vector(-5615, 3786, -130),

            }, 
    
        },    

    },

    ["Weed Grower"] = {

        {
                    
            Name = "Weed Dealer", 
            NameColor = colorWhite,

            Icon = "m_poi_weed_leaf", 
            IconColor =  Color(90,170,99), 

            PrioritizeClosest = true, 

            Positions = {

                Vector(4601, 4193, -118),
                Vector(927, -6626, -136),
                Vector(2142, -1912, -148),

            }, 
    
        },   

    },

    ["Miner"] = {

        {
                    
            Name = "Mining Spot", 
            NameColor = colorWhite,

            Icon = "m_poi_gem_rocks", 
            IconColor =  Color(79,145,207), 

            PrioritizeClosest = false, 

            Positions = {

                Vector(3754, 1172, -510),

            }, 
    
        }, 

    },

}