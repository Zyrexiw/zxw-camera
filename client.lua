local ESX = exports['es_extended']:getSharedObject()

function Translate(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    elseif Locales['en'] and Locales['en'][str] then
        return string.format(Locales['en'][str], ...)
    end
    return str
end

local active = false
local cameraprop = nil
local fov_max = 100.0
local fov_min = 10.0
local zoomspeed = 5.0
local speed_lr = 8.0
local speed_ud = 8.0
local fov = Config.Zoom.Default
local presstake = false

local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(1)
        end
    end
end

local function LoadModel(model)
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Wait(10)
    end
end

local function CloseCamera()
    active = false
    presstake = false
    
    SendNUIMessage({ action = "hideOverlay" })
    SendNUIMessage({ action = "hideFrame" })
    SetNuiFocus(false, false)
    
    if cameraprop then 
        DeleteEntity(cameraprop)
        cameraprop = nil
    end
    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
end

local function HideHUD()
    HideHelpTextThisFrame()
    HideHudAndRadarThisFrame()
    for i = 1, 19 do
        if i ~= 5 and i ~= 10 and i ~= 14 and i ~= 16 and i ~= 17 then
            HideHudComponentThisFrame(i)
        end
    end
end

local function UpdateCameraRotation(cam, zoomvalue)
    local rightX = GetDisabledControlNormal(0, 220)
    local rightY = GetDisabledControlNormal(0, 221)
    if rightX ~= 0.0 or rightY ~= 0.0 then
        local rot = GetCamRot(cam, 2)
        local new_z = rot.z + rightX * -1.0 * speed_ud * (zoomvalue + 0.1)
        local new_x = math.max(math.min(20.0, rot.x + rightY * -1.0 * speed_lr * (zoomvalue + 0.1)), -89.5)
        SetCamRot(cam, new_x, 0.0, new_z, 2)
        SetEntityHeading(PlayerPedId(), new_z)
    end
end

local function UpdateZoom(cam)
    local ped = PlayerPedId()
    local zoomIn = IsPedSittingInAnyVehicle(ped) and 17 or Config.Controls.ZoomIn
    local zoomOut = IsPedSittingInAnyVehicle(ped) and 16 or Config.Controls.ZoomOut
    
    if IsControlJustPressed(0, zoomIn) then
        fov = math.max(fov - zoomspeed, fov_min)
    end
    if IsControlJustPressed(0, zoomOut) then
        fov = math.min(fov + zoomspeed, fov_max)
    end
    
    local current_fov = GetCamFov(cam)
    if math.abs(fov - current_fov) < 0.1 then
        fov = current_fov
    end
    SetCamFov(cam, current_fov + (fov - current_fov) * 0.05)
end

RegisterNetEvent('zxw_camera:useCamera', function()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        ESX.ShowNotification('~r~' .. Translate('cannot_use_in_vehicle'))
        return
    end
    
    if active then
        CloseCamera()
        return
    end
    
    active = true
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    
    SetNuiFocus(false, false)
    Wait(100)
    local localeData = Locales[Config.Locale] or Locales['en']
    SendNUIMessage({ 
        action = "showOverlay",
        locale = Config.Locale,
        translations = localeData
    })
    
    LoadAnimDict(Config.Animation.Dict)
    TaskPlayAnim(ped, Config.Animation.Dict, Config.Animation.Anim, 2.0, 2.0, -1, 1, 0, false, false, false)
    
    local coords = GetEntityCoords(ped)
    LoadModel(Config.Animation.Prop)
    cameraprop = CreateObject(GetHashKey(Config.Animation.Prop), coords.x, coords.y, coords.z + 0.2, true, true, true)
    AttachEntityToEntity(cameraprop, ped, GetPedBoneIndex(ped, Config.Animation.Bone), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(Config.Animation.Prop)
    
    CreateThread(function()
        while active do
            Wait(200)
            local lPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(lPed)
            
            Wait(500)
            SetTimecycleModifier("default")
            SetTimecycleModifierStrength(0.3)
            
            local cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
            AttachCamToEntity(cam, lPed, 0.0, 1.0, 1.0, true)
            SetCamRot(cam, 0.0, 0.0, GetEntityHeading(lPed))
            SetCamFov(cam, fov)
            RenderScriptCams(true, false, 0, 1, 0)
            
            while active and not IsEntityDead(lPed) and GetVehiclePedIsIn(lPed) == vehicle do
                DisableAllControlActions(0)
                DisableAllControlActions(1)
                DisableAllControlActions(2)
                
                EnableControlAction(0, 220, true)
                EnableControlAction(0, 221, true)
                EnableControlAction(0, Config.Controls.ZoomIn, true)
                EnableControlAction(0, Config.Controls.ZoomOut, true)
                EnableControlAction(0, Config.Controls.TakePhoto, true)
                EnableControlAction(0, 194, true)
                
                if IsDisabledControlJustPressed(0, Config.Controls.Exit) or IsDisabledControlJustPressed(1, Config.Controls.Exit) or
                   IsControlJustPressed(0, Config.Controls.Exit) or IsControlJustPressed(1, Config.Controls.Exit) then
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                    CloseCamera()
                    break
                end
                
                if IsControlJustPressed(0, Config.Controls.TakePhoto) or IsControlJustPressed(1, Config.Controls.TakePhoto) then
                    if not presstake then
                        presstake = true
                        PlaySoundFrontend(-1, "Camera_Shoot", "Phone_Soundset_Franklin", 1)
                        SetFlash(0, 0, 500, 500, 500)
                        
                        if Config.DiscordWebhook and Config.DiscordWebhook ~= "" then
                            TriggerServerEvent("zxw_camera:server:capture-photo")
                        else
                            ESX.ShowNotification("~r~" .. Translate('discord_webhook_not_configured'))
                            presstake = false
                        end
                    end
                end
                
                local zoomvalue = (1.0 / (fov_max - fov_min)) * (fov - fov_min)
                UpdateCameraRotation(cam, zoomvalue)
                UpdateZoom(cam)
                HideHUD()
                Wait(1)
            end
            
            CloseCamera()
            ClearTimecycleModifier()
            fov = Config.Zoom.Default
            RenderScriptCams(false, false, 0, 1, 0)
            DestroyCam(cam, false)
            SetNightvision(false)
            SetSeethrough(false)
        end
    end)
    
end)

RegisterNetEvent('zxw_camera:photoTaken', function()
    presstake = false
end)

exports('useCamera', function(data, slot)
    TriggerEvent('zxw_camera:useCamera')
    return false
end)

RegisterNetEvent('zxw_camera:openPhotoFolder', function(stashId)
    exports.ox_inventory:openInventory('stash', {id = stashId})
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName and active then
        CloseCamera()
    end
end)

