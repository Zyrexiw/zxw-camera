Config = {}

Config.Locale = 'fr'

Config.DiscordWebhook = "YOUR_DISCORD_WEBHOOK_URL_HERE"

Config.CameraItem = 'appareil_photo'

Config.PhotoItem = 'photo'

Config.PhotoFolderItem = 'photo_folder'

Config.PhotoFolderStash = {
    slots = 50,
    weight = 100000
}

Config.Controls = {
    TakePhoto = 24, -- Left mouse button
    ZoomIn = 241, -- Mouse wheel up
    ZoomOut = 242, -- Mouse wheel down
    Exit = 194 -- Backspace
}

Config.Zoom = {
    Min = 10.0,
    Max = 100.0,
    Default = 50.0,
    Step = 5.0
}

Config.Animation = { -- DO NOT CHANGE
    Dict = 'amb@world_human_paparazzi@male@base',
    Anim = 'base',
    Prop = 'prop_pap_camera_01',
    Bone = 28422
}

