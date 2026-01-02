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
    Config.fonts.menu = {
        rangeDots = love.graphics.newFont("/fonts/m6x11.ttf", 32, "normal", dpiScale)
    }
end

Config.menus = {
    hoverOffsetX = 2
}
Config.menus.defaults = {
    title = {
        textString = "Menu Title",
        text = nil,
        x = nil,
        y = nil,
        width = nil,
        height = nil
    },
    loaded = false,
    minHeight = 120,
    minWidth = 100,
    backgroundColour = { 0.6, 0.6, 0.6 },
    textColour = { 1, 1, 1 },
    textColourHover = { 0.1, 0.3, 0.1 },
    textColourDisabled = { 0.3, 0.3, 0.3 },
    textLineSpacing = 3,
    marginSize = 6
}

function LoadMenuConfig()
    Config.menus.rangeText = {}

    local ranges = {
        "",
        ".",
        "..",
        "...",
        "....",
        ".....",
        "......",
        ".......",
        "........"
    }
    ranges.count = #ranges

    for i = 1, ranges.count do
        local textTable = {
            Config.menus.defaults.textColour,
            ranges[i],
            Config.menus.defaults.textColourDisabled,
            ranges[ranges.count + 1 - i]
        }
        
        table.insert(Config.menus.rangeText, love.graphics.newText(Config.fonts.ui, textTable))
    end

    Config.menus.rangeText.width = Config.menus.rangeText[1]:getWidth()
    Config.menus.rangeText.height = Config.menus.rangeText[1]:getHeight()
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

function LoadTransforms()
    MapTransform = love.math.newTransform()

    MapTilesTransform = love.math.newTransform()
    MapTilesTransform:scale(Config.tile.width, Config.tile.height)
    MapTilesTransform:shear(-Config.tile.staggerX / Config.tile.width, 0)
end
