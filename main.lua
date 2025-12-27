require "map"
require "settings"
require "menus"

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

    for i = 1, 2 do
        --local fileName = string.format("textures/tile_%d.png",i)
        table.insert(tileFileNames, string.format("textures/pg%d.png", i))
    end

    TileSprites = love.graphics.newArrayImage(tileFileNames)

    Player.targeting.texture = love.graphics.newImage("/textures/targetedTile.png")
end

local mapDefinition = require "tiled/maptest1"

local map1 = Map:New(mapDefinition)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- don't know if size matters here if fullscreen anyway
    love.window.setMode(1920, 1080, { vsync = true, msaa = 0, highdpi = true, fullscreen = true })

    CameraOffset = {}
    CameraOffset.x = 0
    CameraOffset.y = 0

    Player = Config.player
    Player.x = PIXEL_WIDTH / 2
    Player.y = PIXEL_HEIGHT / 2
    Player.facing = "right"
    UpdatePlayerTargetingCoords()

    _Key = Settings.Keybinds

    Game = {
        state = "play",
        visibleMenus = {}
    }
    Hovering = nil

    LoadTileSprites()

    LoadFonts()

    MapTransform = love.math.newTransform()
end

function love.update(dt)
    if Game.state == "play" then
        PlayerMove()
        PlayerInteract()
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == _Key.pause then
        -- If the top menu isn't the pause menu, remove it
        if #Game.visibleMenus > 0 and Game.visibleMenus[#Game.visibleMenus].id ~= "pause" then
            MenuBack()
        else
            SetGameState()
        end
    end
end

-- function love.mousepressed(x, y, button, istouch, presses)
--     local x, y = love.mouse.getPosition()
-- end

function love.mousemoved(x, y, dx, dy, istouch)
    ShowHoverText()
end

function ShowHoverText()
    if #Game.visibleMenus > 0 then
        local pixelX, pixelY = love.mouse.getPosition()
        local menu = Game.visibleMenus[#Game.visibleMenus]
        local newHovering = GetMenuItem(pixelX, pixelY, menu)
        if Hovering == newHovering then
            return
        end
        if Hovering ~= nil then
            Hovering.text:setf({ menu.textColour, Hovering.textString }, PIXEL_WIDTH - 4 * menu.marginSize, "left")
        else
            if newHovering ~= nil then
                newHovering.text:setf({ menu.textColourHover, " " .. newHovering.textString },
                    PIXEL_WIDTH - 4 * menu.marginSize, "left")
            end
        end
        Hovering = newHovering
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if #Game.visibleMenus > 0 and button == 1 and Hovering ~= nil then
        Hovering.onClick()
    end
end

function love.resize(w, h)
    -- Unload menus to force recalculation of positions etc.
    Menus.pause.loaded = false
    Menus.options.loaded = false

    -- debug
    print(("Window resized to width: %d and height: %d."):format(w, h))
end

-- function love.mousefocus(focus)
--     if focus then
--         SetGameState(Game.state)
--     end
-- end

function love.focus(focus)
    if not focus then
        if Game.state ~= "paused" then
            SetGameState("paused")
        end
    end
end

function SetGameState(newState)
    if newState == nil then
        if Game.state == "paused" then
            newState = "play"
        else
            newState = "paused"
        end
    end

    if newState == "play" then
        table.remove(Game.visibleMenus) -- remove the last item from visibleMenus, which should be the pause menu
        -- only get rid of the cursor if there are no menus still open
        if #Game.visibleMenus == 0 then
            love.mouse.setVisible(false)
            love.mouse.setGrabbed(true)
        end
    elseif newState == "paused" then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
        table.insert(Game.visibleMenus, Menus.pause)
    end
    Game.state = newState
end

function love.draw()
    TLfres.beginRendering(PIXEL_WIDTH, PIXEL_HEIGHT)

    love.graphics.push()
    love.graphics.applyTransform(MapTransform)
    map1:Render()
    love.graphics.pop()

    -- Player
    love.graphics.setColor(0, 0.4, 0.4)
    love.graphics.rectangle("fill", Player.x - Player.width / 2, Player.y - Player.height / 2, Player.width,
        Player.height)

    -- Player targeting
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(Player.targeting.texture, Player.targeting.x, Player.targeting.y)

    DrawDebugRenderers()

    if #Game.visibleMenus > 0 then
        for i = 1, #Game.visibleMenus do
            DrawMenu(Game.visibleMenus[i])
        end
    end

    TLfres.endRendering()
end

function DrawDebugRenderers()
    local debugText = {}

    if Config.renderers.debug.cameraOffset then
        love.graphics.setColor(1, 0, 0.8)
        love.graphics.push()
        love.graphics.applyTransform(MapTransform)
        love.graphics.rectangle("fill", 0, 0, 1, 1)
        love.graphics.pop()
    end
    if Config.renderers.debug.player.facing then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", Player.x + Player.width / 2 * Lookups.facingX[Player.facing],
            Player.y - Player.height / 2, 1, 1)
        table.insert(debugText, "Facing: " .. Player.facing)
    end
    if Config.renderers.debug.player.targeting then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", Player.targeting.x, Player.targeting.y, 1, 1)
    end
    if Config.renderers.debug.player.coords then
        table.insert(debugText, "Player.x: " .. Player.x .. " Player.y: " .. Player.y)

        -- Show player x,y in yellow
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("fill", Player.x, Player.y, 1, 1)
    end

    if #debugText > 0 and Game.state ~= "paused" then
        local debugTextString = ""
        for i = 1, #debugText do
            debugTextString = debugTextString .. "\n" .. debugText[i]
        end
        print(debugTextString)
    end
end

function PlayerMove()
    if not love.keyboard.isDown(_Key.up, _Key.down, _Key.left, _Key.right) then
        return
    end

    local speed = {}
    speed.x = 0
    speed.y = 0
    speed.magnitude = Config.movement.moveSpeed

    -- Set direction for x/y movement
    if love.keyboard.isDown(_Key.right) then
        speed.x = speed.x + 1
    end
    if love.keyboard.isDown(_Key.left) then
        speed.x = speed.x - 1
    end
    if love.keyboard.isDown(_Key.down) then
        speed.y = speed.y + 1
    end
    if love.keyboard.isDown(_Key.up) then
        speed.y = speed.y - 1
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

    local dx = speed.magnitude * speed.x * -1 -- invert because we're moving the map, not the player
    local dy = speed.magnitude * speed.y * -1 -- invert because we're moving the map, not the player

    if Settings.movement.useRotatedY then
        dx = dx + ((speed.magnitude * speed.y) / 3)
    end

    MapTransform:translate(dx, dy)

    UpdatePlayerTargetingCoords()
end

function UpdatePlayerTargetingCoords()
    Player.targeting.x = Player.x + Lookups.facingX[Player.facing] * (Player.width / 2 + Player.reachLength)
    Player.targeting.y = Player.y + Player.reachHeight
end

function PlayerInteract()
    -- hi
end

function Quit()
    love.event.quit()
end
