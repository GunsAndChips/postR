Settings = {}
Settings.movement = {}
Settings.movement.useRotatedY = true -- Whether the Y axis for player movement is rotated to match the tilt of the parallelogram tiles

Settings.Keybinds = {}
Settings.Keybinds.up = "w"
Settings.Keybinds.down = "s"
Settings.Keybinds.left = "a"
Settings.Keybinds.right = "d"
Settings.Keybinds.sprint = "lshift"

Config = {}
Config.tile = {}
Config.tile.width = 16
Config.tile.staggerX = 3

Config.movement = {}
Config.movement.moveSpeed = 0.07*1.6*2.5
Config.movement.sprintMultiplier = 1.6
Config.movement.pixelPerfect = false
--Config.movement.deadzone = {}
--Config.movement.deadzone.on = false -- Whether there is a deadzone the player can move in the centre of the screen without the camera moving
--Config.movement.deadzone.size = 1/3 -- How much of the screen is deadzone

Config.player = {}
Config.player.width = 14
Config.player.height = 28
Config.player.reachLength = Config.tile.width*0.85
Config.player.reachHeight = Config.player.height*2/3

Config.renderers = {}
Config.renderers.debug = {}
Config.renderers.debug.cameraOffset = true
Config.renderers.debug.player = {}
Config.renderers.debug.player.targeting = true
Config.renderers.debug.player.facing = true