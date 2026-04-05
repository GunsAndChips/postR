local json = require "libraries/json/json"

SettingsClass = {}
SettingsClass.__index = SettingsClass

function SettingsClass:New()
    local this = {
        Keybinds = {
            sprint = "lshift",
            pause = "escape",
            up = "w",
            down = "s",
            left = "a",
            right = "d"
        },
        volume = {
            master = 2,
            music = 2
        },
        video = {
            fullscreen = true
        },
        movement = {
            useRotatedY = true
        }
    }
    setmetatable(this, self)

    return this
end

function LoadSettings()
    local settings = SettingsClass:New()

    local settingsFile = io.open("playersettings.json", "r")
    if not settingsFile then
        log.debug("There is no playersettings.json file, using defaults")
        return settings
    end

    local settingsFileContents = settingsFile:read("*a")
    if #settingsFileContents < 2 then
        log.debug("playersettings.json file is empty, using defaults")
        return settings
    end

    log.debug("Settings values loaded from JSON:", settingsFileContents)

    return OverwriteTable(settings, json.decode(settingsFileContents))
end

function SaveSettings()
    if Menus.sound.loaded == true then
        Settings.volume.master = Menus.sound.items[1].value
        Settings.volume.music = Menus.sound.items[2].value
    end

    local settingsFile = io.open("playersettings.json", "w")
    if not settingsFile then
        error("An error occurred when opening the settings file.")
    end

    local jason = json.encode(Settings)
    log.debug(jason)
    settingsFile:write(jason)
    settingsFile:close()
end

Config = {}
Config.tile = {
    width = 16,
    height = 9,
    staggerX = 3,
    ids = {
        grass = 1,
        tilled = 10
    }
}

Config.fonts = {}
function LoadFonts()
    local dpiScale = love.graphics.getDPIScale()
    Config.fonts.ui = love.graphics.newFont("/fonts/m6x11.ttf", 16, "normal", dpiScale)
    Config.fonts.ui100 = Config.fonts.ui
    Config.fonts.ui150 = love.graphics.newFont("/fonts/m6x11.ttf", 24, "normal", dpiScale)
    Config.fonts.ui200 = love.graphics.newFont("/fonts/m6x11.ttf", 32, "normal", dpiScale)
end

Config.debug = {
    logging = true,
    renderers = {
        map = {
            Transform = false,
            TileTransform = false
        },
        player = {
            targeting = false,
            facing = false,
            coords = false
        }
    }
}

Config.entity = {
    actions = {
        till = {
            --id = "till",
            baseCooldown = 1
        }
    }
}

Player = {
    x = PIXEL_WIDTH / 2,
    y = PIXEL_HEIGHT / 2,
    width = 16,
    height = 32,
    facing = "right",
    targeting = {},
    interaction = {
        action = nil,
        cooldown = 0
    },
    movement = {
        baseSpeed = 0.07 * 1.6 * 2.5,
        sprintMultiplier = 1.6
    },
    textures = {
        walk = {}
    },
    animations = {
        walk = nil
    }
}
Player.targeting = {
    distance = Config.tile.width * 0.9,
    height = Player.height * 0.2,
    texture = nil,
    tileOrigin = nil,
    x = 0,
    y = 0
}

function Config.Initialise()
    AddIdToChildTables(Config.entity.actions)
end

function LoadTransforms()
    MapTransform = love.math.newTransform()

    MapTilesTransform = love.math.newTransform()
    MapTilesTransform:scale(Config.tile.width, Config.tile.height)
    MapTilesTransform:shear(-Config.tile.staggerX / Config.tile.width, 0)
end
