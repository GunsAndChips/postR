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
    local itemsWithControls = {}

    for i = 1, #menu.items do
        local item = menu.items[i]
        local maxItemLength = PIXEL_WIDTH - 4 * menu.marginSize

        -- Set text
        item.text = love.graphics.newText(Config.fonts.ui)
        item.text:setf({ menu.textColour, item.textString }, maxItemLength, "left")

        -- Set hover text
        if menu.textColourHover == menu.textColour then
            item.textHover = item.text
        else
            item.textHover = love.graphics.newText(Config.fonts.ui)
            item.textHover:setf({ menu.textColourHover, item.textString }, maxItemLength, "left")
        end

        item.height = item.text:getHeight()
        item.width = item.text:getWidth()
        local itemAndControlWidth = item.width

        if item.type == "button" then
            -- Set click text
            if menu.textColourClick == menu.textColour then
                item.textClick = item.text
            elseif menu.textColourClick == menu.textColourHover then
                item.textClick = item.textHover
            else
                item.textClick = love.graphics.newText(Config.fonts.ui)
                item.textClick:setf({ menu.textColourClick, item.textString }, maxItemLength, "left")
            end
        elseif item.type == "range" then
            item.control = {
                x = nil,
                y = nil,
                width = Config.menus.rangeText.width,
                height = Config.menus.rangeText.height
            }
            table.insert(itemsWithControls, item)

            -- Add width of control so Menu is wide enough to fit both
            itemAndControlWidth = itemAndControlWidth + item.control.width + 1
        end

        -- Set coordinates relative to menu
        item.x = menu.marginSize
        item.y = (i - 1) * (item.height + menu.textLineSpacing) + 2 * menu.marginSize + title.height

        largestItemWidth = math.max(largestItemWidth, itemAndControlWidth)
    end

    -- Set menu width to fit all items on it, without going below the minWidth
    menu.width = math.max(largestItemWidth + 2 * menu.marginSize, menu.minWidth)
    -- Set menu width to not go over max width, which is the screen size minus a margin on each size
    menu.width = math.min(menu.width, PIXEL_WIDTH - 2 * menu.marginSize)

    -- Set title x centred on the Menu
    title.x = menu.width / 2 - title.width / 2

    -- Check for itemsWithControls to load
    if #itemsWithControls > 0 then
        for i = 1, #itemsWithControls do
            local item = itemsWithControls[i]
            if item.type == "range" then
                item.control.x = menu.width - menu.marginSize - Config.menus.rangeText.width
                item.control.y = item.y + Config.menus.rangeText.offsetY
            end
        end
    end

    -- TODO: make menu height dynamic to fit all items contained in that menu
    menu.height = menu.minHeight
    menu.transform = love.math.newTransform()
    menu.transform:translate(PIXEL_WIDTH / 2 - menu.width / 2, PIXEL_HEIGHT / 2 - menu.height / 2)

    menu.loaded = true
end

function DrawMenu(menu)
    if not menu.loaded then
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
        local x = item.x
        local displayText = item.text

        if item == Hovering.item then
            displayText = item.textHover

            if item.type == "button" then
                x = item.x + Config.menus.hoverOffsetX
                if Hovering.clicking == 1 then
                    displayText = item.textClick
                end
            end
        end

        -- Draw menu item
        love.graphics.draw(displayText, x, item.y)

        if item.type == "range" then
            local rangeText = Config.menus.rangeText[item.value + 1]
            love.graphics.draw(rangeText, menu.width - menu.marginSize - rangeText:getWidth(), item.control.y)
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
        if menuY > item.y and menuY < item.y + item.text:getHeight() then
            if menuX > item.x and menuX < item.x + item.text:getWidth() then
                return item
            elseif item.control ~= nil and menuX > item.control.x and menuX < item.control.x + item.control.width and menuY > item.control.y and menuY < item.control.y + item.control.height then
                return item.control
            end
        end
    end
    return nil
end

function ShowHoverText()
    if #Game.visibleMenus < 1 then
        return
    end

    local pixelX, pixelY = love.mouse.getPosition()
    local menu = Game.visibleMenus[#Game.visibleMenus]
    Hovering.item = GetMenuItem(pixelX, pixelY, menu)

    if Hovering.item == nil and Hovering.clicking ~= false then
        Hovering.clicking = false
    elseif Hovering.item ~= nil and love.mouse.isDown(1) then
        Hovering.clicking = 1
    end
end

function UpdateHoveringClicking()
    if Hovering.item == nil then
        Hovering.clicking = false
    elseif love.mouse.isDown(1) then
        Hovering.clicking = 1
    else
        Hovering.clicking = false
    end
end

function MenuBack()
    table.remove(Game.visibleMenus)
    Hovering.item = nil
    ShowHoverText()
end
