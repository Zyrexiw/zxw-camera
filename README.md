# zxw_camera - Camera System

A FiveM camera system script that allows players to take photos with a camera item, compatible with zxw_visitecard.

## Features

- ✅ Camera item usage
- ✅ Camera animation with prop in hands
- ✅ Character stays still while allowing camera rotation
- ✅ Photo capture with Discord upload
- ✅ Photos created as items compatible with zxw_visitecard
- ✅ Intuitive controls with zoom functionality
- ✅ Photo folder system for organization

## Dependencies

- [es_extended](https://github.com/esx-framework/es_extended) - ESX Legacy
- [ox_inventory](https://github.com/overextended/ox_inventory) - Inventory system
- [screencapture](https://github.com/itschip/screencapture) - Screen capture functionality
- [zxw_visitecard](https://github.com/Zyrexiw/zxw-visitecard) - Optional, for photo card functionality

## Installation

1. Place the `zxw_camera` folder in your `resources` directory
2. Add the items to your `ox_inventory/data/items.lua` (see `items.txt`)
3. Configure the Discord webhook in `config.lua`
4. Ensure `screencapture` is installed and started - https://github.com/itschip/screencapture
5. Add `ensure zxw_camera` to your `server.cfg`

## Configuration

Edit `config.lua` to customize:
- Discord webhook URL for photo uploads
- Item names
- Controls
- Zoom settings
- Photo folder stash properties

## Controls

- **Left Mouse Button** - Take a photo
- **Mouse Wheel Up/Down** - Zoom in/out
- **Mouse Movement** - Look around (camera rotation)
- **Backspace** - Exit camera mode

## Items Configuration

Add these items to your `ox_inventory/data/items.lua`:

```lua
['appareil_photo'] = {
    label = 'Camera',
    weight = 500,
    stack = false,
    close = true,
    description = 'A camera used to take photos',
    client = {
        export = 'zxw_camera.useCamera'
    }
},

['photo'] = {
    label = 'Photo',
    weight = 50,
    stack = false,
    close = true,
    description = 'A photo taken with a camera',
    server = {
        export = 'zxw_visitecard.useCard'
    },
    buttons = {
        {
            label = 'Show to nearby player',
            action = function(slot)
                exports.zxw_visitecard:showCardToNearby(slot)
            end
        }
    }
},

['photo_folder'] = {
    label = 'Photo Folder',
    weight = 200,
    stack = false,
    close = true,
    description = 'A folder used to store your photos',
    server = {
        export = 'zxw_camera.usePhotoFolder'
    }
}
```

## Exports

### Client Exports

- `exports.zxw_camera.useCamera()` - Triggers camera usage

### Server Exports

- `exports.zxw_camera.useCamera(event, item, inventory, slot, data)` - Handles camera item usage
- `exports.zxw_camera.usePhotoFolder(event, item, inventory, slot, data)` - Handles photo folder usage

## Compatibility

- ESX Legacy
- ox_inventory
- zxw_visitecard (photos can be used as business cards)
- screencapture - https://github.com/itschip/screencapture

## Support

For issues or questions, please join my discord: https://discord.gg/dJcewbNHbT
