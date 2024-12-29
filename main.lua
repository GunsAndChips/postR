require "map"

-- Push to scale up graphics
local push = require("push")
local gameWidth, gameHeight = 320, 180 --fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()
windowWidth, windowHeight = windowWidth*.7, windowHeight*.7 --make the window a bit smaller than the screen itself

push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, pixelperfect = true})

PIXEL_WIDTH = 320
PIXEL_HEIGHT = 180

local tiles = {
     1, 1, 1, 1, 1, 1,
     1, 1, 1, 1, 1, 1,
     1, 1, 1, 1, 1, 1,
     2, 2, 2, 2, 2, 2,
}

local map1 = Map:New(tiles, 6, 4)

tileSprites = {}
function LoadTileSprites()
    for i=1, 2 do
        --local fileName = string.format("textures/tile_%d.png",i)
        local fileName = string.format("textures/pg%d.png",i)
        local newTile = love.graphics.newImage(fileName)
        table.insert(tileSprites, newTile)
    end
end

function love.load()
    Player = {}
    Player.width = 14
    Player.height = 28
    Player.x = PIXEL_WIDTH/2 - Player.width/2
    Player.y = PIXEL_HEIGHT/2 - Player.height/2

    _Key = {}
    _Key.up = "w"
    _Key.down = "s"
    _Key.left = "a"
    _Key.right = "d"
    _Key.sprint = "lshift"

    LoadTileSprites()

    --love.window.setMode(PIXEL_WIDTH * SCALE_FACTOR, PIXEL_HEIGHT * SCALE_FACTOR, {fullscreen=false,vsync=false})
end

function love.update(dt)
    playerMove()
end

function love.draw()
    push:start()

    map1:Render()
    love.graphics.setColor(0, 0.4, 0.4)
    love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height)

    push:finish()
end

function playerMove()
    local speed = {}
    speed.multiplier = 0.45
    speed.x = 0
    speed.y = 0

    -- Sprint or walk
    if love.keyboard.isDown(_Key.sprint) then
        speed.multiplier = speed.multiplier * 1.6
    elseif love.keyboard.isDown(_Key.up, _Key.down, _Key.left, _Key.right) then
        speed.multiplier = speed.multiplier
    else
        return
    end

    -- Set direction for x/y movement
    if love.keyboard.isDown(_Key.right) then
        speed.x = speed.x+1
    end
    if love.keyboard.isDown(_Key.left) then
        speed.x = speed.x-1
    end
    if love.keyboard.isDown(_Key.down) then
        speed.y = speed.y+1
    end
    if love.keyboard.isDown(_Key.up) then
        speed.y = speed.y-1
    end

    -- Return if no movement
    if speed.y == 0 and speed.x == 0 then
        return
    end

    if math.abs(speed.y) + math.abs(speed.x) == 2 then
        speed.multiplier = speed.multiplier / math.sqrt(2)
    end

    -- Move player
    Player.x = Player.x + speed.multiplier * speed.x
    Player.y = Player.y + speed.multiplier * speed.y
end