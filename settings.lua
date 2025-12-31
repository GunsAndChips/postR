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
    Config.fonts.ui = love.graphics.newFont("/fonts/m6x11.ttf", 16, "normal", love.graphics.getDPIScale())
end

Config.menus = {
    hoverOffsetX = 2
}
Config.menus.defaults = {
    title = "Menu Title",
    loaded = false,
    minHeight = 120,
    minWidth = 100,
    backgroundColour = { 0.6, 0.6, 0.6 },
    textColour = { 1, 1, 1 },
    textColourHover = { 0.1, 0.3, 0.1 },
    textColourDisabled = { 1, 0, 0 },
    textLineSpacing = 3,
    marginSize = 6
}

function LoadMenuConfig()
    Config.menus.rangeText = {
        love.graphics.newText(Config.fonts.ui),
        love.graphics.newText(Config.fonts.ui),
        love.graphics.newText(Config.fonts.ui),
        love.graphics.newText(Config.fonts.ui),
        love.graphics.newText(Config.fonts.ui),
        love.graphics.newText(Config.fonts.ui),
        love.graphics.newText(Config.fonts.ui),
        love.graphics.newText(Config.fonts.ui)
    }

    for i = 1, #Config.menus.rangeText do
        local text1 = ""
        for j = 1, i do
            text1 = text1 .. "."
        end

        local text2 = ""
        for j = 1, #Config.menus.rangeText - i do
            text2 = text2 .. "."
        end
        local textTable = {
            Config.menus.defaults.textColour,
            text1,
            Config.menus.defaults.textColourDisabled,
            text2
        }
        Config.menus.rangeText[i]:setf(textTable, 300, "right")
    end
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
