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
Config.movement.moveSpeed = 0.07*1.6*2.5
Config.movement.sprintMultiplier = 1.6
Config.movement.pixelPerfect = false
--Config.movement.deadzone = {}
--Config.movement.deadzone.on = false -- Whether there is a deadzone the player can move in the centre of the screen without the camera moving
--Config.movement.deadzone.size = 1/3 -- How much of the screen is deadzone

Config.player = {}
Config.player.width = 15
Config.player.height = 28
Config.player.reachLength = Config.tile.width*1
Config.player.reachHeight = -Config.player.height/2 + Config.player.height*4/7

Config.renderers = {}
Config.renderers.debug = {}
Config.renderers.debug.cameraOffset = true
Config.renderers.debug.player = {}
Config.renderers.debug.player.targeting = true
Config.renderers.debug.player.facing = true
Config.renderers.debug.player.coords = true

Config.fonts = {}

function LoadFonts()
    Config.fonts.ui = love.graphics.newImageFont("/fonts/font_example.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
end

Menus = {}
Menus.default = {}
Menus.default.loaded = false
Menus.default.height = 120
Menus.default.width = 100
Menus.default.backgroundColour = { 0, 0, 0 }
Menus.default.textColour = { 1, 1, 1 }
Menus.default.textLineSpacing = 8
Menus.default.marginSize = 6

Menus.pause = Menus.default
Menus.pause.backgroundColour = { 0.6, 0.6, 0.6 }
Menus.pause.textColour = { 0.2, 0.2, 0.2 }
Menus.pause.title = "Paused"
Menus.pause.items = { { "Quit", Quit } }

function LoadMenuItems(menu)
    menu.title = love.graphics.newText(Config.fonts.ui,menu.title)
    local maxItemWidth = menu.title:getWidth()

    for i = 1, #menu.items do
        menu.items[i][1] = love.graphics.newText(Config.fonts.ui,menu.items[i][1])
        maxItemWidth = math.max(maxItemWidth, menu.items[i][1]:getWidth())
    end

    menu.width = math.max(maxItemWidth + 2*menu.marginSize, menu.width)
    menu.width = math.min(menu.width, PIXEL_WIDTH - 2*menu.marginSize)

    menu.loaded = true
    return menu
end