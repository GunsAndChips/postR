require "map"
require "settings"

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
end

local mapDefinition = require "tiled/maptest1"

local map1 = Map:New(mapDefinition)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- don't know if size matters here if fullscreen anyway
    love.window.setMode(1920, 1080, {vsync = true, msaa = 0, highdpi = true, fullscreen = true})

    Player = {}
    Player.width = 14
    Player.height = 28
    Player.x = PIXEL_WIDTH/2 - Player.width/2
    Player.y = PIXEL_HEIGHT/2 - Player.height/2

    CameraOffset = {}
    CameraOffset.x = PIXEL_WIDTH/2
    CameraOffset.y = PIXEL_HEIGHT/2

    _Key = Settings.Keybinds

    LoadTileSprites()
end

function love.update(dt)
    playerMove()
    playerInteract()
end

function love.draw()
    TLfres.beginRendering(PIXEL_WIDTH, PIXEL_HEIGHT)

    -- Renders red box at screen borders for debugging
    --love.graphics.setColor(1,0,0)
    --love.graphics.rectangle("line", 0, 0, PIXEL_WIDTH, PIXEL_HEIGHT)

    map1:Render(CameraOffset)

    local pixelPerfectOffset = {}
    pixelPerfectOffset.x = 0
    pixelPerfectOffset.y = 0

    if Config.movement.pixelPerfect then
        pixelPerfectOffset.x = CameraOffset.x - math.floor(CameraOffset.x+0.5)
        pixelPerfectOffset.y = CameraOffset.y - math.floor(CameraOffset.y+0.5)
    end

    love.graphics.setColor(0, 0.4, 0.4)
    love.graphics.rectangle("fill", Player.x + pixelPerfectOffset.x, Player.y + pixelPerfectOffset.y, Player.width, Player.height)

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", CameraOffset.x, CameraOffset.y, 1, 1)

    if Config.renderers.debug.playerTargeting then
        -- show where player is targeting
    end

    TLfres.endRendering()
end

function playerMove()
    local function move(x, y, speed, invert)
        local sign = 1
        if invert then
            sign = -1
        end

        x = x + sign * (speed.magnitude * speed.x)
        y = y + sign * (speed.magnitude * speed.y)

        if Settings.movement.useRotatedY then
            x = x - sign * ((speed.magnitude * speed.y)/3)
        end

        return x, y
    end

    if not love.keyboard.isDown(_Key.up, _Key.down, _Key.left, _Key.right) then
        return
    end

    local speed = {}
    speed.x = 0
    speed.y = 0
    speed.magnitude = Config.movement.moveSpeed

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

    -- Movespeed modifiers
    -- Sprint
    if love.keyboard.isDown(_Key.sprint) then
        speed.magnitude = Config.movement.moveSpeed * Config.movement.sprintMultiplier
    end
    -- Make diagonal movespeed same as straightline
    if math.abs(speed.y) + math.abs(speed.x) == 2 then
        speed.magnitude = speed.magnitude / math.sqrt(2)
    end

    CameraOffset.x, CameraOffset.y = move(CameraOffset.x, CameraOffset.y, speed, true)

    -- OLD DEADZONE CODE FROM WHEN THE PLAYER WAS MOVING, NOT THE BACKGROUND
    --if deadzone.enabled then
    --    if Player.x > deadzone.xMax then
    --        Player.x = deadzone.xMax
    --    elseif Player.x < deadzone.xMin then
    --        Player.x = deadzone.xMin
    --    end
    --    
    --    if Player.y > deadzone.yMax then
    --        Player.y = deadzone.yMax
    --    elseif Player.y < deadzone.yMin then
    --        Player.y = deadzone.yMin
    --    end
    --end
end

function playerInteract()
    -- hi
end