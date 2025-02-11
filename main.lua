require "map"

-- TLfres for scaling
local TLfres = require "libraries/tlfres"

function love.mouse.getPosition() -- Override the standard function with TLFres helper function
    return TLfres.getMousePosition(PIXEL_WIDTH, PIXEL_HEIGHT)
 end

PIXEL_WIDTH = 320
PIXEL_HEIGHT = 180

TileSprites = {}
function LoadTileSprites()
    local tileFileNames = {}
    
    for i=1, 2 do
        --local fileName = string.format("textures/tile_%d.png",i)
        table.insert(tileFileNames, string.format("textures/pg%d.png",i))
    end

    TileSprites = love.graphics.newArrayImage(tileFileNames)

    TileSprites:setFilter("nearest", "nearest")
    TileSprites:setMipmapFilter( )
end

local tiles = {
     1, 1, 1, 1, 1, 1, 2, 2, 1, 1,
     1, 1, 1, 1, 1, 1, 2, 2, 1, 1,
     1, 1, 1, 1, 1, 1, 2, 2, 1, 1,
     2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
     2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
}

local map1 = Map:New(tiles, 10, 5)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- don't know if size matters here if fullscreen anyway
    love.window.setMode(1920, 1080, {vsync = true, msaa = 0, highdpi = true, fullscreen = true})

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
end

function love.update(dt)
    playerMove()
end

function love.draw()
    TLfres.beginRendering(PIXEL_WIDTH, PIXEL_HEIGHT)

    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("line", 0, 0, PIXEL_WIDTH, PIXEL_HEIGHT)

    map1:Render()
    love.graphics.setColor(0, 0.4, 0.4)
    love.graphics.rectangle("fill", math.floor(Player.x+0.5), math.floor(Player.y+0.5), Player.width, Player.height)

    TLfres.endRendering()
end

function playerMove()
    local speed = {}
    speed.multiplier = 0.07*1.6
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
    --love.graphics.draw(player.img, math.floor(player.xPos+0.5), math.floor(player.yPos+0.5)
    -- Move player
    Player.x = Player.x + speed.multiplier * speed.x
    Player.y = Player.y + speed.multiplier * speed.y
end