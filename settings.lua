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
Config.tile = {}
Config.tile.width = 16
Config.tile.height = 9
Config.tile.staggerX = 3

Config.movement = {}
Config.movement.moveSpeed = 0.07 * 1.6 * 2.5
Config.movement.sprintMultiplier = 1.6
Config.movement.pixelPerfect = false
--Config.movement.deadzone = {}
--Config.movement.deadzone.on = false -- Whether there is a deadzone the player can move in the centre of the screen without the camera moving
--Config.movement.deadzone.size = 1/3 -- How much of the screen is deadzone

Config.player = {}
Config.player.width = 15
Config.player.height = 28
Config.player.reachLength = Config.tile.width * 0.9
Config.player.reachHeight = -Config.player.height / 2 + Config.player.height * 5 / 6
Config.player.targeting = {
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
        coords = true
    }
}

Config.fonts = {}

function LoadFonts()
    --Config.fonts.ui = love.graphics.newImageFont("/fonts/font_example.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
    Config.fonts.ui = love.graphics.newFont("/fonts/m6x11.ttf", 16, "normal", love.graphics.getDPIScale())
end

function LoadTransforms()
    MapTransform = love.math.newTransform()
    
    MapTilesTransform = love.math.newTransform()
    MapTilesTransform:scale(Config.tile.width, Config.tile.height)
    MapTilesTransform:shear(- Config.tile.staggerX / Config.tile.width, 0)
end
