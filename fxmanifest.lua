fx_version 'cerulean'
game 'gta5'

author 'Zxw'
description 'Système d\'appareil photo avec zoom et compatibilité visitecard'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua',
    'locales/init.lua',
    'locales/fr.lua',
    'locales/en.lua'
}

server_scripts {
    'server.lua'
}

client_scripts {
    'client.lua'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/camera_overlay.png'
}

dependencies {
    'screencapture',
    'ox_inventory'
}

lua54 'yes'

