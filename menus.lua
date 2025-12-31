require "helpers"

Menus = {}

Menus.pause = Clone(Config.menus.defaults)
Menus.pause.id = "pause"
Menus.pause.title.textString = "Paused"
Menus.pause.items = {
    { textString = "Resume",  type = "button", onClick = function() SetGameState() end },
    { textString = "Options", type = "button", onClick = function() table.insert(Game.visibleMenus, Menus.options) end },
    { textString = "Quit",    type = "button", onClick = function() Quit() end }
}

Menus.options = Clone(Config.menus.defaults)
Menus.options.id = "options"
Menus.options.title.textString = "Options"
Menus.options.items = {
    { textString = "Volume", type = "range",  value = 4 },
    { textString = "Back",   type = "button", onClick = function() MenuBack() end }
}

-- Fleshes out the simple menu objects from above
-- e.g. sets fonts and x/y positions for items, so we don't have to do it every time we render them)
function LoadMenu(menu)
    -- Set Title
    local title = menu.title
    title.text = love.graphics.newText(Config.fonts.ui, title.textString)
    title.width = title.text:getWidth()
    title.height = title.text:getHeight()
    -- Title X can't be set until the menu width is decided
    title.y = menu.marginSize

    local largestItemWidth = title.width

    for i = 1, #menu.items do
        local item = menu.items[i]
        local maxItemLength = PIXEL_WIDTH - 4 * menu.marginSize

        -- if item.type == "range" then
        --     item.control = {
        --         x = menu.width - menu.marginSize - Config.menus.rangeText.width,
        --         y = item.y
        --     }
        -- end

        -- Set text
        item.text = love.graphics.newText(Config.fonts.ui)
        item.text:setf({ menu.textColour, item.textString }, maxItemLength, "left")

        if (item.type == "button") then
            -- Set hover text
            item.textHover = love.graphics.newText(Config.fonts.ui)
            item.textHover:setf({ menu.textColourHover, item.textString }, maxItemLength, "left")
        end

        -- Set coordinates relative to menu
        item.x = menu.marginSize
        item.y = (i - 1) * (item.text:getHeight() + menu.textLineSpacing) + 2 * menu.marginSize + title.height

        largestItemWidth = math.max(largestItemWidth, item.text:getWidth())
    end

    -- Set menu width to fit all items on it, without going below the minWidth
    menu.width = math.max(largestItemWidth + 2 * menu.marginSize, menu.minWidth)
    -- Set menu width to not go over max width, which is the screen size minus a margin on each size
    menu.width = math.min(menu.width, PIXEL_WIDTH - 2 * menu.marginSize)

    -- Set title x centred on the Menu
    title.x = menu.width / 2 - title.width / 2

    -- TODO: make menu height dynamic to fit all items contained in that menu
    menu.height = menu.minHeight
    menu.transform = love.math.newTransform()
    menu.transform:translate(PIXEL_WIDTH / 2 - menu.width / 2, PIXEL_HEIGHT / 2 - menu.height / 2)

    menu.loaded = true
end

function DrawMenu(menu)
    if (not menu.loaded) then
        LoadMenu(menu)
    end

    love.graphics.push()
    love.graphics.applyTransform(menu.transform)

    -- background
    love.graphics.setColor(menu.backgroundColour)
    love.graphics.rectangle("fill", 0, 0, menu.width, menu.height)

    -- title
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(menu.title.text, menu.title.x, menu.title.y)

    -- items
    for i = 1, #menu.items do
        local item = menu.items[i]
        if (item == Hovering and item.type == "button") then
            love.graphics.draw(item.textHover, item.x + Config.menus.hoverOffsetX, item.y)
        else
            love.graphics.draw(item.text, item.x, item.y)
        end

        if item.type == "range" then
            local rangeText = Config.menus.rangeText[item.value + 1]
            love.graphics.draw(rangeText, menu.width - menu.marginSize - rangeText:getWidth(), item.y)
        end
    end

    love.graphics.pop()
end

function GetMenuItem(x, y, menu)
    if not menu.loaded then
        return nil
    end
    local menuX, menuY = menu.transform:inverseTransformPoint(x, y)
    if menuX < 0 or menuX > menu.width or menuY < 0 or menuY > menu.height then
        return nil
    end

    for i = 1, #menu.items do
        local item = menu.items[i]
        if menuY > item.y and menuY < item.y + item.text:getHeight() and menuX > item.x and menuX < item.x + item.text:getWidth() then
            return item
        end
    end
end

function ShowHoverText()
    if #Game.visibleMenus > 0 then
        local pixelX, pixelY = love.mouse.getPosition()
        local menu = Game.visibleMenus[#Game.visibleMenus]
        Hovering = GetMenuItem(pixelX, pixelY, menu)
    end
end

function MenuBack()
    table.remove(Game.visibleMenus)
    Hovering = nil
    ShowHoverText()
end
