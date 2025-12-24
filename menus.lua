function LoadMenuItems(menu)
    menu.title = love.graphics.newText(Config.fonts.ui, menu.title)
    local maxItemWidth = menu.title:getWidth()

    for i = 1, #menu.items do
        local item = menu.items[i]
        -- Set text
        item.text = love.graphics.newText(Config.fonts.ui)
        item.text:setf({ menu.textColour, item.textString }, PIXEL_WIDTH - 4 * menu.marginSize, "left")

        -- Set coordinates relative to menu
        item.x = menu.marginSize
        item.y = i * (math.floor(menu.title:getHeight()) + menu.textLineSpacing) + menu.textLineSpacing

        maxItemWidth = math.max(maxItemWidth, item.text:getWidth())
    end

    menu.width = math.max(maxItemWidth + 2 * menu.marginSize, menu.minWidth)
    menu.width = math.min(menu.width, PIXEL_WIDTH - 2 * menu.marginSize)

    menu.height = menu.minHeight
    menu.transform = love.math.newTransform()
    menu.transform:translate(PIXEL_WIDTH / 2 - menu.width / 2, PIXEL_HEIGHT / 2 - menu.height / 2)

    menu.loaded = true
    return menu
end

function DrawMenu(menu)
    if (not menu.loaded) then
        error("cannot draw menu that is not loaded")
    end

    love.graphics.push()
    love.graphics.applyTransform(menu.transform)

    -- background
    love.graphics.setColor(menu.backgroundColour)
    love.graphics.rectangle("fill", 0, 0, menu.width, menu.height)

    -- title
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(menu.title, menu.width / 2 - menu.title:getWidth() / 2, menu.textLineSpacing)

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
