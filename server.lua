local ESX = exports['es_extended']:getSharedObject()

function Translate(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    elseif Locales['en'] and Locales['en'][str] then
        return string.format(Locales['en'][str], ...)
    end
    return str
end

ESX.RegisterUsableItem(Config.CameraItem, function(source)
    TriggerClientEvent('zxw_camera:useCamera', source)
end)

exports('useCamera', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        TriggerClientEvent('zxw_camera:useCamera', inventory.id)
        return false
    end
    return false
end)

RegisterNetEvent("zxw_camera:server:capture-photo", function()
    local playerSource = source
    local xPlayer = ESX.GetPlayerFromId(playerSource)
    
    if not xPlayer then 
        return 
    end
    
    if not exports.screencapture then
        TriggerClientEvent('esx:showNotification', playerSource, "~r~" .. Translate('screencapture_not_started'))
        TriggerClientEvent('zxw_camera:photoTaken', playerSource)
        return
    end
    
    if not Config.DiscordWebhook or Config.DiscordWebhook == "" then
        TriggerClientEvent('esx:showNotification', playerSource, "~r~" .. Translate('discord_webhook_not_configured'))
        TriggerClientEvent('zxw_camera:photoTaken', playerSource)
        return
    end
    
    exports.screencapture:remoteUpload(tostring(playerSource), tostring(Config.DiscordWebhook), {
        encoding = "png",
        formField = "files[]",
        maxWidth = 3840,
        maxHeight = 2160
    }, function(data)
        if not data then
            TriggerClientEvent('esx:showNotification', playerSource, "~r~" .. Translate('no_data_received'))
            TriggerClientEvent('zxw_camera:photoTaken', playerSource)
            return
        end
        
        local response = data
        if type(data) == "string" then
            local success, decoded = pcall(json.decode, data)
            if success then
                response = decoded
            else
                TriggerClientEvent('esx:showNotification', playerSource, "~r~" .. Translate('processing_error'))
                TriggerClientEvent('zxw_camera:photoTaken', playerSource)
                return
            end
        end
        
        local imageUrl = nil
        if response.attachments and response.attachments[1] then
            imageUrl = response.attachments[1].proxy_url or response.attachments[1].url
        elseif response.url then
            imageUrl = response.url
        end
        
        if imageUrl then
            local time = os.date('*t')
            local dateStr = string.format("%02d/%02d/%04d %02d:%02d", time.day, time.month, time.year, time.hour, time.min)
            local metadata = {
                label = "Photo - " .. dateStr,
                cardImage = imageUrl,
                cardWidth = 3840,
                cardHeight = 2160
            }
            
            local success2, response2 = exports.ox_inventory:AddItem(playerSource, Config.PhotoItem, 1, metadata)
            
            if success2 then
                TriggerClientEvent('esx:showNotification', playerSource, "~g~" .. Translate('photo_taken_success'))
                TriggerClientEvent('zxw_camera:photoTaken', playerSource)
            else
                TriggerClientEvent('esx:showNotification', playerSource, "~r~" .. Translate('cannot_add_photo'))
                TriggerClientEvent('zxw_camera:photoTaken', playerSource)
            end
        else
            TriggerClientEvent('esx:showNotification', playerSource, "~r~" .. Translate('invalid_response_format'))
            TriggerClientEvent('zxw_camera:photoTaken', playerSource)
        end
    end, "blob")
end)

local allowedItems = {
    ['photo'] = true,
    ['visitecard'] = true
}

CreateThread(function()
    while not exports.ox_inventory do
        Wait(100)
    end
    
    exports.ox_inventory:registerHook('swapItems', function(payload)
        local toInventory = payload.toInventory and tostring(payload.toInventory)
        
        if not toInventory or not toInventory:match('dossier_photo_') then
            return true
        end
        
        local item = payload.fromSlot
        local itemName = item and item.name
        
        if not itemName then
            return true
        end
        
        if not allowedItems[itemName] then
            local playerSource = payload.source
            if playerSource then
                TriggerClientEvent('esx:showNotification', playerSource, "~r~" .. Translate('item_not_allowed'))
            end
            return false
        end
        
        return true
    end, {
        inventoryFilter = { 'dossier_photo_' }
    })
end)

local function GetPlayerStashId(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then
        return nil
    end
    local identifier = xPlayer.identifier
    local stashId = 'dossier_photo_' .. identifier
    
    exports.ox_inventory:RegisterStash(
        stashId,
        Translate('photo_folder'),
        Config.PhotoFolderStash.slots,
        Config.PhotoFolderStash.weight,
        true
    )
    
    return stashId
end

exports.ox_inventory:registerHook('swapItems', function(payload)
    local toInventory = payload.toInventory and tostring(payload.toInventory)
    
    if not toInventory or not toInventory:match('dossier_photo_') then
        return true
    end
    
    local item = payload.fromSlot
    local itemName = item and item.name
    
    if not itemName then
        return true
    end
    
    if not allowedItems[itemName] then
        local playerSource = payload.source
        if playerSource then
            TriggerClientEvent('esx:showNotification', playerSource, "~r~" .. Translate('item_not_allowed'))
        end
        return false
    end
    
    return true
end, {
    inventoryFilter = { 'dossier_photo_' }
})

ESX.RegisterUsableItem(Config.PhotoFolderItem, function(source)
    local stashId = GetPlayerStashId(source)
    if stashId then
        TriggerClientEvent('zxw_camera:openPhotoFolder', source, stashId)
    else
        TriggerClientEvent('esx:showNotification', source, "~r~" .. Translate('cannot_open_folder'))
    end
end)

exports('usePhotoFolder', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local stashId = GetPlayerStashId(inventory.id)
        if stashId then
            TriggerClientEvent('zxw_camera:openPhotoFolder', inventory.id, stashId)
            return false
        end
    end
    return false
end)

