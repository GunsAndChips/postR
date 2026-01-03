require "helpers"

Menu = {}
Menu.__index = Menu

function Menu:New(id, title)
    if type(id) ~= "string" then
        error("Unable to create menu without id. Please provide a string value.")
    end
    title = title or "Menu Title"
    local this = {
        title = {
            textString = title,
            text = nil,
            x = nil,
            y = nil,
            width = nil,
            height = nil
        },
        items = {},
        loaded = false,
        minHeight = 120,
        minWidth = 96,
        backgroundColour = { 0.5, 0.5, 0.5 },
        textColour = { 1, 1, 1 },
        textColourHover = { 0.1, 0.3, 0.1 },
        textColourClick = { 0.1, 0.3, 0.1 },
        textColourDisabled = { 0.69, 0.69, 0.69 },
        textLineSpacing = 3,
        marginSize = 6,
        rangeText = nil,
        rangeTextHover = nil,
        hoverOffsetX = 2
    }

    return this
end

-- Creates range text of the desired font for the two colours provided
-- Range text is a series of dots that are two colours, indicating a scalar value
local function CreateRangeText(font, colour1, colour2)
    local rangeText = {}

    -- Set offsetY based on the font scale
    if font == Config.fonts.ui150 then
        rangeText.offsetY = -6
    elseif font == Config.fonts.ui200 then
        rangeText.offsetY = -11
    else
        rangeText.offsetY = 0
    end

    local ranges = {
        "",
        ".",
        "..",
        "...",
        "....",
        ".....",
        "......",
        ".......",
        "........"
    }
    ranges.count = #ranges

    for i = 1, ranges.count do
        local textTable = {
            colour1,
            ranges[i],
            colour2,
            ranges[ranges.count + 1 - i]
        }

        table.insert(rangeText, love.graphics.newText(font, textTable))
    end

    rangeText.width = rangeText[1]:getWidth()
    rangeText.height = rangeText[1]:getHeight()
    rangeText.length = #ranges - 1

    return rangeText
end

-- Fleshes out simple menu definitions
-- e.g. sets fonts and x/y positions for items, so we don't have to do it every time we render them
function Menu:Load()
    log.debug("Loading menu: " .. self.title.textString)

    -- Set Title
    local title = self.title
    title.text = love.graphics.newText(Config.fonts.ui, title.textString)
    title.width = title.text:getWidth()
    title.height = title.text:getHeight()
    -- Title X can't be set until the menu width is decided
    title.y = self.marginSize

    -- Load rangeText for range controls
    self.rangeText = CreateRangeText(Config.fonts.ui150, self.textColour, self.textColourDisabled)
    self.rangeTextHover = CreateRangeText(Config.fonts.ui150, self.textColourHover, self.textColourDisabled)

    local largestItemWidth = title.width
    local itemsWithControls = {}

    for i = 1, #self.items do
        local item = self.items[i]
        local maxItemLength = PIXEL_WIDTH - 4 * self.marginSize

        -- Set text
        item.text = love.graphics.newText(Config.fonts.ui)
        item.text:setf({ self.textColour, item.textString }, maxItemLength, "left")

        -- Set hover text
        if self.textColourHover == self.textColour then
            item.textHover = item.text
        else
            item.textHover = love.graphics.newText(Config.fonts.ui)
            item.textHover:setf({ self.textColourHover, item.textString }, maxItemLength, "left")
        end

        item.height = item.text:getHeight()
        item.width = item.text:getWidth()
        local itemAndControlWidth = item.width

        if item.type == "button" then
            -- Set click text
            if self.textColourClick == self.textColour then
                item.textClick = item.text
            elseif self.textColourClick == self.textColourHover then
                item.textClick = item.textHover
            else
                item.textClick = love.graphics.newText(Config.fonts.ui)
                item.textClick:setf({ self.textColourClick, item.textString }, maxItemLength, "left")
            end
        elseif item.type == "range" then
            item.control = {
                x = nil,
                y = nil,
                width = self.rangeText.width,
                height = self.rangeText.height,
                type = "control",
                parent = item
            }
            table.insert(itemsWithControls, item)

            -- Add width of control so Menu is wide enough to fit both
            itemAndControlWidth = itemAndControlWidth + item.control.width + 1
        end

        -- Set coordinates relative to menu
        item.x = self.marginSize
        item.y = (i - 1) * (item.height + self.textLineSpacing) + 2 * self.marginSize + title.height

        largestItemWidth = math.max(largestItemWidth, itemAndControlWidth)
    end

    -- Set menu width to fit all items on it, without going below the minWidth
    self.width = math.max(largestItemWidth + 2 * self.marginSize, self.minWidth)
    -- Set menu width to not go over max width, which is the screen size minus a margin on each size (rounded down to the nearest even number)
    self.width = math.min(self.width, RoundToEven(PIXEL_WIDTH - 2 * self.marginSize, false))
    -- Round the result up to the nearest even number, so centred text can be properly centred
    self.width = RoundToEven(self.width, true)

    -- Set title x centred on the Menu
    title.x = math.floor(self.width / 2 - title.width / 2)

    -- Check for itemsWithControls to load
    if #itemsWithControls > 0 then
        for i = 1, #itemsWithControls do
            local item = itemsWithControls[i]
            if item.type == "range" then
                item.control.x = self.width - self.marginSize - self.rangeText.width
                item.control.y = item.y + self.rangeText.offsetY
            end
        end
    end

    -- TODO: make menu height dynamic to fit all items contained in that menu
    self.height = self.minHeight

    -- Set transform
    self.transform = love.math.newTransform()
    self.transform:translate(PIXEL_WIDTH / 2 - self.width / 2, PIXEL_HEIGHT / 2 - self.height / 2)

    self.loaded = true
