local TLfres = require "libraries/tlfres"

Settings = {}
Settings.movement = {}
Settings.movement.useRotatedY = true -- Whether the Y axis for player movement is rotated to match the tilt of the parallelogram tiles

Settings.Keybinds = {}
Settings.Keybinds.up = "w"
Settings.Keybinds.down = "s"
Settings.Keybinds.left = "a"
Settings.Keybinds.right = "d"
Settings.Keybinds.sprint = "lshift"
Settings.Keybinds.pause = "escape"

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
Config.player.reachLength = Config.tile.width * 1
Config.player.reachHeight = -Config.player.height / 2 + Config.player.height * 4 / 7

Config.renderers = {}
Config.renderers.debug = {}
Config.renderers.debug.cameraOffset = true
Config.renderers.debug.player = {}
Config.renderers.debug.player.targeting = true
Config.renderers.debug.player.facing = true
Config.renderers.debug.player.coords = true

Config.fonts = {}

function LoadFonts()
    --Config.fonts.ui = love.graphics.newImageFont("/fonts/font_example.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
    Config.fonts.ui = love.graphics.newFont("/fonts/m6x11.ttf", 16, "normal", love.graphics.getDPIScale())
end

Menus = {}
Menus.default = {}
Menus.default.loaded = false
Menus.default.minHeight = 120
Menus.default.minWidth = 100
Menus.default.backgroundColour = { 0.6, 0.6, 0.6 }
Menus.default.textColour = { 1, 1, 1 }
Menus.default.textColourHover = { 0.1, 0.3, 0.1 }
Menus.default.textLineSpacing = 4
Menus.default.marginSize = 6

Menus.pause = Menus.default
Menus.pause.title = "Paused"
Menus.pause.items = {
    { textString = "Quit the game with this button with a really long label that would go off the edge of the screen", onClick = function() Quit() end }
}

function Quit()
    love.event.quit()
end
