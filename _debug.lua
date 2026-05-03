require "settings"

log = {}

-- Input of ... is any number of input args (so non-strings can be passed in to be converted to strings here, instead of having to do that before calling a log function)
local function printToConsole(prefix, ...)
    if type(Config) == "table" and type(Config.debug) == "table" and type(Config.debug.logging) == "boolean" and Config.debug.logging == "false" then
        return
    end

    local text = ""

    -- select("#",...) is effectively #...
    for i = 1, select("#", ...) do
        text = text .. tostring(select(i, ...))
    end
    print("[" .. prefix .. "] ", text)
end

function log.debug(...)
    printToConsole("DEBUG", ...)
end

function log.warning(...)
    printToConsole("WARNING", ...)
end

function DrawDebugRenderers()
    local debugText = {}

    if Config.debug.renderers.map.Transform then
        love.graphics.setColor(1, 0, 0.8)
        love.graphics.push()
        love.graphics.applyTransform(MapTransform)
        love.graphics.rectangle("fill", 0, 0, 1, 1)
        love.graphics.pop()
    end
    if Config.debug.renderers.map.TileTransform then
        love.graphics.setColor(1, 0, 0.8)
        love.graphics.push()
        love.graphics.applyTransform(MapTilesTransform)
        for i = 0, 30 do
            for j = 0, 30 do
                love.graphics.rectangle("fill", i, j, 1 / Config.tile.width, 1 / Config.tile.height)
            end
        end
        love.graphics.pop()
    end
    if Config.debug.renderers.player.facing then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", Player.x + Player.width / 2 * Lookups.facingX[Player.facing],
            Player.y - Player.height / 2, 1, 1)
        table.insert(debugText, "Facing: " .. Player.facing)
    end
    if Config.debug.renderers.player.targeting then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", Player.targeting.x, Player.targeting.y, 1, 1)

        if Player.targeting.tileOrigin ~= nil then
            local tileX, tileY = MapTilesTransform:transformPoint(Player.targeting.tileOrigin.x, Player.targeting.tileOrigin.y)
            love.graphics.rectangle("fill", tileX, tileY, 1, 1)
        end
    end
    if Config.debug.renderers.player.coords then
        table.insert(debugText, "Player.x: " .. Player.x .. " Player.y: " .. Player.y)

        -- Show player x,y in yellow
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("fill", Player.x, Player.y, 1, 1)
    end
    if Config.debug.renderers.menu.hovering then
        if Hovering.item ~= nil and Hovering.item.x ~= nil and Hovering.item.y ~= nil then
            local menuX, menuY = Game.visibleMenus[#Game.visibleMenus].transform:transformPoint(Hovering.item.x, Hovering.item.y)

            local sizeX, sizeY = 1, 1
            if Hovering.item.width ~= nil and Hovering.item.height ~= nil then
                sizeX, sizeY = Hovering.item.width, Hovering.item.height
            end

            love.graphics.setColor(1, 0, 0, 0.3)
            love.graphics.rectangle("fill", menuX, menuY, sizeX, sizeY)
        end
    end

    if #debugText > 0 and Game.state ~= "paused" then
        local debugTextString = ""
        for i = 1, #debugText do
            debugTextString = debugTextString .. "\n" .. debugText[i]
        end
        log.debug(debugTextString)
    end
end
