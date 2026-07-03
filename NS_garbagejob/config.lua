Config = {}

-- Notification System: 'esx', 'ox_lib', 'okokNotify', 'okokTextUI'
Config.NotifySystem = 'okokNotify'

-- General Settings
Config.PayPerBag = 50 -- Money per trash bag collected
Config.TruckModel = 'trash2' -- The vehicle spawned for the job
Config.MaxTruckCapacity = 100 -- Maximum amount of bags the truck can hold

-- Job Location 
Config.BossPed = {
    model = 's_m_y_garbage',
    coords = vector4(-321.7207, -1546.4393, 31.0199, 359.5359) 
}

Config.VehicleSpawn = {
    coords = vector3(-317.2256, -1538.6036, 27.6575),
    heading = 348.9958
}

-- Dumpster Models that can be targeted
Config.DumpsterModels = {
    'prop_dumpster_01a',
    'prop_dumpster_02a',
    'prop_dumpster_02b',
    'prop_dumpster_4b'
}