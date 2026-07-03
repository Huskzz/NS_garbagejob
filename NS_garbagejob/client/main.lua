local ESX = exports['es_extended']:getSharedObject()
local onJob = false
local carryingTrash = false
local truckBags = 0
local jobVehicle = nil
local bossPed = nil
local trashProp = nil
local dumpsterData = {}

local function Notify(msg, msgType)
    if Config.NotifySystem == 'esx' then
        ESX.ShowNotification(msg)
    elseif Config.NotifySystem == 'ox_lib' then
        lib.notify({ title = 'Garbage Job', description = msg, type = msgType or 'info' })
    elseif Config.NotifySystem == 'okokNotify' then
        exports['okokNotify']:Alert('Garbage Job', msg, 4000, msgType or 'info')
    elseif Config.NotifySystem == 'okokTextUI' then
        exports['okokTextUI']:Open(msg, 'darkblue', 'left')
        SetTimeout(4000, function() exports['okokTextUI']:Close() end)
    end
end

local function GiveTrashProp()
    lib.requestModel(`prop_cs_rub_binbag_01`)
    local coords = GetEntityCoords(cache.ped)
    trashProp = CreateObject(`prop_cs_rub_binbag_01`, coords.x, coords.y, coords.z, true, true, false)
    AttachEntityToEntity(trashProp, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.12, 0.0, -0.05, 220.0, 120.0, 0.0, true, true, false, true, 1, true)
end

local function RemoveTrashProp()
    if trashProp and DoesEntityExist(trashProp) then
        DeleteEntity(trashProp)
        trashProp = nil
    end
end

local function GetDumpsterId(entity)
    local coords = GetEntityCoords(entity)
    return string.format("%.2f_%.2f_%.2f", coords.x, coords.y, coords.z)
end

CreateThread(function()
    lib.requestModel(Config.BossPed.model)
    bossPed = CreatePed(4, Config.BossPed.model, Config.BossPed.coords.x, Config.BossPed.coords.y, Config.BossPed.coords.z - 1.0, Config.BossPed.coords.w, false, true)
    FreezeEntityPosition(bossPed, true)
    SetEntityInvincible(bossPed, true)
    SetBlockingOfNonTemporaryEvents(bossPed, true)

    exports.ox_target:addLocalEntity(bossPed, {
        {
            name = 'ns_garbage_start',
            icon = 'fa-solid fa-truck',
            label = 'Start Garbage Job',
            canInteract = function() return not onJob end,
            onSelect = function() StartJob() end
        },
        {
            name = 'ns_garbage_stop',
            icon = 'fa-solid fa-hand-holding-dollar',
            label = 'Finish Job & Get Paid',
            canInteract = function() return onJob end,
            onSelect = function() EndJob() end
        }
    })
end)

function StartJob()
    if not ESX.Game.IsSpawnPointClear(Config.VehicleSpawn.coords, 3.0) then
        Notify("Vehicle spawn area is blocked!", "error")
        return
    end

    lib.requestModel(Config.TruckModel)
    jobVehicle = CreateVehicle(Config.TruckModel, Config.VehicleSpawn.coords.x, Config.VehicleSpawn.coords.y, Config.VehicleSpawn.coords.z, Config.VehicleSpawn.heading, true, false)
    TaskWarpPedIntoVehicle(cache.ped, jobVehicle, -1)
    
    onJob = true
    truckBags = 0
    dumpsterData = {}
    Notify("Job started! Max capacity is " .. Config.MaxTruckCapacity .. " bags.", "success")
end

function EndJob()
    if truckBags > 0 then
        TriggerServerEvent('ns_garbagejob:server:pay', truckBags)
    else
        Notify("You didn't collect any trash!", "error")
    end

    if DoesEntityExist(jobVehicle) then
        DeleteVehicle(jobVehicle)
    end

    RemoveTrashProp()
    onJob = false
    carryingTrash = false
    truckBags = 0
    dumpsterData = {}
    ClearPedTasks(cache.ped)
end

exports.ox_target:addModel(Config.DumpsterModels, {
    {
        name = 'ns_garbage_collect',
        icon = 'fa-solid fa-trash',
        label = 'Search Dumpster',
        canInteract = function(entity)
            if not onJob or carryingTrash then return false end
            
            local dumpId = GetDumpsterId(entity)
            if dumpsterData[dumpId] and dumpsterData[dumpId] <= 0 then return false end 
            
            return true
        end,
        onSelect = function(data)
            CollectTrash(data.entity)
        end
    }
})

function CollectTrash(dumpster)
    if truckBags >= Config.MaxTruckCapacity then
        Notify("Your truck is full! Return to the depot.", "error")
        return
    end

    local dumpId = GetDumpsterId(dumpster)
    
    if not dumpsterData[dumpId] then
        dumpsterData[dumpId] = math.random(1, 5)
    end

    if dumpsterData[dumpId] <= 0 then
        Notify("This dumpster is completely empty.", "error")
        return
    end

    if lib.progressCircle({
        duration = 3000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer' },
    }) then
        dumpsterData[dumpId] = dumpsterData[dumpId] - 1
        carryingTrash = true
        
        GiveTrashProp()
        Notify("You grabbed a bag. Put it in the back of your truck. (" .. dumpsterData[dumpId] .. " left here)", "info")
        
        lib.requestAnimDict('missfbi4prepp1')
        TaskPlayAnim(cache.ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
    else
        Notify("Canceled", "error")
    end
end

exports.ox_target:addModel(Config.TruckModel, {
    {
        name = 'ns_garbage_toss',
        icon = 'fa-solid fa-truck-ramp-box',
        label = 'Throw Bag In Truck',
        canInteract = function(entity)

            if not carryingTrash then return false end

            local rearOffset = GetOffsetFromEntityInWorldCoords(entity, 0.0, -4.5, 0.0)
            local playerCoords = GetEntityCoords(cache.ped)
            
            local distanceToRear = #(playerCoords - rearOffset)

            if distanceToRear < 2.5 then
                return true
            end

            return false
        end,
        onSelect = function(data)
            ClearPedTasks(cache.ped)
            RemoveTrashProp()
            carryingTrash = false
            truckBags = truckBags + 1
            
            if truckBags >= Config.MaxTruckCapacity then
                Notify("Truck is now FULL (" .. truckBags .. "/" .. Config.MaxTruckCapacity .. "). Return to the boss.", "error")
            else
                Notify("Trash collected! Truck Capacity: " .. truckBags .. "/" .. Config.MaxTruckCapacity, "success")
            end
        end
    }
})