PIXEL_WIDTH, PIXEL_HEIGHT = 320, 180

require "map"
require "settings"
require "menus"
require "player"
require "_debug"
require "textures"

-- TLfres for scaling
local TLfres = require "libraries/tlfres"
-- Override the standard function with TLFres helper function
---@diagnostic disable-next-line: duplicate-set-field
function love.mouse.getPosition()
    return TLfres.getMousePosition(PIXEL_WIDTH, PIXEL_HEIGHT)
end

-- anim8 for animations
local anim8 = require "libraries/anim8/anim8"

Settings = LoadSettings()
Config.Initialise()

function love.load()
    -- Configure love behaviour
    love.graphics.setDefaultFilter("nearest", "nearest") -- Turn off antialiasing for images
    love.graphics.setLineStyle("rough")                  -- Turn off antialiasing for lines
    love.graphics.setBackgroundColor({ 0.09, 0.09, 0.09, 1 })

    -- Size here determines the default screen size if Fullscreen is disabled
    local _, _, flags = love.window.getMode()
    local desktopWidth, desktopHeight = love.window.getDesktopDimensions(flags.display)
    local startInFullscreen = Settings.video.fullscreen or false

    love.window.setMode(
        desktopWidth * 0.8,
        desktopHeight * 0.8,
        {
            vsync = true,
            msaa = 0,
            highdpi = true,
            fullscreen = startInFullscreen,
            resizable = true,
            minwidth = PIXEL_WIDTH,
            minheight = PIXEL_HEIGHT
        })

    LoadMenus()
    LoadTransforms()

    Player.targeting.texture = love.graphics.newImage("/textures/targetedTile.png")
    UpdatePlayerTargetingCoords()

    Player.textures.walk = love.graphics.newImage("/textures/Sprite-0001.png")
    local grid = anim8.newGrid(Player.width, Player.height, Player.textures.walk:getWidth(), Player.textures.walk:getHeight())
    Player.animations.walk = anim8.newAnimation(grid('1-4', 1), 0.1)

    _Key = Settings.Keybinds

    AddIdToChildTables(Menus)

    Game = {
        state = "play",
        visibleMenus = {}
    }
    Hovering = {
        item = nil,
        clicking = false,
        rangePosition = 1
    }

    -- Load map
    local mapDefinition = require "tiled/maptest1"
    Map1 = Map:New(mapDefinition)

    TileSheet = love.graphics.newImage("textures/Sprite-0003.png")
    TileQuads = CreateQuads(TileSheet, Config.tile.width + (Config.tile.staggerX - 1), Config.tile.height, 1)

    LoadFonts()
end

function love.update(dt)
    if Game.state == "play" then
        PlayerMove(dt)
        if Player.interaction.action ~= nil then
            Player.Interact(nil, dt)
        end
    end
end

function love.draw()
    TLfres.beginRendering(PIXEL_WIDTH, PIXEL_HEIGHT, false, true)

    -- Draw Map
    Map1:Render()

    -- Player targeting
    if Player.targeting.tileOrigin ~= nil then
        local excludedTileIds = {
            [-1] = true,
            [0] = true,
            [8] = true,
            [10] = true
        }

        if not excludedTileIds[Map1:GetTile(Player.targeting.tileOrigin.x, Player.targeting.tileOrigin.y, 1)] then
            local period = 3
            local opacity = math.sin(math.abs(period / 2 - love.timer.getTime() % period) / period / 1.5) + 0.15
            love.graphics.setColor(1, 1, 1, opacity)

            local targetX, targetY = MapTilesTransform:transformPoint(Player.targeting.tileOrigin.x - 1, Player.targeting.tileOrigin.y - 1)
            love.graphics.draw(Player.targeting.texture, targetX - Config.tile.staggerX + 1, targetY)
        end
    end

    love.graphics.setColor(1, 1, 1)
    Player.animations.walk:draw(Player.textures.walk, Player.x - Player.width / 2, Player.y - Player.height / 2)

    DrawDebugRenderers()

    if #Game.visibleMenus > 0 then
        for i = 1, #Game.visibleMenus do
            Menu.Draw(Game.visibleMenus[i])
        end
    end

    TLfres.endRendering()
end

function love.keypressed(key, scancode, isrepeat)
    if key == _Key.pause then
        local currentMenu = Game.visibleMenus[#Game.visibleMenus]
        -- If the top menu isn't the pause menu, remove it
        if #Game.visibleMenus > 0 and currentMenu.id ~= "pause" then
            Menu.Back()
        else
            SetGameState()
        end
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    -- Overwrite x and y using the TLFres library's function
    x, y = love.mouse.getPosition()

    if button == 1 then
        if Hovering.item ~= nil then
            Hovering.clicking = button
        else
            Hovering.clicking = false
        end
    end

    if Game.state == "play" then
        if button == 1 or button == 2 then
            Player.Interact(button, 0)
        end
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    ShowHoverText()
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        Hovering.clicking = false
        if #Game.visibleMenus > 0 and Hovering.item ~= nil then
            if Hovering.item.onClick ~= nil then
                Hovering.item.onClick()
                ShowHoverText()
            end
        end
    end
end

function love.resize(w, h)
    -- Update fullscreen setting to match the actual state
    local _
    Settings.video.fullscreen, _ = love.window.getFullscreen()

    --log.debug(("Window resized to width: %d and height: %d."):format(w, h))
end

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
    log.debug("Game state set to: ", Game.state)
end

function Quit()
    SaveSettingsToFile()
    love.event.quit()
end