end

function Menu:Draw()
    if not self.loaded then
        Menu.Load(self)
    end

    love.graphics.push()
    love.graphics.applyTransform(self.transform)

    -- background
    love.graphics.setColor(self.backgroundColour)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)

    -- title
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.title.text, self.title.x, self.title.y)

    -- items
    for i = 1, #self.items do
        local item = self.items[i]
        local x = item.x
        local displayText = item.text

        if item.type == "button" and Hovering.item == item then
            x = item.x + self.hoverOffsetX
            if Hovering.clicking == 1 then
                displayText = item.textClick
            else
                displayText = item.textHover
            end
        elseif item.type == "range" and Hovering.item == item.control then
            displayText = item.textHover
        end

        -- Draw menu item
        love.graphics.draw(displayText, x, item.y)

        if item.type == "range" then
            local controlText = nil

            if Hovering.item == item.control then
                controlText = self.rangeTextHover[Hovering.rangePosition + 1]
            else
                controlText = self.rangeText[item.value + 1]
            end

            love.graphics.draw(controlText, self.width - self.marginSize - controlText:getWidth(), item.control.y)
        end
    end

    love.graphics.pop()
end

function Menu:GetItem(x, y)
    if not self.loaded then
        return nil, nil
    end
    local menuX, menuY = self.transform:inverseTransformPoint(x, y)
    if menuX < 0 or menuX > self.width or menuY < 0 or menuY > self.height then
        return nil, nil
    end

    for i = 1, #self.items do
        local item = self.items[i]
        if menuY > item.y and menuY < item.y + item.height then
            if menuX > item.x and menuX < item.x + item.width then
                return item
            elseif item.control ~= nil and menuX > item.control.x and menuX < item.control.x + item.control.width and menuY > item.control.y and menuY < item.control.y + item.control.height then
                local rangePosition = nil
                if item.type == "range" then
                    local rangeDotCount = self.rangeTextHover.length
                    rangePosition = math.floor((menuX - item.control.x) / item.control.width * rangeDotCount) + 1
                    if rangePosition < 1 or rangePosition > rangeDotCount + 1 then
                        error("rangePosition: '" ..
                            rangePosition .. "' is not valid. Must not be less than 1 or more than " .. rangeDotCount)
                    end
                end
                return item.control, rangePosition
            end
        end
    end
    return nil, nil
end

function ShowHoverText()
    if #Game.visibleMenus < 1 then
        return
    end

    local pixelX, pixelY = love.mouse.getPosition()
    local menu = Game.visibleMenus[#Game.visibleMenus]
    Hovering.item, Hovering.rangePosition = Menu.GetItem(menu, pixelX, pixelY)
    Hovering.clicking = GetClickingIfHovering()
end

function GetClickingIfHovering()
    if Hovering.item == nil then
        return false
    elseif love.mouse.isDown(1) then
        return 1
    else
        return false
    end
end

function Menu:Back()
    SaveSettings()
    table.remove(Game.visibleMenus)
end
