require "map"

PIXEL_WIDTH = 640
PIXEL_HEIGHT = 360
SCALE_FACTOR = 2
SCREEN_WIDTH = PIXEL_WIDTH * SCALE_FACTOR
SCREEN_HEIGHT = PIXEL_HEIGHT * SCALE_FACTOR

local tiles = {
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,1,0,
    0,0,0,0,0,0,0,0
}

local map1 = Map:New(tiles,8,4)

function love.load()
    Player = {}
    Player.width = 14 * SCALE_FACTOR
    Player.height = 28 * SCALE_FACTOR
    Player.x = PIXEL_WIDTH/2 - Player.width/2
    Player.y = PIXEL_HEIGHT/2 - Player.height/2

    _Key = {}
    _Key.up = "w"
    _Key.down = "s"
    _Key.left = "a"
    _Key.right = "d"
    _Key.sprint = "lshift"

    love.window.setMode(PIXEL_WIDTH * SCALE_FACTOR,PIXEL_HEIGHT * SCALE_FACTOR,{fullscreen=false,vsync=false})
end

function love.update(dt)
    playerMove()
end

function love.draw()
    map1:Render()
    love.graphics.setColor(0, 0.4, 0.4)
    love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height)
end

function playerMove()
    local speed = {}
    speed.multiplier = 0
    speed.x = 0
    speed.y = 0

    if SCALE_FACTOR < 1 then
        return
    else
        speed.multiplier = SCALE_FACTOR
    end

    -- Sprint or walk
    if love.keyboard.isDown(_Key.sprint) then
        speed.multiplier = speed.multiplier * 0.25
    elseif love.keyboard.isDown(_Key.up, _Key.down, _Key.left, _Key.right) then
        speed.multiplier = speed.multiplier * 0.125
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