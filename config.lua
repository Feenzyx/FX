Config = {}

--[[ Notitie
50 juwelen = 1 goudstaaf
max 500k aan juwelen kun je bijhebben
max 1 mil aan goudstaven kun je bijhebben
]]

Config.GoldToStart = 2 -- Goudstaven nodig om een run te starten

-- Animatie kloppen
Config.AnimDict				= 'timetable@jimmy@doorknock@'
Config.Anim					= 'knockdoor_idle' -- knock
Config.KnockTime			= 5000

-- Animatie geven
Config.AnimDictGive         = "mp_common"
Config.AnimGive             = "givetake1_b"
Config.GiveTime			    = 5000
Config.DrugProp             = 'prop_gold_bar'

--Animatie smelten
Config.AnimDictSmelt         = "mini@repair"
Config.AnimSmelt             = "fixing_a_ped"
Config.SmeltTime		     = 10000
Config.SmeltHeading          = 224.41

-- Algemeen
Config.CopsNeeded			    = 3 -- Default: 3
Config.DeliveryAmount           = 5
Config.MainThreadDelay          = 5000
Config.JewelPrice               = 50000  -- Price = Black money
Config.GoldPrice                = 47500 -- Price = White money (Belangrijk: -5% afname)

-- Locaties      

Config.SellLocations = {
    {Location = vector3(-1552.97, -587.88, 33.98), heading = 217.6, isUsed = false},
    {Location = vector3(-1387.28, -437.23, 36.36), heading = 42.88, isUsed = false},
    {Location = vector3(-1197.44, -259.1, 37.76), heading = 41.56, isUsed = false},
    {Location = vector3(-802.14, -177.94, 38.14), heading = 119.36, isUsed = false},
    {Location = vector3(-665.3, 165.5, 59.35), heading = 47.26, isUsed = false},
    {Location = vector3(-794.28, 351.79, 88.0), heading = 183.93, isUsed = false},
    {Location = vector3(-1212.12, 322.65, 71.05), heading = 20.5, isUsed = false},
    {Location = vector3(-1551.21, 210.16, 58.86), heading = 118.0, isUsed = false},
    {Location = vector3(-622.86, 311.72, 83.93), heading = 87.61, isUsed = false},
    {Location = vector3(359.11, -59.37, 72.88), heading = 70.04, isUsed = false},
    {Location = vector3(-70.79, 141.9, 81.86), heading = 212.18, isUsed = false},
    {Location = vector3(-1001.44, -785.05, 16.37), heading = 331.3, isUsed = false},
    {Location = vector3(-637.01, -1077.64, 12.33), heading = 63.5, isUsed = false},
    {Location = vector3(-912.1, -1269.13, 5.22), heading = 290.7, isUsed = false},
    {Location = vector3(-1323.38, -1025.64, 7.75), heading = 300.6, isUsed = false},
    {Location = vector3(287.68, -303.54, 49.86), heading = 340.73, isUsed = false},
}

Config.StartLocations = {
    {Type = 'smeltery', Text = 'Juwelen smelten', Coords = vector3(1085.14, -2001.82, 31.45)},
    {Type = 'jewerly', Text = 'Juwelen inkopen (€'..Config.JewelPrice..')', Coords = vector3(-1989.72, -330.52, 32.1)},
    {Type = 'jewerly', Text = 'Juwelen inkopen (€'..Config.JewelPrice..')', Coords = vector3(-1519.46, -893.81, 13.73)},
    {Type = 'start', Text = 'Start run', Coords = vector3(-1152.82, -1516.95, 10.68), Gangjob = true},
    {Type = 'start', Text = 'Start run', Coords = vector3(-16.77, -1430.48, 31.15), Gangjob = true},
}