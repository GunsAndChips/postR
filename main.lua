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

    CameraOffset = {}
    CameraOffset.x = 0
    CameraOffset.y = 0

    Player = Config.player
    Player.x = PIXEL_WIDTH/2
    Player.y = PIXEL_HEIGHT/2
    CalculatePlayerTileCoords()
    Player.facing = "right"

    _Key = Settings.Keybinds

    LoadTileSprites()
end

function love.update(dt)
    PlayerMove()
    PlayerInteract()
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
    love.graphics.rectangle("fill", Player.x + pixelPerfectOffset.x - Player.width/2, Player.y + pixelPerfectOffset.y - Player.height/2, Player.width, Player.height)

    DebugRenderers()

    TLfres.endRendering()
end

function DebugRenderers()
    local debugText = {}

    local facingX = -1
    if Player.facing == "right" then
        facingX = 1
    end

    if Config.renderers.debug.cameraOffset then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", CameraOffset.x, CameraOffset.y, 1, 1)
    end
    if Config.renderers.debug.player.facing then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", Player.x + Player.width/2*facingX, Player.y - Player.height/2, 1, 1)
        table.insert(debugText,"Facing: " .. Player.facing)
    end
    if Config.renderers.debug.player.targeting then
        local target = {}
        target.fixedX = Player.x + facingX * (Player.width/2 + Player.reachLength)
        target.y = Player.y + Player.reachHeight
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", target.fixedX, target.y, 1, 1)
    end
    if Config.renderers.debug.player.coords then
        table.insert(debugText,"Player.x: " .. Player.x .. " Player.y: " .. Player.y)
        table.insert(debugText,"CameraOffset.x: " .. CameraOffset.x .. " CameraOffset.y: " .. CameraOffset.y)
        table.insert(debugText, "Player.tileX: " .. Player.tileX .. " Player.tileY: " .. Player.tileY)
    end

    love.graphics.setColor(1,1,0)
    love.graphics.rectangle("fill", Player.x, Player.y, 1, 1)

    if #debugText > 0 then
        local debugTextString = ""
        for i = 1, #debugText do
            debugTextString = debugTextString .. "\n" .. debugText[i]
        end
        print(debugTextString)
    end
end

--function ArrayAppend(array,newElement)
--    local length = #array
--    array[length+1] = newElement
--    return array
--end

function PlayerMove()
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
    elseif speed.x > 0 then
        Player.facing = "right"
    elseif speed.x < 0 then
        Player.facing = "left"
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
    CalculatePlayerTileCoords()
end

function CalculatePlayerTileCoords()
    Player.tileY = math.floor((Player.y - CameraOffset.y)/Config.tile.height)
    Player.tileX = math.floor((Player.x - CameraOffset.x + (Player.y - CameraOffset.y)/3)/Config.tile.width)
end

function PlayerInteract()
    -- hi
end