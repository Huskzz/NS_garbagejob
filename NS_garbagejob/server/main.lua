local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('ns_garbagejob:server:pay', function(bags)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end

    if type(bags) ~= 'number' or bags <= 0 or bags > Config.MaxTruckCapacity then
        DropPlayer(src, "Exploit detected: Invalid bag count.")
        return
    end

    local payout = bags * Config.PayPerBag

    xPlayer.addAccountMoney('money', payout)

    if Config.NotifySystem == 'esx' then
        TriggerClientEvent('esx:showNotification', src, "You were paid $" .. payout .. " for collecting " .. bags .. " bags.")
    elseif Config.NotifySystem == 'ox_lib' then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Garbage Job', description = "You were paid $" .. payout, type = 'success' })
    elseif Config.NotifySystem == 'okokNotify' then
        TriggerClientEvent('okokNotify:Alert', src, 'Garbage Job', "You were paid $" .. payout, 4000, 'success')
    elseif Config.NotifySystem == 'okokTextUI' then
        TriggerClientEvent('esx:showNotification', src, "You were paid $" .. payout .. " for collecting " .. bags .. " bags.")
    end
end)