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
        error("An error occurred when opening the settings file.")
    end

    local settingsFileContents = settingsFile:read("*a")
    if #settingsFileContents < 2 then
        log.debug("Settings file is empty, using defaults")
        return settings
    end

    log.debug(settingsFileContents)
    return OverwriteTable(settings, json.decode(settingsFileContents))
end

function SaveSettings()
    Settings.volume.master = Menus.sound.items[1].value
    Settings.volume.music = Menus.sound.items[2].value
    
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
    staggerX = 3
}

Config.fonts = {}
function LoadFonts()
    local dpiScale = love.graphics.getDPIScale()
    Config.fonts.ui = love.graphics.newFont("/fonts/m6x11.ttf", 16, "normal", dpiScale)
    Config.fonts.ui100 = Config.fonts.ui
    Config.fonts.ui150 = love.graphics.newFont("/fonts/m6x11.ttf", 24, "normal", dpiScale)
    Config.fonts.ui200 = love.graphics.newFont("/fonts/m6x11.ttf", 32, "normal", dpiScale)
end

Config.movement = {
    moveSpeed = 0.07 * 1.6 * 2.5,
    sprintMultiplier = 1.6
}

Config.player = {
    width = 15,
    height = 28,
    targeting = {}
}
Config.player.targeting = {
    distance = Config.tile.width * 0.9,
    height = Config.player.height * 0.2,
    texture = nil,
    tile = nil,
    x = 0,
    y = 0
}

Config.renderers = {}
Config.renderers.debug = {
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

Config.debug = {
    logging = true
}

function LoadTransforms()
    MapTransform = love.math.newTransform()

    MapTilesTransform = love.math.newTransform()
    MapTilesTransform:scale(Config.tile.width, Config.tile.height)
    MapTilesTransform:shear(-Config.tile.staggerX / Config.tile.width, 0)
end
