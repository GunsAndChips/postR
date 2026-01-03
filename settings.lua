local TLfres = require "libraries/tlfres"

Settings = {}
Settings.movement = {}
Settings.movement.useRotatedY = true -- Whether the Y axis for player movement is rotated to match the tilt of the parallelogram tiles

Settings.Keybinds = {
    up = "w",
    down = "s",
    left = "a",
    right = "d",
    sprint = "lshift",
    pause = "escape"
}

Settings.volume = {
    master = 4
}

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

Config.menus = {
    hoverOffsetX = 2 -- Should be less than the Margin Size for the menu to not cause issues
}

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
