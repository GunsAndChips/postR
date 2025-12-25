require "helpers"

Menus = {}
Menus.default = {
    title = "Menu Title",
    loaded = false,
    minHeight = 120,
    minWidth = 100,
    backgroundColour = { 0.6, 0.6, 0.6 },
    textColour = { 1, 1, 1 },
    textColourHover = { 0.1, 0.3, 0.1 },
    textLineSpacing = 3,
    marginSize = 6
}

Menus.pause = ShallowClone(Menus.default)
Menus.pause.id = "pause"
Menus.pause.titleString = "Paused"
Menus.pause.items = {
    { textString = "Resume", onClick = function() SetGameState() end },
    { textString = "Options", onClick = function() table.insert(Game.visibleMenus, Menus.options) end },
    { textString = "Quit", onClick = function() Quit() end }
}

Menus.options = ShallowClone(Menus.default)
Menus.options.id = "options"
Menus.options.titleString = "Options"
Menus.options.items = {
    { textString = "Back", onClick = function() MenuBack() end }
}

-- Converts simple menu defined objects from above into fleshed out object
-- e.g. sets fonts and x/y positions for items, so we don't have to do it every time we render them)
function LoadMenuItems(menu)
    menu.title = love.graphics.newText(Config.fonts.ui, menu.titleString)
    local maxItemWidth = menu.title:getWidth()

    for i = 1, #menu.items do
        local item = menu.items[i]
        -- Set text
        item.text = love.graphics.newText(Config.fonts.ui)
        item.text:setf({ menu.textColour, item.textString }, PIXEL_WIDTH - 4 * menu.marginSize, "left")

        -- Set coordinates relative to menu
        item.x = menu.marginSize
        item.y = (i - 1) * (item.text:getHeight() + menu.textLineSpacing) + 2 * menu.marginSize + menu.title:getHeight()

        maxItemWidth = math.max(maxItemWidth, item.text:getWidth())
    end

    menu.width = math.max(maxItemWidth + 2 * menu.marginSize, menu.minWidth)
    menu.width = math.min(menu.width, PIXEL_WIDTH - 2 * menu.marginSize)

    menu.height = menu.minHeight
    menu.transform = love.math.newTransform()
    menu.transform:translate(PIXEL_WIDTH / 2 - menu.width / 2, PIXEL_HEIGHT / 2 - menu.height / 2)

    menu.loaded = true
end

function DrawMenu(menu)
    if (not menu.loaded) then
        LoadMenuItems(menu)
    end

    love.graphics.push()
    love.graphics.applyTransform(menu.transform)

    -- background
    love.graphics.setColor(menu.backgroundColour)
    love.graphics.rectangle("fill", 0, 0, menu.width, menu.height)

    -- title
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(menu.title, menu.width / 2 - menu.title:getWidth() / 2, menu.marginSize)

    -- items
    for i = 1, #menu.items do
        local item = menu.items[i]
        love.graphics.draw(item.text, item.x, item.y)
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

function MenuBack()
    table.remove(Game.visibleMenus)
    Hovering = nil
    ShowHoverText()
end
